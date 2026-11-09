///|
fn modulo(a : Int32, b : Int32) -> Int32 {
  let r = a % b
  if r < 0 {
    r + b
  } else {
    r
  }
}

///|
pub fn Grid::lonlat_to_ring(self : Grid, point : LonLat) -> Int32 {
  let z = @math.sin(point.lat)
  let za = z.abs()
  let tt = point.lon * (2.0 / @math.PI)
  let n = self.nside
  let cap = 2 * n * (n - 1)
  if za <= 2.0 / 3.0 {
    let a = n.to_double() * (0.5 + tt)
    let b = n.to_double() * z * 0.75
    let jp = @math.floor(a - b).to_int()
    let jm = @math.floor(a + b).to_int()
    let ring = n + 1 + jp - jm
    let shift = 1 - (ring & 1)
    let pos = (jp + jm - n + shift + 1) / 2
    cap + (ring - 1) * 4 * n + modulo(pos, 4 * n)
  } else {
    let tp = tt - @math.floor(tt)
    let tmp = n.to_double() * (3.0 * (1.0 - za)).sqrt()
    let jp = @math.floor(tp * tmp).to_int()
    let jm = @math.floor((1.0 - tp) * tmp).to_int()
    let ring = jp + jm + 1
    let pos = @math.floor(tt * ring.to_double()).to_int().min(4 * ring - 1)
    if z > 0.0 {
      2 * ring * (ring - 1) + pos
    } else {
      self.npix - 2 * ring * (ring + 1) + pos
    }
  }
}

///|
/// A full latitude ring; start is its first RING pixel and count its length.
pub struct RingInfo {
  number : Int32
  start : Int32
  count : Int32
  latitude : Double
  first_longitude : Double
} derive(Eq, Debug)

///|
pub extend RingInfo with Eq::{equal, not_equal}

///|
pub extend RingInfo with @debug.Debug::{to_repr}

///|
pub fn Grid::ring_count(self : Grid) -> Int32 {
  4 * self.nside - 1
}

///|
pub fn Grid::ring_info(
  self : Grid,
  number : Int32,
) -> RingInfo raise HealpixError {
  let n = self.nside
  if number < 1 || number >= 4 * n {
    raise InvalidRange
  }
  let (start, count, z, first) = if number < n {
    let r = number.to_double()
    (
      2 * number * (number - 1),
      4 * number,
      1.0 - r * r / (3.0 * n.to_double() * n.to_double()),
      @math.PI / (4.0 * r),
    )
  } else if number <= 3 * n {
    let start = 2 * n * (n - 1) + (number - n) * 4 * n
    let first = if ((number + n) & 1) == 0 {
      @math.PI / (4.0 * n.to_double())
    } else {
      0.0
    }
    (
      start,
      4 * n,
      (2 * n - number).to_double() * 2.0 / (3.0 * n.to_double()),
      first,
    )
  } else {
    let r = 4 * n - number
    let rd = r.to_double()
    (
      self.npix - 2 * r * (r + 1),
      4 * r,
      -1.0 + rd * rd / (3.0 * n.to_double() * n.to_double()),
      @math.PI / (4.0 * rd),
    )
  }
  {
    number,
    start,
    count,
    latitude: @math.asin(clamp(z, -1.0, 1.0)),
    first_longitude: first,
  }
}

///|
pub fn RingInfo::number(self : RingInfo) -> Int32 {
  self.number
}

///|
pub fn RingInfo::start(self : RingInfo) -> Int32 {
  self.start
}

///|
pub fn RingInfo::count(self : RingInfo) -> Int32 {
  self.count
}

///|
pub fn RingInfo::latitude(self : RingInfo) -> Double {
  self.latitude
}

///|
pub fn RingInfo::first_longitude(self : RingInfo) -> Double {
  self.first_longitude
}

///|
pub fn RingInfo::longitude_step(self : RingInfo) -> Double {
  2.0 * @math.PI / self.count.to_double()
}

///|
pub fn Grid::pixel_ring(
  self : Grid,
  pixel : Int32,
) -> RingInfo raise HealpixError {
  self.validate_pixel(pixel)
  let n = self.nside
  let cap = 2 * n * (n - 1)
  let number = if pixel < cap {
    (0.5 * (1.0 + (1.0 + 2.0 * pixel.to_double()).sqrt())).to_int()
  } else if pixel >= self.npix - cap {
    4 * n -
    (0.5 * (1.0 + (1.0 + 2.0 * (self.npix - 1 - pixel).to_double()).sqrt())).to_int()
  } else {
    n + (pixel - cap) / (4 * n)
  }
  self.ring_info(number)
}

///|
pub fn Grid::ring_center(
  self : Grid,
  pixel : Int32,
) -> LonLat raise HealpixError {
  let r = self.pixel_ring(pixel)
  {
    lon: wrap_longitude(
      r.first_longitude + (pixel - r.start).to_double() * r.longitude_step(),
    ),
    lat: r.latitude,
  }
}
