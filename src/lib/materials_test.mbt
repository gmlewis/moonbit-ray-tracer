///|
let material = @lib.material

test "The default material (p.125)" {
  let m = material()
  assert_eq!(m.color, color(1, 1, 1))
  assert_eq!(m.ambient, 0.1)
  assert_eq!(m.diffuse, 0.9)
  assert_eq!(m.specular, 0.9)
  assert_eq!(m.shininess, 200)
}

test "Lighting with the eye between the light and the surface (p.126)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq!(result, color(1.9, 1.9, 1.9))
}

test "Lighting with the eye between light and surface, eye offset 45° (p.127)" {
  let m = material()
  let position = point(0, 0, 0)
  let sq2 = 2.0.sqrt() / 2
  let eyev = vector(0, sq2, -sq2)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq!(result, color(1, 1, 1))
}

test "Lighting with the eye opposite surface, light offset 45° (p.128)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 10, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq!(result, color(0.7364, 0.7364, 0.7364))
}

test "Lighting with the eye in the path of the reflection vector (p.129)" {
  let m = material()
  let position = point(0, 0, 0)
  let sq2 = 2.0.sqrt() / 2
  let eyev = vector(0, -sq2, -sq2)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 10, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq!(result, color(1.6364, 1.6364, 1.6364))
}

test "Lighting with the light behind the surface (p.129)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, 10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq!(result, color(0.1, 0.1, 0.1))
}

test "Lighting with the surface in shadow (p.155)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let in_shadow = true
  let result = m.lighting(light, position, eyev, normalv, in_shadow~)
  assert_eq!(result, color(0.1, 0.1, 0.1))
}

test "Lighting with a pattern applied (p.176)" {
  let m = material()
  m.pattern = Some(stripe_pattern([white, black]))
  m.ambient = 1
  m.diffuse = 0
  m.specular = 0
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let c1 = m.lighting(light, point(0.9, 0, 0), eyev, normalv)
  let c2 = m.lighting(light, point(1.1, 0, 0), eyev, normalv)
  assert_eq!(c1, white)
  assert_eq!(c2, black)
}
