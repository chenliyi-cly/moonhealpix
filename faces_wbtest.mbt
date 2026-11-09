///|
test "Morton coordinates are a bijection on all faces" {
  for level = 0; level <= 4; level = level + 1 {
    let g = Grid::from_level(level)
    for p = 0; p < g.npix(); p = p + 1 {
      assert_eq(g.face_pixel(g.pixel_face(p)), p)
    }
  }
  assert_true(
    try {
      FaceXY::new(Grid::new(2), 12, 0, 0) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
