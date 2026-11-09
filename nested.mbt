///|
/// HEALPix NESTED angular indexing. At shared edges the standard floor-based
/// ownership rule applies; longitude is in [0, 2*pi).
pub fn Grid::lonlat_to_nested(
  self : Grid,
  point : LonLat,
) -> Int32 raise HealpixError {
  let z = @math.sin(point.lat)
  let za = z.abs()
  let tt = point.lon * (2.0 / @math.PI)
  let n = self.nside
  let (face, x, y) = if za <= 2.0 / 3.0 {
    let a = n.to_double() * (0.5 + tt)
    let b = n.to_double() * (0.75 * z)
    let jp = @math.floor(a - b).to_int()
    let jm = @math.floor(a + b).to_int()
    let fp = jp / n
    let fm = jm / n
    let f = if fp == fm { fp | 4 } else if fp < fm { fp } else { fm + 8 }
    (f, jm % n, n - jp % n - 1)
  } else {
    let sector = @math.floor(tt).to_int().min(3)
    let tp = tt - sector.to_double()
    let tmp = n.to_double() * (3.0 * (1.0 - za)).sqrt()
    let jp = @math.floor(tp * tmp).to_int().min(n - 1)
    let jm = @math.floor((1.0 - tp) * tmp).to_int().min(n - 1)
    if z >= 0.0 {
      (sector, n - jm - 1, n - jp - 1)
    } else {
      (sector + 8, jp, jm)
    }
  }
  self.face_pixel(FaceXY::new(self, face, x, y))
}

///|
pub fn Grid::vector_to_nested(
  self : Grid,
  vector : Vector,
) -> Int32 raise HealpixError {
  self.lonlat_to_nested(vector.lonlat())
}

///|
/// Continuous HEALPix face projection; coordinates run from 0 to nside.
fn face_lonlat(grid : Grid, face : Int32, x : Double, y : Double) -> LonLat {
  let jrll = [2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4]
  let jpll = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7]
  let n = grid.nside.to_double()
  let jr = jrll[face].to_double() * n - x - y
  let (nr, z) = if jr < n {
    (jr, 1.0 - jr * jr / (3.0 * n * n))
  } else if jr > 3.0 * n {
    let r = 4.0 * n - jr
    (r, -1.0 + r * r / (3.0 * n * n))
  } else {
    (n, (2.0 * n - jr) * (2.0 / (3.0 * n)))
  }
  let lon = if nr <= 0.0 {
    jpll[face].to_double() * @math.PI / 4.0
  } else {
    (jpll[face].to_double() * nr + x - y) * @math.PI / (4.0 * nr)
  }
  { lon: wrap_longitude(lon), lat: @math.asin(clamp(z, -1.0, 1.0)), }
}

///|
pub fn Grid::nested_center(
  self : Grid,
  pixel : Int32,
) -> LonLat raise HealpixError {
  let c = self.pixel_face(pixel)
  face_lonlat(self, c.face, c.x.to_double() + 0.5, c.y.to_double() + 0.5)
}
