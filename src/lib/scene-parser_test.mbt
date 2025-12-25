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
