///|
test "face geometry is continuous and boundary sampling is bounded" {
  for n in [1, 2, 8, 8192] {
    let g = Grid::new(n)
    for p in [0, g.npix() / 2, g.npix() - 1] {
      let center = g.pixel_position(p, 0.5, 0.5)
      assert_true(center.separation(g.nested_center(p)) < 1.0e-14)
      let points = Cell::new(g, p).boundary(8, 32)
      assert_eq(points.length(), 32)
      for point in points {
        assert_true(finite(point.longitude()) && finite(point.latitude()))
        assert_true(point.latitude().abs() <= @math.PI / 2.0)
      }
    }
  }
  let c = Cell::new(Grid::new(1), 0)
  assert_true(
    try {
      c.boundary(4097, 20000) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      c.boundary(8, 31) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
