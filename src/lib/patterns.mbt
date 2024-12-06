///|
pub(all) struct StripePattern {
  colors : Array[Color]
} derive(Show, Eq)

///|
pub fn stripe_pattern(colors : Array[Color]) -> StripePattern {
  { colors, }
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
