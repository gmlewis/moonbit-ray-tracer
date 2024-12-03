///
pub(all) struct Color {
  red : Double
  green : Double
  blue : Double
  // alpha : Double
} derive(Show)

///
pub fn color(red : Double, green : Double, blue : Double) -> Color {
  { red, green, blue }
}

///
pub fn op_equal(self : Color, other : Color) -> Bool {
  let { red, green, blue } = self - other
  red.abs() < EPSILON && green.abs() < EPSILON && blue.abs() < EPSILON
}

///
pub fn op_add(self : Color, other : Color) -> Color {
  let red = self.red + other.red
  let green = self.green + other.green
  let blue = self.blue + other.blue
  { red, green, blue }
}

///
pub fn op_sub(self : Color, other : Color) -> Color {
  let red = self.red - other.red
  let green = self.green - other.green
  let blue = self.blue - other.blue
  { red, green, blue }
}

///
pub fn op_mul(self : Color, other : Color) -> Color {
  let red = self.red * other.red
  let green = self.green * other.green
  let blue = self.blue * other.blue
  { red, green, blue }
}

///
pub fn mul_scalar(self : Color, s : Double) -> Color {
  let red = self.red * s
  let green = self.green * s
  let blue = self.blue * s
  { red, green, blue }
}
