// SPDX-License-Identifier: BSD-3-Clause
// Face adjacency adapted from astropy-healpix 1.1.3,
// cextern/astrometry.net/healpix.c (Astrometry.net Developers, 2006-2015).
// Original notices and conditions: LICENSES/astrometry-BSD-3-Clause.txt and
// LICENSES/astropy-healpix-BSD-3-Clause.txt; see THIRD_PARTY.md.
// Pinned sdist SHA-256:
// f520d83abe8215d3e8e1a37b2bd91171ee36a6f55f110d5a2db863d75d81b3b7.

///|
/// Base-face transition for a step crossing one or two face boundaries.
fn neighbour_face(face : Int32, dx : Int32, dy : Int32) -> Int32 {
  if dx == 0 && dy == 0 {
    return face
  }
  if face < 4 {
    match (dx, dy) {
      (1, 0) => (face + 1) % 4
      (0, 1) => (face + 3) % 4
      (1, 1) => (face + 2) % 4
      (-1, 0) => face + 4
      (0, -1) => 4 + (face + 1) % 4
      (-1, -1) => face + 8
      _ => -1
    }
  } else if face >= 8 {
    match (dx, dy) {
      (1, 0) => 4 + (face + 1) % 4
      (0, 1) => face - 4
      (-1, 0) => 8 + (face + 3) % 4
      (0, -1) => 8 + (face + 1) % 4
      (-1, -1) => 8 + (face + 2) % 4
      (1, 1) => face - 8
      _ => -1
    }
  } else {
    match (dx, dy) {
      (1, 0) => face - 4
      (0, 1) => (face + 3) % 4
      (-1, 0) => 8 + (face + 3) % 4
      (0, -1) => face + 4
      (1, -1) => 4 + (face + 1) % 4
      (-1, 1) => 4 + (face - 1) % 4
      _ => -1
    }
  }
}

///|
/// Eight HEALPix neighbours, ordered SW, W, NW, N, NE, E, SE, S
/// (clockwise from SW, as in astropy-healpix/healpy). Directions refer to
/// the local pixel axes, including their rotation across polar faces.
/// A missing neighbour occupies its original slot with sentinel -1.
/// Both input and output pixels use `ordering`; invalid input raises.
pub fn Grid::neighbours(
  self : Grid,
  pixel : Int32,
  ordering : Ordering,
) -> Array[Int32] raise HealpixError {
  let coordinate = self.pixel_face(self.convert(pixel, ordering, Nested))
  let steps = [
    (-1, 0),
    (-1, 1),
    (0, 1),
    (1, 1),
    (1, 0),
    (1, -1),
    (0, -1),
    (-1, -1),
  ]
  let result = Array::make(8, -1)
  let n = self.nside
  for i = 0; i < 8; i = i + 1 {
    let (dx, dy) = steps[i]
    let x = coordinate.x + dx
    let y = coordinate.y + dy
    let cx = if x < 0 { -1 } else if x >= n { 1 } else { 0 }
    let cy = if y < 0 { -1 } else if y >= n { 1 } else { 0 }
    let face = neighbour_face(coordinate.face, cx, cy)
    if face < 0 {
      continue
    }
    let mut nx = modulo(x, n)
    let mut ny = modulo(y, n)
    // Across a polar seam the two face axes exchange roles. The axis
    // leaving the face stays on the polar edge instead of wrapping.
    if coordinate.face < 4 && (cx > 0 || cy > 0) {
      if cx > 0 {
        nx = n - 1
      }
      if cy > 0 {
        ny = n - 1
      }
      let previous = nx
      nx = ny
      ny = previous
    } else if coordinate.face >= 8 && (cx < 0 || cy < 0) {
      if cx < 0 {
        nx = 0
      }
      if cy < 0 {
        ny = 0
      }
      let previous = nx
      nx = ny
      ny = previous
    }
    let nested = self.face_pixel(FaceXY::new(self, face, nx, ny))
    result[i] = self.convert(nested, Nested, ordering)
  }
  result
}
