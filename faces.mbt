///|
/// One of twelve base faces and integer coordinates within that face.
pub struct FaceXY {
  face : Int32
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend FaceXY with Eq::{equal, not_equal}

///|
pub extend FaceXY with @debug.Debug::{to_repr}

///|
pub fn FaceXY::new(
  grid : Grid,
  face : Int32,
  x : Int32,
  y : Int32,
) -> FaceXY raise HealpixError {
  if face < 0 ||
    face >= 12 ||
    x < 0 ||
    x >= grid.nside ||
    y < 0 ||
    y >= grid.nside {
    raise InvalidFace
  }
  { face, x, y, }
}

///|
pub fn FaceXY::components(self : FaceXY) -> (Int32, Int32, Int32) {
  (self.face, self.x, self.y)
}

///|
fn spread(v : Int32, level : Int32) -> Int32 {
  let mut out = 0
  for bit = 0; bit < level; bit = bit + 1 {
    out = out | (((v >> bit) & 1) << (2 * bit))
  }
  out
}

///|
fn compact(v : Int32, level : Int32) -> Int32 {
  let mut out = 0
  for bit = 0; bit < level; bit = bit + 1 {
    out = out | (((v >> (2 * bit)) & 1) << bit)
  }
  out
}

///|
pub fn Grid::face_pixel(
  self : Grid,
  coordinate : FaceXY,
) -> Int32 raise HealpixError {
  let c = FaceXY::new(self, coordinate.face, coordinate.x, coordinate.y)
  c.face * self.nside * self.nside +
  spread(c.x, self.level) +
  (spread(c.y, self.level) << 1)
}

///|
pub fn Grid::pixel_face(
  self : Grid,
  pixel : Int32,
) -> FaceXY raise HealpixError {
  self.validate_pixel(pixel)
  let area = self.nside * self.nside
  let p = pixel % area
  {
    face: pixel / area,
    x: compact(p, self.level),
    y: compact(p >> 1, self.level),
  }
}
