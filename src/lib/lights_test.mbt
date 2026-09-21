///|
test "A point light has a position and intensity (p.124)" {
  let intensity = @lib.color(1, 1, 1)
  let position = @lib.point(0, 0, 0)
  let light = @lib.point_light(position, intensity)
  assert_eq(light.position, position)
  assert_eq(light.intensity, intensity)
}
