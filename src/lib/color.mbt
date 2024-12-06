///|
pub(all) struct Color {
  red : Double
  green : Double
  blue : Double
  // alpha : Double
}

///|
pub fn clone(self : Color) -> Color {
  let { red, green, blue } = self
  { red, green, blue }
}

///|
pub let black : Color = color(0, 0, 0)

///|
pub let white : Color = color(1, 1, 1)

///|
pub fn to_string(self : Color) -> String {
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
pub fn op_equal(self : Color, other : Color) -> Bool {
  let { red, green, blue } = self - other
  red.abs() < EPSILON && green.abs() < EPSILON && blue.abs() < EPSILON
}

///|
pub fn op_add(self : Color, other : Color) -> Color {
  let red = self.red + other.red
  let green = self.green + other.green
  let blue = self.blue + other.blue
  { red, green, blue }
}

///|
pub fn op_sub(self : Color, other : Color) -> Color {
  let red = self.red - other.red
  let green = self.green - other.green
  let blue = self.blue - other.blue
  { red, green, blue }
}

///|
pub fn op_mul(self : Color, other : Color) -> Color {
  let red = self.red * other.red
  let green = self.green * other.green
  let blue = self.blue * other.blue
  { red, green, blue }
}

///|
pub fn mul_scalar(self : Color, s : Double) -> Color {
  let red = self.red * s
  let green = self.green * s
  let blue = self.blue * s
  { red, green, blue }
}
