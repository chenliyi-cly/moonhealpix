// SPDX-License-Identifier: BSD-3-Clause

///|
test "neighbours sentinel counts, validity, distinctness and reciprocity" {
  for n in [1, 2, 4, 16] {
    let g = Grid::new(n)
    let mut missing_total = 0
    for pixel = 0; pixel < g.npix(); pixel = pixel + 1 {
      let neighbours = g.neighbours(pixel, Nested)
      assert_eq(neighbours.length(), 8)
      let mut missing = 0
      for i = 0; i < 8; i = i + 1 {
        let neighbour = neighbours[i]
        if neighbour == -1 {
          missing = missing + 1
          continue
        }
        assert_true(
          neighbour >= 0 && neighbour < g.npix() && neighbour != pixel,
        )
        for j = 0; j < i; j = j + 1 {
          assert_true(neighbour != neighbours[j])
        }
        assert_true(g.neighbours(neighbour, Nested).contains(pixel))
      }
      missing_total = missing_total + missing
      assert_true(if n == 1 { missing == 2 } else { missing <= 1 })
    }
    assert_eq(missing_total, 24)
  }
}

///|
test "neighbours rejects invalid pixels and returns fresh arrays" {
  let g = Grid::new(2)
  for ordering in [Ring, Nested] {
    for pixel in [-1, g.npix(), 2147483647] {
      assert_true(
        try {
          g.neighbours(pixel, ordering) |> ignore
          false
        } catch {
          InvalidPixel(p) => p == pixel
          _ => false
        },
      )
    }
    let before = g.neighbours(0, ordering)
    let other = g.neighbours(0, ordering)
    other[0] = -77
    assert_eq(g.neighbours(0, ordering), before)
  }
}
