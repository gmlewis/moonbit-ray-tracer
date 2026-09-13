///|
// Every Show impl in this package must terminate. These types once delegated
// `output` to a `to_string` that did not exist, which resolved to the trait's
// default `to_string` -- and that default calls `output`, so simply printing
// one of them overflowed the stack (it crashed the renderer's --debug flag).
test "Show for LightingMode and Operation terminates" {
  let modes : Array[LightingMode] = [Phong, PBR]
  inspect(modes.map(fn(m) { m.to_string() }).join(","), content="phong,pbr")
  let ops : Array[Operation] = [Union, Intersection, Difference]
  inspect(
    ops.map(fn(o) { o.to_string() }).join(","),
    content="union,intersection,difference",
  )
}

///|
test "Show for CSG terminates" {
  let shape = csg(Union, sphere(), cube())
  let csg_shape = match shape.object {
    CSG(csg) => csg
    _ => abort("expected a CSG shape")
  }
  inspect(csg_shape.to_string(), content="csg(union)")
}

///|
test "Show for Light terminates" {
  let white = color(1, 1, 1)
  inspect(
    point_light(point(0, 0, 0), white).to_string(),
    content="point_light(point(0, 0, 0), color(1, 1, 1))",
  )
  let area = area_light(
    point(0, 0, 0),
    vector(2, 0, 0),
    2,
    vector(0, 2, 0),
    2,
    white,
  )
  inspect(
    area.to_string(),
    content="area_light(point(0, 0, 0), vector(1, 0, 0), 2, vector(0, 1, 0), 2, color(1, 1, 1))",
  )
}

///|
test "Show for Material and MaterialLayer terminates" {
  let mat = material()
  inspect(
    mat.to_string(),
    content="material(color=color(1, 1, 1), ambient=0.1, diffuse=0.9, specular=0.9, shininess=200, reflective=0, transparency=0, refractive_index=1, metallic=0, roughness=0.5, lighting_mode=phong)",
  )

  let layer : MaterialLayer = {
    top: mat,
    mask: checkers_pattern([color(0, 0, 0), color(1, 1, 1)]),
    opacity: 0.5,
  }
  let s = layer.to_string()
  inspect(s.contains("material_layer(opacity=0.5"), content="true")
  inspect(s.contains("lighting_mode=phong"), content="true")
}
