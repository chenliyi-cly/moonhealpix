// Acceptance tests use analytic geometry, exact integer endpoints, conservation
// laws and public workflows. They deliberately do not duplicate the oracle or
// enumerate small-grid index/center round trips. Failing regressions assert the
// required behavior (they do not bless the observed defect).

///|
fn acceptance_expect_error(
  action : () -> Unit raise HealpixError,
  expected : HealpixError,
) -> Unit raise {
  let actual = try {
    action()
    None
  } catch {
    error => Some(error)
  }
  assert_eq(actual, Some(expected))
}

///|
test "acceptance regression disc includes its own polar pixel center" {
  let grid = Grid::new(8192)
  for pixel in [0, 4, 12, 24, 40, 60, 84, 112, 144, 180, 805306367, 805306363] {
    let center = grid.ring_center(pixel)
    let selected = grid.query_disc(center, 0.0, 1, 40000)
    assert_eq(selected.pixels(1), [pixel])
  }
}

///|
test "acceptance regression catalog zero cone identifies the same north pole" {
  let source = LonLat::degrees(180.0, 90.0)
  let center = LonLat::degrees(0.0, 90.0)
  let catalog = Catalog::new(Grid::new(8192), [source], 1)
  assert_eq(catalog.query_cone(center, 0.0, 1, 2).map(hit => hit.index()), [0])
}

///|
test "acceptance regression binning rejects final variance overflow" {
  let point = LonLat::degrees(0.0, 0.0)
  let catalog = Catalog::new(Grid::new(1), [point, point], 2)
  // Population variance is 1e310. Each input, weighted sum and M2 is finite.
  // The result must raise InvalidData instead of creating an infinite map.
  acceptance_expect_error(
    () => {
      catalog.bin_values(
        [Some(1.0e155), Some(-1.0e155)],
        [1.0e-100, 1.0e-100],
        12,
      )
      |> ignore
    },
    InvalidData,
  )
}
