///|
/// A closed convex minor-arc polygon contained in an open hemisphere.
/// Vertex winding may be either direction. Non-convex, duplicate and antipodal
/// edges are rejected instead of silently reinterpreted as a different region.
pub struct SphericalPolygon {
  vertices : Array[Vector]
  normals : Array[Vector]
}

///|
fn cross_unit(a : Vector, b : Vector) -> Vector raise HealpixError {
  Vector::new(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  )
}

///|
pub fn SphericalPolygon::new(
  vertices : Array[LonLat],
  max_vertices : Int32,
) -> SphericalPolygon raise HealpixError {
  if max_vertices < 0 || vertices.length() > max_vertices {
    raise ResourceLimit
  }
  if vertices.length() < 3 || vertices.length() > 4096 {
    raise InvalidData
  }
  let vs = vertices.map(p => p.vector())
  let mut sx = 0.0
  let mut sy = 0.0
  let mut sz = 0.0
  for v in vs {
    sx = sx + v.x
    sy = sy + v.y
    sz = sz + v.z
  }
  let middle = Vector::new(sx, sy, sz)
  // Non-adjacent repeats also encode a duplicate winding. Antipodal pairs
  // cannot lie in an open hemisphere, irrespective of their edge positions.
  for i = 0; i < vs.length(); i = i + 1 {
    for j = i + 1; j < vs.length(); j = j + 1 {
      let d = vs[i].separation(vs[j])
      if d < 1.0e-12 || d > @math.PI - 1.0e-12 {
        raise InvalidData
      }
    }
  }
  let normals : Array[Vector] = []
  let mut winding = 0
  for i = 0; i < vs.length(); i = i + 1 {
    let a = vs[i]
    let b = vs[(i + 1) % vs.length()]
    let length = a.separation(b)
    if length < 1.0e-12 || length > @math.PI - 1.0e-12 {
      raise InvalidData
    }
    let n = cross_unit(a, b)
    let side = n.dot(middle)
    if side.abs() <= 1.0e-14 {
      raise InvalidData
    }
    let sign = if side > 0.0 { 1 } else { -1 }
    if winding != 0 && sign != winding {
      raise InvalidData
    }
    winding = sign
    let inward = if sign > 0 { n } else { Vector::new(-n.x, -n.y, -n.z) }
    for v in vs {
      if inward.dot(v) < -1.0e-14 {
        raise InvalidData
      }
    }
    normals.push(inward)
  }
  // The vertex average is an interior direction, but need not be a
  // hemisphere pole (e.g. a long, thin triangle). Inward edge normals have
  // nonnegative dot products with every vertex. Their sum gives a strict
  // separating hemisphere for the nondegenerate convex polygon.
  let mut nx = 0.0
  let mut ny = 0.0
  let mut nz = 0.0
  for n in normals {
    nx = nx + n.x
    ny = ny + n.y
    nz = nz + n.z
  }
  let pole = Vector::new(nx, ny, nz)
  for v in vs {
    if pole.dot(v) <= 1.0e-14 {
      raise InvalidData
    }
  }
  { vertices: vs, normals, }
}

///|
pub fn SphericalPolygon::vertices(self : SphericalPolygon) -> Array[LonLat] {
  self.vertices.map(v => v.lonlat())
}

///|
/// Closed halfspaces, with 1e-14 unit-vector roundoff allowance at edges.
pub fn SphericalPolygon::contains(
  self : SphericalPolygon,
  point : LonLat,
) -> Bool {
  let v = point.vector()
  self.normals.all(n => n.dot(v) >= -1.0e-14)
}

///|
/// Center queries use exact great-circle halfspaces, not a flat lon/lat box.
/// Returns NESTED intervals; max_work includes each visited hierarchy node.
pub fn Grid::query_polygon(
  self : Grid,
  polygon : SphericalPolygon,
  max_pixels : Int32,
  max_work : Int32,
) -> PixelSet raise HealpixError {
  region_centers(self, PolygonRegion(polygon), max_pixels, max_work).pixels
}
