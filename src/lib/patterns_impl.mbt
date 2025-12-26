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
pub impl PatternTrait for StripePattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub impl PatternTrait for StripePattern with uv_at(self, u, _v) {
  let ncols = self.colors.length()
  let index = @math.floor(u * ncols.to_double()).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub fn stripe_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(StripePattern::{ colors, })
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
pub impl PatternTrait for GradientPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let t = point.x - @math.floor(point.x)
  let index = @math.floor(point.x).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  let next_index = (index + 1) % ncols
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(t)
}

///|
pub impl PatternTrait for GradientPattern with uv_at(self, u, _v) {
  let ncols = self.colors.length()
  let t = u * ncols.to_double()
  let index = @math.floor(t).to_int() % ncols
  let next_index = (index + 1) % ncols
  let fraction = t - @math.floor(t)
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(fraction)
}

///|
pub fn gradient_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(GradientPattern::{ colors, })
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
pub impl PatternTrait for RingPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let r = (point.x * point.x + point.z * point.z).sqrt()
  let index = @math.floor(r).to_int() % ncols
  self.colors[index]
}

///|
pub impl PatternTrait for RingPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let dist = ((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)).sqrt()
  let index = @math.floor(dist * 2.0 * ncols.to_double()).to_int() % ncols
  self.colors[index]
}

///|
pub fn ring_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(RingPattern::{ colors, })
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
pub impl PatternTrait for GradientRingPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let r = (point.x * point.x + point.z * point.z).sqrt()
  let t = r - @math.floor(r)
  let index = @math.floor(r).to_int() % ncols
  let next_index = (index + 1) % ncols
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(t)
}

///|
pub impl PatternTrait for GradientRingPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let dist = ((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)).sqrt()
  let t = dist * 2.0 * ncols.to_double()
  let index = @math.floor(t).to_int() % ncols
  let next_index = (index + 1) % ncols
  let fraction = t - @math.floor(t)
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(fraction)
}

///|
pub fn gradient_ring_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(GradientRingPattern::{ colors, })
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
pub impl PatternTrait for CheckersPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x + 0.00001).to_int() +
    @math.floor(point.y + 0.00001).to_int() +
    @math.floor(point.z + 0.00001).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub impl PatternTrait for CheckersPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let index = @math.floor(u * 2.0 + 0.00001).to_int() +
    @math.floor(v * 2.0 + 0.00001).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub fn checkers_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(CheckersPattern::{ colors, })
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
  self.uv_at(u, v)
}

///|
pub impl PatternTrait for Texture with uv_at(self, u, v) {
  let u = u - @math.floor(u)
  let v = v - @math.floor(v)
  self.canvas.pixel_at_bilinear(u, v)
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
  Pattern::new(Texture::{ canvas, mapping: m })
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
  "gradient_checkers(\{colors})"
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
pub impl PatternTrait for GradientCheckersPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let x_floor = @math.floor(point.x)
  let y_floor = @math.floor(point.y)
  let z_floor = @math.floor(point.z)
  let index = x_floor.to_int() + y_floor.to_int() + z_floor.to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  let next_index = (index + 1) % ncols
  let t = (point.x - x_floor + point.y - y_floor + point.z - z_floor) / 3.0
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(t)
}

///|
pub impl PatternTrait for GradientCheckersPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let t = (u + v) * 2.0
  let index = @math.floor(t).to_int() % ncols
  let next_index = (index + 1) % ncols
  let fraction = t - @math.floor(t)
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(fraction)
}

///|
pub fn gradient_checkers_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(GradientCheckersPattern::{ colors, })
}
