///|
test "disc queries match brute force at seam poles and large radius" {
  for n in [1, 2, 4, 8] {
    let g = Grid::new(n)
    for
      center in [
        LonLat::degrees(359.9, 0.0),
        LonLat::degrees(35.0, 90.0),
        LonLat::degrees(120.0, -70.0),
      ] {
      for radius in [0.0, 0.01, 0.4, 1.7, @math.PI] {
        let set = g.query_disc(center, radius, 1000, 10000)
        for p = 0; p < g.npix(); p = p + 1 {
          assert_eq(
            set.contains(p),
            center.separation(g.ring_center(p)) <= radius,
          )
        }
      }
    }
  }
  let g = Grid::new(8)
  assert_true(
    try {
      g.query_disc(LonLat::degrees(0.0, 0.0), 1.0, 1000, 0) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      g.query_disc(LonLat::degrees(0.0, 0.0), @math.PI, 1, 0) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
