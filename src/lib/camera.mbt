///|
pub(all) struct Camera {
  hsize : Int
  vsize : Int
  field_of_view : Double
  mut transform : Matrix
  pixel_size : Double
  half_width : Double
  half_height : Double
} derive(Show, Eq)

///|
pub fn camera(hsize : Int, vsize : Int, field_of_view : Double) -> Camera {
  let transform = mat4ident()
  let half_view = @math.tan(field_of_view / 2)
  let aspect = hsize.to_double() / vsize.to_double()
  let (half_width, half_height) = if aspect >= 1 {
    (half_view, half_view / aspect)
  } else {
    (half_view * aspect, half_view)
  }
  let pixel_size = half_width * 2 / hsize.to_double()
  {
    hsize,
    vsize,
    field_of_view,
    transform,
    pixel_size,
    half_width,
    half_height,
  }
}

///|
pub fn Camera::ray_for_pixel(self : Camera, px : Int, py : Int) -> Ray {
  // the offset from the edge of the canvas to the pixel's center
  let xoffset = (px.to_double() + 0.5) * self.pixel_size
  let yoffset = (py.to_double() + 0.5) * self.pixel_size
  // the untransformed coordinates of the pixel in world space
  // (the camera looks toward -z, so +x is to the *left*)
  let world_x = self.half_width - xoffset
  let world_y = self.half_height - yoffset

  // using the camera matrix, transform the canvas point and the origin
  // and then compute the ray's direction vector.
  // (the canvas is at z = -1)
  let inv = self.transform.inverse()
  let pixel = inv.mul_tuple(point(world_x, world_y, -1))
  let origin = inv.mul_tuple(point(0, 0, 0))
  let direction = (pixel - origin).normalize()
  ray(origin, direction)
}

///|
pub fn Camera::render(self : Camera, world : World) -> Canvas {
  let image = canvas(self.hsize, self.vsize)
  for y in 0..<self.vsize {
    for x in 0..<self.hsize {
      let ray = self.ray_for_pixel(x, y)
      let color = world.color_at(ray)
      image.write_pixel(x, y, color)
    }
  }
  image
}
