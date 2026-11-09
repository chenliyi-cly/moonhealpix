///|
pub(all) enum Ordering {
  Ring
  Nested
} derive(Eq, Debug)

///|
pub extend Ordering with Eq::{equal, not_equal}

///|
pub extend Ordering with @debug.Debug::{to_repr}

///|
pub fn Grid::nested_to_ring(
  self : Grid,
  pixel : Int32,
) -> Int32 raise HealpixError {
  self.lonlat_to_ring(self.nested_center(pixel))
}

///|
pub fn Grid::ring_to_nested(
  self : Grid,
  pixel : Int32,
) -> Int32 raise HealpixError {
  self.lonlat_to_nested(self.ring_center(pixel))
}

///|
pub fn Grid::convert(
  self : Grid,
  pixel : Int32,
  from : Ordering,
  to : Ordering,
) -> Int32 raise HealpixError {
  self.validate_pixel(pixel)
  match (from, to) {
    (Nested, Ring) => self.nested_to_ring(pixel)
    (Ring, Nested) => self.ring_to_nested(pixel)
    _ => pixel
  }
}

///|
pub fn Grid::index(
  self : Grid,
  point : LonLat,
  ordering : Ordering,
) -> Int32 raise HealpixError {
  match ordering {
    Ring => self.lonlat_to_ring(point)
    Nested => self.lonlat_to_nested(point)
  }
}

///|
pub fn Grid::center(
  self : Grid,
  pixel : Int32,
  ordering : Ordering,
) -> LonLat raise HealpixError {
  match ordering {
    Ring => self.ring_center(pixel)
    Nested => self.nested_center(pixel)
  }
}
