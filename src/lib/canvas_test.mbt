///|
let canvas = @lib.canvas

test "Creating a canvas" {
  let c = canvas!(10, 20)
  assert_eq!(c.width, 10)
  assert_eq!(c.height, 20)
  for y in 0..<c.height {
    for x in 0..<c.width {
      assert_eq!(c.pixel_at(x, y), color(0, 0, 0))
    }
  }
}
