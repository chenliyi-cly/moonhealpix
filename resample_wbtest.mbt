///|
test "resolution changes preserve intensive fields and integrated sums" {
  let g = Grid::new(4)
  let m = ScalarMap::filled(g, Ring, Some(8.0), 1000).with_value(
    g.nested_to_ring(0),
    None,
  )
  let low = m.resample(Grid::new(1), Mean, 100)
  assert_eq(low.get(0), Some(8.0))
  let high = low.resample(g, Mean, 1000)
  assert_eq(high.get(0), Some(8.0))
  let sums = m.resample(Grid::new(1), Sum, 100)
  assert_true(
    (sums.summary().unwrap().sum() - m.summary().unwrap().sum()).abs() < 1.0e-12,
  )
  let expanded = sums.resample(g, Sum, 1000)
  assert_true(
    (expanded.summary().unwrap().sum() - sums.summary().unwrap().sum()).abs() <
    1.0e-12,
  )
  assert_eq(
    ScalarMap::filled(g, Nested, None, 1000)
    .resample(Grid::new(1), Mean, 12)
    .get(0),
    None,
  )
  assert_true(
    try {
      low.resample(Grid::new(8192), Mean, 1000) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
