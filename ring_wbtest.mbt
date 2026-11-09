///|
test "RING polar and equatorial base cells" {
  let g = Grid::new(1)
  assert_eq(g.lonlat_to_ring(LonLat::degrees(45.0, 60.0)), 0)
  assert_eq(g.lonlat_to_ring(LonLat::degrees(0.0, 0.0)), 4)
  assert_eq(g.lonlat_to_ring(LonLat::degrees(45.0, -60.0)), 8)
  let h = Grid::new(8192)
  for lat in [-90.0, -60.0, 0.0, 60.0, 90.0] {
    for lon in [0.0, 90.0, 180.0, 270.0, 359.99] {
      h.validate_pixel(h.lonlat_to_ring(LonLat::degrees(lon, lat)))
    }
  }
}
