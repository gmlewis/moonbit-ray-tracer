///|
let canvas = @lib.canvas

test "Creating a canvas (p.46)" {
  let c = canvas!(10, 20)
  assert_eq!(c.width, 10)
  assert_eq!(c.height, 20)
  for y in 0..<c.height {
    for x in 0..<c.width {
      assert_eq!(c.pixel_at(x, y), color(0, 0, 0))
    }
  }
}

test "Writing pixels to a canvas (p.46)" {
  let c = canvas!(10, 20)
  let red = color(1, 0, 0)
  ignore(c.write_pixel(2, 3, red))
  assert_eq!(c.pixel_at(2, 3), red)
  assert_eq!(c.pixel_at(0, 0), color(0, 0, 0))
}
