///|
pub(all) struct Canvas {
  width : Int
  height : Int
  red : Array[Double]
  green : Array[Double]
  blue : Array[Double]
  mut exposure : Double
  mut use_tone_mapping : Bool
} derive(Show, Eq)

///|
pub fn canvas(width : Int, height : Int) -> Canvas {
  let size = width * height
  let red = Array::make(size, 0.0)
  let green = Array::make(size, 0.0)
  let blue = Array::make(size, 0.0)
  { width, height, red, green, blue, exposure: 1.0, use_tone_mapping: false }
}

///|
fn Canvas::offset(self : Canvas, x : Int, y : Int) -> Int {
  y * self.width + x
}

///|
pub fn Canvas::pixel_at(self : Canvas, x : Int, y : Int) -> Color {
  let x = if x < 0 { 0 } else if x >= self.width { self.width - 1 } else { x }
  let y = if y < 0 { 0 } else if y >= self.height { self.height - 1 } else { y }
  let off = self.offset(x, y)
  let r = self.red[off]
  let g = self.green[off]
  let b = self.blue[off]
  color(r, g, b)
}

///|
pub fn Canvas::pixel_at_bilinear(
  self : Canvas,
  u : Double,
  v : Double,
) -> Color {
  let x = u * (self.width - 1).to_double()
  let y = (1.0 - v) * (self.height - 1).to_double()
  let x1 = @math.floor(x).to_int()
  let y1 = @math.floor(y).to_int()
  let x2 = @cmp.minimum(x1 + 1, self.width - 1)
  let y2 = @cmp.minimum(y1 + 1, self.height - 1)
  let dx = x - @math.floor(x)
  let dy = y - @math.floor(y)
  let c11 = self.pixel_at(x1, y1)
  let c21 = self.pixel_at(x2, y1)
  let c12 = self.pixel_at(x1, y2)
  let c22 = self.pixel_at(x2, y2)
  let r1 = c11.mul_scalar(1.0 - dx) + c21.mul_scalar(dx)
  let r2 = c12.mul_scalar(1.0 - dx) + c22.mul_scalar(dx)
  r1.mul_scalar(1.0 - dy) + r2.mul_scalar(dy)
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
fn tone_map_and_gamma(v : Double, exposure : Double) -> Double {
  let v = v * exposure
  // ACES Filmic Tone Mapping Curve approximation
  let a = 2.51
  let b = 0.03
  let c = 2.43
  let d = 0.59
  let e = 0.14
  let v = v * (a * v + b) / (v * (c * v + d) + e)

  // Clamp to [0, 1]
  let v = if v < 0.0 { 0.0 } else if v > 1.0 { 1.0 } else { v }

  // Gamma Correction (approx 2.2)
  @math.pow(v, 1.0 / 2.2)
}

///|
fn clamp2ppm(v : Double, exposure : Double, use_tone_mapping : Bool) -> String {
  let v = if use_tone_mapping { tone_map_and_gamma(v, exposure) } else { v }
  let v = if v < 0.0 { 0.0 } else if v > 1.0 { 1.0 } else { v }
  let v = @math.round(v * 255).to_int()
  v.to_string()
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
      let s = clamp2ppm(v, self.exposure, self.use_tone_mapping)
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
pub fn Canvas::from_image(
  img : &@image.Image,
  linear? : Bool = false,
) -> Canvas {
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
      let c1 = color(r, g, b)
      c.write_pixel(x, y, if linear { c1 } else { c1.srgb_to_linear() })
    }
  }
  c
}

///|
pub fn Canvas::from_png(png_data : Bytes, linear? : Bool = false) -> Canvas? {
  let b = @io.Buffer::from_bytes(png_data)
  let (img, err) = @png.decode(b)
  if err is None {
    Some(Canvas::from_image(img, linear~))
  } else {
    None
  }
}

///|
pub fn Canvas::from_jpeg(jpeg_data : Bytes, linear? : Bool = false) -> Canvas? {
  let b = @io.Buffer::from_bytes(jpeg_data)
  let (img, err) = @jpeg.decode(b)
  if err is None {
    Some(Canvas::from_image(img, linear~))
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
fn clamp2byte(v : Double, exposure : Double, use_tone_mapping : Bool) -> Byte {
  let v = if use_tone_mapping { tone_map_and_gamma(v, exposure) } else { v }
  let v = if v < 0.0 { 0.0 } else if v > 1.0 { 1.0 } else { v }
  @math.round(v * 255).to_int().to_byte()
}

///|
pub fn Canvas::to_png(self : Canvas) -> Bytes raise @image.SizeError {
  let r = @image.rect(0, 0, self.width, self.height)
  let img = @image.RGBA::new(r)
  let mut off = 0
  for y in 0..<self.height {
    for x in 0..<self.width {
      let r = clamp2byte(self.red[off], self.exposure, self.use_tone_mapping)
      let g = clamp2byte(self.green[off], self.exposure, self.use_tone_mapping)
      let b = clamp2byte(self.blue[off], self.exposure, self.use_tone_mapping)
      let c = @color.RGBA::new(r, g, b, 255)
      img.set_rgba(x, y, c)
      off += 1
    }
  }
  let b = @io.Buffer::new()
  guard @png.encode(b, img) is None
  b.to_bytes()
}
