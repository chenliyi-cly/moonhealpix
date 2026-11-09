///|
test "compact cover exactly expands, preserves face boundaries and enforces budgets" {
  let g = Grid::new(8)
  let all = PixelSet::new(g, Nested, [PixelRange::new(g, 0, g.npix())])
  let cells = all.compact_cells(12)
  assert_eq(cells.length(), 12)
  assert_eq(g.cover_cells(cells, 12).count(), g.npix())
  let a = PixelSet::new(g, Nested, [
    PixelRange::new(g, 3, 109),
    PixelRange::new(g, 180, 320),
  ])
  let b = g.cover_cells(a.compact_cells(100), 100)
  assert_eq(a.pixels(1000), b.pixels(1000))
  assert_eq(
    a.reorder(Ring, 1000).reorder(Nested, 1000).pixels(1000),
    a.pixels(1000),
  )
  assert_eq(all.at_level(0).count(), 12)
  assert_eq(all.at_level(0).at_level(3).count(), g.npix())
  assert_true(
    try {
      a.at_level(0) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      all.compact_cells(11) |> ignore
      false
    } catch {
      _ => true
    },
  )
}
