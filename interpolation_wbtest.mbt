// SPDX-License-Identifier: BSD-3-Clause

///|
fn interpolation_assert_oracle(
  grid : Grid,
  ordering : Ordering,
  lon : Double,
  lat : Double,
  expected_pixels : Array[Int32],
  expected_weights : Array[Double],
  expected_value : Double,
) -> Unit raise {
  let point = LonLat::new(lon, lat)
  let (pixels, weights) = grid.bilinear_interpolation_weights(point, ordering)
  assert_eq(pixels.length(), 4)
  assert_eq(weights.length(), 4)
  let tolerance = if grid.nside() == 8192 { 2.0e-11 } else { 2.0e-12 }
  let mut total = 0.0
  let mut value = 0.0
  for i = 0; i < 4; i = i + 1 {
    assert_true(pixels[i] >= 0 && pixels[i] < grid.npix())
    assert_true(finite(weights[i]) && weights[i] >= 0.0 && weights[i] <= 1.0)
    total = total + weights[i]
    value = value +
      weights[i] *
      (
        @math.sin(pixels[i].to_double() * 0.17) +
        @math.cos(pixels[i].to_double() * 0.031)
      )
  }
  assert_true((total - 1.0).abs() < 1.0e-14)
  // At exact boundaries independent trig implementations can select the
  // other zero-weight corner, or reverse the two members of a pair. Compare
  // the sparse operator in both directions, not the incidental slot order.
  for k = 0; k < 8; k = k + 1 {
    let pixel = if k < 4 { pixels[k] } else { expected_pixels[k - 4] }
    let mut actual = 0.0
    let mut expected = 0.0
    for i = 0; i < 4; i = i + 1 {
      if pixels[i] == pixel {
        actual = actual + weights[i]
      }
      if expected_pixels[i] == pixel {
        expected = expected + expected_weights[i]
      }
    }
    assert_true(
      (actual - expected).abs() < tolerance,
      msg="oracle stencil nside=\{grid.nside()} lon=\{lon} lat=\{lat} pixel=\{pixel} actual=\{actual} expected=\{expected}",
    )
  }
  assert_true(
    (value - expected_value).abs() < 4.0 * tolerance,
    msg="oracle value nside=\{grid.nside()} lon=\{lon} lat=\{lat} actual=\{value} expected=\{expected_value}",
  )
  // Full scalar-map path on bounded grids, sparse stencil only at nside8192.
  if grid.nside() <= 16 {
    let values = Array::make(grid.npix(), Some(0.0))
    for i = 0; i < grid.npix(); i = i + 1 {
      values[i] = Some(
        @math.sin(i.to_double() * 0.17) + @math.cos(i.to_double() * 0.031),
      )
    }
    let map = ScalarMap::new(grid, ordering, values, grid.npix())
    assert_true(
      (map.interpolate_bilinear(point).unwrap() - expected_value).abs() <
      4.0 * tolerance,
    )
  }
}

///|
fn interpolation_assert_missing(
  nside : Int32,
  ordering : Ordering,
  lon : Double,
  lat : Double,
  missing : Int32,
) -> Unit raise {
  let grid = Grid::new(nside)
  let map = ScalarMap::filled(grid, ordering, Some(1.0), grid.npix()).with_value(
    missing,
    None,
  )
  assert_true(
    map.interpolate_bilinear(LonLat::new(lon, lat)) == None,
    msg="missing oracle nside=\{nside} lon=\{lon} lat=\{lat} missing=\{missing}",
  )
}

///|
test "interpolation poles, constants, missing slots and wrapping" {
  for n in [1, 2, 4, 16, 8192] {
    let g = Grid::new(n)
    for ordering in [Ring, Nested] {
      for lat in [-@math.PI / 2.0, @math.PI / 2.0] {
        for lon in [0.0, 0.7, @math.PI, 6.2] {
          let (pixels, weights) = g.bilinear_interpolation_weights(
            LonLat::new(lon, lat),
            ordering,
          )
          for i = 0; i < 4; i = i + 1 {
            assert_eq(weights[i], 0.25)
            for j = 0; j < i; j = j + 1 {
              assert_true(pixels[i] != pixels[j])
            }
            let ring_pixel = g.convert(pixels[i], ordering, Ring)
            assert_true(
              if lat > 0.0 {
                ring_pixel < 4
              } else {
                ring_pixel >= g.npix() - 4
              },
            )
          }
        }
      }
    }
  }
  let g = Grid::new(4)
  for ordering in [Ring, Nested] {
    let map = ScalarMap::filled(g, ordering, Some(7.0), g.npix())
    for
      point in [
        LonLat::new(0.0, 0.0),
        LonLat::new(0.3, 0.27),
        LonLat::degrees(43.0, 90.0),
        LonLat::degrees(317.0, -90.0),
      ] {
      assert_true(
        (map.interpolate_bilinear(point).unwrap() - 7.0).abs() < 2.0e-15,
      )
      let (pixels, _) = g.bilinear_interpolation_weights(point, ordering)
      for pixel in pixels {
        assert_eq(map.with_value(pixel, None).interpolate_bilinear(point), None)
      }
    }
    let center = g.center(17, ordering)
    let (pixels, weights) = g.bilinear_interpolation_weights(center, ordering)
    let mut zero_count = 0
    for i = 0; i < 4; i = i + 1 {
      if weights[i] == 0.0 {
        zero_count = zero_count + 1
        assert_eq(
          map.with_value(pixels[i], None).interpolate_bilinear(center),
          None,
        )
      }
    }
    assert_true(zero_count > 0)
    assert_eq(
      ScalarMap::filled(g, ordering, None, g.npix()).interpolate_bilinear(
        center,
      ),
      None,
    )
  }
  let point = LonLat::new(0.3, 0.27)
  let (_, original) = g.bilinear_interpolation_weights(point, Ring)
  let (_, wrapped) = g.bilinear_interpolation_weights(
    LonLat::new(0.3 + 2.0 * @math.PI, 0.27),
    Ring,
  )
  for i = 0; i < 4; i = i + 1 {
    assert_true((original[i] - wrapped[i]).abs() < 1.0e-14)
  }
}

///|
test "interpolation physical map invariant under ordering" {
  let g = Grid::new(16)
  let ring_data = Array::make(g.npix(), Some(0.0))
  let nested_data = Array::make(g.npix(), Some(0.0))
  for p = 0; p < g.npix(); p = p + 1 {
    let value = Some(@math.sin(p.to_double() * 0.37))
    ring_data[p] = value
    nested_data[g.ring_to_nested(p)] = value
  }
  let ring_map = ScalarMap::new(g, Ring, ring_data, g.npix())
  let nested_map = ScalarMap::new(g, Nested, nested_data, g.npix())
  for
    point in [
      LonLat::new(0.1, 0.2),
      LonLat::new(6.28, -0.7),
      LonLat::degrees(17.0, 90.0),
      LonLat::degrees(73.0, -90.0),
    ] {
    assert_eq(
      ring_map.interpolate_bilinear(point),
      nested_map.interpolate_bilinear(point),
    )
  }
}
