///|
test "NUNIQ and hierarchy preserve exact integer identities" {
  for level = 0; level <= 13; level = level + 1 {
    let g = Grid::from_level(level)
    for p in [0, g.npix() / 2, g.npix() - 1] {
      let c = Cell::new(g, p)
      assert_eq(Cell::from_uniq(c.uniq()), c)
      let root = c.parent(0)
      assert_true(root.contains(c))
      let r = root.descendant_range(level)
      assert_true(p >= r.start() && p < r.end())
    }
  }
  let root = Cell::new(Grid::new(1), 11)
  let children = root.children(2, 16)
  assert_eq(children.length(), 16)
  for child in children {
    assert_eq(child.parent(0), root)
  }
  assert_true(
    try {
      root.children(13, 1000) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      Cell::from_uniq(3) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_eq(Cell::from_uniq(1073741823).grid().nside(), 8192)
}
