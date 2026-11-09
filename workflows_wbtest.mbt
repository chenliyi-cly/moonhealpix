// Three public-API workflows with independent expected results: analytic
// equatorial distances, hand-computed weighted statistics, conserved flux,
// missing-vs-zero observations, and explicit maximum-level integer intervals.

///|
test "workflow catalog seam selection to weighted observation maps" {
  let grid = Grid::new(16)
  let sources = [
    LonLat::degrees(359.8, 0.0),
    LonLat::degrees(0.1, 0.0),
    LonLat::degrees(0.1, 0.0),
    LonLat::degrees(0.6, 0.0),
    LonLat::degrees(180.0, 0.0),
    LonLat::degrees(0.0, 80.0),
  ]
  let values : Array[Double?] = [
    Some(2.0),
    Some(4.0),
    Some(8.0),
    Some(1000.0),
    Some(999.0),
    None,
  ]
  let weights = [1.0, 1.0, 3.0, 1.0, 1.0, 1.0]
  let catalog = Catalog::new(grid, sources, 6)
  let hits = catalog.query_cone(
    LonLat::degrees(0.0, 0.0),
    0.5 * @math.PI / 180.0,
    3,
    12,
  )
  // On the equator the short longitude differences are 0.1, 0.1, 0.2 deg.
  // Duplicate positions retain both source identifiers, in input-index order.
  assert_eq(hits.map(hit => hit.index()), [1, 2, 0])
  for i = 0; i < 3; i = i + 1 {
    let degrees = if i < 2 { 0.1 } else { 0.2 }
    assert_true(
      (hits[i].distance() - degrees * @math.PI / 180.0).abs() < 1.0e-14,
    )
  }
  let selected = Catalog::new(
    grid,
    hits.map(hit => catalog.source(hit.index())),
    3,
  )
  let stats = selected.bin_values(
    hits.map(hit => values[hit.index()]),
    hits.map(hit => weights[hit.index()]),
    3072,
  )
  let east = grid.lonlat_to_nested(sources[1])
  let west = grid.lonlat_to_nested(sources[0])
  assert_true(east != west)
  assert_eq(stats.counts().get(east), Some(2.0))
  assert_eq(stats.weights().get(east), Some(4.0))
  assert_eq(stats.sums().get(east), Some(28.0))
  assert_eq(stats.means().get(east), Some(7.0))
  assert_eq(stats.variances().get(east), Some(3.0))
  assert_eq(stats.means().get(west), Some(2.0))
  assert_eq(stats.variances().get(west), Some(0.0))
  assert_eq(stats.counts().reorder(Ring).summary().unwrap().sum(), 3.0)
  assert_eq(stats.weights().summary().unwrap().sum(), 5.0)
  assert_eq(stats.sums().reorder(Ring).summary().unwrap().sum(), 30.0)
  assert_eq(stats.means().summary().unwrap().count(), 2)
  assert_eq(selected.count_map(3072).summary().unwrap().sum(), 3.0)
  // Excluded high-valued sources must not contaminate the selected map.
  let far = grid.lonlat_to_nested(sources[4])
  assert_eq(stats.counts().get(far), Some(0.0))
  assert_eq(stats.means().get(far), None)
}

///|
test "workflow scalar flux resampling preserves totals and missing semantics" {
  let fine = Grid::new(8)
  let coarse = Grid::new(2)
  let high = Grid::new(16)
  let values : Array[Double?] = Array::make(768, None)
  // At nside=8, each nside=2 parent has 16 NESTED children.
  // Two partially observed parents have flux 8 each; the last has a real zero.
  values[0] = Some(2.0)
  values[1] = Some(6.0)
  values[16] = Some(-4.0)
  values[31] = Some(12.0)
  values[767] = Some(0.0)
  let input = ScalarMap::new(fine, Nested, values, 768).reorder(Ring)
  let flux = input.resample(coarse, Sum, 48)
  let field = input.resample(coarse, Mean, 48)
  assert_eq(flux.ordering(), Ring)
  assert_eq(field.ordering(), Ring)
  for parent in [0, 1] {
    assert_eq(flux.get(coarse.nested_to_ring(parent)), Some(8.0))
    assert_eq(field.get(coarse.nested_to_ring(parent)), Some(4.0))
  }
  assert_eq(flux.get(coarse.nested_to_ring(2)), None)
  assert_eq(field.get(coarse.nested_to_ring(2)), None)
  assert_eq(flux.get(coarse.nested_to_ring(47)), Some(0.0))
  assert_eq(field.get(coarse.nested_to_ring(47)), Some(0.0))
  let summary = flux.summary().unwrap()
  assert_eq(summary.count(), 3)
  assert_eq(summary.missing(), 45)
  assert_eq(summary.sum(), 16.0)
  // A coarse pixel becomes 64 nside=16 descendants. Flux is divided;
  // intensive fields repeat. A missing parent stays missing in every child.
  let expanded_flux = flux.resample(high, Sum, 3072)
  let expanded_field = field.resample(high, Mean, 3072)
  assert_eq(expanded_flux.ordering(), Ring)
  for child in [0, 63, 64, 127] {
    assert_eq(expanded_flux.get(high.nested_to_ring(child)), Some(0.125))
    assert_eq(expanded_field.get(high.nested_to_ring(child)), Some(4.0))
  }
  assert_eq(expanded_flux.get(high.nested_to_ring(128)), None)
  assert_eq(expanded_field.get(high.nested_to_ring(128)), None)
  assert_eq(expanded_flux.get(high.nested_to_ring(3071)), Some(0.0))
  assert_eq(expanded_field.get(high.nested_to_ring(3071)), Some(0.0))
  assert_eq(expanded_flux.summary().unwrap().sum(), 16.0)
  assert_eq(expanded_flux.summary().unwrap().count(), 192)
  assert_eq(expanded_flux.summary().unwrap().missing(), 2880)
  // A caller's insufficient output budget yields the typed error; retrying
  // with the correct budget must not have mutated the source map.
  assert_true(
    try {
      flux.resample(high, Sum, 3071) |> ignore
      false
    } catch {
      ResourceLimit => true
      _ => false
    },
  )
  assert_eq(flux.summary().unwrap().sum(), 16.0)
  assert_eq(input.summary().unwrap().sum(), 16.0)
  assert_eq(input.summary().unwrap().count(), 5)
}

///|
test "workflow mixed hierarchy coverage to maximum-level range algebra" {
  let grid = Grid::new(8192)
  let root = Grid::new(1)
  let level1 = Grid::new(2)
  // A level-0 face spans 67,108,864 leaves, and a level-1 cell 16,777,216.
  // Survey A covers cell 4 at level 1 and face 11. The redundant finer
  // cell and duplicate face represent overlapping input survey tiles.
  let a = grid.cover_cells(
    [
      Cell::new(root, 11),
      Cell::new(level1, 4),
      Cell::new(Grid::new(4), 17),
      Cell::new(root, 11),
    ],
    4,
  )
  let b = grid.cover_cells(
    [Cell::new(level1, 5), Cell::new(level1, 45), Cell::new(grid, 805306367)],
    3,
  )
  assert_eq(a.ranges(), [
    PixelRange::new(grid, 67108864, 83886080),
    PixelRange::new(grid, 738197504, 805306368),
  ])
  assert_eq(a.count(), 83886080)
  assert_eq(b.count(), 33554433)
  let union = a.union(b)
  let common = a.intersection(b)
  let exclusive = a.difference(b)
  let outside = a.complement()
  assert_eq(union.ranges(), [
    PixelRange::new(grid, 67108864, 100663296),
    PixelRange::new(grid, 738197504, 805306368),
  ])
  assert_eq(common.ranges(), [
    PixelRange::new(grid, 754974720, 771751936),
    PixelRange::new(grid, 805306367, 805306368),
  ])
  assert_eq(exclusive.ranges(), [
    PixelRange::new(grid, 67108864, 83886080),
    PixelRange::new(grid, 738197504, 754974720),
    PixelRange::new(grid, 771751936, 805306367),
  ])
  // Explicit interval membership is independent of hierarchy expansion.
  // Witness both sides of every boundary, including the final valid leaf.
  for
    pixel in [
      -1, 0, 67108863, 67108864, 83886079, 83886080, 100663295, 100663296, 738197503,
      738197504, 754974719, 754974720, 771751935, 771751936, 805306366, 805306367,
      805306368,
    ] {
    let in_a = (pixel >= 67108864 && pixel < 83886080) ||
      (pixel >= 738197504 && pixel < 805306368)
    let in_b = (pixel >= 83886080 && pixel < 100663296) ||
      (pixel >= 754974720 && pixel < 771751936) ||
      pixel == 805306367
    assert_eq(a.contains(pixel), in_a)
    assert_eq(b.contains(pixel), in_b)
    assert_eq(union.contains(pixel), in_a || in_b)
    assert_eq(common.contains(pixel), in_a && in_b)
    assert_eq(exclusive.contains(pixel), in_a && !in_b)
    assert_eq(outside.contains(pixel), pixel >= 0 && pixel < 805306368 && !in_a)
  }
  assert_eq(union.count(), 100663296)
  assert_eq(common.count(), 16777217)
  assert_eq(exclusive.count(), 67108863)
  assert_eq(a.count() + outside.count(), 805306368)
  // Deliver compact tiles and a coarser exact coverage, without expanding
  // 83 million leaves or relying solely on a compact/expand round trip.
  assert_eq(a.compact_cells(2).map(cell => cell.uniq()), [20, 15])
  assert_eq(a.at_level(1).ranges(), [
    PixelRange::new(level1, 4, 5),
    PixelRange::new(level1, 44, 48),
  ])
  assert_true(
    try {
      a.pixels(1000) |> ignore
      false
    } catch {
      ResourceLimit => true
      _ => false
    },
  )
}
