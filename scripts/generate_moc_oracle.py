#!/usr/bin/env python3
"""Independent spatial MOC oracle, using mocpy 0.21.0 (BSD-3-Clause).

Install mocpy==0.21.0 in a separate venv. Run this script to regenerate only
moc_wbtest.mbt's generated section and tests-data/moc-oracle.json. --check
regenerates both in memory and compares without writes (moonfmt on PATH).
Combine --check --verify-moon-output PATH to also check the polygon report
without writing it. Then run
moon test and pass its captured stdout to --verify-moon-output PATH. That
mode feeds MoonBit's ACTUAL serializations to mocpy, checks coverage AND
max_order, and requires every fixture exactly once (no self-roundtrip).
It also reconstructs polygon-derived source PixelSets in mocpy independently
from their ranges and checks both actual serializations; the report goes to
tests-data/moc-cover-oracle.json. This tests conversion, not equality of
geometry algorithms or conservative boundary decisions.

References, read 2026-11-13:
https://www.ivoa.net/documents/MOC/20220727/REC-moc-2.0-20220727.pdf
  section 4.3.2 (normative ASCII); Appendix F (informative JSON).
https://github.com/cds-astro/mocpy (installed source and wheel metadata)
  abstract_moc.py, moc/moc.py: from_string, to_string, from_healpix_cells,
  uniq_hpx and to_depth29_ranges. No upstream implementation is copied.

Scope: spatial ICRS NESTED MOC, orders 0..13, ASCII / JSON only. No FITS,
temporal, frequency or space-time encoding. Mocpy's permissive acceptance
of reversed ranges, duplicate JSON keys, or unknown objects is NOT an
oracle for malformed input: rejection tests follow the IVOA grammar.

mocpy 0.21.0 / CDS (2018), BSD-3-Clause, is a development-only oracle.
Fixtures contain behavior data; no upstream implementation or wheel is
redistributed. Upstream redistribution requires retaining the CDS notice.
Appendix F JSON is informative, not a normative MOC conformance level.
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
from pathlib import Path
import random
import shutil
import subprocess

import numpy as np
from mocpy import MOC

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "tests-data" / "moc-oracle.json"
TEST = ROOT / "moc_wbtest.mbt"
MARKER = "// BEGIN GENERATED MOC ORACLE -- scripts/generate_moc_oracle.py\n"
SEED = 20261113
SHIFT = 2 * (29 - 13)
POLYGONS = [
    {"name": "equator", "order": 5, "refine": 2,
     "vertices": [[25.0, -8.0], [55.0, -8.0], [55.0, 12.0], [25.0, 12.0]]},
    {"name": "seam", "order": 5, "refine": 2,
     "vertices": [[350.0, -12.0], [10.0, -12.0], [10.0, 12.0], [350.0, 12.0]]},
    {"name": "north", "order": 5, "refine": 2,
     "vertices": [[0.0, 65.0], [120.0, 65.0], [240.0, 65.0]]},
    {"name": "south", "order": 5, "refine": 2,
     "vertices": [[0.0, -65.0], [120.0, -65.0], [240.0, -65.0]]},
]


def signature(moc):
    return {
        "order": int(moc.max_order),
        "ranges13": [[int(a) >> SHIFT, int(b) >> SHIFT]
                     for a, b in moc.to_depth29_ranges],
        "uniq": sorted(map(int, moc.uniq_hpx)),
    }


def fixture(name, moc, **source):
    return dict(name=name, **source, **signature(moc),
                ascii=moc.to_string(format="ascii"),
                json=json.dumps(json.loads(moc.to_string(format="json")),
                                separators=(",", ":")))


def mb_string(text):
    return json.dumps(text, ensure_ascii=True)


def record_lines(row, expression):
    ranges = "[" + ", ".join(f"({a}, {b})" for a, b in row["ranges13"]) + "]"
    uniq = json.dumps(row["uniq"])
    return [
        "///|", f'test "moc oracle {row["name"]}" {{',
        "  let limits = MocLimits::default()",
        f"  let actual = {expression}",
        f"  moc_oracle_assert({mb_string(row['name'])}, actual, {row['order']},",
        f"    {ranges}, {uniq},",
        f"    {mb_string(row['ascii'])}, {mb_string(row['json'])})",
        "}", "",
    ]


def check_or_write(path, text, check):
    if check:
        if not path.is_file() or path.read_text(encoding="utf-8") != text:
            raise SystemExit(f"Generated data differs: {path.relative_to(ROOT)}")
    else:
        path.parent.mkdir(exist_ok=True)
        path.write_text(text, encoding="utf-8")


def generate(check=False):
    version = importlib.metadata.version("mocpy")
    if version != "0.21.0":
        raise SystemExit(f"Pinned oracle requires mocpy 0.21.0, got {version}")
    rows = []
    seeds = [
        ("ivoa-section-4.3.2", "1/1 2 4 2/12-14 21 23 25 8/"),
        ("empty-0", "0/"), ("empty-13", "13/"),
        ("all-sky", "0/0-11"), ("all-sky-order13", "0/0-11 13/"),
        ("siblings", "13/0-3"), ("large-range", "13/0-805306367"),
        ("last-cell", "13/805306367"),
        ("faces", "0/0 11 13/"),
        ("folded", "1/\r\n1 2 4\n2/12-14 21 23 25\r8/"),
        ("leading-zero-ascii", "00/01 02 13/"),
        ("repeated-order", "1/0 1/2 3 13/"),
    ]
    seeds += [(f"order-{order}", f"{order}/0 {12 * 4 ** order - 1}")
              for order in range(14)]
    for name, source in seeds:
        m = MOC.from_string(source, format="ascii")
        rows.append(fixture(name, m, input_ascii=source,
                            input_json=m.to_string(format="json")))
    rng = random.Random(SEED)
    for index in range(60):
        order = rng.randrange(14)
        depths, pixels = [], []
        for _ in range(rng.randrange(0, 65)):
            d = rng.randrange(order + 1)
            depths.append(d)
            pixels.append(rng.randrange(12 * 4 ** d))
        # Overlaps/duplicates intentionally exercise normalization in from_cells.
        moc = MOC.from_healpix_cells(np.array(pixels, dtype=np.uint64),
                                    np.array(depths, dtype=np.uint8),
                                    max_depth=order)
        cells = list(zip(depths, pixels))
        rows.append(fixture(f"cells-{index:02}", moc, cells=cells,
                            input_ascii=moc.to_string(format="ascii"),
                            input_json=moc.to_string(format="json")))
    # Keep operands at different orders, with holes and overlap. Using compact
    # cell lists avoids an enormous flattened full-sky array in either runtime.
    for index in range(24):
        da, db = rng.randrange(2, 14), rng.randrange(2, 14)
        a = MOC.from_healpix_cells(
            np.array(sorted(rng.sample(range(12 * 4 ** da), 16)), dtype=np.uint64),
            np.full(16, da, dtype=np.uint8), max_depth=da)
        b = MOC.from_healpix_cells(
            np.array(sorted(rng.sample(range(12 * 4 ** db), 16)), dtype=np.uint64),
            np.full(16, db, dtype=np.uint8), max_depth=db)
        # Add a common region, generating intersections and split differences.
        a = a.union(MOC.from_string("1/0-3"))
        b = b.union(MOC.from_string("2/0-7"))
        for op in ("union", "intersection", "difference", "complement"):
            m = a.complement() if op == "complement" else getattr(a, op)(b)
            rows.append(fixture(f"set-{index:02}-{op}", m, operation=op,
                                a=a.to_string(), b=b.to_string()))
    doc = {
        "scope": "Spatial ICRS MOC orders 0..13; ASCII + informative Appendix F JSON; no FITS/TMOC/STMOC",
        "standard": "IVOA REC MOC 2.0 2022-07-27 section 4.3.2 and Appendix F",
        "oracle": {"name": "mocpy", "version": version,
                   "numpy": importlib.metadata.version("numpy"),
                   "license": "BSD-3-Clause", "copyright": "2018 CDS"},
        "seed": SEED, "polygon_cases": POLYGONS, "cases": rows,
    }
    data_text = json.dumps(doc, indent=2) + "\n"
    manual = TEST.read_text(encoding="utf-8").split(MARKER)[0]
    lines = [MARKER.rstrip(), "// Expected coverage, compact UNIQ, order and strings come from mocpy 0.21.0.", ""]
    for row in rows:
        if "operation" in row:
            lines += ["///|", f'test "moc oracle {row["name"]}" {{',
                      "  let limits = MocLimits::default()",
                      f"  let a = Moc::from_ascii({mb_string(row['a'])}, limits)",
                      f"  let b = Moc::from_ascii({mb_string(row['b'])}, limits)"] if row["operation"] != "complement" else [
                      "///|", f'test "moc oracle {row["name"]}" {{',
                      "  let limits = MocLimits::default()",
                      f"  let a = Moc::from_ascii({mb_string(row['a'])}, limits)"]
            expression = ("a.complement(limits)" if row["operation"] == "complement"
                          else f"a.{row['operation']}(b, limits)")
            block = record_lines(row, expression)
            lines += block[3:]
        else:
            expression = f"Moc::from_ascii({mb_string(row['input_ascii'])}, limits)"
            lines += record_lines(row, expression)
            lines += ["///|", f'test "moc oracle JSON {row["name"]}" {{',
                      "  let limits = MocLimits::default()",
                      f"  let ascii = Moc::from_ascii({mb_string(row['input_ascii'])}, limits)",
                      f"  let json = Moc::from_json({mb_string(row['input_json'])}, limits)",
                      "  assert_true(ascii.equals(json))",
                      "  assert_eq(ascii.max_order(), json.max_order())", "}", ""]
            if "cells" in row:
                cs = ", ".join(f"Cell::new(Grid::from_level({d}), {p})"
                               for d, p in row["cells"])
                lines += ["///|", f'test "moc oracle normalize {row["name"]}" {{',
                          "  let limits = MocLimits::default()",
                          f"  let cells = [{cs}]",
                          f"  let actual = Moc::from_cells(cells, {row['order']}, limits)",
                          f"  let expected = Moc::from_ascii({mb_string(row['ascii'])}, limits)",
                          "  assert_true(actual.equals(expected))",
                          "  assert_eq(actual.max_order(), expected.max_order())", "}", ""]
    for poly in POLYGONS:
        vs = ", ".join(f"LonLat::degrees({lon}, {lat})" for lon, lat in poly["vertices"])
        lines += ["///|", f'test "moc polygon cover interop {poly["name"]}" {{',
                  f"  let grid = Grid::from_level({poly['order']})",
                  f"  let polygon = SphericalPolygon::new([{vs}], 16)",
                  f"  let cover = grid.cover_polygon(polygon, {poly['refine']}, grid.npix(), 500000)",
                  "  let centers = grid.search_polygon(polygon, grid.npix(), 500000).pixels()",
                  "  let limits = MocLimits::default()",
                  "  let interior = Moc::from_pixel_set(cover.interior(), grid.level(), limits)",
                  "  let boundary = Moc::from_pixel_set(cover.boundary(), grid.level(), limits)",
                  "  let footprint = Moc::from_pixel_set(cover.pixels(), grid.level(), limits)",
                  "  assert_true(interior.union(boundary, limits).equals(footprint))",
                  "  assert_eq(interior.intersection(boundary, limits).uniq(limits), [])"]
        for kind, expr in (("cover", "cover.pixels()"), ("interior", "cover.interior()"),
                           ("boundary", "cover.boundary()"), ("centers", "centers")):
            lines.append(f"  moc_cover_export({mb_string(poly['name'] + ':' + kind)}, {expr})")
        lines += ["}", ""]
    formatter = shutil.which("moonfmt")
    if formatter is None:
        raise SystemExit("moonfmt must be on PATH (use the configured MoonBit toolchain)")
    formatted = subprocess.run([formatter, "-"], input=manual + "\n".join(lines),
                               text=True, encoding="utf-8", capture_output=True, check=True).stdout
    check_or_write(DATA, data_text, check)
    check_or_write(TEST, formatted, check)
    verb = "PASS: read-only regeneration matches" if check else "Generated"
    print(f"{verb} {len(rows)} independent oracle cases; sha256={hashlib.sha256(data_text.encode('utf-8')).hexdigest()}")


def verify(output, check=False):
    doc = json.loads(DATA.read_text(encoding="utf-8"))
    if importlib.metadata.version("mocpy") != doc["oracle"]["version"]:
        raise SystemExit("Oracle version differs from fixture manifest")
    expected = {row["name"]: row for row in doc["cases"]}
    seen = set()
    cover_expected = {f"{poly['name']}:{kind}": poly for poly in doc["polygon_cases"]
                      for kind in ("cover", "interior", "boundary", "centers")}
    cover_seen = {}
    for line in output.read_text(encoding="utf-8-sig").splitlines():
        if line.startswith("MOC_COVER|"):
            _, name, order_text, raw_ranges, ascii_text, json_text = line.split("|", 5)
            if name in cover_seen or name not in cover_expected:
                raise SystemExit(f"Duplicate/unknown polygon conversion {name}")
            order = int(order_text)
            if order != cover_expected[name]["order"]:
                raise SystemExit(f"Wrong polygon resolution {name}")
            ranges = [list(map(int, pair.split(":"))) for pair in raw_ranges.split(",")] if raw_ranges else []
            # Independent construction from SOURCE coverage, never a local MOC
            # parse/serialize cycle. Array values are in mocpy's depth-29 grid.
            bits = 2 * (29 - order)
            arr = np.array([[a << bits, b << bits] for a, b in ranges], dtype=np.uint64).reshape(-1, 2)
            expected_moc = MOC.from_depth29_ranges(order, arr)
            wanted = signature(expected_moc)
            for fmt, text in (("ascii", ascii_text), ("json", json_text)):
                actual = signature(MOC.from_string(text, format=fmt))
                if actual != wanted:
                    raise SystemExit(f"Polygon conversion disagrees: {name} {fmt}")
            cover_seen[name] = dict(source_order=order, source_ranges=ranges,
                                    **wanted, ascii=ascii_text, json=json_text)
            continue
        if not line.startswith("MOC_INTEROP|"):
            continue
        _, name, ascii_text, json_text = line.split("|", 3)
        if name in seen or name not in expected:
            raise SystemExit(f"Duplicate or unknown MoonBit output: {name}")
        seen.add(name)
        wanted = {k: expected[name][k] for k in ("order", "ranges13", "uniq")}
        for fmt, text in (("ascii", ascii_text), ("json", json_text)):
            actual = signature(MOC.from_string(text, format=fmt))
            if actual != wanted:
                raise SystemExit(f"mocpy disagrees with MoonBit {name} {fmt}: {actual} != {wanted}")
    missing = expected.keys() - seen
    if missing:
        raise SystemExit(f"Missing {len(missing)} actual MoonBit outputs (first: {sorted(missing)[:5]})")
    missing_covers = cover_expected.keys() - cover_seen.keys()
    if missing_covers:
        raise SystemExit(f"Missing polygon output: {sorted(missing_covers)}")
    # These are conversion records, not a claim of identical boundary policies.
    report = {"scope": "Actual MoonBit polygon cover/interior/boundary/center PixelSets -> MOC; conversion evidence only",
              "oracle": doc["oracle"], "polygons": doc["polygon_cases"],
              "cases": {k: cover_seen[k] for k in sorted(cover_seen)}}
    check_or_write(DATA.parent / "moc-cover-oracle.json",
                   json.dumps(report, indent=2) + "\n", check)
    print(f"PASS: mocpy independently verified {len(cover_seen)} polygon-derived PixelSet conversions in ASCII + JSON")
    print(f"PASS: mocpy independently parsed {len(seen)} actual MoonBit ASCII + {len(seen)} JSON outputs; coverage, UNIQ and max_order agree")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify-moon-output", type=Path)
    parser.add_argument("--check", action="store_true",
                        help="Regenerate and compare in memory; never write fixture or test files")
    args = parser.parse_args()
    if args.check or not args.verify_moon_output:
        generate(check=args.check)
    if args.verify_moon_output:
        verify(args.verify_moon_output, check=args.check)


if __name__ == "__main__":
    main()
