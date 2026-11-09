///|
/// Mean: intensive field. Sum: integrated quantity per pixel.
#derive(Eq, Debug)
pub(all) enum ResampleMode {
  Mean
  Sum
}

///|
pub extend ResampleMode with Eq::{equal, not_equal}

///|
pub extend ResampleMode with @debug.Debug::{to_repr}

///|
/// Exact hierarchy-based resolution changes, preserving the input ordering.
/// Downsampling ignores missing children; no valid children yields None.
/// Upsampling repeats a Mean value or divides a Sum among descendants.
/// This is not harmonic resampling or interpolation at arbitrary directions.
pub fn ScalarMap::resample(
  self : ScalarMap,
  target : Grid,
  mode : ResampleMode,
  max_pixels : Int32,
) -> ScalarMap raise HealpixError {
  if max_pixels < 0 || target.npix > max_pixels {
    raise ResourceLimit
  }
  if target == self.grid {
    return { grid: target, ordering: self.ordering, data: self.data.copy(), }
  }
  let data : Array[Double?] = Array::make(target.npix, None)
  if target.level < self.grid.level {
    let bits = 2 * (self.grid.level - target.level)
    let counts = Array::make(target.npix, 0)
    let sums = Array::make(target.npix, 0.0)
    let compensation = Array::make(target.npix, 0.0)
    for p = 0; p < self.grid.npix; p = p + 1 {
      if self.data[p] is Some(value) {
        let nested = self.grid.convert(p, self.ordering, Nested)
        let parent = nested >> bits
        let corrected = value - compensation[parent]
        let sum = sums[parent] + corrected
        compensation[parent] = sum - sums[parent] - corrected
        if !finite(sum) {
          raise InvalidData
        }
        sums[parent] = sum
        counts[parent] = counts[parent] + 1
      }
    }
    for p = 0; p < target.npix; p = p + 1 {
      if counts[p] > 0 {
        data[p] = Some(
          match mode {
            Sum => sums[p]
            Mean => sums[p] / counts[p].to_double()
          },
        )
      }
    }
  } else {
    let bits = 2 * (target.level - self.grid.level)
    let divisor = (1 << bits).to_double()
    for p = 0; p < target.npix; p = p + 1 {
      let parent = self.grid.convert(p >> bits, Nested, self.ordering)
      data[p] = match self.data[parent] {
        None => None
        Some(v) =>
          Some(
            match mode {
              Mean => v
              Sum => v / divisor
            },
          )
      }
    }
  }
  let nested_map : ScalarMap = { grid: target, ordering: Nested, data, }
  nested_map.reorder(self.ordering)
}
