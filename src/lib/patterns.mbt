///|
pub(open) trait PatternTrait {
  pattern_at(Self, Tuple) -> Color
  clone(Self) -> Pattern // `clone(Self) -> Self` causes a compiler error
  // https://github.com/moonbitlang/core/issues/1304
  output(Self, Logger) -> Unit
  to_string(Self) -> String
}

///|
pub(all) struct Pattern {
  pattern : PatternTrait
  // Do not modify transform directly. Use `set_transform` instead.
  mut transform : Matrix
  mut inv_transform : Matrix
} derive(Show)

///|
pub fn Pattern::new(pattern : PatternTrait) -> Pattern {
  let transform = mat4ident()
  let inv_transform = mat4ident()
  { pattern, transform, inv_transform }
}

///|
pub fn op_equal(self : Pattern, other : Pattern) -> Bool {
  // https://github.com/moonbitlang/core/issues/1304#issuecomment-2523373703
  // self.pattern == other.pattern &&
  self.transform == other.transform
}

///|
pub fn clone(self : Pattern) -> Pattern {
  let pattern = self.pattern.clone().pattern
  let transform = self.transform.clone()
  let inv_transform = self.inv_transform.clone()
  { pattern, transform, inv_transform }
}

///|
pub fn set_pattern_transform(self : Pattern, transform : Matrix) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn pattern_at_shape(
  self : Pattern,
  shape : Shape,
  world_point : Tuple
) -> Color {
  let object_point = shape.inv_transform.mul_tuple(world_point)
  let pattern_point = self.inv_transform.mul_tuple(object_point)
  self.pattern.pattern_at(pattern_point)
}

///|
pub(all) struct StripePattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn to_string(self : StripePattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  //let colors = colors.join(",")
  // YUCK! https://github.com/moonbitlang/core/pull/993
  let colors = String::concat(colors, separator=",")
  "stripe(\{colors})"
}

///|
pub fn output(self : StripePattern, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn clone(self : StripePattern) -> Pattern {
  stripe_pattern(self.colors)
}

///|
pub fn stripe_pattern(colors : Array[Color]) -> Pattern {
  let pattern = StripePattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub fn pattern_at(self : StripePattern, point : Tuple) -> Color {
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
pub(all) struct GradientPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn to_string(self : GradientPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  //let colors = colors.join(",")
  // YUCK! https://github.com/moonbitlang/core/pull/993
  let colors = String::concat(colors, separator=",")
  "gradient(\{colors})"
}

///|
pub fn output(self : GradientPattern, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn clone(self : GradientPattern) -> Pattern {
  gradient_pattern(self.colors)
}

///|
pub fn gradient_pattern(colors : Array[Color]) -> Pattern {
  let pattern = GradientPattern::{ colors, }
  Pattern::new(pattern)
}

///|
pub fn pattern_at(self : GradientPattern, point : Tuple) -> Color {
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
