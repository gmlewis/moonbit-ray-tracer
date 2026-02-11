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
let rotation_x = @lib.rotation_x

///|
let rotation_y = @lib.rotation_y

///|
let rotation_z = @lib.rotation_z

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
async fn main {
  let width = 600
  let height = 300
  let white = color(1, 1, 1)
  let black = color(0, 0, 0)
  let red = color(1, 0, 0)
  let green = color(0, 1, 0)
  let blue = color(0, 0, 1)
  let c110 = color(1, 1, 0)
  let c011 = color(0, 1, 1)
  let c101 = color(1, 0, 1)
  let c199 = color(1, 0.9, 0.9)
  let c01105 = color(0.1, 1, 0.5)
  let c05101 = color(0.5, 1, 0.1)
  let c10801 = color(1, 0.8, 0.1)
  let pattern = @lib.checkers_pattern([
    white, black, red, green, blue, c110, c011, c101, c199, c01105, c05101, c10801,
  ])

  //
  let floor = plane()
  floor.set_transform(rotation_y(0.9))
  floor.material.pattern = Some(
    {
      let p = pattern.clone()
      p.set_pattern_transform(scaling(0.1, 1, 1) * rotation_y(@math.PI / 3))
      p
    },
  )
  floor.material.specular = 0

  //
  let middle = sphere()
  middle.set_transform(
    translation(-0.5, 1, 0.5) *
    rotation_x(1.9) *
    rotation_y(0.9) *
    rotation_z(3.3),
  )
  middle.material.pattern = Some(
    {
      let p = pattern.clone()
      p.set_pattern_transform(scaling(0.3, 1, 1) * rotation_y(@math.PI / 4))
      p
    },
  )
  middle.material.diffuse = 0.7
  middle.material.specular = 0.3

  //
  let right = sphere()
  right.set_transform(
    translation(1.5, 0.5, -0.5) *
    scaling(0.5, 0.5, 0.5) *
    rotation_x(0.9) *
    rotation_y(1.3) *
    rotation_z(1.9),
  )
  right.material.pattern = Some(
    {
      let p = pattern.clone()
      p.set_pattern_transform(scaling(0.01, 1, 1) * rotation_y(@math.PI / 7))
      p
    },
  )
  right.material.diffuse = 0.7
  right.material.specular = 0.3

  //
  let left = sphere()
  left.set_transform(
    translation(-1.5, 0.33, -0.75) *
    scaling(0.33, 0.33, 0.33) *
    rotation_x(1.3) *
    rotation_y(1.9) *
    rotation_z(0.9),
  )
  left.material.pattern = Some(
    {
      let p = pattern.clone()
      p.set_pattern_transform(scaling(0.7, 1, 1) * rotation_y(@math.PI + 0.3))
      p
    },
  )
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
  try {
    @fs.write_file("ch10-checkers.ppm", canvas.to_ppm(), create=0o644)
    @fs.write_file("ch10-checkers.png", canvas.to_png(), create=0o644)
  } catch {
    _ => println("error writing ch10-checkers.png")
  }
}
