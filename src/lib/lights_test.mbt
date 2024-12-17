test "A point light has a position and intensity (p.124)" {
  let intensity = color(1, 1, 1)
  let position = point(0, 0, 0)
  let light = point_light(position, intensity)
  assert_eq!(light.position, position)
  assert_eq!(light.intensity, intensity)
}
