///|
test "RING partitions sphere and centers round trip" {
  for n in [1, 2, 4, 8, 16, 32] {
    let g = Grid::new(n)
    let mut end = 0
    for r = 1; r <= g.ring_count(); r = r + 1 {
      let info = g.ring_info(r)
      assert_eq(info.start(), end)
      end = end + info.count()
    }
    assert_eq(end, g.npix())
    for p = 0; p < g.npix(); p = p + 1 {
      assert_eq(g.lonlat_to_ring(g.ring_center(p)), p)
    }
  }
  let g = Grid::new(8192)
  for p in [0, 3, 4, 134201344, 134217727, 402653184, 671088639, 805306367] {
    assert_eq(g.lonlat_to_ring(g.ring_center(p)), p)
  }
}
