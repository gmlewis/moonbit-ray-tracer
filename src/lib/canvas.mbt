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
pub fn write_pixel(self : Canvas, x : Int, y : Int, color : Color) -> Unit {
  let off = self.offset(x, y)
  self.red[off] = color.red
  self.green[off] = color.green
  self.blue[off] = color.blue
}

///|
fn clamp2ppm(v : Double) -> String {
  let v = if v < 0 { 0.0 } else if v > 1 { 1.0 } else { v }
  let v = @math.round(v * 255).to_int()
  "\{v}"
}

///|
pub fn to_ppm(self : Canvas) -> String {
  let lines = Array::new(capacity=self.height + 3)
  lines.push("P3")
  lines.push("\{self.width} \{self.height}")
  lines.push("255")
  let mut off = 0
  for y in 0..<self.height {
    let line = Array::new(capacity=self.width * 3)
    for x in 0..<self.width {
      line.push(clamp2ppm(self.red[off]))
      line.push(clamp2ppm(self.green[off]))
      line.push(clamp2ppm(self.blue[off]))
      off += 1
    }
    // lines.push(line.join(" "))
    // YUCK! https://github.com/moonbitlang/core/pull/993
    lines.push(String::concat(line, separator=" "))
  }
  // lines.join("\n")
  // YUCK! https://github.com/moonbitlang/core/pull/993
  String::concat(lines, separator="\n")
}

///|
fn clamp2byte(v : Double) -> Byte {
  let v = if v < 0 { 0.0 } else if v > 1 { 1.0 } else { v }
  @math.round(v * 255).to_int().to_byte()
}

///|
pub fn to_png(self : Canvas) -> Bytes!@image.SizeError {
  let r = @image.rect(0, 0, self.width, self.height)
  let img = @image.RGBA::new!(r)
  let mut off = 0
  for y in 0..<self.height {
    for x in 0..<self.width {
      let r = clamp2byte(self.red[off])
      let g = clamp2byte(self.green[off])
      let b = clamp2byte(self.blue[off])
      let c = @color.RGBA::new(r, g, b, 255)
      img.set_rgba(x, y, c)
      off += 1
    }
  }
  let b = @io.Buffer::new()
  guard let None = @png.encode(b, img)
  b.to_bytes()
}
