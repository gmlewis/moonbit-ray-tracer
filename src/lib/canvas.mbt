///|
pub(all) struct Canvas {
  width : Int
  height : Int
  image : @image.Image
}

///|
pub fn canvas(width : Int, height : Int) -> Canvas!@image.SizeError {
  let r = @image.rect(0, 0, width, height)
  let image = @image.RGBA::new!(r)
  { width, height, image }
}

///|
pub fn pixel_at(self : Canvas, x : Int, y : Int) -> Color {
  let p = self.image.at(x, y)
  let { r, g, b, .. } = @color.RGBA::from(p)
  let r = r.to_int().to_double() / 255
  let g = g.to_int().to_double() / 255
  let b = b.to_int().to_double() / 255
  color(r, g, b)
}

///|
pub fn write_pixel(self : Canvas, x : Int, y : Int, color : Color) -> Canvas {
  let r = @math.round(color.red * 255).to_int().to_byte()
  let g = @math.round(color.green * 255).to_int().to_byte()
  let b = @math.round(color.blue * 255).to_int().to_byte()
  let c = @color.RGBA::new(r, g, b, 255)
  self.image.set(x, y, c)
  self
}
