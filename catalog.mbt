///|
struct CatalogBin {
  pixel : Int32
  start : Int32
  end : Int32
  center : Vector
  radius : Double
}

///|
/// Sparse NESTED bin index retaining input source identifiers (array offsets).
/// Caps enclose the actual sources in each bin, avoiding guessed pixel radii.
pub struct Catalog {
  grid : Grid
  sources : Array[LonLat]
  indices : Array[(Int32, Int32)]
  bins : Array[CatalogBin]
}

///|
pub fn Catalog::new(
  grid : Grid,
  sources : Array[LonLat],
  max_sources : Int32,
) -> Catalog raise HealpixError {
  if max_sources < 0 || sources.length() > max_sources {
    raise ResourceLimit
  }
  let indices : Array[(Int32, Int32)] = []
  for i = 0; i < sources.length(); i = i + 1 {
    indices.push((grid.lonlat_to_nested(sources[i]), i))
  }
  indices.sort_by_key(entry => entry.0)
  let bins : Array[CatalogBin] = []
  let mut start = 0
  while start < indices.length() {
    let pixel = indices[start].0
    let center = grid.nested_center(pixel).vector()
    let mut end = start
    let mut radius = 0.0
    while end < indices.length() && indices[end].0 == pixel {
      radius = radius.max(center.separation(sources[indices[end].1].vector()))
      end = end + 1
    }
    bins.push({ pixel, start, end, center, radius, })
    start = end
  }
  { grid, sources: sources.copy(), indices, bins, }
}

///|
pub fn Catalog::grid(self : Catalog) -> Grid {
  self.grid
}

///|
pub fn Catalog::length(self : Catalog) -> Int32 {
  self.sources.length()
}

///|
pub fn Catalog::occupied_pixels(self : Catalog) -> Int32 {
  self.bins.length()
}

///|
pub fn Catalog::source(
  self : Catalog,
  index : Int32,
) -> LonLat raise HealpixError {
  if index < 0 || index >= self.sources.length() {
    raise InvalidRange
  }
  self.sources[index]
}

///|
pub fn Catalog::pixel_sources(
  self : Catalog,
  nested_pixel : Int32,
  max_sources : Int32,
) -> Array[Int32] raise HealpixError {
  self.grid.validate_pixel(nested_pixel)
  if max_sources < 0 {
    raise ResourceLimit
  }
  let mut lo = 0
  let mut hi = self.bins.length()
  while lo < hi {
    let mid = lo + (hi - lo) / 2
    if self.bins[mid].pixel < nested_pixel {
      lo = mid + 1
    } else {
      hi = mid
    }
  }
  let out : Array[Int32] = []
  if lo < self.bins.length() && self.bins[lo].pixel == nested_pixel {
    let bin = self.bins[lo]
    if bin.end - bin.start > max_sources {
      raise ResourceLimit
    }
    for i = bin.start; i < bin.end; i = i + 1 {
      out.push(self.indices[i].1)
    }
  }
  out
}

///|
pub struct SourceHit {
  index : Int32
  distance : Double
} derive(Eq, Debug)

///|
pub extend SourceHit with Eq::{equal, not_equal}

///|
pub extend SourceHit with @debug.Debug::{to_repr}

///|
pub fn SourceHit::index(self : SourceHit) -> Int32 {
  self.index
}

///|
pub fn SourceHit::distance(self : SourceHit) -> Double {
  self.distance
}

///|
/// Exact closed cone filter over sources, sorted by distance then input index.
/// Work is occupied-bin visits plus tested sources. It does not use the
/// center-only pixel selection as a source candidate cover.
pub fn Catalog::query_cone(
  self : Catalog,
  center : LonLat,
  radius : Double,
  max_hits : Int32,
  max_work : Int32,
) -> Array[SourceHit] raise HealpixError {
  validate_query(radius, max_hits, max_work)
  let vector = center.vector()
  let hits : Array[SourceHit] = []
  let mut work = 0
  for bin in self.bins {
    if work >= max_work {
      raise ResourceLimit
    }
    work = work + 1
    if vector.separation(bin.center) > radius + bin.radius + 1.0e-14 {
      continue
    }
    for i = bin.start; i < bin.end; i = i + 1 {
      if work >= max_work {
        raise ResourceLimit
      }
      work = work + 1
      let index = self.indices[i].1
      let distance = vector.separation(self.sources[index].vector())
      if distance <= radius {
        if hits.length() >= max_hits {
          raise ResourceLimit
        }
        hits.push({ index, distance, })
      }
    }
  }
  hits.sort_by(fn(a, b) {
    if a.distance < b.distance {
      -1
    } else if a.distance > b.distance {
      1
    } else {
      a.index - b.index
    }
  })
  hits
}

///|
/// All cells receive a finite count, including zero for unoccupied cells.
pub fn Catalog::count_map(
  self : Catalog,
  max_pixels : Int32,
) -> ScalarMap raise HealpixError {
  if max_pixels < 0 || self.grid.npix > max_pixels {
    raise ResourceLimit
  }
  let data : Array[Double?] = Array::make(self.grid.npix, Some(0.0))
  for bin in self.bins {
    data[bin.pixel] = Some((bin.end - bin.start).to_double())
  }
  { grid: self.grid, ordering: Nested, data, }
}
