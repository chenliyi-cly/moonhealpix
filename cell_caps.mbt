///|
/// Conservative spherical cap enclosing the entire curved HEALPix cell.
/// Bound uses continuous projection extrema, not a finite edge sampling.
pub fn Cell::bounding_radius(self : Cell) -> Double raise HealpixError {
  let c = self.grid.pixel_face(self.pixel)
  let x0 = c.x.to_double()
  let y0 = c.y.to_double()
  let n = self.grid.nside.to_double()
  let jrll = [2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4]
  let jpll = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7]
  let base = jpll[c.face].to_double() * @math.PI / 4.0
  let center = self.grid.nested_center(self.pixel)
  let jrbase = jrll[c.face].to_double() * n
  let center_jr = jrbase - x0 - y0 - 1.0
  let center_nr = if center_jr < n {
    center_jr
  } else if center_jr > 3.0 * n {
    4.0 * n - center_jr
  } else {
    n
  }
  let center_lon = base + (x0 - y0) * @math.PI / (4.0 * center_nr)
  let mut lon_extent = 0.0
  let candidates : Array[(Double, Double)] = [
    (x0, y0),
    (x0 + 1.0, y0),
    (x0, y0 + 1.0),
    (x0 + 1.0, y0 + 1.0),
  ]
  // Each polar/equatorial piece has a linear-fractional longitude. Its extrema
  // on a convex piece occur at vertices, including transition intersections.
  for transition in [n, 3.0 * n] {
    let sum = jrbase - transition
    for x in [x0, x0 + 1.0] {
      let y = sum - x
      if y >= y0 && y <= y0 + 1.0 {
        candidates.push((x, y))
      }
    }
    for y in [y0, y0 + 1.0] {
      let x = sum - y
      if x >= x0 && x <= x0 + 1.0 {
        candidates.push((x, y))
      }
    }
  }
  for xy in candidates {
    let jr = jrbase - xy.0 - xy.1
    let nr = if jr < n { jr } else if jr > 3.0 * n { 4.0 * n - jr } else { n }
    if nr <= 0.0 {
      // The pole has no unique longitude; limiting longitudes stay in the
      // base-face wedge. Including both wedge ends is a safe bound.
      lon_extent = lon_extent
        .max((base - @math.PI / 4.0 - center_lon).abs())
        .max((base + @math.PI / 4.0 - center_lon).abs())
    } else {
      let lon = base + (xy.0 - xy.1) * @math.PI / (4.0 * nr)
      lon_extent = lon_extent.max((lon - center_lon).abs())
    }
  }
  let low = face_lonlat(self.grid, c.face, x0, y0).lat
  let high = face_lonlat(self.grid, c.face, x0 + 1.0, y0 + 1.0).lat
  let lat_extent = (low - center.lat).abs().max((high - center.lat).abs())
  // Parallel at center latitude followed by a meridian is an explicit path
  // to every point in the cell. Geodesic distance cannot exceed its length.
  (@math.cos(center.lat).abs() * lon_extent + lat_extent + 2.0e-14).min(
    @math.PI,
  )
}
