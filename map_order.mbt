///|
/// Reorders samples; no resampling, averaging or missing-value substitution.
pub fn ScalarMap::reorder(
  self : ScalarMap,
  ordering : Ordering,
) -> ScalarMap raise HealpixError {
  if ordering == self.ordering {
    return { grid: self.grid, ordering, data: self.data.copy(), }
  }
  let data : Array[Double?] = Array::make(self.grid.npix, None)
  for p = 0; p < self.grid.npix; p = p + 1 {
    let dest = self.grid.convert(p, self.ordering, ordering)
    data[dest] = self.data[p]
  }
  { grid: self.grid, ordering, data, }
}

///|
/// Restrict a map to a region without losing its coordinate system.
pub fn ScalarMap::masked(
  self : ScalarMap,
  selection : PixelSet,
) -> ScalarMap raise HealpixError {
  if self.grid != selection.grid || self.ordering != selection.ordering {
    raise IncompatibleGrid
  }
  let data : Array[Double?] = Array::make(self.grid.npix, None)
  for r in selection.spans {
    for p = r.start; p < r.end; p = p + 1 {
      data[p] = self.data[p]
    }
  }
  { grid: self.grid, ordering: self.ordering, data, }
}

///|
/// Fill only missing pixels from another identically indexed map.
pub fn ScalarMap::coalesce(
  self : ScalarMap,
  fallback : ScalarMap,
) -> ScalarMap raise HealpixError {
  if self.grid != fallback.grid || self.ordering != fallback.ordering {
    raise IncompatibleGrid
  }
  let data = self.data.copy()
  for p = 0; p < data.length(); p = p + 1 {
    if data[p] is None {
      data[p] = fallback.data[p]
    }
  }
  { grid: self.grid, ordering: self.ordering, data, }
}
