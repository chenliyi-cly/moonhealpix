///|
test "nested pixel centers map back exhaustively" {
  for n in [1, 2, 4, 8, 16, 32] {
    let g = Grid::new(n)
    for p = 0; p < g.npix(); p = p + 1 {
      assert_eq(g.lonlat_to_nested(g.nested_center(p)), p)
    }
  }
  let g = Grid::new(8192)
  for p in [0, 1, 67108863, 335544320, 805306367] {
    assert_eq(g.lonlat_to_nested(g.nested_center(p)), p)
  }
}
