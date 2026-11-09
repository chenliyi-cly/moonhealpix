///|
fn main {
  try {
    let grid = @hp.Grid::new(4)
    let points = [
      @hp.LonLat::degrees(10.0, 10.0),
      @hp.LonLat::degrees(10.0, 10.0),
      @hp.LonLat::degrees(180.0, -30.0),
    ]
    let catalog = @hp.Catalog::new(grid, points, 100)
    let stats = catalog.bin_values(
      [Some(10.0), Some(14.0), Some(20.0)],
      [1.0, 3.0, 2.0],
      1000,
    )
    let pixel = grid.lonlat_to_nested(points[0])
    assert_eq(stats.means().get(pixel), Some(13.0))
    let totals = stats.sums().resample(@hp.Grid::new(1), @hp.Sum, 100)
    assert_eq(totals.summary().unwrap().sum(), 92.0)
    println("observations: weighted mean=13, weighted sum=92")
    let region = @hp.LonLatBox::degrees(0.0, 90.0, -90.0, 90.0)
    let selected = grid.query_box(region, 1000, 10000).reorder(@hp.Nested, 1000)
    let regional = stats.means().masked(selected)
    println("regional observed pixels=\{regional.summary().unwrap().count()}")
  } catch {
    error => abort("observations example failed: \{error}")
  }
}
