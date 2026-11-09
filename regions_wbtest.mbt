///|
test "wrapped boxes match exhaustive center membership" {
  let g = Grid::new(8)
  for
    region in [
      LonLatBox::degrees(350.0, 30.0, -30.0, 60.0),
      LonLatBox::degrees(0.0, 360.0, -90.0, 90.0),
      LonLatBox::degrees(0.0, 0.0, -90.0, 90.0),
    ] {
    let selection = g.query_box(region, 1000, 10000)
    for p = 0; p < g.npix(); p = p + 1 {
      assert_eq(selection.contains(p), region.contains(g.ring_center(p)))
    }
  }
  let half = LonLatBox::degrees(0.0, 180.0, -90.0, 90.0)
  assert_true(half.contains(LonLat::degrees(0.0, 0.0)))
  assert_true(!half.contains(LonLat::degrees(180.0, 0.0)))
  assert_true(
    try {
      LonLatBox::degrees(0.0, 361.0, -90.0, 90.0) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
