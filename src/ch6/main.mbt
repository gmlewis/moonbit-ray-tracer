///|
let canvas = @lib.canvas

///|
let color = @lib.color

///|
let mat4ident = @lib.mat4ident

///|
let point = @lib.point

///|
let point_light = @lib.point_light

///|
let ray = @lib.ray

///|
let sphere = @lib.sphere

///|
fn main {
  let width = 300
  let height = 300
  let c = canvas(width, height)

  // start the ray at z = -5
  let ray_origin = point(0, 0, -5)

  // put the wall at z = 10
  let wall_z = 10.0
  let wall_size = 7.0
  let pixel_size = wall_size / width.to_double()
  let half = wall_size / 2
  let shape = sphere()
  shape.material.color = color(1, 0.2, 1)
  // shape.set_transform(mat4ident().scale(1, 0.5, 1))
  // shape.set_transform(mat4ident().scale(0.5, 1, 1))
  // shape.set_transform(mat4ident().scale(0.5, 1, 1).rotate_z(@math.PI / 4))
  // shape.set_transform(mat4ident().scale(0.5, 1, 1).shear(1, 0, 0, 0, 0, 0))

  let light = point_light(point(-10, 10, -10), color(1, 1, 1))

  // for each row of pixels in the canvas
  for y in 0..<height {
    // compute the world y coordinate (top = +half, bottom = -half)
    let world_y = half - pixel_size * y.to_double()
    // for each pixel in the row
    for x in 0..<width {
      // compute the world x coordinate (right = +half, left = -half)
      let world_x = -half + pixel_size * x.to_double()
      let position = point(world_x, world_y, wall_z)

      //
      let r = ray(ray_origin, (position - ray_origin).normalize())
      let xs = shape.intersect(r)
      match xs.hit() {
        Some(hit) => {
          let point = r.position(hit.t)
          let normal = hit.object.normal_at(point)
          let eye = r.direction
          let clr = hit.object.material.lighting(light, point, eye, normal)
          c.write_pixel(x, y, clr)
        }
        _ => ()
      }
    }
  }

  //
  @fs.write_string_to_file(path="ch6.ppm", content=c.to_ppm())
  try {
    @fs.write_bytes_to_file(path="ch6.png", content=c.to_png!())
  } catch {
    _ => println("error writing ch6.png")
  }
}
