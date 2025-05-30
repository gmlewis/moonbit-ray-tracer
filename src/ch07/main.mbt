///|
let camera = @lib.camera

///|
let color = @lib.color

///|
let point = @lib.point

///|
let point_light = @lib.point_light

///|
let rotation_x = @lib.rotation_x

///|
let rotation_y = @lib.rotation_y

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
  let floor = sphere()
  floor..set_transform(scaling(10, 0.01, 10))
  floor.material.color = color(1, 0.9, 0.9)
  floor.material.specular = 0

  //
  let left_wall = sphere()
  left_wall..set_transform(
    translation(0, 0, 5) *
    rotation_y(-@math.PI / 4) *
    rotation_x(@math.PI / 2) *
    scaling(10, 0.01, 10),
  )
  left_wall.material = floor.material

  //
  let right_wall = sphere()
  right_wall..set_transform(
    translation(0, 0, 5) *
    rotation_y(@math.PI / 4) *
    rotation_x(@math.PI / 2) *
    scaling(10, 0.01, 10),
  )
  right_wall.material = floor.material

  //
  let middle = sphere()
  middle..set_transform(translation(-0.5, 1, 0.5))
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3

  //
  let right = sphere()
  right..set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5))
  right.material.color = color(0.5, 1, 0.1)
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  //
  let left = sphere()
  left..set_transform(
    translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33),
  )
  left.material.color = color(1, 0.8, 0.1)
  left.material.diffuse = 0.7
  left.material.specular = 0.3

  //
  let world = world()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  world.lights = [light]
  world.shapes = [left, right, middle, left_wall, right_wall, floor]

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
  try {
    @fs.write_string_to_file!("ch7.ppm", canvas.to_ppm())
    @fs.write_bytes_to_file!("ch7.png", canvas.to_png!())
  } catch {
    _ => println("error writing ch7.png")
  }
}
