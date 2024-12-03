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
  let (r, g, b, _a) = p.rgba()
  let r = r.reinterpret_as_int().to_double() / 255
  let g = g.reinterpret_as_int().to_double() / 255
  let b = b.reinterpret_as_int().to_double() / 255
  color(r, g, b)
}
