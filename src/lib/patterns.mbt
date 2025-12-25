///|
pub(open) trait PatternTrait: Show {
  pattern_at(Self, Tuple) -> Color
  uv_at(Self, Double, Double) -> Color
  clone(Self) -> Pattern // `clone(Self) -> Self` causes a compiler error
}

///|
pub(all) struct Pattern {
  pattern : &PatternTrait
  // Do not modify transform directly. Use `set_transform` instead.
  mut transform : Matrix
  mut inv_transform : Matrix
} derive(Show)

///|
pub fn Pattern::new(pattern : &PatternTrait) -> Pattern {
  let transform = mat4ident()
  let inv_transform = mat4ident()
  { pattern, transform, inv_transform }
}

///|
pub impl PatternTrait for Pattern with pattern_at(self, point) {
  self.pattern.pattern_at(point)
}

///|
pub impl PatternTrait for Pattern with uv_at(self, u, v) {
  self.pattern.uv_at(u, v)
}

///|
pub impl Eq for Pattern with equal(self, other) {
  // https://github.com/moonbitlang/core/issues/1304#issuecomment-2523373703
  // self.pattern == other.pattern &&
  self.transform == other.transform
}

///|
pub impl PatternTrait for Pattern with clone(self) {
  let pattern = self.pattern.clone().pattern
  let transform = self.transform.clone()
  let inv_transform = self.inv_transform.clone()
  { pattern, transform, inv_transform }
}

///|
pub fn Pattern::set_pattern_transform(
  self : Pattern,
  transform : Matrix,
) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn Pattern::pattern_at_shape(
  self : Pattern,
  shape : Shape,
  world_point : Tuple,
) -> Color {
  let object_point = shape.world_to_object(world_point)
  let pattern_point = self.inv_transform.mul_tuple(object_point)
  
  self.pattern.pattern_at(pattern_point)
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Mappings
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(open) trait Mapping: Show {
  map(Self, Tuple) -> (Double, Double)
}

///|
pub(all) struct SphericalMapping {} derive(Show, Eq)

///|
pub impl Mapping for SphericalMapping with map(_self, p) {
  spherical_map(p)
}

///|
pub(all) struct PlanarMapping {} derive(Show, Eq)

///|
pub impl Mapping for PlanarMapping with map(_self, p) {
  planar_map(p)
}

///|
pub(all) struct CylindricalMapping {} derive(Show, Eq)

///|
pub impl Mapping for CylindricalMapping with map(_self, p) {
  cylindrical_map(p)
}

///|
pub(all) struct CubicMapping {} derive(Show, Eq)

///|
pub impl Mapping for CubicMapping with map(_self, p) {
  cubic_map(p)
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// StripePattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct StripePattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn StripePattern::to_string(self : StripePattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "stripe(\{colors})"
}

///|
pub impl Show for StripePattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for StripePattern with clone(self) {
  stripe_pattern(self.colors)
}

///|
pub impl PatternTrait for StripePattern with uv_at(_self, _u, _v) {
  color(0, 0, 0)
}

///|
pub fn stripe_pattern(colors : Array[Color]) -> Pattern {
  let pattern = StripePattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub impl PatternTrait for StripePattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    let d = -index / ncols
    (index + ncols * (d + 1)) % ncols
  }
  self.colors[index]
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// GradientPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct GradientPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn GradientPattern::to_string(self : GradientPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "gradient(\{colors})"
}

///|
pub impl Show for GradientPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for GradientPattern with clone(self) {
  gradient_pattern(self.colors)
}

///|
pub impl PatternTrait for GradientPattern with uv_at(_self, _u, _v) {
  color(0, 0, 0)
}

///|
pub fn gradient_pattern(colors : Array[Color]) -> Pattern {
  let pattern = GradientPattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub impl PatternTrait for GradientPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    let d = -index / ncols
    (index + ncols * (d + 1)) % ncols
  }
  let next_index = (index + 1) % ncols
  let ca = self.colors[index]
  let cb = self.colors[next_index]
  let t = point.x - @math.floor(point.x)
  ca + (cb - ca).mul_scalar(t)
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// RingPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct RingPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn RingPattern::to_string(self : RingPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "ring(\{colors})"
}

///|
pub impl Show for RingPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for RingPattern with clone(self) {
  ring_pattern(self.colors)
}

///|
pub impl PatternTrait for RingPattern with uv_at(_self, _u, _v) {
  color(0, 0, 0)
}

///|
pub fn ring_pattern(colors : Array[Color]) -> Pattern {
  let pattern = RingPattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub impl PatternTrait for RingPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let r = (point.x * point.x + point.z * point.z).sqrt()
  let index = @math.floor(r).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    let d = -index / ncols
    (index + ncols * (d + 1)) % ncols
  }
  self.colors[index]
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// GradientRingPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct GradientRingPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn GradientRingPattern::to_string(self : GradientRingPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "ring(\{colors})"
}

///|
pub impl Show for GradientRingPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for GradientRingPattern with clone(self) {
  gradient_ring_pattern(self.colors)
}

///|
pub impl PatternTrait for GradientRingPattern with uv_at(_self, _u, _v) {
  color(0, 0, 0)
}

///|
pub fn gradient_ring_pattern(colors : Array[Color]) -> Pattern {
  let pattern = GradientRingPattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub impl PatternTrait for GradientRingPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let r = (point.x * point.x + point.z * point.z).sqrt()
  let index = @math.floor(r).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    let d = -index / ncols
    (index + ncols * (d + 1)) % ncols
  }
  let next_index = (index + 1) % ncols
  let ca = self.colors[index]
  let cb = self.colors[next_index]
  let t = r - @math.floor(r)
  ca + (cb - ca).mul_scalar(t)
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// CheckersPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct CheckersPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn CheckersPattern::to_string(self : CheckersPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "checkers(\{colors})"
}

///|
pub impl Show for CheckersPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for CheckersPattern with clone(self) {
  checkers_pattern(self.colors)
}

///|
pub impl PatternTrait for CheckersPattern with uv_at(_self, _u, _v) {
  color(0, 0, 0)
}

///|
pub fn checkers_pattern(colors : Array[Color]) -> Pattern {
  let pattern = CheckersPattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub impl PatternTrait for CheckersPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x).to_int() +
    @math.floor(point.y).to_int() +
    @math.floor(point.z).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    let d = -index / ncols
    (index + ncols * (d + 1)) % ncols
  }
  self.colors[index]
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Texture
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct Texture {
  canvas : Canvas
  mapping : &Mapping
}

///|
pub impl Show for Texture with output(_self, logger) {
  logger.write_string("texture()")
}

///|
pub impl PatternTrait for Texture with pattern_at(self, point) {
  let (u, v) = self.mapping.map(point)
  // Use modulo to wrap u and v to [0, 1]
  let u = u - @math.floor(u)
  let v = v - @math.floor(v)
  
  let x = (u * self.canvas.width.to_double()).to_int()
  let y = ((1.0 - v) * self.canvas.height.to_double()).to_int()
  
  // Clamp indices to avoid out of bounds
  let x = if x < 0 { 0 } else if x >= self.canvas.width { self.canvas.width - 1 } else { x }
  let y = if y < 0 { 0 } else if y >= self.canvas.height { self.canvas.height - 1 } else { y }
  
  self.canvas.pixel_at(x, y)
}

///|
pub impl PatternTrait for Texture with uv_at(self, u, v) {
  // Use modulo to wrap u and v to [0, 1]
  let u = u - @math.floor(u)
  let v = v - @math.floor(v)
  
  let x = (u * self.canvas.width.to_double()).to_int()
  let y = ((1.0 - v) * self.canvas.height.to_double()).to_int()
  
  // Clamp indices to avoid out of bounds
  let x = if x < 0 { 0 } else if x >= self.canvas.width { self.canvas.width - 1 } else { x }
  let y = if y < 0 { 0 } else if y >= self.canvas.height { self.canvas.height - 1 } else { y }
  
  self.canvas.pixel_at(x, y)
}

///|
pub impl PatternTrait for Texture with clone(self) {
  texture(self.canvas, mapping=self.mapping)
}

///|
pub impl Eq for Texture with equal(self, other) {
  self.canvas == other.canvas
}

///|
pub fn texture(canvas : Canvas, mapping? : &Mapping) -> Pattern {
  let m : &Mapping = match mapping {
    Some(m) => m
    None => PlanarMapping::{  } as &Mapping
  }
  let pattern = Texture::{ canvas, mapping: m }
  Pattern::new(pattern)
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// GradientCheckersPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct GradientCheckersPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn GradientCheckersPattern::to_string(
  self : GradientCheckersPattern,
) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "gradient(\{colors})"
}

///|
pub impl Show for GradientCheckersPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for GradientCheckersPattern with clone(self) {
  gradient_checkers_pattern(self.colors)
}

///|
pub impl PatternTrait for GradientCheckersPattern with uv_at(_self, _u, _v) {
  color(0, 0, 0)
}

///|
pub fn gradient_checkers_pattern(colors : Array[Color]) -> Pattern {
  let pattern = GradientCheckersPattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub impl PatternTrait for GradientCheckersPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x).to_int() +
    @math.floor(point.y).to_int() +
    @math.floor(point.z).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    let d = -index / ncols
    (index + ncols * (d + 1)) % ncols
  }
  let next_index = (index + 1) % ncols
  let ca = self.colors[index]
  let cb = self.colors[next_index]
  let t = (
      point.x +
      point.y +
      point.z -
      (@math.floor(point.x) + @math.floor(point.y) + @math.floor(point.z))
    ) /
    3
  ca + (cb - ca).mul_scalar(t)
}