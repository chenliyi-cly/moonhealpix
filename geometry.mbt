///|
/// Position within one NESTED pixel; (0,0) and (1,1) are opposite corners.
/// Coordinates describe the HEALPix curved face projection, not flat edges.
pub fn Grid::pixel_position(
  self : Grid,
  pixel : Int32,
  dx : Double,
  dy : Double,
) -> LonLat raise HealpixError {
  if !finite(dx) || !finite(dy) || dx < 0.0 || dx > 1.0 || dy < 0.0 || dy > 1.0 {
    raise InvalidAngle
  }
  let c = self.pixel_face(pixel)
  face_lonlat(self, c.face, c.x.to_double() + dx, c.y.to_double() + dy)
}

///|
/// Samples the four curved edges, counterclockwise in face coordinates.
/// Returns 4*steps points, each corner once; the caller may close the polyline.
/// This is geometry for display, not an exact spherical polygon intersection.
pub fn Cell::boundary(
  self : Cell,
  steps : Int32,
  max_points : Int32,
) -> Array[LonLat] raise HealpixError {
  if steps < 1 || steps > 4096 {
    raise InvalidRange
  }
  if max_points < 0 || steps > max_points / 4 {
    raise ResourceLimit
  }
  let out : Array[LonLat] = []
  let n = steps.to_double()
  for edge = 0; edge < 4; edge = edge + 1 {
    for k = 0; k < steps; k = k + 1 {
      let t = k.to_double() / n
      let (x, y) = match edge {
        0 => (t, 0.0)
        1 => (1.0, t)
        2 => (1.0 - t, 1.0)
        _ => (0.0, 1.0 - t)
      }
      out.push(self.grid.pixel_position(self.pixel, x, y))
    }
  }
  out
}
