///|
priv enum SphereRegion {
  DiscRegion(LonLat, Double)
  PolygonRegion(SphericalPolygon)
}

///|
fn region_contains(region : SphereRegion, point : LonLat) -> Bool {
  match region {
    DiscRegion(center, radius) => center.separation(point) <= radius
    PolygonRegion(polygon) => polygon.contains(point)
  }
}

///|
// -1: guaranteed disjoint; +1: entire cap inside; 0: unresolved boundary.
fn region_relation(
  region : SphereRegion,
  center : LonLat,
  radius : Double,
) -> Int32 {
  match region {
    DiscRegion(point, r) => {
      if r == @math.PI {
        return 1
      }
      let d = point.separation(center)
      if d > r + radius + 3.0e-14 {
        -1
      } else if d + radius <= r {
        1
      } else {
        0
      }
    }
    PolygonRegion(polygon) => {
      let v = center.vector()
      let mut inside = true
      for n in polygon.normals {
        let signed_distance = @math.asin(n.dot(v))
        if signed_distance < -radius - 3.0e-14 {
          return -1
        }
        if signed_distance < radius + 3.0e-14 {
          inside = false
        }
      }
      if inside {
        1
      } else {
        0
      }
    }
  }
}

///|
/// Exact center selection and actual number of visited hierarchy cells.
pub struct PixelSearch {
  pixels : PixelSet
  visited : Int32
}

///|
pub fn PixelSearch::pixels(self : PixelSearch) -> PixelSet {
  self.pixels
}

///|
pub fn PixelSearch::visited(self : PixelSearch) -> Int32 {
  self.visited
}

///|
fn spend_node(work : Array[Int32], max_work : Int32) -> Unit raise HealpixError {
  if work[0] >= max_work {
    raise ResourceLimit
  }
  work[0] = work[0] + 1
}

///|
fn add_selection(
  r : PixelRange,
  ranges : Array[PixelRange],
  counts : Array[Int32],
  max_pixels : Int32,
) -> Unit raise HealpixError {
  if r.length() > max_pixels - counts[0] {
    raise ResourceLimit
  }
  counts[0] = counts[0] + r.length()
  ranges.push(r)
}

///|
fn walk_centers(
  cell : Cell,
  target : Grid,
  region : SphereRegion,
  ranges : Array[PixelRange],
  work : Array[Int32],
  selected : Array[Int32],
  max_pixels : Int32,
  max_work : Int32,
) -> Unit raise HealpixError {
  spend_node(work, max_work)
  let center = cell.grid.nested_center(cell.pixel)
  let relation = region_relation(region, center, cell.bounding_radius())
  if relation < 0 {
    return
  }
  if relation > 0 {
    add_selection(
      cell.descendant_range(target.level),
      ranges,
      selected,
      max_pixels,
    )
  } else if cell.grid.level == target.level {
    if region_contains(region, center) {
      add_selection(
        { start: cell.pixel, end: cell.pixel + 1, },
        ranges,
        selected,
        max_pixels,
      )
    }
  } else {
    let next = Grid::from_level(cell.grid.level + 1)
    for k = 0; k < 4; k = k + 1 {
      walk_centers(
        Cell::new(next, cell.pixel * 4 + k),
        target,
        region,
        ranges,
        work,
        selected,
        max_pixels,
        max_work,
      )
    }
  }
}

///|
fn region_centers(
  grid : Grid,
  region : SphereRegion,
  max_pixels : Int32,
  max_work : Int32,
) -> PixelSearch raise HealpixError {
  if max_pixels < 0 || max_work < 0 {
    raise ResourceLimit
  }
  let ranges : Array[PixelRange] = []
  let work = [0]
  let selected = [0]
  let base = Grid::new(1)
  for face = 0; face < 12; face = face + 1 {
    walk_centers(
      Cell::new(base, face),
      grid,
      region,
      ranges,
      work,
      selected,
      max_pixels,
      max_work,
    )
  }
  { pixels: PixelSet::new(grid, Nested, ranges), visited: work[0], }
}

///|
/// Exact closed-disc center selection with NESTED quadtree pruning.
pub fn Grid::search_disc(
  self : Grid,
  center : LonLat,
  radius : Double,
  max_pixels : Int32,
  max_work : Int32,
) -> PixelSearch raise HealpixError {
  validate_query(radius, max_pixels, max_work)
  region_centers(self, DiscRegion(center, radius), max_pixels, max_work)
}

///|
pub fn Grid::search_polygon(
  self : Grid,
  polygon : SphericalPolygon,
  max_pixels : Int32,
  max_work : Int32,
) -> PixelSearch raise HealpixError {
  region_centers(self, PolygonRegion(polygon), max_pixels, max_work)
}

///|
/// Conservative curved-pixel overlap result. `pixels` includes every actual
/// overlap. `interior` is guaranteed wholly inside; the rest may include false
/// positives. Refinement removes boundary candidates, never true overlaps.
pub struct RegionCover {
  pixels : PixelSet
  interior : PixelSet
  visited : Int32
  refinement_level : Int32
}

///|
pub fn RegionCover::pixels(self : RegionCover) -> PixelSet {
  self.pixels
}

///|
pub fn RegionCover::interior(self : RegionCover) -> PixelSet {
  self.interior
}

///|
pub fn RegionCover::boundary(self : RegionCover) -> PixelSet raise HealpixError {
  self.pixels.difference(self.interior)
}

///|
pub fn RegionCover::visited(self : RegionCover) -> Int32 {
  self.visited
}

///|
pub fn RegionCover::refinement_level(self : RegionCover) -> Int32 {
  self.refinement_level
}

///|
fn possibly_overlaps(
  cell : Cell,
  region : SphereRegion,
  stop : Int32,
  work : Array[Int32],
  max_work : Int32,
) -> Bool raise HealpixError {
  spend_node(work, max_work)
  let relation = region_relation(
    region,
    cell.grid.nested_center(cell.pixel),
    cell.bounding_radius(),
  )
  if relation < 0 {
    return false
  }
  if relation > 0 || cell.grid.level == stop {
    return true
  }
  let next = Grid::from_level(cell.grid.level + 1)
  for k = 0; k < 4; k = k + 1 {
    if possibly_overlaps(
        Cell::new(next, cell.pixel * 4 + k),
        region,
        stop,
        work,
        max_work,
      ) {
      return true
    }
  }
  false
}

///|
fn walk_cover(
  cell : Cell,
  target : Grid,
  region : SphereRegion,
  stop : Int32,
  ranges : Array[PixelRange],
  interior : Array[PixelRange],
  work : Array[Int32],
  selected : Array[Int32],
  max_pixels : Int32,
  max_work : Int32,
) -> Unit raise HealpixError {
  spend_node(work, max_work)
  let relation = region_relation(
    region,
    cell.grid.nested_center(cell.pixel),
    cell.bounding_radius(),
  )
  if relation < 0 {
    return
  }
  if relation > 0 {
    let r = cell.descendant_range(target.level)
    add_selection(r, ranges, selected, max_pixels)
    interior.push(r)
  } else if cell.grid.level < target.level {
    let next = Grid::from_level(cell.grid.level + 1)
    for k = 0; k < 4; k = k + 1 {
      walk_cover(
        Cell::new(next, cell.pixel * 4 + k),
        target,
        region,
        stop,
        ranges,
        interior,
        work,
        selected,
        max_pixels,
        max_work,
      )
    }
  } else if possibly_overlaps(cell, region, stop, work, max_work) {
    add_selection(
      { start: cell.pixel, end: cell.pixel + 1, },
      ranges,
      selected,
      max_pixels,
    )
  }
}

///|
fn region_cover(
  grid : Grid,
  region : SphereRegion,
  refine_levels : Int32,
  max_pixels : Int32,
  max_work : Int32,
) -> RegionCover raise HealpixError {
  if max_pixels < 0 || max_work < 0 {
    raise ResourceLimit
  }
  if refine_levels < 0 || refine_levels > 13 - grid.level {
    raise InvalidOrder(refine_levels)
  }
  let stop = grid.level + refine_levels
  let ranges : Array[PixelRange] = []
  let interior : Array[PixelRange] = []
  let work = [0]
  let selected = [0]
  let base = Grid::new(1)
  for face = 0; face < 12; face = face + 1 {
    walk_cover(
      Cell::new(base, face),
      grid,
      region,
      stop,
      ranges,
      interior,
      work,
      selected,
      max_pixels,
      max_work,
    )
  }
  {
    pixels: PixelSet::new(grid, Nested, ranges),
    interior: PixelSet::new(grid, Nested, interior),
    visited: work[0],
    refinement_level: stop,
  }
}

///|
/// Inclusive footprint cover, with explicit unresolved boundary cells.
/// refine_levels corresponds to a 2^refine_levels linear refinement factor.
pub fn Grid::cover_disc(
  self : Grid,
  center : LonLat,
  radius : Double,
  refine_levels : Int32,
  max_pixels : Int32,
  max_work : Int32,
) -> RegionCover raise HealpixError {
  validate_query(radius, max_pixels, max_work)
  region_cover(
    self,
    DiscRegion(center, radius),
    refine_levels,
    max_pixels,
    max_work,
  )
}

///|
pub fn Grid::cover_polygon(
  self : Grid,
  polygon : SphericalPolygon,
  refine_levels : Int32,
  max_pixels : Int32,
  max_work : Int32,
) -> RegionCover raise HealpixError {
  region_cover(
    self,
    PolygonRegion(polygon),
    refine_levels,
    max_pixels,
    max_work,
  )
}
