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
pub fn Camera::ray_for_pixel(
  self : Camera,
  px : Int,
  py : Int,
  offset_x? : Double = 0.5,
  offset_y? : Double = 0.5,
) -> Ray {
  // the offset from the edge of the canvas to the pixel's center
  let xoffset = (px.to_double() + offset_x) * self.pixel_size
  let yoffset = (py.to_double() + offset_y) * self.pixel_size
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
pub async fn Camera::render(
  self : Camera,
  world : World,
  samples? : Int = 1,
  progress? : async (Int) -> Unit,
) -> Canvas {
  let image = canvas(self.hsize, self.vsize)
  let samples = if samples < 1 { 1 } else { samples }
  let rng = @random.Rand::chacha8()
  for y in 0..<self.vsize {
    for x in 0..<self.hsize {
      let mut color = color(0, 0, 0)
      if samples == 1 {
        let ray = self.ray_for_pixel(x, y)
        color = world.color_at(ray)
      } else {
        for s in 0..<samples {
          let rx = rng.double()
          let ry = rng.double()
          let ray = self.ray_for_pixel(x, y, offset_x=rx, offset_y=ry)
          color = color + world.color_at(ray)
        }
        color = color.mul_scalar(1.0 / samples.to_double())
      }
      image.write_pixel(x, y, color)
    }
    match progress {
      Some(f) => f(y + 1)
      None => ()
    }
    @async.pause()
  }
  image
}
