// SPDX-License-Identifier: BSD-3-Clause
// Latitude-ring bilinear interpolation adapted from astropy-healpix 1.1.3,
// astropy_healpix/interpolation.c (Astropy Developers, 2016-2018), and
// cextern/astrometry.net/healpix.c (Astrometry.net Developers, 2006-2015).
// Original notices and conditions are retained in LICENSES; see THIRD_PARTY.md.
// Source SHA-256: 54150c2a32a95083a3aa4aa3578813f95892ef7b1c825a810a9a21096396da06.

///|
/// Astrometry.net's face projection chooses the interpolation anchor. The
/// existing index API has a different ownership convention at exact edges;
/// this local version also avoids 1-sin(lat) cancellation near a polar ring.
/// This matters even for zero-weight corners under strict missing propagation.
fn interpolation_anchor(
  grid : Grid,
  point : LonLat,
) -> Int32 raise HealpixError {
  let z = @math.sin(point.lat)
  let cosine = @math.cos(point.lat)
  let phi = wrap_longitude(
    @math.atan2(cosine * @math.sin(point.lon), cosine * @math.cos(point.lon)),
  )
  let half_pi = @math.PI / 2.0
  let phase = phi % half_pi
  let sector = @math.round((phi - phase) / half_pi).to_int() % 4
  let n = grid.nside.to_double()
  let (face, xx, yy) = if z.abs() >= 2.0 / 3.0 {
    let scale = cosine / (1.0 + z.abs()).sqrt() * 3.0.sqrt()
    let kx = scale * (n * (2.0 * phase - @math.PI) / @math.PI).abs()
    let ky = scale * n * 2.0 * phase / @math.PI
    if z >= 0.0 {
      (sector, n - kx, n - ky)
    } else {
      (8 + sector, ky, kx)
    }
  } else {
    let zunits = (z + 2.0 / 3.0) / (4.0 / 3.0)
    let phiunits = phase / half_pi
    let x = (zunits + phiunits) * n
    let y = (zunits - phiunits + 1.0) * n
    if x >= n {
      if y >= n {
        (sector, x - n, y - n)
      } else {
        (4 + (sector + 1) % 4, x - n, y)
      }
    } else if y >= n {
      (sector + 4, x, y - n)
    } else {
      (sector + 8, x, y)
    }
  }
  let x = @math.floor(xx).to_int().max(0).min(grid.nside - 1)
  let y = @math.floor(yy).to_int().max(0).min(grid.nside - 1)
  grid.nested_to_ring(grid.face_pixel(FaceXY::new(grid, face, x, y)))
}

///|
/// Avoid loss of precision in asin(1 - r*r/(3*n*n)) near the poles.
fn interpolation_latitude(grid : Grid, ring : RingInfo) -> Double {
  let r = ring.number.min(4 * grid.nside - ring.number)
  if r < grid.nside {
    let colat = 2.0 *
      @math.asin(r.to_double() / (6.0.sqrt() * grid.nside.to_double()))
    if ring.number < grid.nside {
      @math.PI / 2.0 - colat
    } else {
      colat - @math.PI / 2.0
    }
  } else {
    ring.latitude
  }
}

///|
fn interpolation_near_longitude(lon : Double, reference : Double) -> Double {
  if reference - lon > @math.PI {
    lon + 2.0 * @math.PI
  } else if lon - reference > @math.PI {
    lon - 2.0 * @math.PI
  } else {
    lon
  }
}

///|
/// Pair on a latitude ring, starting at `pixel` and extending toward `lon`.
fn interpolation_ring_pair(
  ring : RingInfo,
  pixel : Int32,
  lon : Double,
) -> (Int32, Double) {
  let position = pixel - ring.start
  let center = interpolation_near_longitude(
    ring.first_longitude + position.to_double() * ring.longitude_step(),
    lon,
  )
  let direction = if lon < center { -1 } else { 1 }
  let next = ring.start + modulo(position + direction, ring.count)
  let fraction = clamp(
    (lon - center) / (direction.to_double() * ring.longitude_step()),
    0.0,
    1.0,
  )
  (next, fraction)
}

///|
/// Four pixels and matching bilinear weights, in the requested ordering.
/// The first pair brackets longitude on the containing pixel's latitude
/// ring; the second pair is on the adjacent ring toward the query latitude.
/// At a pole the four pixels of the nearest ring have weight 1/4 each.
/// Between that ring and its pole, blend longitude interpolation with their
/// mean. Weights are nonnegative and sum to one (up to floating point error).
/// At exact pixel/ring boundaries a zero-weight slot may choose either side;
/// slot order is not a compass order. No dense map is allocated.
pub fn Grid::bilinear_interpolation_weights(
  self : Grid,
  point : LonLat,
  ordering : Ordering,
) -> (Array[Int32], Array[Double]) raise HealpixError {
  let first = interpolation_anchor(self, point)
  let ring = self.pixel_ring(first)
  let lat = interpolation_latitude(self, ring)
  let (second, x) = interpolation_ring_pair(ring, first, point.lon)
  let adjacent = ring.number + (if point.lat > lat { -1 } else { 1 })
  let (third, fourth, weights) = if adjacent > 0 && adjacent < 4 * self.nside {
    let next_ring = self.ring_info(adjacent)
    // Match astropy's choice of initial pixel on the second ring. Either
    // member of the bracketing pair is valid; weights travel with indices.
    let offset = if next_ring.count == 4 * self.nside && (adjacent & 1) == 1 {
      0.5
    } else {
      0.0
    }
    let position = @math.floor(point.lon / next_ring.longitude_step() + offset)
      .to_int()
      .min(next_ring.count - 1)
    let third = next_ring.start + position
    let (fourth, next_x) = interpolation_ring_pair(next_ring, third, point.lon)
    let y = clamp(
      (point.lat - lat) / (interpolation_latitude(self, next_ring) - lat),
      0.0,
      1.0,
    )
    (
      third,
      fourth,
      [(1.0 - x) * (1.0 - y), x * (1.0 - y), (1.0 - next_x) * y, next_x * y],
    )
  } else {
    let pole = if adjacent == 0 { @math.PI / 2.0 } else { -@math.PI / 2.0 }
    let y = clamp((point.lat - lat) / (pole - lat), 0.0, 1.0)
    let third = ring.start + modulo(first - ring.start + 2, 4)
    let fourth = ring.start + modulo(second - ring.start + 2, 4)
    (
      third,
      fourth,
      [
        (1.0 - x) * (1.0 - y) + 0.25 * y,
        x * (1.0 - y) + 0.25 * y,
        0.25 * y,
        0.25 * y,
      ],
    )
  }
  let pixels = [first, second, third, fourth]
  if ordering == Nested {
    for i = 0; i < 4; i = i + 1 {
      pixels[i] = self.ring_to_nested(pixels[i])
    }
  }
  (pixels, weights)
}

///|
/// Bilinear sampling with strict missing-value propagation: if any of the
/// four returned stencil pixels is None (even at zero weight), return None.
/// This mirrors NaN propagation on the returned stencil without storing NaNs.
/// At exact boundaries, floating point tie choices can change zero-weight
/// corners relative to another implementation, and hence its missing result.
/// Values are not renormalized around missing pixels. Nonfinite arithmetic
/// raises InvalidData; the map and its ordering are never changed.
pub fn ScalarMap::interpolate_bilinear(
  self : ScalarMap,
  point : LonLat,
) -> Double? raise HealpixError {
  let (pixels, weights) = self.grid.bilinear_interpolation_weights(
    point,
    self.ordering,
  )
  // Check the whole stencil before arithmetic so missingness wins over an
  // overflow in an earlier partial sum.
  for pixel in pixels {
    if self.data[pixel] is None {
      return None
    }
  }
  let mut value = 0.0
  for i = 0; i < 4; i = i + 1 {
    value = value + self.data[pixels[i]].unwrap() * weights[i]
  }
  if !finite(value) {
    raise InvalidData
  }
  Some(value)
}
