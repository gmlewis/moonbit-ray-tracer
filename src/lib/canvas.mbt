///|
pub(all) struct Canvas {
  width : Int
  height : Int
  red : Array[Double]
  green : Array[Double]
  blue : Array[Double]
} derive(Show, Eq)

///|
pub fn canvas(width : Int, height : Int) -> Canvas {
  let size = width * height
  let red = Array::make(size, 0.0)
  let green = Array::make(size, 0.0)
  let blue = Array::make(size, 0.0)
  { width, height, red, green, blue }
}

///|
fn Canvas::offset(self : Canvas, x : Int, y : Int) -> Int {
  y * self.width + x
}

///|
pub fn Canvas::pixel_at(self : Canvas, x : Int, y : Int) -> Color {
  let off = self.offset(x, y)
  let r = self.red[off]
  let g = self.green[off]
  let b = self.blue[off]
  color(r, g, b)
}

///|
pub fn Canvas::write_pixel(
  self : Canvas,
  x : Int,
  y : Int,
  color : Color,
) -> Unit {
  let off = self.offset(x, y)
  self.red[off] = color.red
  self.green[off] = color.green
  self.blue[off] = color.blue
}

///|
/// clear clears the canvas to the provided color.
pub fn Canvas::clear(self : Canvas, color : Color) -> Unit {
  let mut off = 0
  for y in 0..<self.height {
    for x in 0..<self.width {
      self.red[off] = color.red
      self.green[off] = color.green
      self.blue[off] = color.blue
      off += 1
    }
  }
}

///|
fn clamp2ppm(v : Double) -> String {
  let v = if v < 0 { 0.0 } else if v > 1 { 1.0 } else { v }
  let v = @math.round(v * 255).to_int()
  "\{v}"
}

///|
const MAX_PPM_LINE_LENGTH = 70

///|
pub fn Canvas::to_ppm(self : Canvas) -> String {
  let lines = Array::new(capacity=self.height + 4)
  lines.push("P3")
  lines.push("\{self.width} \{self.height}")
  lines.push("255")
  let mut off = 0
  for y in 0..<self.height {
    let mut line = StringBuilder::new(size_hint=MAX_PPM_LINE_LENGTH)
    let mut len = 0
    let f = fn(v : Double) {
      let s = clamp2ppm(v)
      if len + 1 + s.length() > MAX_PPM_LINE_LENGTH {
        lines.push(line.to_string())
        line = StringBuilder::new(size_hint=MAX_PPM_LINE_LENGTH)
        line.write_string(s)
        len = s.length()
      } else {
        if len > 0 {
          line.write_string(" ")
          len += 1
        }
        line.write_string(s)
        len += s.length()
      }
    }
    for x in 0..<self.width {
      f(self.red[off])
      f(self.green[off])
      f(self.blue[off])
      off += 1
    }
    if len > 0 {
      lines.push(line.to_string())
    }
  }
  lines.push("")
  lines.join("\n")
}

///|
pub fn Canvas::from_image(img : &@image.Image) -> Canvas {
  let rect = img.bounds()
  let width = rect.dx()
  let height = rect.dy()
  let c = canvas(width, height)
  for y in 0..<height {
    for x in 0..<width {
      let clr = img.at(rect.min.x + x, rect.min.y + y)
      let (r, g, b, _) = clr.rgba()
      // rgba() returns values in range [0, 65535]
      let r = r.to_double() / 65535.0
      let g = g.to_double() / 65535.0
      let b = b.to_double() / 65535.0
      c.write_pixel(x, y, color(r, g, b))
    }
  }
  c
}

///|
pub fn Canvas::from_png(png_data : Bytes) -> Canvas? {
  let b = @io.Buffer::from_bytes(png_data)
  let (img, err) = @png.decode(b)
  if err is None {
    Some(Canvas::from_image(img))
  } else {
    None
  }
}

///|
pub fn Canvas::from_hdr(hdr : @hdr.HdrImage) -> Canvas {
  let c = canvas(hdr.width, hdr.height)
  for y in 0..<hdr.height {
    for x in 0..<hdr.width {
      let offset = (y * hdr.width + x) * 3
      let r = hdr.data[offset + 0]
      let g = hdr.data[offset + 1]
      let b = hdr.data[offset + 2]
      c.write_pixel(x, y, color(r, g, b))
    }
  }
  c
}

///|
fn clamp2byte(v : Double) -> Byte {
  let v = if v < 0 { 0.0 } else if v > 1 { 1.0 } else { v }
  @math.round(v * 255).to_int().to_byte()
}

///|
pub fn Canvas::to_png(self : Canvas) -> Bytes raise @image.SizeError {
  let r = @image.rect(0, 0, self.width, self.height)
  let img = @image.RGBA::new(r)
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
  guard @png.encode(b, img) is None
  b.to_bytes()
}
