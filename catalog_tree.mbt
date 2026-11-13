///|
struct CatalogNode {
  start : Int32
  end : Int32
  center : Vector
  radius : Double
  left : Int32
  right : Int32
}

///|
fn build_catalog_tree(
  bins : Array[CatalogBin],
  start : Int32,
  end : Int32,
  nodes : Array[CatalogNode],
) -> Int32 raise HealpixError {
  let index = nodes.length()
  let anchor = bins[start].center
  nodes.push({ start, end, center: anchor, radius: 0.0, left: -1, right: -1, })
  if end - start <= 4 {
    let mut radius = 0.0
    for i = start; i < end; i = i + 1 {
      radius = radius.max(anchor.separation(bins[i].center) + bins[i].radius)
    }
    nodes[index] = {
      start,
      end,
      center: anchor,
      radius: radius.min(@math.PI),
      left: -1,
      right: -1,
    }
  } else {
    let mid = start + (end - start) / 2
    let left = build_catalog_tree(bins, start, mid, nodes)
    let right = build_catalog_tree(bins, mid, end, nodes)
    let a = nodes[left]
    let b = nodes[right]
    let d = a.center.separation(b.center)
    let (center, radius) = if a.radius >= d + b.radius {
      (a.center, a.radius)
    } else if b.radius >= d + a.radius {
      (b.center, b.radius)
    } else if d >= @math.PI - 1.0e-10 ||
      (d + a.radius + b.radius) * 0.5 >= @math.PI {
      (a.center, @math.PI)
    } else {
      let r = (d + a.radius + b.radius) * 0.5
      let t = (r - a.radius) / d
      let w1 = @math.sin((1.0 - t) * d) / @math.sin(d)
      let w2 = @math.sin(t * d) / @math.sin(d)
      let c = Vector::new(
        w1 * a.center.x + w2 * b.center.x,
        w1 * a.center.y + w2 * b.center.y,
        w1 * a.center.z + w2 * b.center.z,
      )
      // Recompute from actual centers to cover floating-point slerp error.
      (
        c,
        (c.separation(a.center) + a.radius)
        .max(c.separation(b.center) + b.radius)
        .min(@math.PI),
      )
    }
    nodes[index] = { start, end, center, radius, left, right, }
  }
  index
}

///|
/// Exact source matches with observable, deterministic pruning work.
pub struct CatalogSearch {
  hits : Array[SourceHit]
  visited_nodes : Int32
  tested_sources : Int32
}

///|
pub fn CatalogSearch::hits(self : CatalogSearch) -> Array[SourceHit] {
  self.hits.copy()
}

///|
pub fn CatalogSearch::visited_nodes(self : CatalogSearch) -> Int32 {
  self.visited_nodes
}

///|
pub fn CatalogSearch::tested_sources(self : CatalogSearch) -> Int32 {
  self.tested_sources
}

///|
pub fn Catalog::search_cone(
  self : Catalog,
  center : LonLat,
  radius : Double,
  max_hits : Int32,
  max_work : Int32,
) -> CatalogSearch raise HealpixError {
  validate_query(radius, max_hits, max_work)
  let vector = center.vector()
  let hits : Array[SourceHit] = []
  let stack : Array[Int32] = []
  if !self.tree.is_empty() {
    stack.push(0)
  }
  let mut visited_nodes = 0
  let mut tested_sources = 0
  while !stack.is_empty() {
    if visited_nodes + tested_sources >= max_work {
      raise ResourceLimit
    }
    let node = self.tree[stack.pop().unwrap()]
    visited_nodes = visited_nodes + 1
    if vector.separation(node.center) > radius + node.radius + 3.0e-14 {
      continue
    }
    if node.left >= 0 {
      stack.push(node.right)
      stack.push(node.left)
    } else {
      for b = node.start; b < node.end; b = b + 1 {
        let bin = self.bins[b]
        if vector.separation(bin.center) > radius + bin.radius + 3.0e-14 {
          continue
        }
        for i = bin.start; i < bin.end; i = i + 1 {
          if visited_nodes + tested_sources >= max_work {
            raise ResourceLimit
          }
          tested_sources = tested_sources + 1
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
  { hits, visited_nodes, tested_sources, }
}
