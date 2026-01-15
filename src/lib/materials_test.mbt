///|
test "The default material (p.125)" {
  let m = material()
  assert_eq(m.color, color(1, 1, 1))
  assert_eq(m.ambient, 0.1)
  assert_eq(m.diffuse, 0.9)
  assert_eq(m.specular, 0.9)
  assert_eq(m.shininess, 200)
}

///|
test "Lighting with the eye between the light and the surface (p.126)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq(result, color(1.8, 1.8, 1.8))
}

///|
test "Lighting with the eye between light and surface, eye offset 45° (p.127)" {
  let m = material()
  let position = point(0, 0, 0)
  let sq2 = 2.0.sqrt() / 2
  let eyev = vector(0, sq2, -sq2)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq(result, color(0.9, 0.9, 0.9))
}

///|
test "Lighting with the eye opposite surface, light offset 45° (p.128)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 10, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq(result, color(0.6364, 0.6364, 0.6364))
}

///|
test "Lighting with the eye in the path of the reflection vector (p.129)" {
  let m = material()
  let position = point(0, 0, 0)
  let sq2 = 2.0.sqrt() / 2
  let eyev = vector(0, -sq2, -sq2)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 10, -10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq(result, color(1.5364, 1.5364, 1.5364))
}

///|
test "Lighting with the light behind the surface (p.129)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, 10), color(1, 1, 1))
  let result = m.lighting(light, position, eyev, normalv)
  assert_eq(result, color(0, 0, 0))
}

///|
test "Lighting with the surface in shadow (p.155)" {
  let m = material()
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let in_shadow = true
  let result = m.lighting(light, position, eyev, normalv, in_shadow~)
  assert_eq(result, color(0, 0, 0))
}

///|
test "PBR: metallic_pattern overrides metallic" {
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let shape = Some(sphere())
  let base = material()
  base.lighting_mode = PBR
  base.color = color(0.2, 0.6, 0.9)
  base.metallic = 0.0
  base.roughness = 0.5
  let c0 = base.lighting(light, position, eyev, normalv, shape~)
  let patterned = base.clone()
  patterned.metallic_pattern = Some(stripe_pattern([white, white]))
  let c1 = patterned.lighting(light, position, eyev, normalv, shape~)
  let delta = (c0.red - c1.red).abs() +
    (c0.green - c1.green).abs() +
    (c0.blue - c1.blue).abs()
  assert_true(delta > 1.e-3)
}

///|
test "PBR: roughness_pattern overrides roughness" {
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let shape = Some(sphere())
  let base = material()
  base.lighting_mode = PBR
  base.color = color(1, 1, 1)
  base.metallic = 0.0
  base.roughness = 1.0
  let c0 = base.lighting(light, position, eyev, normalv, shape~)
  let shiny = base.clone()
  // Luminance 0 => roughness ~ 0, clamped away from 0 internally.
  shiny.roughness_pattern = Some(stripe_pattern([black, black]))
  let c1 = shiny.lighting(light, position, eyev, normalv, shape~)
  let delta = (c0.red - c1.red).abs() +
    (c0.green - c1.green).abs() +
    (c0.blue - c1.blue).abs()
  assert_true(delta > 1.e-3)
}

///|
test "Lighting with a pattern applied (p.176)" {
  let m = material()
  m.pattern = Some(stripe_pattern([white, black]))
  m.ambient = 1
  m.diffuse = 0
  m.specular = 0
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let shape = Some(sphere())
  let c1 = m.lighting(light, point(0.9, 0, 0), eyev, normalv, shape~)
  let c2 = m.lighting(light, point(1.1, 0, 0), eyev, normalv, shape~)
  assert_eq(c1, color(0, 0, 0))
  assert_eq(c2, color(0, 0, 0))
}

///|
test "Bump mapping (normal_pattern) perturbs lighting" {
  let light = point_light(point(0, 0, -10), color(1, 1, 1))
  let position = point(0, 0, 0)
  let eyev = vector(0, 0, -1)
  let normalv = vector(0, 0, -1)
  let shape = Some(sphere())
  let m0 = material()
  m0.color = color(1, 1, 1)
  m0.ambient = 0
  m0.diffuse = 1
  m0.specular = 0
  m0.normal_pattern = Some(gradient_pattern([black, white]))
  m0.normal_strength = 0.0
  let baseline = m0.lighting(light, position, eyev, normalv, shape~)
  assert_eq(baseline, color(1, 1, 1))
  let m1 = material()
  m1.color = color(1, 1, 1)
  m1.ambient = 0
  m1.diffuse = 1
  m1.specular = 0
  m1.normal_pattern = Some(gradient_pattern([black, white]))
  m1.normal_strength = 1.0
  let bumped = m1.lighting(light, position, eyev, normalv, shape~)
  assert_eq(bumped, color(0.7071, 0.7071, 0.7071))
}

///|
test "Bump mapping perturbs sphere normal (deterministic)" {
  let shape = sphere()
  let wp = point(0.0, 0.0, -1.0)
  let gn = vector(0.0, 0.0, -1.0)

  // For this point/normal, the bump code's tangent_u is +X, so the +X height
  // ramp should tilt the normal toward -X (negative x component).
  let bumped = bump_normal_from_pattern(rampx_pattern(), 10.0, shape, wp, gn)
  assert_eq(bumped == gn, false)
  assert_eq(bumped.x < -1.e-4, true)
  // Must still be a unit vector.
  assert_true((bumped.magnitude() - 1.0).abs() < 1.e-6)
}

///|
// A simple height field: grayscale ramps with +x.
struct RampX {}

///|
impl PatternTrait for RampX with clone(_self) {
  rampx_pattern()
}

///|
impl Show for RampX with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn rampx_pattern() -> Pattern {
  Pattern::new(RampX::{  })
}

///|
impl PatternTrait for RampX with pattern_at(_self, p) {
  let t = p.x * 0.5 + 0.5
  let t = if t < 0.0 { 0.0 } else if t > 1.0 { 1.0 } else { t }
  color(t, t, t)
}

///|
impl PatternTrait for RampX with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
impl PatternTrait for RampX with pattern_at_with_info(self, p, _n, uv) {
  match uv {
    Some((u, v)) => self.uv_at(u, v)
    None => self.pattern_at(p)
  }
}

///|
test "Stripes with an object transformation (p.179)" {
  let object = sphere()
  object.set_transform(scaling(2, 2, 2))
  let pattern = stripe_pattern([white, black])
  let c = pattern.pattern_at_shape(
    object,
    point(1.5, 0, 0),
    normal=vector(0, 0, 0),
  )
  assert_eq(c, white)
}

///|
test "Stripes with a pattern transformation (p.179)" {
  let object = sphere()
  let pattern = stripe_pattern([white, black])
  pattern.set_pattern_transform(scaling(2, 2, 2))
  let c = pattern.pattern_at_shape(
    object,
    point(1.5, 0, 0),
    normal=vector(0, 0, 0),
  )
  assert_eq(c, white)
}

///|
test "Stripes with both an object and a pattern transformation (p.179)" {
  let shape = sphere()
  shape.set_transform(scaling(2, 2, 2))
  let pattern = stripe_pattern([white, black])
  pattern.set_pattern_transform(translation(0.5, 0, 0))
  let c = pattern.pattern_at_shape(
    shape,
    point(2.5, 0, 0),
    normal=vector(0, 0, 0),
  )
  assert_eq(c, white)
}

///|
test "Reflectivity for the default material (p.196)" {
  let m = material()
  assert_eq(m.reflective, 0)
}

///|
test "Transparency and Refractive Index for the default material (p.204)" {
  let m = material()
  assert_eq(m.transparency, 0)
  assert_eq(m.refractive_index, 1)
}
