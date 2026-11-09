///|
fn main {
  try {
    let grid = @hp.Grid::new(8)
    let sources = [
      @hp.LonLat::degrees(359.8, 0.1),
      @hp.LonLat::degrees(0.2, -0.1),
      @hp.LonLat::degrees(120.0, 30.0),
    ]
    let catalog = @hp.Catalog::new(grid, sources, 100)
    let hits = catalog.query_cone(
      @hp.LonLat::degrees(0.0, 0.0),
      1.0 * @math.PI / 180.0,
      100,
      1000,
    )
    assert_eq(hits.length(), 2)
    assert_eq(catalog.count_map(1000).summary().unwrap().sum(), 3.0)
    for hit in hits {
      println("source=\{hit.index()} separation_rad=\{hit.distance()}")
    }
    let nested = grid.lonlat_to_nested(sources[0])
    let ring = grid.nested_to_ring(nested)
    assert_eq(grid.ring_to_nested(ring), nested)
    println(
      "catalog: 3 sources, 2 cone matches; nested=\{nested}, ring=\{ring}",
    )
  } catch {
    error => abort("catalog example failed: \{error}")
  }
}
