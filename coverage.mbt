///|
/// Expand mixed-resolution cells to normalized NESTED intervals without
/// allocating individual pixels. Cells coarser than target are exact blocks.
pub fn Grid::cover_cells(
  self : Grid,
  cells : Array[Cell],
  max_ranges : Int32,
) -> PixelSet raise HealpixError {
  if max_ranges < 0 || cells.length() > max_ranges {
    raise ResourceLimit
  }
  let ranges : Array[PixelRange] = []
  for cell in cells {
    if cell.grid.level > self.level {
      raise InvalidOrder(cell.grid.level)
    }
    ranges.push(cell.descendant_range(self.level))
  }
  PixelSet::new(self, Nested, ranges)
}

///|
/// Minimal aligned quadtree blocks representing this exact selection.
/// Compression never joins across the twelve base faces.
pub fn PixelSet::compact_cells(
  self : PixelSet,
  max_cells : Int32,
) -> Array[Cell] raise HealpixError {
  if self.ordering != Nested {
    raise IncompatibleGrid
  }
  if max_cells < 0 {
    raise ResourceLimit
  }
  let out : Array[Cell] = []
  for range in self.spans {
    let mut p = range.start
    while p < range.end {
      let mut step = 1
      let mut levels = 0
      while levels < self.grid.level {
        let next = step * 4
        if p % next != 0 || next > range.end - p {
          break
        }
        step = next
        levels = levels + 1
      }
      if out.length() >= max_cells {
        raise ResourceLimit
      }
      out.push(Cell::new(Grid::from_level(self.grid.level - levels), p / step))
      p = p + step
    }
  }
  out
}

///|
/// Exact change of level: lowering resolution rejects partial parent cells.
pub fn PixelSet::at_level(
  self : PixelSet,
  level : Int32,
) -> PixelSet raise HealpixError {
  if self.ordering != Nested {
    raise IncompatibleGrid
  }
  let target = Grid::from_level(level)
  let ranges : Array[PixelRange] = []
  if level >= self.grid.level {
    let bits = 2 * (level - self.grid.level)
    for r in self.spans {
      ranges.push({ start: r.start << bits, end: r.end << bits, })
    }
  } else {
    let bits = 2 * (self.grid.level - level)
    let mask = (1 << bits) - 1
    for r in self.spans {
      if (r.start & mask) != 0 || (r.end & mask) != 0 {
        raise InvalidRange
      }
      ranges.push({ start: r.start >> bits, end: r.end >> bits, })
    }
  }
  PixelSet::new(target, Nested, ranges)
}

///|
/// Converts ordering explicitly; conversion is bounded by expanded pixels.
pub fn PixelSet::reorder(
  self : PixelSet,
  ordering : Ordering,
  max_pixels : Int32,
) -> PixelSet raise HealpixError {
  if ordering == self.ordering {
    return PixelSet::new(self.grid, ordering, self.spans)
  }
  let ranges : Array[PixelRange] = []
  for pixel in self.pixels(max_pixels) {
    let p = self.grid.convert(pixel, self.ordering, ordering)
    ranges.push({ start: p, end: p + 1, })
  }
  PixelSet::new(self.grid, ordering, ranges)
}
