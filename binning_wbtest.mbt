///|
test "weighted observations aggregate with explicit missing and zero-weight semantics" {
  let p = LonLat::degrees(10.0, 0.0)
  let c = Catalog::new(Grid::new(2), [p, p, p, p], 4)
  let stats = c.bin_values(
    [Some(1.0), Some(3.0), None, Some(99.0)],
    [1.0, 3.0, 4.0, 0.0],
    48,
  )
  let pixel = c.grid().lonlat_to_nested(p)
  assert_eq(stats.counts().get(pixel), Some(2.0))
  assert_eq(stats.weights().get(pixel), Some(4.0))
  assert_eq(stats.sums().get(pixel), Some(10.0))
  assert_eq(stats.means().get(pixel), Some(2.5))
  assert_eq(stats.variances().get(pixel), Some(0.75))
  assert_eq(stats.means().summary().unwrap().count(), 1)
  assert_eq(stats.counts().summary().unwrap().sum(), 2.0)
  assert_true(
    try {
      c.bin_values([Some(1.0), None, None, None], [-1.0, 0.0, 0.0, 0.0], 48)
      |> ignore
      false
    } catch {
      _ => true
    },
  )
}
