///|
/// Half-open interval [start, end) in a single pixel ordering.
#derive(Eq, Debug)
pub struct PixelRange {
  start : Int32
  end : Int32
}

///|
pub extend PixelRange with Eq::{equal, not_equal}

///|
pub extend PixelRange with @debug.Debug::{to_repr}

///|
pub fn PixelRange::new(
  grid : Grid,
  start : Int32,
  end : Int32,
) -> PixelRange raise HealpixError {
  if start < 0 || end < start || end > grid.npix {
    raise InvalidRange
  }
  { start, end, }
}

///|
pub fn PixelRange::start(self : PixelRange) -> Int32 {
  self.start
}

///|
pub fn PixelRange::end(self : PixelRange) -> Int32 {
  self.end
}

///|
pub fn PixelRange::length(self : PixelRange) -> Int32 {
  self.end - self.start
}

///|
/// Sorted disjoint, non-adjacent ranges; input arrays are copied.
pub struct PixelSet {
  grid : Grid
  ordering : Ordering
  spans : Array[PixelRange]
}

///|
pub fn PixelSet::new(
  grid : Grid,
  ordering : Ordering,
  ranges : Array[PixelRange],
) -> PixelSet raise HealpixError {
  let sorted = ranges.copy()
  for r in sorted {
    PixelRange::new(grid, r.start, r.end) |> ignore
  }
  sorted.sort_by_key(r => r.start)
  let out : Array[PixelRange] = []
  for r in sorted {
    if r.start == r.end {
      continue
    }
    if out.is_empty() || out[out.length() - 1].end < r.start {
      out.push(r)
    } else {
      let last = out[out.length() - 1]
      out[out.length() - 1] = { start: last.start, end: last.end.max(r.end), }
    }
  }
  { grid, ordering, spans: out, }
}

///|
pub fn PixelSet::grid(self : PixelSet) -> Grid {
  self.grid
}

///|
pub fn PixelSet::ordering(self : PixelSet) -> Ordering {
  self.ordering
}

///|
pub fn PixelSet::ranges(self : PixelSet) -> Array[PixelRange] {
  self.spans.copy()
}

///|
pub fn PixelSet::count(self : PixelSet) -> Int32 {
  let mut total = 0
  for r in self.spans {
    total = total + r.length()
  }
  total
}

///|
pub fn PixelSet::contains(self : PixelSet, pixel : Int32) -> Bool {
  let mut lo = 0
  let mut hi = self.spans.length()
  while lo < hi {
    let mid = lo + (hi - lo) / 2
    let r = self.spans[mid]
    if pixel < r.start {
      hi = mid
    } else if pixel >= r.end {
      lo = mid + 1
    } else {
      return true
    }
  }
  false
}

///|
/// Explicitly bounded expansion, checked before allocation.
pub fn PixelSet::pixels(
  self : PixelSet,
  max_pixels : Int32,
) -> Array[Int32] raise HealpixError {
  if max_pixels < 0 || self.count() > max_pixels {
    raise ResourceLimit
  }
  let out : Array[Int32] = []
  for r in self.spans {
    for p = r.start; p < r.end; p = p + 1 {
      out.push(p)
    }
  }
  out
}

///|
fn compatible_sets(a : PixelSet, b : PixelSet) -> Unit raise HealpixError {
  if a.grid != b.grid || a.ordering != b.ordering {
    raise IncompatibleGrid
  }
}

///|
pub fn PixelSet::union(
  self : PixelSet,
  other : PixelSet,
) -> PixelSet raise HealpixError {
  compatible_sets(self, other)
  let both = self.spans.copy()
  for r in other.spans {
    both.push(r)
  }
  PixelSet::new(self.grid, self.ordering, both)
}

///|
pub fn PixelSet::intersection(
  self : PixelSet,
  other : PixelSet,
) -> PixelSet raise HealpixError {
  compatible_sets(self, other)
  let out : Array[PixelRange] = []
  let mut i = 0
  let mut j = 0
  while i < self.spans.length() && j < other.spans.length() {
    let a = self.spans[i]
    let b = other.spans[j]
    let lo = a.start.max(b.start)
    let hi = a.end.min(b.end)
    if lo < hi {
      out.push({ start: lo, end: hi, })
    }
    if a.end < b.end {
      i = i + 1
    } else {
      j = j + 1
    }
  }
  { grid: self.grid, ordering: self.ordering, spans: out, }
}

///|
pub fn PixelSet::difference(
  self : PixelSet,
  other : PixelSet,
) -> PixelSet raise HealpixError {
  compatible_sets(self, other)
  let out : Array[PixelRange] = []
  let mut j = 0
  for a in self.spans {
    let mut cursor = a.start
    while j < other.spans.length() && other.spans[j].end <= cursor {
      j = j + 1
    }
    let mut k = j
    while k < other.spans.length() && other.spans[k].start < a.end {
      let b = other.spans[k]
      if cursor < b.start {
        out.push({ start: cursor, end: b.start.min(a.end), })
      }
      cursor = cursor.max(b.end)
      if cursor >= a.end {
        break
      }
      k = k + 1
    }
    if cursor < a.end {
      out.push({ start: cursor, end: a.end, })
    }
  }
  { grid: self.grid, ordering: self.ordering, spans: out, }
}

///|
pub fn PixelSet::complement(self : PixelSet) -> PixelSet raise HealpixError {
  let full = PixelSet::new(self.grid, self.ordering, [
    { start: 0, end: self.grid.npix, },
  ])
  full.difference(self)
}
