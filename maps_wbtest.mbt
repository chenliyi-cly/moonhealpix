///|
test "scalar maps copy input, preserve missing values and compute statistics" {
  let g = Grid::new(1)
  let values : Array[Double?] = Array::make(12, None)
  values[0] = Some(2.0)
  values[1] = Some(4.0)
  let m = ScalarMap::new(g, Nested, values, 12)
  values[0] = Some(999.0)
  assert_eq(m.get(0), Some(2.0))
  let stats = m.summary().unwrap()
  assert_eq(stats.count(), 2)
  assert_eq(stats.missing(), 10)
  assert_eq(stats.sum(), 6.0)
  assert_eq(stats.mean(), 3.0)
  assert_eq(stats.variance(), 1.0)
  assert_eq(m.with_value(0, None).get(0), None)
  assert_eq(m.get(0), Some(2.0))
  assert_eq(ScalarMap::filled(g, Ring, None, 12).summary(), None)
  assert_true(
    try {
      ScalarMap::filled(Grid::new(8192), Ring, None, 1000) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      ScalarMap::filled(g, Ring, Some(@double.infinity), 12) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
