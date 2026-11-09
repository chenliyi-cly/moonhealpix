///|
test "catalog cones equal source brute force, including near pixel edges" {
  let points : Array[LonLat] = []
  for lat = -85; lat <= 85; lat = lat + 10 {
    for lon = 0; lon < 360; lon = lon + 11 {
      points.push(LonLat::degrees(lon.to_double() + 0.1, lat.to_double()))
    }
  }
  for n in [1, 8, 64] {
    let c = Catalog::new(Grid::new(n), points, 1000)
    for
      center in [
        points[0],
        LonLat::degrees(359.9, 0.0),
        LonLat::degrees(90.0, 89.0),
      ] {
      for radius in [0.0, 0.15, 1.0, @math.PI] {
        let hits = c.query_cone(center, radius, 1000, 3000)
        let ids = hits.map(h => h.index())
        for i = 0; i < points.length(); i = i + 1 {
          assert_eq(ids.contains(i), center.separation(points[i]) <= radius)
        }
      }
    }
    assert_eq(
      c.count_map(50000).summary().unwrap().sum(),
      points.length().to_double(),
    )
    let p = c.grid().lonlat_to_nested(points[0])
    assert_true(c.pixel_sources(p, 1000).contains(0))
  }
}
