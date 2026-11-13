///|
test "wide convex triangle uses a separating hemisphere, not vertex mean" {
  let vertices = [
    LonLat::degrees(-80.0, 0.0),
    LonLat::degrees(80.0, 0.0),
    LonLat::degrees(-79.0, 1.0),
  ]
  let polygon = SphericalPolygon::new(vertices, 3)
  for v in vertices {
    assert_true(polygon.contains(v))
  }
  assert_true(polygon.contains(LonLat::degrees(0.0, 0.2)))
  let reverse = SphericalPolygon::new(
    [vertices[2], vertices[1], vertices[0]],
    3,
  )
  let g = Grid::new(8)
  assert_eq(
    g.query_polygon(polygon, g.npix(), 100000).pixels(g.npix()),
    g.query_polygon(reverse, g.npix(), 100000).pixels(g.npix()),
  )
}

///|
test "non adjacent repeated vertices reject multiple polygon winding" {
  let a = LonLat::degrees(-10.0, -10.0)
  let b = LonLat::degrees(10.0, -10.0)
  let c = LonLat::degrees(0.0, 10.0)
  assert_true(
    try {
      SphericalPolygon::new([a, b, c, a, b, c], 6) |> ignore
      false
    } catch {
      InvalidData => true
      _ => false
    },
  )
}

///|
test "construction and containment share normalized halfspace tolerance" {
  let vertices = [
    LonLat::degrees(0.0, 0.0),
    LonLat::degrees(5.0, 1.0e-11),
    LonLat::degrees(10.0, 0.0),
    LonLat::degrees(0.0, 10.0),
  ]
  assert_true(
    try {
      SphericalPolygon::new(vertices, 4) |> ignore
      false
    } catch {
      InvalidData => true
      _ => false
    },
  )
  let near_edge = [
    LonLat::degrees(0.0, 0.0),
    LonLat::degrees(5.0, 1.0e-14),
    LonLat::degrees(10.0, 0.0),
    LonLat::degrees(0.0, 10.0),
  ]
  let accepted = SphericalPolygon::new(near_edge, 4)
  for v in near_edge {
    assert_true(accepted.contains(v))
  }
}
