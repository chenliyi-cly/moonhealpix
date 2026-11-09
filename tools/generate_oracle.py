#!/usr/bin/env python3
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026, MoonHEALPix contributors. All rights reserved.
"""Generate independent, deterministic HEALPix reference fixtures offline.

Only the Python standard library and the installed packages listed in
requirements-oracle.txt are used. No MoonHEALPix code is imported, no packages
are installed, and no network resources are accessed. The sole output is the
path selected by --output (its parent directories are created if necessary).
All longitude/latitude coordinates, including pixel centers, are in radians.

Sources (documentation references only; never fetched by this script):
https://astropy-healpix.readthedocs.io/en/stable/api.html
https://github.com/astropy/astropy-healpix/tree/v1.1.3
The oracle uses public astropy-healpix APIs; no implementation is copied.
NUNIQ uses NESTED pixel indices, not RING indices.

This generator is distributed under the BSD 3-Clause terms below. The upstream
astropy-healpix notice and terms are also retained for attribution:

Copyright (c) 2016-2018, Astropy Developers
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
* Neither the name of the Astropy Team nor the names of its contributors may be
  used to endorse or promote products derived from this software without
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from importlib.metadata import version
from pathlib import Path

# Avoid bytecode files even when run without Python's -B option.
sys.dont_write_bytecode = True

import numpy as np
from astropy import units as u
from astropy.utils import iers
from astropy_healpix import HEALPix, level_ipix_to_uniq, uniq_to_level_ipix

# These APIs do not require Earth-orientation data; disable downloads explicitly.
iers.conf.auto_download = False

SEED = 20261109
NSIDES = (1, 2, 4, 8, 16, 64, 8192)
ANGLES_PER_NSIDE = 256
PIXEL_EDGE_MARGIN = 0.01
COORDINATE_MARGIN = 1e-8
EXPECTED_VERSIONS = {
    "astropy-healpix": "1.1.3",
    "numpy": "2.5.4",
    "astropy": "8.0.2",
}
SOURCES = [
    "https://astropy-healpix.readthedocs.io/en/stable/api.html",
    "https://github.com/astropy/astropy-healpix/tree/v1.1.3",
]


def require(condition: bool, message: str) -> None:
    """Checks remain enabled even under python -O."""
    if not condition:
        raise RuntimeError(message)


def center(hp: HEALPix, pixel: int) -> dict[str, float]:
    lon, lat = hp.healpix_to_lonlat(pixel)
    require(int(hp.lonlat_to_healpix(lon, lat)) == pixel, "Center round-trip")
    return {"lon": float(lon.to_value(u.rad)), "lat": float(lat.to_value(u.rad))}


def pixel_samples(nside: int, limit: int, rng: np.random.Generator) -> list[int]:
    """Include both ends of each NESTED base face, then random valid indices."""
    face_size = nside * nside
    npix = 12 * face_size
    target = min(npix, limit)
    if target == npix:
        return list(range(npix))
    pixels = {face * face_size for face in range(12)}
    pixels.update((face + 1) * face_size - 1 for face in range(12))
    while len(pixels) < target:
        pixels.add(int(rng.integers(0, npix)))
    return sorted(pixels)


def generate() -> dict:
    dependencies = {name: version(name) for name in EXPECTED_VERSIONS}
    require(dependencies == EXPECTED_VERSIONS,
            f"Expected pinned dependencies {EXPECTED_VERSIONS}; got {dependencies}")
    # Explicit PCG64, fixed stream ordering, no timestamps or absolute paths.
    rng = np.random.Generator(np.random.PCG64(SEED))
    angles, ordering, nuniq = [], [], []
    rejected = {}
    for nside in NSIDES:
        ring = HEALPix(nside=nside, order="ring")
        nested = HEALPix(nside=nside, order="nested")
        accepted = attempts = 0
        while accepted < ANGLES_PER_NSIDE:
            attempts += 1
            require(attempts <= 100000, "Boundary rejection budget exceeded")
            lon = float(rng.uniform(0.0, 2.0 * math.pi))
            z = float(rng.uniform(-1.0, 1.0))
            lat = math.asin(z)
            # Uniform sphere sampling; reject coordinate seams/poles and the
            # polar/equatorial transition in addition to actual pixel edges.
            if (min(lon, 2.0 * math.pi - lon) <= COORDINATE_MARGIN
                    or math.pi / 2.0 - abs(lat) <= COORDINATE_MARGIN
                    or abs(abs(z) - 2.0 / 3.0) <= COORDINATE_MARGIN):
                continue
            rp, rx, ry = ring.lonlat_to_healpix(lon * u.rad, lat * u.rad,
                                                return_offsets=True)
            np_, nx, ny = nested.lonlat_to_healpix(lon * u.rad, lat * u.rad,
                                                  return_offsets=True)
            if not all(PIXEL_EDGE_MARGIN < float(v) < 1.0 - PIXEL_EDGE_MARGIN
                       for v in (rx, ry, nx, ny)):
                continue
            rp, np_ = int(rp), int(np_)
            r2n, n2r = int(ring.ring_to_nested(rp)), int(nested.nested_to_ring(np_))
            require(r2n == np_ and n2r == rp, "Angular ordering agreement")
            rc, nc = center(ring, rp), center(nested, np_)
            lon_delta = math.remainder(rc["lon"] - nc["lon"], 2.0 * math.pi)
            require(abs(lon_delta) < 1e-12 and abs(rc["lat"] - nc["lat"]) < 1e-12,
                    "Corresponding RING/NESTED centers disagree")
            angles.append({
                "nside": nside, "lon": lon, "lat": lat,
                "ring_pixel": rp, "nested_pixel": np_,
                "ring_center": rc, "nested_center": nc,
                "ring2nest": r2n, "nest2ring": n2r,
            })
            accepted += 1
        rejected[str(nside)] = attempts - accepted

        # Each record treats pixel independently as a RING and a NESTED input.
        for pixel in pixel_samples(nside, 128, rng):
            r2n = int(ring.ring_to_nested(pixel))
            n2r = int(nested.nested_to_ring(pixel))
            require(int(nested.nested_to_ring(r2n)) == pixel, "RING round-trip")
            require(int(ring.ring_to_nested(n2r)) == pixel, "NESTED round-trip")
            ordering.append({"nside": nside, "pixel": pixel,
                             "ring2nest": r2n, "nest2ring": n2r})

        level = nside.bit_length() - 1
        for pixel in pixel_samples(nside, 64, rng):
            uniq = int(level_ipix_to_uniq(level, pixel))
            decoded_level, decoded_pixel = uniq_to_level_ipix(uniq)
            require(int(decoded_level) == level and int(decoded_pixel) == pixel,
                    "NUNIQ round-trip")
            require(uniq == 4 * nside * nside + pixel, "NUNIQ defining identity")
            nuniq.append({"uniq": uniq, "level": level,
                          "nside": nside, "pixel": pixel})

    return {
        "metadata": {
            "schema_version": 1,
            "generator": "tools/generate_oracle.py",
            "oracle": "astropy-healpix",
            "dependencies": dependencies,
            "license": "BSD-3-Clause",
            "license_notice": "Full generator and upstream notices are in tools/generate_oracle.py",
            "sources": SOURCES,
            "seed": SEED,
            "rng": "numpy.random.Generator(PCG64)",
            "nsides": list(NSIDES),
            "angle_unit": "radian",
            "longitude_range": "[0, 2*pi)",
            "latitude_range": "[-pi/2, pi/2]",
            "pixel_index_base": 0,
            "sampling": "uniform longitude and uniform sin(latitude), rejection of boundaries",
            "pixel_edge_margin": PIXEL_EDGE_MARGIN,
            "coordinate_margin": COORDINATE_MARGIN,
            "coordinate_margin_note": "radians for longitude/poles; sin(latitude) for abs(z)=2/3",
            "rejected_candidates": rejected,
            "ang2pix_note": "ring2nest input is ring_pixel; nest2ring input is nested_pixel",
            "ordering_note": "pixel is the independent input to BOTH ring2nest and nest2ring",
            "nuniq_order": "nested",
            "nuniq_identity": "uniq = 4*nside*nside + pixel; nside = 2**level",
            "suggested_center_absolute_tolerance_rad": 1e-12,
            "center_comparison": "compare longitude differences modulo 2*pi",
            "counts": {"ang2pix": len(angles), "ordering": len(ordering),
                       "nuniq": len(nuniq)},
        },
        "ang2pix": angles,
        "ordering": ordering,
        "nuniq": nuniq,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n", 1)[0])
    parser.add_argument("--output", type=Path,
                        default=Path(__file__).resolve().parents[1] / "tests-data" / "oracle.json",
                        help="JSON destination (default: project tests-data/oracle.json)")
    args = parser.parse_args()
    data = generate()
    text = json.dumps(data, ensure_ascii=False, indent=2, allow_nan=False) + "\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(text.encode("utf-8"))
    counts = data["metadata"]["counts"]
    print(f"Wrote {args.output}: " + ", ".join(f"{k}={v}" for k, v in counts.items()))


if __name__ == "__main__":
    main()
