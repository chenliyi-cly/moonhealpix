///|
fn validate_query(
  radius : Double,
  max_pixels : Int32,
  max_work : Int32,
) -> Unit raise HealpixError {
  if !finite(radius) || radius < 0.0 || radius > @math.PI {
    raise InvalidAngle
  }
  if max_pixels < 0 || max_work < 0 {
    raise ResourceLimit
  }
}

///|
/// Selects pixels whose CENTERS are inside the closed spherical disc.
/// max_work bounds ring visits plus candidate center tests, not wall time.
/// Output is RING ordering; it is never a cell-footprint intersection cover.
pub fn Grid::query_disc(
  self : Grid,
  center : LonLat,
  radius : Double,
  max_pixels : Int32,
  max_work : Int32,
) -> PixelSet raise HealpixError {
  validate_query(radius, max_pixels, max_work)
  if radius == @math.PI {
    if self.npix > max_pixels {
      raise ResourceLimit
    }
    return PixelSet::new(self, Ring, [{ start: 0, end: self.npix, }])
  }
  let ranges : Array[PixelRange] = []
  let cv = center.vector()
  let sin_c = @math.sin(center.lat)
  let cos_c = @math.cos(center.lat)
  let cos_radius = @math.cos(radius)
  let mut work = 0
  let mut selected = 0
  for number = 1; number <= self.ring_count(); number = number + 1 {
    if work >= max_work {
      raise ResourceLimit
    }
    work = work + 1
    let ring = self.ring_info(number)
    if (ring.latitude - center.lat).abs() > radius + 1.0e-14 {
      continue
    }
    let a = @math.sin(ring.latitude) * sin_c
    let b = @math.cos(ring.latitude) * cos_c
    let half = if b.abs() < 1.0e-15 {
      @math.PI
    } else {
      let threshold = (cos_radius - a) / b
      if threshold > 1.0 + 1.0e-13 {
        continue
      }
      @math.acos(clamp(threshold, -1.0, 1.0))
    }
    let step = ring.longitude_step()
    let mut low = @math.floor((center.lon - half - ring.first_longitude) / step).to_int() -
      1
    let mut high = @math.ceil((center.lon + half - ring.first_longitude) / step).to_int() +
      1
    if high - low + 1 >= ring.count {
      low = 0
      high = ring.count - 1
    }
    let mut run_start = -1
    let mut previous = -2
    for j = low; j <= high; j = j + 1 {
      if work >= max_work {
        raise ResourceLimit
      }
      work = work + 1
      let p = ring.start + modulo(j, ring.count)
      let point = self.ring_center(p)
      if cv.separation(point.vector()) <= radius {
        if selected >= max_pixels {
          raise ResourceLimit
        }
        selected = selected + 1
        if p != previous + 1 {
          if run_start >= 0 {
            ranges.push({ start: run_start, end: previous + 1, })
          }
          run_start = p
        }
        previous = p
      }
    }
    if run_start >= 0 {
      ranges.push({ start: run_start, end: previous + 1, })
    }
  }
  PixelSet::new(self, Ring, ranges)
}
