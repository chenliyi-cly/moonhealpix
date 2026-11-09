///|
test "ordering permutations are exact at every small-grid pixel" {
  for n in [1, 2, 4, 8, 16, 32] {
    let g = Grid::new(n)
    for p = 0; p < g.npix(); p = p + 1 {
      let r = g.nested_to_ring(p)
      assert_eq(g.ring_to_nested(r), p)
      assert_true(g.nested_center(p).separation(g.ring_center(r)) < 1.0e-12)
    }
  }
  let g = Grid::new(8192)
  for p in [0, 1, 67108863, 134217727, 402653184, 805306367] {
    assert_eq(g.ring_to_nested(g.nested_to_ring(p)), p)
  }
}
