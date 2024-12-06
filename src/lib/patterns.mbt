///|
pub(all) struct StripePattern {
  colors : Array[Color]
  // Do not modify transform directly. Use `set_transform` instead.
  mut transform : Matrix
  mut inv_transform : Matrix
} derive(Show, Eq)

///|
pub fn set_pattern_transform(self : StripePattern, transform : Matrix) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn stripe_pattern(colors : Array[Color]) -> StripePattern {
  let transform = mat4ident()
  let inv_transform = mat4ident()
  { colors, transform, inv_transform }
}

///|
pub fn stripe_at(self : StripePattern, point : Tuple) -> Color {
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
pub fn stripe_at_object(
  self : StripePattern,
  object : Shape,
  world_point : Tuple
) -> Color {
  let object_point = object.inv_transform.mul_tuple(world_point)
  let pattern_point = self.inv_transform.mul_tuple(object_point)
  self.stripe_at(pattern_point)
}
