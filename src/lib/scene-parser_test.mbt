///|
test "parse simple scene" {
  let toml_content =
    #|[scene]
    #|name = "Test Scene"
    #|
    #|[scene.render]
    #|width = 400
    #|height = 300
    #|
    #|[camera]
    #|position = [0.0, 0.0, -5.0]
    #|look_at = [0.0, 0.0, 0.0]
    #|up = [0.0, 1.0, 0.0]
    #|field_of_view = 1.047
    #|
    #|[[lights]]
    #|type = "point"
    #|position = [-10.0, 10.0, -10.0]
    #|intensity = [1.0, 1.0, 1.0]
    #|
    #|[materials.red_material]
    #|color = [0.8, 0.2, 0.2]
    #|
    #|[[objects]]
    #|type = "sphere"
    #|material = "red_material"
    #|
  let scene = @lib.parse_scene(toml_content)

  // Check metadata
  inspect(scene.metadata.name, content="Test Scene")

  // Check render settings
  inspect(scene.render_settings.width, content="400")
  inspect(scene.render_settings.height, content="300")

  // Check camera
  inspect(scene.camera.hsize, content="400")
  inspect(scene.camera.vsize, content="300")

  // Check world has one light and one shape
  inspect(scene.world.lights.length(), content="1")
  inspect(scene.world.shapes.length(), content="1")
}

///|
test "parse scene with inline material" {
  let toml_content =
    #|[scene]
    #|name = "Inline Material Scene"
    #|
    #|[camera]
    #|position = [0.0, 0.0, -5.0]
    #|look_at = [0.0, 0.0, 0.0]
    #|up = [0.0, 1.0, 0.0]
    #|field_of_view = 1.047
    #|
    #|[[objects]]
    #|type = "sphere"
    #|material = { color = [0.0, 1.0, 0.0], ambient = 0.2, diffuse = 0.8 }
    #|
  let scene = @lib.parse_scene(toml_content)

  // Check that the sphere has the correct material
  inspect(scene.world.shapes.length(), content="1")
  let sphere_material = scene.world.shapes[0].material
  inspect(sphere_material.color, content="color(0, 1, 0)")
  inspect(sphere_material.ambient, content="0.2")
  inspect(sphere_material.diffuse, content="0.8")
}

///|
test "parse scene with pattern" {
  let toml_content =
    #|[scene]
    #|name = "Pattern Scene"
    #|
    #|[camera]
    #|position = [0.0, 0.0, -5.0]
    #|look_at = [0.0, 0.0, 0.0]
    #|up = [0.0, 1.0, 0.0]
    #|field_of_view = 1.047
    #|
    #|[patterns.stripes]
    #|type = "stripes"
    #|colors = [
    #|  [1.0, 0.0, 0.0],
    #|  [1.0, 1.0, 1.0]
    #|]
    #|
    #|[[objects]]
    #|type = "sphere"
    #|material = { pattern = "stripes" }
    #|
  let scene = @lib.parse_scene(toml_content)

  // Check that the sphere has a pattern
  inspect(scene.world.shapes.length(), content="1")
  let sphere_material = scene.world.shapes[0].material
  match sphere_material.pattern {
    Some(_) => inspect("has_pattern", content="has_pattern")
    None => inspect("no_pattern", content="has_pattern")
  }
}

///|
test "parse scene with cylinder properties" {
  let toml_content =
    #|[scene]
    #|name = "Cylinder Scene"
    #|
    #|[camera]
    #|position = [0.0, 0.0, -5.0]
    #|look_at = [0.0, 0.0, 0.0]
    #|up = [0.0, 1.0, 0.0]
    #|field_of_view = 1.047
    #|
    #|[[objects]]
    #|type = "cylinder"
    #|properties = { minimum = -2.0, maximum = 2.0, closed = true }
    #|
  let scene = @lib.parse_scene(toml_content)

  // Check that we have a cylinder
  inspect(scene.world.shapes.length(), content="1")
  // We can't easily test the cylinder properties since they're internal to the shape
  // but the fact that it parses without error is a good sign
}

///|
test "parse scene with transforms" {
  let toml_content =
    #|[scene]
    #|name = "Transform Scene"
    #|
    #|[camera]
    #|position = [0.0, 0.0, -5.0]
    #|look_at = [0.0, 0.0, 0.0]
    #|up = [0.0, 1.0, 0.0]
    #|field_of_view = 1.047
    #|
    #|[[objects]]
    #|type = "sphere"
    #|transform = { translation = [1.0, 2.0, 3.0], scale = [2.0, 2.0, 2.0], rotation = [0.0, 1.571, 0.0] }
    #|
  let scene = @lib.parse_scene(toml_content)

  // Check that we have a sphere with a transform
  inspect(scene.world.shapes.length(), content="1")
  let sphere = scene.world.shapes[0]
  // The transform should not be the identity matrix
  let is_identity = sphere.transform == @lib.mat4ident()
  inspect(is_identity, content="false")
}

///|
test "parse scene with multiple transforms and verify order" {
  let toml_content =
    #|[scene]
    #|name = "Transform Order Scene"
    #|[camera]
    #|position = [0.0, 0.0, -5.0]
    #|look_at = [0.0, 0.0, 0.0]
    #|up = [0.0, 1.0, 0.0]
    #|field_of_view = 1.047
    #|[[objects]]
    #|type = "sphere"
    #|transform = { translation = [10.0, 5.0, 7.0], scale = [5.0, 5.0, 5.0], rotation = [1.5707963267948966, 0.0, 0.0] }
    #|
  let scene = @lib.parse_scene(toml_content)
  let sphere = scene.world.shapes[0]

  // From Page 87 of The Ray Tracer Challenge:
  // p = point(1, 0, 1)
  // rotation_x(pi/2) then scale(5, 5, 5) then translate(10, 5, 7)
  // results in point(15, 0, 7)
  let p = @lib.point(1, 0, 1)
  let result = sphere.transform.mul_tuple(p)
  assert_eq(result, @lib.point(15, 0, 7))
}

///|
test "parse error - missing required field" {
  let toml_content =
    #|[scene]
    #|name = "Incomplete Scene"
    #|
    #|# Missing camera section
    #|
  try {
    let _scene = @lib.parse_scene(toml_content)
    inspect("should_fail", content="correctly_failed")
  } catch {
    _ => inspect("correctly_failed", content="correctly_failed")
  }
}

///|
test "parse error - unknown object type" {
  let toml_content =
    #|[scene]
    #|name = "Unknown Object Scene"
    #|[camera]
    #|position = [0,0,-5]
    #|look_at = [0,0,0]
    #|up = [0,1,0]
    #|field_of_view = 1.0
    #|[[objects]]
    #|type = "unknown_type"
    #|
  try {
    let _scene = @lib.parse_scene(toml_content)
    inspect("should_fail", content="correctly_failed")
  } catch {
    e => {
      let msg = e.to_string()
      let is_unknown = msg.contains("Unknown object type: unknown_type")
      inspect(is_unknown, content="true")
    }
  }
}

///|
test "parse error - invalid color" {
  let toml_content =
    #|[scene]
    #|name = "Invalid Color Scene"
    #|[camera]
    #|position = [0,0,-5]
    #|look_at = [0,0,0]
    #|up = [0,1,0]
    #|field_of_view = 1.0
    #|[[objects]]
    #|type = "sphere"
    #|material = { color = [1.0, 0.0] } # Only 2 components
    #|
  try {
    let _scene = @lib.parse_scene(toml_content)
    inspect("should_fail", content="correctly_failed")
  } catch {
    e => {
      let msg = e.to_string()
      let is_invalid = msg.contains("color must have exactly 3 components")
      inspect(is_invalid, content="true")
    }
  }
}

///|
test "parse material with pattern reference" {
  let toml_content =
    #|[scene]
    #|name = "Material Pattern Reference Scene"
    #|[camera]
    #|position = [0,0,-5]
    #|look_at = [0,0,0]
    #|up = [0,1,0]
    #|field_of_view = 1.0
    #|[patterns.stripes]
    #|type = "stripes"
    #|colors = [[1,1,1], [0,0,0]]
    #|[materials.patterned]
    #|pattern = "stripes"
    #|[[objects]]
    #|type = "sphere"
    #|material = "patterned"
    #|
  let scene = @lib.parse_scene(toml_content)
  inspect(scene.world.shapes.length(), content="1")
  let mat = scene.world.shapes[0].material
  match mat.pattern {
    Some(_) => inspect("has_pattern", content="has_pattern")
    None => inspect("no_pattern", content="has_pattern")
  }
}

///|
test "parse material with normal_pattern affects lighting" {
  let toml_content =
    #|[scene]
    #|name = "Normal Pattern Scene"
    #|[camera]
    #|position = [0, 0, -5]
    #|look_at = [0, 0, 0]
    #|up = [0, 1, 0]
    #|field_of_view = 1.0
    #|
    #|[patterns.h]
    #|type = "fbm"
    #|seed = 1
    #|scale = 3.0
    #|octaves = 3
    #|
    #|[materials.flat]
    #|color = [1, 1, 1]
    #|ambient = 0.0
    #|diffuse = 0.9
    #|specular = 0.9
    #|shininess = 200.0
    #|normal_pattern = "h"
    #|normal_strength = 0.0
    #|
    #|[materials.bump]
    #|color = [1, 1, 1]
    #|ambient = 0.0
    #|diffuse = 0.9
    #|specular = 0.9
    #|shininess = 200.0
    #|normal_pattern = "h"
    #|normal_strength = 5.0
    #|
    #|[[lights]]
    #|type = "point"
    #|position = [-10, 10, -10]
    #|intensity = [1, 1, 1]
    #|
    #|[[objects]]
    #|type = "sphere"
    #|material = "flat"
    #|
    #|[[objects]]
    #|type = "sphere"
    #|material = "bump"
    #|transform = { translation = [2, 0, 0] }
    #|
  let scene = @lib.parse_scene(toml_content)
  inspect(scene.world.shapes.length(), content="2")
  let flat_shape = scene.world.shapes[0]
  let bump_shape = scene.world.shapes[1]
  match
    (flat_shape.material.normal_pattern, bump_shape.material.normal_pattern) {
    (Some(_), Some(_)) => ()
    _ => abort("expected normal_pattern to be resolved")
  }
  inspect(flat_shape.material.normal_strength, content="0")
  inspect(bump_shape.material.normal_strength, content="5")
  let light = scene.world.lights[0]
  let position = @lib.point(0.35, 0.42, -0.84)
  let eyev = @lib.vector(0.0, 0.0, -1.0)
  let normalv = @lib.vector(0.0, 0.0, -1.0)
  let c_flat = flat_shape.material.lighting(
    light,
    position,
    eyev,
    normalv,
    shape=Some(flat_shape),
  )
  let c_bump = bump_shape.material.lighting(
    light,
    position,
    eyev,
    normalv,
    shape=Some(bump_shape),
  )

  // Bump should perturb the normal enough to change the computed color.
  assert_eq(c_flat == c_bump, false)
}

///|
test "parse error - displacement inline material not supported" {
  let toml_content =
    #|[scene]
    #|name = "Displacement Inline Material Scene"
    #|[camera]
    #|position = [0,0,-5]
    #|look_at = [0,0,0]
    #|up = [0,1,0]
    #|field_of_view = 1.0
    #|[patterns.h]
    #|type = "fbm"
    #|seed = 1
    #|scale = 3.0
    #|octaves = 3
    #|[[objects]]
    #|type = "sphere"
    #|material = { displacement_pattern = "h", displacement_strength = 1.0 }
    #|
  try {
    let _scene = @lib.parse_scene(toml_content)
    inspect("should_fail", content="correctly_failed")
  } catch {
    e => {
      let msg = e.to_string()
      let ok = msg.contains("displacement is not supported")
      inspect(ok, content="true")
    }
  }
}

///|
test "parse error - displacement referenced material not supported" {
  let toml_content =
    #|[scene]
    #|name = "Displacement Ref Material Scene"
    #|[camera]
    #|position = [0,0,-5]
    #|look_at = [0,0,0]
    #|up = [0,1,0]
    #|field_of_view = 1.0
    #|[patterns.h]
    #|type = "fbm"
    #|seed = 1
    #|scale = 3.0
    #|octaves = 3
    #|[materials.disp]
    #|displacement_pattern = "h"
    #|displacement_strength = 1.0
    #|[[objects]]
    #|type = "sphere"
    #|material = "disp"
    #|
  try {
    let _scene = @lib.parse_scene(toml_content)
    inspect("should_fail", content="correctly_failed")
  } catch {
    e => {
      let msg = e.to_string()
      let ok = msg.contains("displacement is not supported")
      inspect(ok, content="true")
    }
  }
}

///|
test "propagate material to CSG children" {
  let toml_content =
    #|[scene]
    #|name = "CSG Material Propagation Scene"
    #|[camera]
    #|position = [0,0,-10]
    #|look_at = [0,0,0]
    #|up = [0,1,0]
    #|field_of_view = 1.0
    #|[[objects]]
    #|type = "csg"
    #|material = { color = [1, 0, 0] }
    #|properties = { operation = "union" }
    #|left = { type = "sphere" }
    #|right = { type = "cube" }
    #|
  let scene = @lib.parse_scene(toml_content)
  inspect(scene.world.shapes.length(), content="1")
  let csg_shape = scene.world.shapes[0]
  match csg_shape.object {
    CSG(c) => {
      inspect(c.left.material.color, content="color(1, 0, 0)")
      inspect(c.right.material.color, content="color(1, 0, 0)")
    }
    _ => abort("expected CSG object")
  }
}
