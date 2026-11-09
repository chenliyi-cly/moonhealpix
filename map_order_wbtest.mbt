///|
test "map reorder is a permutation including missing samples" {
  let g = Grid::new(8)
  let values : Array[Double?] = Array::make(g.npix(), None)
  for p = 0; p < g.npix(); p = p + 1 {
    if p % 3 != 0 {
      values[p] = Some(p.to_double())
    }
  }
  let m = ScalarMap::new(g, Nested, values, 1000)
  let r = m.reorder(Ring)
  assert_eq(r.reorder(Nested).values(), values)
  for p = 0; p < g.npix(); p = p + 1 {
    assert_eq(r.sample(g.nested_center(p)), m.get(p))
  }
  let selection = PixelSet::new(g, Nested, [PixelRange::new(g, 10, 20)])
  assert_eq(m.masked(selection).summary().unwrap().count(), 7)
  let filled = m.coalesce(ScalarMap::filled(g, Nested, Some(-1.0), 1000))
  assert_eq(filled.get(0), Some(-1.0))
  assert_eq(filled.get(1), Some(1.0))
}
