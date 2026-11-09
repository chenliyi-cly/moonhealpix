///|
pub suberror HealpixError {
  InvalidNside(Int32)
  InvalidPixel(Int32)
  InvalidOrder(Int32)
  InvalidAngle
  InvalidVector
  InvalidFace
} derive(Eq, Debug)

///|
/// A validated power-of-two resolution. The maximum is chosen so every
/// pixel index and NUNIQ identifier fits a signed 32-bit integer.
pub struct Grid {
  nside : Int32
  level : Int32
  npix : Int32
} derive(Eq, Debug)

///|
pub fn Grid::new(nside : Int32) -> Grid raise HealpixError {
  if nside < 1 || nside > 8192 || (nside & (nside - 1)) != 0 {
    raise InvalidNside(nside)
  }
  let mut v = nside
  let mut level = 0
  while v > 1 {
    v = v >> 1
    level = level + 1
  }
  { nside, level, npix: 12 * nside * nside, }
}

///|
pub fn Grid::from_level(level : Int32) -> Grid raise HealpixError {
  if level < 0 || level > 13 {
    raise InvalidOrder(level)
  }
  Grid::new(1 << level)
}

///|
pub fn Grid::nside(self : Grid) -> Int32 {
  self.nside
}

///|
pub fn Grid::level(self : Grid) -> Int32 {
  self.level
}

///|
pub fn Grid::npix(self : Grid) -> Int32 {
  self.npix
}

///|
pub fn Grid::pixel_area(self : Grid) -> Double {
  4.0 * @math.PI / self.npix.to_double()
}

///|
/// Square root of the equal pixel area, in radians; not an edge length.
pub fn Grid::resolution(self : Grid) -> Double {
  self.pixel_area().sqrt()
}

///|
pub fn Grid::validate_pixel(
  self : Grid,
  pixel : Int32,
) -> Unit raise HealpixError {
  if pixel < 0 || pixel >= self.npix {
    raise InvalidPixel(pixel)
  }
}

///|
pub extend HealpixError with Eq::{equal, not_equal}

///|
pub extend HealpixError with @debug.Debug::{to_repr}

///|
pub extend Grid with Eq::{equal, not_equal}

///|
pub extend Grid with @debug.Debug::{to_repr}
