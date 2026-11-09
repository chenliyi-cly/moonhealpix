///|
/// Weighted observations aggregated on the catalogue's NESTED grid.
pub struct BinnedStats {
  counts : ScalarMap
  weights : ScalarMap
  sums : ScalarMap
  means : ScalarMap
  variances : ScalarMap
}

///|
pub fn BinnedStats::counts(self : BinnedStats) -> ScalarMap {
  self.counts
}

///|
pub fn BinnedStats::weights(self : BinnedStats) -> ScalarMap {
  self.weights
}

///|
pub fn BinnedStats::sums(self : BinnedStats) -> ScalarMap {
  self.sums
}

///|
pub fn BinnedStats::means(self : BinnedStats) -> ScalarMap {
  self.means
}

///|
pub fn BinnedStats::variances(self : BinnedStats) -> ScalarMap {
  self.variances
}

///|
/// Nonnegative finite weights; zero weight and missing values are ignored.
/// Count and weight maps are defined everywhere (zero in empty bins).
/// Sum, mean and population variance are missing where no observation remains.
/// All numeric intermediates must be finite; overflow raises InvalidData.
pub fn Catalog::bin_values(
  self : Catalog,
  values : Array[Double?],
  weights : Array[Double],
  max_pixels : Int32,
) -> BinnedStats raise HealpixError {
  let grid = self.grid
  if max_pixels < 0 || grid.npix > max_pixels {
    raise ResourceLimit
  }
  if values.length() != self.sources.length() ||
    weights.length() != values.length() {
    raise InvalidData
  }
  for i = 0; i < values.length(); i = i + 1 {
    if !finite(weights[i]) || weights[i] < 0.0 {
      raise InvalidData
    }
    if values[i] is Some(v) {
      if !finite(v) {
        raise InvalidData
      }
    }
  }
  let counts : Array[Double?] = Array::make(grid.npix, Some(0.0))
  let total_weights : Array[Double?] = Array::make(grid.npix, Some(0.0))
  let sums : Array[Double?] = Array::make(grid.npix, None)
  let means : Array[Double?] = Array::make(grid.npix, None)
  let variances : Array[Double?] = Array::make(grid.npix, None)
  for bin in self.bins {
    let mut count = 0
    let mut weight = 0.0
    let mut sum = 0.0
    let mut compensation = 0.0
    let mut mean = 0.0
    let mut m2 = 0.0
    for j = bin.start; j < bin.end; j = j + 1 {
      let i = self.indices[j].1
      let w = weights[i]
      if values[i] is Some(v) {
        if w == 0.0 {
          continue
        }
        let next_weight = weight + w
        let delta = v - mean
        let next_mean = mean + delta * (w / next_weight)
        m2 = m2 + w * delta * (v - next_mean)
        mean = next_mean
        weight = next_weight
        let corrected = v * w - compensation
        let next_sum = sum + corrected
        compensation = next_sum - sum - corrected
        sum = next_sum
        count = count + 1
        if !finite(weight) || !finite(mean) || !finite(m2) || !finite(sum) {
          raise InvalidData
        }
      }
    }
    if count > 0 {
      let p = bin.pixel
      counts[p] = Some(count.to_double())
      total_weights[p] = Some(weight)
      sums[p] = Some(sum)
      means[p] = Some(mean)
      variances[p] = Some((m2 / weight).max(0.0))
    }
  }
  {
    counts: { grid, ordering: Nested, data: counts, },
    weights: { grid, ordering: Nested, data: total_weights, },
    sums: { grid, ordering: Nested, data: sums, },
    means: { grid, ordering: Nested, data: means, },
    variances: { grid, ordering: Nested, data: variances, },
  }
}
