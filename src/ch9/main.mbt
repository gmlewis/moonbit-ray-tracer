///|
let camera = @lib.camera

///|
let color = @lib.color

///|
let plane = @lib.plane

///|
let point = @lib.point

///|
let point_light = @lib.point_light

///|
let scaling = @lib.scaling

///|
let sphere = @lib.sphere

///|
let translation = @lib.translation

///|
let vector = @lib.vector

///|
let view_transform = @lib.view_transform

///|
let world = @lib.world

///|
fn main {
  let width = 600
  let height = 300

  //
  let floor = plane()
  floor.material.color = color(1, 0.9, 0.9)
  floor.material.specular = 0

  //
  let middle = sphere()..set_transform(translation(-0.5, 1, 0.5))
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3

  //
  let right = sphere()..set_transform(
    translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5),
  )
  right.material.color = color(0.5, 1, 0.1)
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  //
  let left = sphere()..set_transform(
    translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33),
  )
  left.material.color = color(1, 0.8, 0.1)
  left.material.diffuse = 0.7
  left.material.specular = 0.3

  //
  let world = world()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  world.lights = [light]
  world.shapes = [left, right, middle, floor]

  //
  let camera = camera(width, height, @math.PI / 3)
  camera.transform = view_transform(
    point(0, 1.5, -5),
    point(0, 1, 0),
    vector(0, 1, 0),
  )

  //
  let canvas = camera.render(world)

  //
  @fs.write_string_to_file(path="ch9.ppm", content=canvas.to_ppm())
  try {
    @fs.write_bytes_to_file(path="ch9.png", content=canvas.to_png!())
  } catch {
    _ => println("error writing ch9.png")
  }
}
