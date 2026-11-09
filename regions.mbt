///|
/// Longitude interval is [west, west + width), wrapping at 2*pi.
/// Latitude interval is closed. width=0 is empty, width=2*pi is full longitude.
pub struct LonLatBox {
  west : Double
  width : Double
  south : Double
  north : Double
}

///|
pub fn LonLatBox::new(
  west : Double,
  width : Double,
  south : Double,
  north : Double,
) -> LonLatBox raise HealpixError {
  if !finite(west) ||
    !finite(width) ||
    !finite(south) ||
    !finite(north) ||
    width < 0.0 ||
    width > 2.0 * @math.PI ||
    south < -@math.PI / 2.0 ||
    north > @math.PI / 2.0 ||
    south > north {
    raise InvalidAngle
  }
  { west: wrap_longitude(west), width, south, north, }
}

///|
pub fn LonLatBox::degrees(
  west : Double,
  width : Double,
  south : Double,
  north : Double,
) -> LonLatBox raise HealpixError {
  if !finite(width) || width < 0.0 || width > 360.0 {
    raise InvalidAngle
  }
  let r = @math.PI / 180.0
  LonLatBox::new(west % 360.0 * r, width * r, south * r, north * r)
}

///|
pub fn LonLatBox::contains(self : LonLatBox, point : LonLat) -> Bool {
  point.lat >= self.south &&
  point.lat <= self.north &&
  (
    self.width == 2.0 * @math.PI ||
    wrap_longitude(point.lon - self.west) < self.width
  )
}

///|
/// Pixel-center selection with the box's exact seam and endpoint semantics.
pub fn Grid::query_box(
  self : Grid,
  region : LonLatBox,
  max_pixels : Int32,
  max_work : Int32,
) -> PixelSet raise HealpixError {
  if max_pixels < 0 || max_work < 0 {
    raise ResourceLimit
  }
  let ranges : Array[PixelRange] = []
  let mut work = 0
  let mut selected = 0
  if region.width == 0.0 {
    return PixelSet::new(self, Ring, [])
  }
  for number = 1; number <= self.ring_count(); number = number + 1 {
    if work >= max_work {
      raise ResourceLimit
    }
    work = work + 1
    let ring = self.ring_info(number)
    if ring.latitude < region.south || ring.latitude > region.north {
      continue
    }
    if region.width == 2.0 * @math.PI {
      if ring.count > max_pixels - selected {
        raise ResourceLimit
      }
      selected = selected + ring.count
      ranges.push({ start: ring.start, end: ring.start + ring.count, })
      continue
    }
    let step = ring.longitude_step()
    let mut low = @math.floor((region.west - ring.first_longitude) / step).to_int() -
      1
    let mut high = @math.ceil(
        (region.west + region.width - ring.first_longitude) / step,
      ).to_int() +
      1
    if high - low + 1 >= ring.count {
      low = 0
      high = ring.count - 1
    }
    for j = low; j <= high; j = j + 1 {
      if work >= max_work {
        raise ResourceLimit
      }
      work = work + 1
      let p = ring.start + modulo(j, ring.count)
      if region.contains(self.ring_center(p)) {
        if selected >= max_pixels {
          raise ResourceLimit
        }
        selected = selected + 1
        ranges.push({ start: p, end: p + 1, })
      }
    }
  }
  PixelSet::new(self, Ring, ranges)
}
