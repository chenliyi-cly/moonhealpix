///|
fn main {
  try {
    let grid = @hp.Grid::new(16)
    let limits = @hp.MocLimits::default()
    let polygon = @hp.SphericalPolygon::new(
      [
        @hp.LonLat::degrees(350.0, -10.0),
        @hp.LonLat::degrees(15.0, -10.0),
        @hp.LonLat::degrees(15.0, 12.0),
        @hp.LonLat::degrees(350.0, 12.0),
      ],
      16,
    )
    let cover = grid.cover_polygon(polygon, 3, grid.npix(), 200000)
    let moc = @hp.Moc::from_pixel_set(cover.pixels(), grid.level(), limits)
    let ascii = moc.to_ascii(limits)
    let json = moc.to_json(limits)
    assert_true(@hp.Moc::from_ascii(ascii, limits).equals(moc))
    assert_true(@hp.Moc::from_json(json, limits).equals(moc))
    let center = @hp.LonLat::degrees(0.0, 0.0)
    let neighbours = grid.neighbours(grid.index(center, @hp.Nested), @hp.Nested)
    assert_eq(neighbours.length(), 8)
    let constant = @hp.ScalarMap::new(
      grid,
      @hp.Nested,
      Array::make(grid.npix(), Some(2.0)),
      grid.npix(),
    )
    assert_true(
      (constant.interpolate_bilinear(center).unwrap() - 2.0).abs() < 1.0e-12,
    )
    let fine = @hp.Grid::new(8192)
    let fine_query = fine.search_disc(
      fine.nested_center(268435456),
      0.0,
      10,
      1500,
    )
    assert_eq(fine_query.pixels().pixels(10), [268435456])
    let points : Array[@hp.LonLat] = []
    for i = 0; i < 12000; i = i + 1 {
      points.push(
        @hp.LonLat::new(
          i.to_double() * 2.399963229728653,
          @math.asin(1.0 - 2.0 * (i.to_double() + 0.5) / 12000.0),
        ),
      )
    }
    let catalog = @hp.Catalog::new(@hp.Grid::new(64), points, 12000)
    let found = catalog.search_cone(points[6000], 0.02, 100, 1000)
    let ids = found.hits().map(h => h.index())
    for i = 0; i < points.length(); i = i + 1 {
      assert_eq(ids.contains(i), points[6000].separation(points[i]) <= 0.02)
    }
    println("spatial: neighbour_slots=\{neighbours.length()}, interpolated=2")
    println(
      "polygon: candidates=\{cover.pixels().count()}, interior=\{cover.interior().count()}, unresolved=\{cover.boundary().count()}, visited=\{cover.visited()}",
    )
    println("MOC ASCII: \{ascii}")
    println("MOC JSON: \{json}")
    println(
      "nside8192: exact center query visited=\{fine_query.visited()} of \{fine.npix()} pixels",
    )
    println(
      "catalog: sources=12000, hits=\{ids.length()}, visited_nodes=\{found.visited_nodes()}, tested_sources=\{found.tested_sources()}, brute_force_match=true",
    )
  } catch {
    error => abort("spatial example failed: \{error}")
  }
}
