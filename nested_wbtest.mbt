///|
test "nested base cells and polar ownership" {
  let g = Grid::new(1)
  assert_eq(g.lonlat_to_nested(LonLat::degrees(45.0, 60.0)), 0)
  assert_eq(g.lonlat_to_nested(LonLat::degrees(0.0, 0.0)), 4)
  assert_eq(g.lonlat_to_nested(LonLat::degrees(45.0, -60.0)), 8)
  for lat in [-90.0, -80.0, -10.0, 0.0, 10.0, 80.0, 90.0] {
    for lon in [0.0, 45.0, 90.0, 180.0, 270.0, 359.99] {
      let p = LonLat::degrees(lon, lat)
      let h = Grid::new(8192)
      h.validate_pixel(h.lonlat_to_nested(p))
    }
  }
}
