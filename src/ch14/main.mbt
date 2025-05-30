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
fn main {
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
  let pattern = @lib.stripe_pattern([
    white, black, red, green, blue, c110, c011, c101, c199, c01105, c05101, c10801,
  ])

  //
  let floor = plane()
  floor..set_transform(rotation_y(0.9))
  floor.material.pattern = Some(
    {
      let p = pattern.clone()
      p.set_pattern_transform(scaling(0.1, 1, 1) * rotation_y(@math.PI / 3))
      p
    },
  )
  floor.material.specular = 0

  //
  let hex = hexagon()
  hex..set_transform(translation(0, 0.5, 0))

  //
  let world = world()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  world.lights = [light]
  world.shapes = [hex, floor]

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
    @fs.write_string_to_file!("ch14.ppm", canvas.to_ppm())
    @fs.write_bytes_to_file!("ch14.png", canvas.to_png!())
  } catch {
    _ => println("error writing ch14.png")
  }
}

///|
fn hexagon_corner() -> @lib.Shape {
  let s = sphere()
  s.set_transform(translation(0, 0, -1) * scaling(0.25, 0.25, 0.25))
  s
}

///|
fn hexagon_edge() -> @lib.Shape {
  let c = @lib.cylinder(minimum=0, maximum=1)
  c.set_transform(
    translation(0, 0, -1) *
    rotation_y(-@math.PI / 6) *
    rotation_z(-@math.PI / 2) *
    scaling(0.25, 1, 0.25),
  )
  c
}

///|
fn hexagon_side() -> @lib.Shape {
  let g = @lib.group()
  g..add_child(hexagon_corner())..add_child(hexagon_edge())
  g
}

///|
fn hexagon() -> @lib.Shape {
  let hex = @lib.group()
  for n in 0..<6 {
    let side = hexagon_side()
    side..set_transform(rotation_y(n.to_double() * @math.PI / 3))
    hex.add_child(side)
  }
  hex
}
