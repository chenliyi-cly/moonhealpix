///|
/// A bounded dense scalar map. None denotes missing data, never numeric NaN.
/// Constructors copy the input; callers cannot mutate a map through aliases.
pub struct ScalarMap {
  grid : Grid
  ordering : Ordering
  data : Array[Double?]
}

///|
pub fn ScalarMap::new(
  grid : Grid,
  ordering : Ordering,
  values : Array[Double?],
  max_pixels : Int32,
) -> ScalarMap raise HealpixError {
  if max_pixels < 0 || grid.npix > max_pixels {
    raise ResourceLimit
  }
  if values.length() != grid.npix {
    raise InvalidData
  }
  for value in values {
    if value is Some(v) {
      if !finite(v) {
        raise InvalidData
      }
    }
  }
  { grid, ordering, data: values.copy(), }
}

///|
pub fn ScalarMap::filled(
  grid : Grid,
  ordering : Ordering,
  value : Double?,
  max_pixels : Int32,
) -> ScalarMap raise HealpixError {
  if max_pixels < 0 || grid.npix > max_pixels {
    raise ResourceLimit
  }
  if value is Some(v) {
    if !finite(v) {
      raise InvalidData
    }
  }
  { grid, ordering, data: Array::make(grid.npix, value), }
}

///|
pub fn ScalarMap::grid(self : ScalarMap) -> Grid {
  self.grid
}

///|
pub fn ScalarMap::ordering(self : ScalarMap) -> Ordering {
  self.ordering
}

///|
pub fn ScalarMap::values(self : ScalarMap) -> Array[Double?] {
  self.data.copy()
}

///|
pub fn ScalarMap::get(
  self : ScalarMap,
  pixel : Int32,
) -> Double? raise HealpixError {
  self.grid.validate_pixel(pixel)
  self.data[pixel]
}

///|
pub fn ScalarMap::sample(
  self : ScalarMap,
  point : LonLat,
) -> Double? raise HealpixError {
  self.get(self.grid.index(point, self.ordering))
}

///|
pub fn ScalarMap::with_value(
  self : ScalarMap,
  pixel : Int32,
  value : Double?,
) -> ScalarMap raise HealpixError {
  self.grid.validate_pixel(pixel)
  if value is Some(v) {
    if !finite(v) {
      raise InvalidData
    }
  }
  let data = self.data.copy()
  data[pixel] = value
  { grid: self.grid, ordering: self.ordering, data, }
}

///|
#derive(Eq, Debug)
pub struct Summary {
  count : Int32
  missing : Int32
  sum : Double
  mean : Double
  variance : Double
  minimum : Double
  maximum : Double
}

///|
pub extend Summary with Eq::{equal, not_equal}

///|
pub extend Summary with @debug.Debug::{to_repr}

///|
pub fn Summary::count(self : Summary) -> Int32 {
  self.count
}

///|
pub fn Summary::missing(self : Summary) -> Int32 {
  self.missing
}

///|
pub fn Summary::sum(self : Summary) -> Double {
  self.sum
}

///|
pub fn Summary::mean(self : Summary) -> Double {
  self.mean
}

///|
/// Population variance, not sample variance.
pub fn Summary::variance(self : Summary) -> Double {
  self.variance
}

///|
pub fn Summary::minimum(self : Summary) -> Double {
  self.minimum
}

///|
pub fn Summary::maximum(self : Summary) -> Double {
  self.maximum
}

///|
/// Welford variance and compensated sum. Empty maps return None.
/// Arithmetic overflow is a typed error instead of silently returning infinity.
pub fn ScalarMap::summary(self : ScalarMap) -> Summary? raise HealpixError {
  let mut count = 0
  let mut sum = 0.0
  let mut compensation = 0.0
  let mut mean = 0.0
  let mut m2 = 0.0
  let mut minimum = @double.infinity
  let mut maximum = @double.neg_infinity
  for value in self.data {
    if value is Some(v) {
      count = count + 1
      let corrected = v - compensation
      let next = sum + corrected
      compensation = next - sum - corrected
      sum = next
      let delta = v - mean
      mean = mean + delta / count.to_double()
      m2 = m2 + delta * (v - mean)
      minimum = minimum.min(v)
      maximum = maximum.max(v)
      if !finite(sum) || !finite(mean) || !finite(m2) {
        raise InvalidData
      }
    }
  }
  if count == 0 {
    return None
  }
  Some({
    count,
    missing: self.grid.npix - count,
    sum,
    mean,
    variance: (m2 / count.to_double()).max(0.0),
    minimum,
    maximum,
  })
}
