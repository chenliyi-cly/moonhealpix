///|
test "angles wrap and vectors normalize without overflow" {
  let a = LonLat::degrees(-30.0, 45.0)
  assert_true((a.longitude_degrees() - 330.0).abs() < 1.0e-12)
  assert_true(a.separation(a.vector().lonlat()) < 1.0e-14)
  let v = Vector::new(1.0e300, 1.0e300, 0.0)
  assert_true((v.lonlat().longitude_degrees() - 45.0).abs() < 1.0e-12)
  assert_true(
    try {
      Vector::new(0.0, 0.0, 0.0) |> ignore
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      LonLat::degrees(0.0, 91.0) |> ignore
      false
    } catch {
      _ => true
    },
  )
  let b = LonLat::degrees(150.0, -45.0)
  assert_true((a.separation(b) - @math.PI).abs() < 1.0e-14)
}
