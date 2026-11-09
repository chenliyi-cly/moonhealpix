///|
test "range algebra agrees with membership truth tables" {
  let g = Grid::new(4)
  let a = PixelSet::new(g, Nested, [
    PixelRange::new(g, 4, 10),
    PixelRange::new(g, 2, 5),
    PixelRange::new(g, 20, 20),
  ])
  let b = PixelSet::new(g, Nested, [PixelRange::new(g, 7, 14)])
  assert_eq(a.count(), 8)
  let u = a.union(b)
  let i = a.intersection(b)
  let d = a.difference(b)
  let c = a.complement()
  for p = -1; p <= g.npix(); p = p + 1 {
    assert_eq(u.contains(p), a.contains(p) || b.contains(p))
    assert_eq(i.contains(p), a.contains(p) && b.contains(p))
    assert_eq(d.contains(p), a.contains(p) && !b.contains(p))
    if p >= 0 && p < g.npix() {
      assert_eq(c.contains(p), !a.contains(p))
    }
  }
  assert_true(
    try {
      a.pixels(7) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_eq(a.pixels(8).length(), 8)
  assert_true(
    try {
      a.union(PixelSet::new(g, Ring, [])) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
