///|
fn main {
  try {
    let grid = @hp.Grid::new(4)
    let data : Array[Double?] = []
    for pixel = 0; pixel < grid.npix(); pixel = pixel + 1 {
      data.push(Some(2.0 + @math.sin(grid.nested_center(pixel).latitude())))
    }
    let field = @hp.ScalarMap::new(grid, @hp.Nested, data, 1000)
    let coarse = field.resample(@hp.Grid::new(2), @hp.Mean, 1000)
    let display = coarse.resample(grid, @hp.Mean, 1000).reorder(@hp.Ring)
    assert_true((display.summary().unwrap().mean() - 2.0).abs() < 1.0e-12)
    let disc = grid.query_disc(
      @hp.LonLat::degrees(45.0, 45.0),
      0.4,
      1000,
      10000,
    )
    let cells = disc.reorder(@hp.Nested, 1000).compact_cells(1000)
    let boundary = @hp.Cell::new(grid, 0).boundary(8, 32)
    assert_eq(boundary.length(), 32)
    println(
      "simulation: mean=2, selected_centers=\{disc.count()}, compact_cells=\{cells.length()}, boundary_points=\{boundary.length()}",
    )
  } catch {
    error => abort("simulation example failed: \{error}")
  }
}
