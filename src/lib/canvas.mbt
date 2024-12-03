///|
pub(all) struct Canvas {
  width : Int
  height : Int
  red : Array[Double]
  green : Array[Double]
  blue : Array[Double]
}

///|
pub fn canvas(width : Int, height : Int) -> Canvas {
  let size = width * height
  let red = Array::make(size, 0.0)
  let green = Array::make(size, 0.0)
  let blue = Array::make(size, 0.0)
  { width, height, red, green, blue }
}

///|
fn offset(self : Canvas, x : Int, y : Int) -> Int {
  y * self.width + x
}

///|
pub fn pixel_at(self : Canvas, x : Int, y : Int) -> Color {
  let off = self.offset(x, y)
  let r = self.red[off]
  let g = self.green[off]
  let b = self.blue[off]
  color(r, g, b)
}

///|
pub fn write_pixel(self : Canvas, x : Int, y : Int, color : Color) -> Canvas {
  let off = self.offset(x, y)
  self.red[off] = color.red
  self.green[off] = color.green
  self.blue[off] = color.blue
  self
}

///|
pub fn to_ppm(self : Canvas) -> String {
  #|P3
  $|\{self.width} \{self.height}
  #|255
}
