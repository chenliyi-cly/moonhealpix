///|
test "hierarchical disc remains exact at nside8192 with small work budget" {
  let g = Grid::new(8192)
  for p in [0, 67108863, 268435456, 536870912, 805306367] {
    let center = g.nested_center(p)
    let found = g.search_disc(center, 0.0, 10, 1500)
    assert_eq(found.pixels().pixels(10), [p])
    assert_true(found.visited() < 1500)
  }
}

///|
test "center search and closed-disc overlap have separate contracts" {
  let g = Grid::new(8)
  let center = g.pixel_position(42, 0.0, 0.0)
  let centers = g.search_disc(center, 0.0, g.npix(), 10000).pixels()
  let coarse = g.cover_disc(center, 0.0, 0, g.npix(), 10000)
  let refined = g.cover_disc(center, 0.0, 4, g.npix(), 100000)
  assert_true(coarse.pixels().contains(42))
  assert_true(refined.pixels().contains(42))
  assert_eq(centers.count(), 0)
  assert_true(refined.pixels().difference(coarse.pixels()).count() == 0)
  assert_eq(refined.interior().count(), 0)
}

///|
test "convex polygons wind both ways and reject ambiguous geometry" {
  let vs = [
    LonLat::degrees(350.0, -10.0),
    LonLat::degrees(10.0, -10.0),
    LonLat::degrees(10.0, 10.0),
    LonLat::degrees(350.0, 10.0),
  ]
  let p = SphericalPolygon::new(vs, 10)
  let q = SphericalPolygon::new([vs[3], vs[2], vs[1], vs[0]], 10)
  assert_true(p.contains(LonLat::degrees(0.0, 0.0)))
  assert_true(!p.contains(LonLat::degrees(180.0, 0.0)))
  let g = Grid::new(16)
  assert_eq(
    g.query_polygon(p, 1000, 10000).pixels(1000),
    g.query_polygon(q, 1000, 10000).pixels(1000),
  )
  for
    bad in [
      [],
      [vs[0], vs[1]],
      [vs[0], vs[0], vs[2]],
      [vs[0], vs[2], vs[1], vs[3]],
      [
        LonLat::degrees(0.0, 0.0),
        LonLat::degrees(180.0, 0.0),
        LonLat::degrees(0.0, 30.0),
      ],
    ] {
    assert_true(
      try {
        SphericalPolygon::new(bad, 10) |> ignore
        false
      } catch {
        _ => true
      },
    )
  }
  assert_true(
    try {
      SphericalPolygon::new(vs, 3) |> ignore
      false
    } catch {
      ResourceLimit => true
      _ => false
    },
  )
}

///|
test "polygon footprint covers its vertices and all accepted center cells" {
  let vertices = [
    LonLat::degrees(350.0, -8.0),
    LonLat::degrees(20.0, -10.0),
    LonLat::degrees(15.0, 17.0),
  ]
  let p = SphericalPolygon::new(vertices, 10)
  let g = Grid::new(16)
  let cover = g.cover_polygon(p, 3, g.npix(), 100000)
  for v in vertices {
    assert_true(cover.pixels().contains(g.lonlat_to_nested(v)))
  }
  let centers = g.query_polygon(p, g.npix(), 100000)
  assert_eq(centers.difference(cover.pixels()).count(), 0)
  assert_eq(cover.interior().difference(centers).count(), 0)
  assert_eq(cover.interior().intersection(cover.boundary()).count(), 0)
  assert_eq(
    cover.interior().union(cover.boundary()).count(),
    cover.pixels().count(),
  )
  let refined = g.cover_polygon(p, 4, g.npix(), 1000000)
  assert_eq(refined.pixels().difference(cover.pixels()).count(), 0)
}

///|
test "region budgets reject incomplete results and invalid refinement" {
  let g = Grid::new(8)
  let center = LonLat::degrees(0.0, 0.0)
  assert_true(
    try {
      g.search_disc(center, 0.2, 0, 10000) |> ignore
      false
    } catch {
      ResourceLimit => true
      _ => false
    },
  )
  assert_true(
    try {
      g.cover_disc(center, 0.2, 1, 1000, 0) |> ignore
      false
    } catch {
      ResourceLimit => true
      _ => false
    },
  )
  assert_true(
    try {
      g.cover_disc(center, 0.2, 11, 1000, 10000) |> ignore
      false
    } catch {
      InvalidOrder(_) => true
      _ => false
    },
  )
  let full = g.cover_disc(center, @math.PI, 0, g.npix(), 10000)
  assert_eq(full.pixels().count(), g.npix())
}

///|
test "bounding-cap tree cones prune actual source candidates" {
  let points : Array[LonLat] = []
  // Deterministic equal-area sky sequence, not a single clustered demo.
  for i = 0; i < 12000; i = i + 1 {
    points.push(
      LonLat::new(
        i.to_double() * 2.399963229728653,
        @math.asin(1.0 - 2.0 * (i.to_double() + 0.5) / 12000.0),
      ),
    )
  }
  let c = Catalog::new(Grid::new(64), points, 12000)
  let center = points[6000]
  let result = c.search_cone(center, 0.02, 100, 1000)
  let ids = result.hits().map(h => h.index())
  for i = 0; i < points.length(); i = i + 1 {
    assert_eq(ids.contains(i), center.separation(points[i]) <= 0.02)
  }
  assert_true(result.tested_sources() < 120)
  assert_true(result.visited_nodes() < 500)
  assert_true(
    try {
      c.search_cone(center, 0.02, 100, 0) |> ignore
      false
    } catch {
      ResourceLimit => true
      _ => false
    },
  )
  assert_eq(
    Catalog::new(Grid::new(1), [], 0)
    .search_cone(center, 0.0, 0, 0)
    .hits()
    .length(),
    0,
  )
}
