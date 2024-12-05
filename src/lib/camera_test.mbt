///|
let camera = @lib.camera

test "Constructing a camera (p.144)" {
  let hsize = 160
  let vsize = 120
  let field_of_view = @math.PI / 2
  let c = camera(hsize, vsize, field_of_view)
  assert_eq!(c.hsize, 160)
  assert_eq!(c.vsize, 120)
  assert_eq!(c.field_of_view, @math.PI / 2)
  assert_eq!(c.transform, mat4ident())
}

test "The pixel size for a horizontal canvas (p.144)" {
  let c = camera(200, 125, @math.PI / 2)
  assert_eq!(c.pixel_size, 0.01)
}

test "The pixel size for a vertical canvas (p.144)" {
  let c = camera(125, 200, @math.PI / 2)
  assert_eq!(c.pixel_size, 0.01)
}

test "Constructing a ray through the center of the canvas (p.146)" {
  let c = camera(201, 101, @math.PI / 2)
  let r = c.ray_for_pixel(100, 50)
  assert_eq!(r.origin, point(0, 0, 0))
  assert_eq!(r.direction, vector(0, 0, -1))
}

test "Constructing a ray through a corner of the canvas (p.146)" {
  let c = camera(201, 101, @math.PI / 2)
  let r = c.ray_for_pixel(0, 0)
  assert_eq!(r.origin, point(0, 0, 0))
  assert_eq!(r.direction, vector(0.66519, 0.33259, -0.66851))
}

test "Constructing a ray when the camera is transformed (p.146)" {
  let c = camera(201, 101, @math.PI / 2)
  c.transform = rotation_y(@math.PI / 4) * translation(0, -2, 5)
  let r = c.ray_for_pixel(100, 50)
  assert_eq!(r.origin, point(0, 2, -5))
  let sq2 = 2.0.sqrt() / 2
  assert_eq!(r.direction, vector(sq2, 0, -sq2))
}
