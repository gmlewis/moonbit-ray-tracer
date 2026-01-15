///|
// Regression: glTF `material.normalTexture.texCoord` selects which UV set is
// used to sample the normal texture (e.g. TEXCOORD_1).

///|
test "normalTexture texCoord selects UV set for normal map" {
  let m = material()
  m.lighting_mode = Phong
  m.color = color(1.0, 1.0, 1.0)
  m.ambient = 0.0
  m.diffuse = 1.0
  m.specular = 0.0

  // 2x1 normal map: left pixel = flat (0,0,1), right pixel = tangent-x.
  let c = canvas(2, 1)
  c.write_pixel(0, 0, color(0.5, 0.5, 1.0))
  c.write_pixel(1, 0, color(1.0, 0.5, 0.5))
  let nt = texture(c)
  m.normal_texture = Some(nt)
  m.normal_texture_scale = 1.0

  // A simple UV triangle in the XY plane.
  let tri = triangle_uv(
    point(0.0, 0.0, 0.0),
    point(1.0, 0.0, 0.0),
    point(0.0, 1.0, 0.0),
    (0.0, 0.0),
    (1.0, 0.0),
    (0.0, 1.0),
  )
  let light = point_light(point(0.0, 0.0, -10.0), color(1.0, 1.0, 1.0))
  let position = point(0.0, 0.0, 0.0)
  let eyev = vector(0.0, 0.0, -1.0)
  let normalv = vector(0.0, 0.0, -1.0)
  let uv0 = Some((0.25, 0.5))
  let uv1 = Some((0.75, 0.5))

  // texCoord=0 samples the flat pixel: should be brighter.
  let m0 = m.clone()
  m0.normal_texture_texcoord = 0
  let c0 = m0.lighting(
    light,
    position,
    eyev,
    normalv,
    shape=Some(tri),
    uv0?,
    uv1?,
  )

  // texCoord=1 samples the tangent-x pixel: should reduce N·L.
  let m1 = m.clone()
  m1.normal_texture_texcoord = 1
  let c1 = m1.lighting(
    light,
    position,
    eyev,
    normalv,
    shape=Some(tri),
    uv0?,
    uv1?,
  )
  assert_true(c0.red > c1.red + 0.1)
}
