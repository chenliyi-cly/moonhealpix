///|
/// Spatial ICRS MOC only: IVOA MOC 2.0 section 4.3.2 ASCII and
/// Appendix F JSON (an informative encoding), orders 0..13. No FITS,
/// temporal, frequency, or space-time MOC support. Algorithms are original;
/// mocpy (BSD-3-Clause, CDS 2018) is an independent test dependency only.
/// Limits bound input/candidate ranges, materialized cells, and text UTF-16
/// code units (all accepted literal characters are ASCII). Zero is allowed.
/// Hard ceilings prevent a caller from accidentally disabling protection.
pub struct MocLimits {
  max_ranges : Int32
  max_cells : Int32
  max_chars : Int32
}

///|
pub fn MocLimits::new(
  max_ranges : Int32,
  max_cells : Int32,
  max_chars : Int32,
) -> MocLimits raise HealpixError {
  if max_ranges < 0 ||
    max_ranges > 100000 ||
    max_cells < 0 ||
    max_cells > 100000 ||
    max_chars < 0 ||
    max_chars > 4194304 {
    raise ResourceLimit
  }
  { max_ranges, max_cells, max_chars, }
}

///|
pub fn MocLimits::default() -> MocLimits {
  { max_ranges: 100000, max_cells: 100000, max_chars: 4194304, }
}

///|
/// Immutable normalized coverage: disjoint NESTED ranges at order 13.
/// Resolution metadata survives sibling compaction, including empty MOCs.
/// Constructors normalize cells; parsers additionally reject overlapping or
/// duplicate cells. ASCII orders/indices and JSON arrays must be ascending.
/// Malformed syntax/dimensions raise InvalidData, unsupported orders raise
/// InvalidOrder, and budgets raise ResourceLimit; no silent truncation.
struct Moc {
  coverage : PixelSet
  order : Int32
}

///|
pub fn Moc::max_order(self : Moc) -> Int32 {
  self.order
}

///|
pub fn Moc::empty(max_order : Int32) -> Moc raise HealpixError {
  Grid::from_level(max_order) |> ignore
  {
    coverage: PixelSet::new(Grid::from_level(13), Nested, []),
    order: max_order,
  }
}

///|
fn moc_from_ranges(
  ranges : Array[PixelRange],
  order : Int32,
  limits : MocLimits,
  strict : Bool,
) -> Moc raise HealpixError {
  Grid::from_level(order) |> ignore
  if ranges.length() > limits.max_ranges {
    raise ResourceLimit
  }
  if strict {
    ranges.sort_by_key(r => r.start)
    for i = 1; i < ranges.length(); i = i + 1 {
      if ranges[i - 1].end > ranges[i].start {
        raise InvalidData
      }
    }
  }
  { coverage: PixelSet::new(Grid::from_level(13), Nested, ranges), order, }
}

///|
pub fn Moc::from_cells(
  cells : Array[Cell],
  max_order : Int32,
  limits : MocLimits,
) -> Moc raise HealpixError {
  Grid::from_level(max_order) |> ignore
  if cells.length() > limits.max_cells || cells.length() > limits.max_ranges {
    raise ResourceLimit
  }
  let ranges : Array[PixelRange] = []
  for cell in cells {
    if cell.grid.level > max_order {
      raise InvalidOrder(cell.grid.level)
    }
    ranges.push(cell.descendant_range(13))
  }
  moc_from_ranges(ranges, max_order, limits, false)
}

///|
/// NUNIQ identifiers fit Int32 through order 13 (largest: 1073741823).
/// The declared resolution is explicit because UNIQ alone cannot preserve it.
pub fn Moc::from_uniq(
  uniq : Array[Int32],
  max_order : Int32,
  limits : MocLimits,
) -> Moc raise HealpixError {
  Grid::from_level(max_order) |> ignore
  if uniq.length() > limits.max_cells || uniq.length() > limits.max_ranges {
    raise ResourceLimit
  }
  let cells : Array[Cell] = []
  for u in uniq {
    if u >= 1073741824 {
      raise InvalidOrder(14)
    }
    cells.push(Cell::from_uniq(u))
  }
  Moc::from_cells(cells, max_order, limits)
}

///|
/// Accepts NESTED sets only. A finer input must align exactly at max_order.
pub fn Moc::from_pixel_set(
  set : PixelSet,
  max_order : Int32,
  limits : MocLimits,
) -> Moc raise HealpixError {
  Grid::from_level(max_order) |> ignore
  if set.spans.length() > limits.max_ranges {
    raise ResourceLimit
  }
  let exact = set.at_level(max_order).at_level(13)
  moc_from_ranges(exact.spans, max_order, limits, false)
}

///|
/// Returns an independent array; callers cannot mutate the MOC through it.
pub fn Moc::pixel_set(self : Moc) -> PixelSet raise HealpixError {
  PixelSet::new(self.coverage.grid, Nested, self.coverage.spans)
}

///|
pub fn Moc::cells(
  self : Moc,
  limits : MocLimits,
) -> Array[Cell] raise HealpixError {
  if self.coverage.spans.length() > limits.max_ranges {
    raise ResourceLimit
  }
  let cells = self.coverage.compact_cells(limits.max_cells)
  cells.sort_by_key(c => c.uniq())
  cells
}

///|
pub fn Moc::uniq(
  self : Moc,
  limits : MocLimits,
) -> Array[Int32] raise HealpixError {
  self.cells(limits).map(c => c.uniq())
}

///|
/// Coverage equality ignores declared resolution metadata.
pub fn Moc::equals(self : Moc, other : Moc) -> Bool {
  self.coverage.spans == other.coverage.spans
}

///|
/// Budgets include candidate ranges before normalization, not just output.
fn moc_binary_budget(
  a : Moc,
  b : Moc,
  limits : MocLimits,
) -> Unit raise HealpixError {
  if a.coverage.spans.length() > limits.max_ranges ||
    b.coverage.spans.length() > limits.max_ranges - a.coverage.spans.length() {
    raise ResourceLimit
  }
}

///|
pub fn Moc::union(
  self : Moc,
  other : Moc,
  limits : MocLimits,
) -> Moc raise HealpixError {
  moc_binary_budget(self, other, limits)
  let set = self.coverage.union(other.coverage)
  { coverage: set, order: self.order.max(other.order), }
}

///|
pub fn Moc::intersection(
  self : Moc,
  other : Moc,
  limits : MocLimits,
) -> Moc raise HealpixError {
  moc_binary_budget(self, other, limits)
  let set = self.coverage.intersection(other.coverage)
  { coverage: set, order: self.order.max(other.order), }
}

///|
pub fn Moc::difference(
  self : Moc,
  other : Moc,
  limits : MocLimits,
) -> Moc raise HealpixError {
  moc_binary_budget(self, other, limits)
  let set = self.coverage.difference(other.coverage)
  { coverage: set, order: self.order.max(other.order), }
}

///|
pub fn Moc::complement(
  self : Moc,
  limits : MocLimits,
) -> Moc raise HealpixError {
  if self.coverage.spans.length() >= limits.max_ranges {
    raise ResourceLimit
  }
  { coverage: self.coverage.complement(), order: self.order, }
}

///|
priv struct MocReader {
  text : String
  mut pos : Int32
}

///|
fn MocReader::peek(self : MocReader) -> Int32 {
  if self.pos == self.text.length() {
    -1
  } else {
    self.text.at(self.pos).to_int()
  }
}

///|
fn MocReader::space(self : MocReader, json : Bool) -> Bool {
  let before = self.pos
  while self.peek() == 32 ||
        self.peek() == 10 ||
        self.peek() == 13 ||
        (json && self.peek() == 9) {
    self.pos = self.pos + 1
  }
  self.pos > before
}

///|
fn MocReader::expect(self : MocReader, code : Int32) -> Unit raise HealpixError {
  if self.peek() != code {
    raise InvalidData
  }
  self.pos = self.pos + 1
}

///|
/// Checks before multiplication, so arbitrarily long numbers cannot wrap.
fn MocReader::number(self : MocReader, json : Bool) -> Int32 raise HealpixError {
  let start = self.pos
  let mut n = 0
  while self.peek() >= 48 && self.peek() <= 57 {
    if json && self.pos > start && self.text.at(start).to_int() == 48 {
      raise InvalidData
    }
    let d = self.peek() - 48
    if n > (2147483647 - d) / 10 {
      raise InvalidData
    }
    n = n * 10 + d
    self.pos = self.pos + 1
  }
  if self.pos == start {
    raise InvalidData
  }
  n
}

///|
fn moc_add_range(
  ranges : Array[PixelRange],
  order : Int32,
  lo : Int32,
  hi : Int32,
  limits : MocLimits,
) -> Unit raise HealpixError {
  let grid = Grid::from_level(order)
  if lo < 0 || hi < lo || hi >= grid.npix {
    raise InvalidData
  }
  if ranges.length() >= limits.max_ranges {
    raise ResourceLimit
  }
  let bits = 2 * (13 - order)
  ranges.push({ start: lo << bits, end: (hi + 1) << bits, })
}

///|
/// Strict section 4.3.2 separators are SP/CR/LF (not TAB). Accepts the
/// optional spatial 's' prefix. An empty MOC is written as e.g. "13/".
pub fn Moc::from_ascii(
  text : String,
  limits : MocLimits,
) -> Moc raise HealpixError {
  if text.length() > limits.max_chars {
    raise ResourceLimit
  }
  let r : MocReader = { text, pos: 0, }
  r.space(false) |> ignore
  if r.peek() == 115 {
    r.pos = r.pos + 1
  }
  let ranges : Array[PixelRange] = []
  let mut order = -1
  let mut last_end = -1
  let mut has_value = false
  while true {
    let n = r.number(false)
    let lo = if r.peek() == 47 {
      Grid::from_level(n) |> ignore
      if order >= 0 && (!has_value || n < order) {
        raise InvalidData
      }
      if n != order {
        last_end = -1
      }
      order = n
      has_value = false
      r.pos = r.pos + 1
      r.space(false) |> ignore
      if r.peek() == -1 {
        break
      }
      r.number(false)
    } else {
      if order < 0 {
        raise InvalidData
      }
      n
    }
    let hi = if r.peek() == 45 {
      r.pos = r.pos + 1
      r.number(false)
    } else {
      lo
    }
    if lo <= last_end {
      raise InvalidData
    }
    moc_add_range(ranges, order, lo, hi, limits)
    has_value = true
    last_end = hi
    let separated = r.space(false)
    if r.peek() == -1 {
      break
    }
    if !separated {
      raise InvalidData
    }
  }
  moc_from_ranges(ranges, order, limits, true)
}

///|
/// JSON order keys may use standard Unicode escapes for ASCII digits / s.
/// No general JSON tree is allocated; nesting depth is bounded to two.
fn MocReader::key(self : MocReader) -> Int32 raise HealpixError {
  self.expect(34)
  let mut n = 0
  let mut size = 0
  let mut first = -1
  while self.peek() != 34 {
    let mut ch = self.peek()
    if ch == 92 {
      self.pos = self.pos + 1
      self.expect(117)
      ch = 0
      for _i = 0; _i < 4; _i = _i + 1 {
        let c = self.peek()
        let d = if c >= 48 && c <= 57 {
          c - 48
        } else if c >= 65 && c <= 70 {
          c - 55
        } else if c >= 97 && c <= 102 {
          c - 87
        } else {
          raise InvalidData
        }
        ch = ch * 16 + d
        self.pos = self.pos + 1
      }
    } else {
      if ch < 0 {
        raise InvalidData
      }
      self.pos = self.pos + 1
    }
    if size == 0 {
      first = ch
    }
    if ch == 115 && size == 0 && self.peek() == 34 {
      self.pos = self.pos + 1
      return -1
    }
    if ch < 48 || ch > 57 || size >= 10 || (size > 0 && first == 48) {
      raise InvalidData
    }
    let d = ch - 48
    if n > (2147483647 - d) / 10 {
      raise InvalidData
    }
    n = n * 10 + d
    size = size + 1
  }
  self.pos = self.pos + 1
  if size == 0 {
    raise InvalidData
  }
  n
}

///|
fn moc_json_object(
  r : MocReader,
  ranges : Array[PixelRange],
  limits : MocLimits,
) -> Int32 raise HealpixError {
  r.expect(123)
  r.space(true) |> ignore
  let mut order = 0
  let seen = Array::make(14, false)
  if r.peek() == 125 {
    r.pos = r.pos + 1
    return order
  }
  while true {
    let key = r.key()
    if key < 0 {
      raise InvalidData
    }
    Grid::from_level(key) |> ignore
    if seen[key] {
      raise InvalidData
    }
    seen[key] = true
    order = order.max(key)
    r.space(true) |> ignore
    r.expect(58)
    r.space(true) |> ignore
    r.expect(91)
    r.space(true) |> ignore
    let mut last = -1
    if r.peek() != 93 {
      while true {
        let p = r.number(true)
        if p <= last {
          raise InvalidData
        }
        moc_add_range(ranges, key, p, p, limits)
        last = p
        r.space(true) |> ignore
        if r.peek() == 93 {
          break
        }
        r.expect(44)
        r.space(true) |> ignore
      }
    }
    r.expect(93)
    r.space(true) |> ignore
    if r.peek() == 125 {
      r.pos = r.pos + 1
      break
    }
    r.expect(44)
    r.space(true) |> ignore
  }
  order
}

///|
/// Appendix F spatial JSON: a bare order map or exactly {"s": order-map}.
/// Rejects duplicate keys, non-integer indices, overlaps, extra members,
/// trailing content, all other dimensions, and orders above 13.
pub fn Moc::from_json(
  text : String,
  limits : MocLimits,
) -> Moc raise HealpixError {
  if text.length() > limits.max_chars {
    raise ResourceLimit
  }
  let r : MocReader = { text, pos: 0, }
  r.space(true) |> ignore
  let start = r.pos
  r.expect(123)
  r.space(true) |> ignore
  let wrapped = if r.peek() == 125 {
    false
  } else {
    let key = r.key()
    key == -1
  }
  let ranges : Array[PixelRange] = []
  let order = if wrapped {
    r.space(true) |> ignore
    r.expect(58)
    r.space(true) |> ignore
    let order = moc_json_object(r, ranges, limits)
    r.space(true) |> ignore
    r.expect(125)
    order
  } else {
    r.pos = start
    moc_json_object(r, ranges, limits)
  }
  r.space(true) |> ignore
  if r.peek() != -1 {
    raise InvalidData
  }
  moc_from_ranges(ranges, order, limits, true)
}

///|
priv struct MocWriter {
  builder : StringBuilder
  mut size : Int32
  limit : Int32
}

///|
fn MocWriter::append(
  self : MocWriter,
  text : String,
) -> Unit raise HealpixError {
  if text.length() > self.limit - self.size {
    raise ResourceLimit
  }
  self.builder.write_string(text)
  self.size = self.size + text.length()
}

///|
/// Canonical order/index ordering, inclusive ranges, no trailing whitespace.
/// Retains a trailing empty max-order group whenever necessary.
pub fn Moc::to_ascii(
  self : Moc,
  limits : MocLimits,
) -> String raise HealpixError {
  let cells = self.cells(limits)
  let w : MocWriter = {
    builder: StringBuilder(),
    size: 0,
    limit: limits.max_chars,
  }
  let mut i = 0
  let mut last_order = -1
  while i < cells.length() {
    let c = cells[i]
    if i > 0 {
      w.append(" ")
    }
    if c.grid.level != last_order {
      last_order = c.grid.level
      w.append("\{last_order}/")
    }
    let mut end = c.pixel
    i = i + 1
    while i < cells.length() &&
          cells[i].grid.level == last_order &&
          cells[i].pixel == end + 1 {
      end = cells[i].pixel
      i = i + 1
    }
    w.append("\{c.pixel}")
    if end > c.pixel {
      w.append("-\{end}")
    }
  }
  if last_order < self.order {
    if !cells.is_empty() {
      w.append(" ")
    }
    w.append("\{self.order}/")
  }
  w.builder.to_string()
}

///|
/// Canonical compact JSON with individual indices (JSON has no ranges).
/// Output is the bare spatial order map, suitable for mocpy.MOC.from_string.
pub fn Moc::to_json(
  self : Moc,
  limits : MocLimits,
) -> String raise HealpixError {
  let cells = self.cells(limits)
  let w : MocWriter = {
    builder: StringBuilder(),
    size: 0,
    limit: limits.max_chars,
  }
  w.append("{")
  let mut i = 0
  let mut last_order = -1
  while i < cells.length() {
    let order = cells[i].grid.level
    if i > 0 {
      w.append(",")
    }
    w.append("\"\{order}\":[")
    let mut first = true
    while i < cells.length() && cells[i].grid.level == order {
      if !first {
        w.append(",")
      }
      first = false
      w.append("\{cells[i].pixel}")
      i = i + 1
    }
    w.append("]")
    last_order = order
  }
  if last_order < self.order {
    if !cells.is_empty() {
      w.append(",")
    }
    w.append("\"\{self.order}\":[]")
  }
  w.append("}")
  w.builder.to_string()
}
