///|
/// A single NESTED cell, with its own resolution. NUNIQ is not a MOC document.
#derive(Eq, Debug)
pub struct Cell {
  grid : Grid
  pixel : Int32
}

///|
pub extend Cell with Eq::{equal, not_equal}

///|
pub extend Cell with @debug.Debug::{to_repr}

///|
pub fn Cell::new(grid : Grid, nested_pixel : Int32) -> Cell raise HealpixError {
  grid.validate_pixel(nested_pixel)
  { grid, pixel: nested_pixel, }
}

///|
pub fn Cell::grid(self : Cell) -> Grid {
  self.grid
}

///|
pub fn Cell::pixel(self : Cell) -> Int32 {
  self.pixel
}

///|
pub fn Cell::uniq(self : Cell) -> Int32 {
  4 * self.grid.nside * self.grid.nside + self.pixel
}

///|
pub fn Cell::from_uniq(uniq : Int32) -> Cell raise HealpixError {
  if uniq < 4 || uniq > 1073741823 {
    raise InvalidRange
  }
  let mut level = 0
  let mut base = 4
  while level < 13 && uniq >= base * 4 {
    base = base * 4
    level = level + 1
  }
  Cell::new(Grid::from_level(level), uniq - base)
}

///|
pub fn Cell::parent(self : Cell, level : Int32) -> Cell raise HealpixError {
  if level < 0 || level > self.grid.level {
    raise InvalidOrder(level)
  }
  Cell::new(
    Grid::from_level(level),
    self.pixel >> (2 * (self.grid.level - level)),
  )
}

///|
pub fn Cell::descendant_range(
  self : Cell,
  level : Int32,
) -> PixelRange raise HealpixError {
  if level < self.grid.level || level > 13 {
    raise InvalidOrder(level)
  }
  let bits = 2 * (level - self.grid.level)
  let g = Grid::from_level(level)
  PixelRange::new(g, self.pixel << bits, (self.pixel + 1) << bits)
}

///|
pub fn Cell::children(
  self : Cell,
  level : Int32,
  max_cells : Int32,
) -> Array[Cell] raise HealpixError {
  let r = self.descendant_range(level)
  if max_cells < 0 || r.length() > max_cells {
    raise ResourceLimit
  }
  let grid = Grid::from_level(level)
  let out : Array[Cell] = []
  for pixel = r.start; pixel < r.end; pixel = pixel + 1 {
    out.push({ grid, pixel, })
  }
  out
}

///|
pub fn Cell::contains(self : Cell, other : Cell) -> Bool {
  if self.grid.level > other.grid.level {
    return false
  }
  other.pixel >> (2 * (other.grid.level - self.grid.level)) == self.pixel
}

///|
pub fn Cell::center(self : Cell) -> LonLat raise HealpixError {
  self.grid.nested_center(self.pixel)
}

///|
pub fn Cell::area(self : Cell) -> Double {
  self.grid.pixel_area()
}
