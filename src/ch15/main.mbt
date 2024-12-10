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
let scaling = @lib.scaling

///|
let vector = @lib.vector

///|
let view_transform = @lib.view_transform

///|
let world = @lib.world

///|
fn main {
  let width = 200
  let height = 100
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
  let pattern = @lib.stripe_pattern(
    [
      white, black, red, green, blue, c110, c011, c101, c199, c01105, c05101, c10801,
    ],
  )

  //
  let floor = plane()..set_transform(rotation_y(0.9))
  floor.material.pattern = Some(
    pattern
    .clone()
    ..set_pattern_transform(scaling(0.1, 1, 1) * rotation_y(@math.PI / 3)),
  )
  floor.material.specular = 0

  //
  let parser = try {
    let buf = @fs.read_file_to_string!(path="teapot.obj")
    @lib.parse_obj_file!(buf)
  } catch {
    e => return println(e)
  }
  let obj = parser
    .obj_to_group()
    ..set_transform(rotation_x(-@math.PI / 2) * scaling(0.15, 0.15, 0.15))

  //
  let world = world()
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  world.lights = [light]
  world.shapes = [obj, floor]

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
  @fs.write_string_to_file(path="ch15.ppm", content=canvas.to_ppm())
  try {
    @fs.write_bytes_to_file(path="ch15.png", content=canvas.to_png!())
  } catch {
    _ => println("error writing ch15.png")
  }
}
