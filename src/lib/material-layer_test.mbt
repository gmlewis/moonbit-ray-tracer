///|
// Material layering: blend base vs top material lighting using a mask pattern.

///|
test "material layer blends base and top via mask" {
  let base = material()
  base.lighting_mode = Phong
  base.color = color(1.0, 0.0, 0.0)
  base.diffuse = 1.0
  base.specular = 0.0
  let top = material()
  top.lighting_mode = Phong
  top.color = color(0.0, 0.0, 1.0)
  top.diffuse = 1.0
  top.specular = 0.0
  let s = sphere()
  s.material = base
  s.material_layer = Some({
    top,
    mask: stripe_pattern([color(0.0, 0.0, 0.0), color(1.0, 1.0, 1.0)]),
    opacity: 1.0,
  })
  let light = point_light(point(0.0, 0.0, -10.0), color(1.0, 1.0, 1.0))
  let eyev = vector(0.0, 0.0, -1.0)
  let normalv = vector(0.0, 0.0, -1.0)

  // Keep the hit point fixed so N·L stays constant; toggle the mask using UVs.
  let p = point(0.0, 0.0, 0.0)

  // Mask black => base.
  let uv0 = Some((0.25, 0.5))
  let c0 = s.material.lighting(light, p, eyev, normalv, shape=Some(s), uv0?)
  assert_true((c0.red - 1.0).abs() < 1.e-6)
  assert_true(c0.blue < 1.e-6)

  // Mask white => top.
  let uv0 = Some((0.75, 0.5))
  let c1 = s.material.lighting(light, p, eyev, normalv, shape=Some(s), uv0?)
  assert_true((c1.blue - 1.0).abs() < 1.e-6)
  assert_true(c1.red < 1.e-6)
}

///|
test "material layer opacity scales mask" {
  let base = material()
  base.lighting_mode = Phong
  base.color = color(1.0, 0.0, 0.0)
  base.diffuse = 1.0
  base.specular = 0.0
  let top = material()
  top.lighting_mode = Phong
  top.color = color(0.0, 0.0, 1.0)
  top.diffuse = 1.0
  top.specular = 0.0
  let s = sphere()
  s.material = base
  s.material_layer = Some({
    top,
    mask: stripe_pattern([color(1.0, 1.0, 1.0), color(1.0, 1.0, 1.0)]),
    opacity: 0.5,
  })
  let light = point_light(point(0.0, 0.0, -10.0), color(1.0, 1.0, 1.0))
  let eyev = vector(0.0, 0.0, -1.0)
  let normalv = vector(0.0, 0.0, -1.0)
  let c = s.material.lighting(
    light,
    point(0.0, 0.0, 0.0),
    eyev,
    normalv,
    shape=Some(s),
  )
  // Halfway between red and blue.
  assert_true((c.red - 0.5).abs() < 1.e-6)
  assert_true((c.blue - 0.5).abs() < 1.e-6)
}
