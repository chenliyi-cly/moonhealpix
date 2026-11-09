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
