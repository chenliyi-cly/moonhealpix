///|
/// Radians; longitude is canonicalized to [0, 2*pi), latitude to [-pi/2, pi/2].
pub struct LonLat {
  lon : Double
  lat : Double
} derive(Eq, Debug)

///|
pub extend LonLat with Eq::{equal, not_equal}

///|
pub extend LonLat with @debug.Debug::{to_repr}

///|
/// Unit Cartesian vector. Construction rejects zero and nonfinite input.
pub struct Vector {
  x : Double
  y : Double
  z : Double
} derive(Eq, Debug)

///|
pub extend Vector with Eq::{equal, not_equal}

///|
pub extend Vector with @debug.Debug::{to_repr}

///|
fn finite(x : Double) -> Bool {
  x == x && x != @double.infinity && x != @double.neg_infinity
}

///|
fn clamp(x : Double, lo : Double, hi : Double) -> Double {
  if x < lo {
    lo
  } else if x > hi {
    hi
  } else {
    x
  }
}

///|
fn wrap_longitude(lon : Double) -> Double {
  let period = 2.0 * @math.PI
  let r = lon % period
  if r < 0.0 {
    r + period
  } else if r >= period {
    0.0
  } else {
    r
  }
}

///|
pub fn LonLat::new(lon : Double, lat : Double) -> LonLat raise HealpixError {
  if !finite(lon) || !finite(lat) || lat.abs() > @math.PI / 2.0 {
    raise InvalidAngle
  }
  { lon: wrap_longitude(lon), lat, }
}

///|
pub fn LonLat::degrees(lon : Double, lat : Double) -> LonLat raise HealpixError {
  if !finite(lon) || !finite(lat) || lat.abs() > 90.0 {
    raise InvalidAngle
  }
  LonLat::new(lon % 360.0 * @math.PI / 180.0, lat * @math.PI / 180.0)
}

///|
pub fn LonLat::longitude(self : LonLat) -> Double {
  self.lon
}

///|
pub fn LonLat::latitude(self : LonLat) -> Double {
  self.lat
}

///|
pub fn LonLat::longitude_degrees(self : LonLat) -> Double {
  self.lon * 180.0 / @math.PI
}

///|
pub fn LonLat::latitude_degrees(self : LonLat) -> Double {
  self.lat * 180.0 / @math.PI
}

///|
pub fn LonLat::vector(self : LonLat) -> Vector {
  let c = @math.cos(self.lat)
  {
    x: c * @math.cos(self.lon),
    y: c * @math.sin(self.lon),
    z: @math.sin(self.lat),
  }
}

///|
pub fn Vector::new(
  x : Double,
  y : Double,
  z : Double,
) -> Vector raise HealpixError {
  if !finite(x) || !finite(y) || !finite(z) {
    raise InvalidVector
  }
  let scale = x.abs().max(y.abs()).max(z.abs())
  if scale == 0.0 {
    raise InvalidVector
  }
  let a = x / scale
  let b = y / scale
  let c = z / scale
  let norm = (a * a + b * b + c * c).sqrt()
  { x: a / norm, y: b / norm, z: c / norm, }
}

///|
pub fn Vector::components(self : Vector) -> (Double, Double, Double) {
  (self.x, self.y, self.z)
}

///|
pub fn Vector::lonlat(self : Vector) -> LonLat {
  {
    lon: wrap_longitude(@math.atan2(self.y, self.x)),
    lat: @math.atan2(self.z, @math.hypot(self.x, self.y)),
  }
}

///|
pub fn Vector::dot(self : Vector, other : Vector) -> Double {
  clamp(self.x * other.x + self.y * other.y + self.z * other.z, -1.0, 1.0)
}

///|
/// atan2(cross length, dot) remains stable for small and antipodal angles.
pub fn Vector::separation(self : Vector, other : Vector) -> Double {
  let x = self.y * other.z - self.z * other.y
  let y = self.z * other.x - self.x * other.z
  let z = self.x * other.y - self.y * other.x
  @math.atan2((x * x + y * y + z * z).sqrt(), self.dot(other))
}

///|
pub fn LonLat::separation(self : LonLat, other : LonLat) -> Double {
  self.vector().separation(other.vector())
}
