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
let gradient_checkers_pattern = @lib.gradient_checkers_pattern

///|
let translation = @lib.translation

///|
let vector = @lib.vector

///|
let view_transform = @lib.view_transform

///|
let world = @lib.world

///|
async fn main {
  let width = 100
  let height = 50
  let world = world()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  world.lights = [light]

  //
  let white = color(1, 1, 1)
  let black = color(0, 0, 0)
  let pattern = gradient_checkers_pattern([white, black])
  pattern.set_pattern_transform(scaling(0.5, 0.5, 0.5))

  //
  let floor = plane()
  floor.material.pattern = Some(pattern)
  floor.material.specular = 0

  //
  let middle = sphere()
  middle.set_transform(translation(-0.5, 1, 0.5))
  middle.material.color = color(0.1, 1, 0.5)
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3

  //
  let right = sphere()
  right.set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5))
  right.material.color = color(0.5, 1, 0.1)
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  //
  let left = sphere()
  left.set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33))
  left.material.color = color(1, 0.8, 0.1)
  left.material.diffuse = 0.7
  left.material.specular = 0.3

  //
  world.shapes = [floor, middle, right, left]

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
    @fs.write_file("ch10-gradient-checkers.ppm", canvas.to_ppm(), create=0o644)
    @fs.write_file("ch10-gradient-checkers.png", canvas.to_png(), create=0o644)
  } catch {
    _ => println("error writing ch10-gradient-checkers.png")
  }
}
