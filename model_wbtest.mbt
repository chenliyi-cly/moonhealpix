///|
test "resolution validation and exact size" {
  let g = Grid::new(8)
  assert_eq(g.npix(), 768)
  assert_eq(g.level(), 3)
  assert_true((g.pixel_area() * 768.0 - 4.0 * @math.PI).abs() < 1.0e-12)
  for n in [0, -1, 3, 8193, 16384] {
    let rejected = try {
      Grid::new(n) |> ignore
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
  assert_eq(Grid::from_level(13).npix(), 805306368)
  assert_true(
    try {
      Grid::from_level(14) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      g.validate_pixel(768)
      false
    } catch {
      _ => true
    },
  )
}
