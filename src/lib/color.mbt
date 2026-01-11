///|
pub(all) struct Color {
  red : Double
  green : Double
  blue : Double
  // alpha : Double
}

///|
pub fn Color::clone(self : Color) -> Color {
  let { red, green, blue } = self
  { red, green, blue }
}

///|
pub let black : Color = color(0, 0, 0)

///|
pub let white : Color = color(1, 1, 1)

///|
pub fn Color::to_string(self : Color) -> String {
  let r = round_to_fixed(self.red, 5).to_string()
  let g = round_to_fixed(self.green, 5).to_string()
  let b = round_to_fixed(self.blue, 5).to_string()
  "color(\{r}, \{g}, \{b})"
}

///|
pub impl Show for Color with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn color(red : Double, green : Double, blue : Double) -> Color {
  { red, green, blue }
}

///|
pub fn Color::luminance(self : Color) -> Double {
  // Perceptual-ish luminance, clamped to [0,1].
  let v = 0.2126 * self.red + 0.7152 * self.green + 0.0722 * self.blue
  if v < 0.0 {
    0.0
  } else if v > 1.0 {
    1.0
  } else {
    v
  }
}

///|
pub impl Eq for Color with equal(self, other) {
  let { red, green, blue } = self - other
  red.abs() < EPSILON && green.abs() < EPSILON && blue.abs() < EPSILON
}

///|
pub impl Add for Color with add(self, other) {
  let red = self.red + other.red
  let green = self.green + other.green
  let blue = self.blue + other.blue
  { red, green, blue }
}

///|
pub impl Sub for Color with sub(self, other) {
  let red = self.red - other.red
  let green = self.green - other.green
  let blue = self.blue - other.blue
  { red, green, blue }
}

///|
pub impl Mul for Color with mul(self, other) {
  let red = self.red * other.red
  let green = self.green * other.green
  let blue = self.blue * other.blue
  { red, green, blue }
}

///|
pub fn Color::mul_scalar(self : Color, s : Double) -> Color {
  let red = self.red * s
  let green = self.green * s
  let blue = self.blue * s
  color(red, green, blue).clamp_valid()
}

///|
pub fn Color::clamp_valid(self : Color) -> Color {
  let r = if self.red.is_nan() || self.red.is_inf() { 0.0 } else { self.red }
  let g = if self.green.is_nan() || self.green.is_inf() {
    0.0
  } else {
    self.green
  }
  let b = if self.blue.is_nan() || self.blue.is_inf() { 0.0 } else { self.blue }
  color(r, g, b)
}

///|
fn srgb_to_linear_value(v : Double) -> Double {
  let v = if v < 0 { 0.0 } else { v }
  if v <= 0.04045 {
    v / 12.92
  } else {
    @math.pow((v + 0.055) / 1.055, 2.4)
  }
}

///|
pub fn Color::srgb_to_linear(self : Color) -> Color {
  color(
    srgb_to_linear_value(self.red),
    srgb_to_linear_value(self.green),
    srgb_to_linear_value(self.blue),
  )
}
