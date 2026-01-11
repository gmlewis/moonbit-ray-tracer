///|
/// Shared scene application helpers.
///
/// These functions intentionally contain logic used by both the sync and async
/// scene parsers so we don't accidentally fix one path and forget the other.

///|
fn apply_transform(
  shape : Shape,
  object_table : Map[String, @toml.TomlValue],
) -> Unit raise SceneParseError {
  // Apply object transform if specified
  match object_table.get("transform") {
    Some(t) => {
      let transform = parse_transform(t)
      shape.set_transform(transform)
    }
    _ => ()
  }

  // Apply pattern transform if specified
  match object_table.get("pattern_transform") {
    Some(t) => {
      let transform = parse_transform(t)
      match shape.material.pattern {
        Some(pattern) => pattern.set_pattern_transform(transform)
        None => ()
      }
      match shape.material.normal_pattern {
        Some(pattern) => pattern.set_pattern_transform(transform)
        None => ()
      }
    }
    _ => ()
  }
}

///|
fn propagate_material(shape : Shape, mat_to_propagate : Material) -> Unit {
  let def_mat = material()
  match shape.object {
    Group(group) =>
      for child in group.children {
        if child.material == def_mat {
          child.material = mat_to_propagate.clone()
        }
        propagate_material(child, mat_to_propagate)
      }
    CSG(csg) => {
      if csg.left.material == def_mat {
        csg.left.material = mat_to_propagate.clone()
      }
      propagate_material(csg.left, mat_to_propagate)
      if csg.right.material == def_mat {
        csg.right.material = mat_to_propagate.clone()
      }
      propagate_material(csg.right, mat_to_propagate)
    }
    _ => ()
  }
}

///|
fn apply_material_and_transform(
  shape : Shape,
  object_table : Map[String, @toml.TomlValue],
  materials : Map[String, Material],
  patterns : Map[String, Pattern],
) -> Unit raise SceneParseError {
  let has_material_ref = match object_table.get("material") {
    Some(@toml.TomlString(_)) => true
    _ => false
  }
  let has_material_inline = match object_table.get("material") {
    Some(@toml.TomlTable(_)) => true
    _ => false
  }
  if has_material_ref && has_material_inline {
    raise SceneParseError(
      "Cannot specify both material reference and inline material",
    )
  }
  if has_material_ref {
    let material_name = get_string_required(object_table, "material")
    match materials.get(material_name) {
      Some(mat) => {
        shape.material.color = mat.color
        shape.material.ambient = mat.ambient
        shape.material.diffuse = mat.diffuse
        shape.material.specular = mat.specular
        shape.material.shininess = mat.shininess
        shape.material.reflective = mat.reflective
        shape.material.transparency = mat.transparency
        shape.material.refractive_index = mat.refractive_index
        shape.material.pattern = match mat.pattern {
          Some(p) => Some(p.clone())
          None => None
        }
        shape.material.normal_pattern = match mat.normal_pattern {
          Some(p) => Some(p.clone())
          None => None
        }
        shape.material.normal_strength = mat.normal_strength
        shape.material.metallic = mat.metallic
        shape.material.roughness = mat.roughness
        shape.material.lighting_mode = mat.lighting_mode
      }
      None =>
        raise SceneParseError("Unknown material reference: \{material_name}")
    }
  }
  if has_material_inline {
    let material_value = match object_table.get("material") {
      Some(value) => value
      None => raise SceneParseError("Should have material")
    }
    let parsed_material = parse_material(material_value)
    shape.material.color = parsed_material.color
    shape.material.ambient = parsed_material.ambient
    shape.material.diffuse = parsed_material.diffuse
    shape.material.specular = parsed_material.specular
    shape.material.shininess = parsed_material.shininess
    shape.material.reflective = parsed_material.reflective
    shape.material.transparency = parsed_material.transparency
    shape.material.refractive_index = parsed_material.refractive_index
    shape.material.normal_strength = parsed_material.normal_strength
    shape.material.metallic = parsed_material.metallic
    shape.material.roughness = parsed_material.roughness
    shape.material.lighting_mode = parsed_material.lighting_mode
  }

  // Resolve pattern references if present in inline material
  if has_material_inline {
    let material_table = match object_table.get("material") {
      Some(@toml.TomlTable(table)) => table
      _ => Map::new()
    }
    match material_table.get("pattern") {
      Some(@toml.TomlString(pattern_name)) =>
        match patterns.get(pattern_name) {
          Some(pattern) => shape.material.pattern = Some(pattern.clone())
          None =>
            raise SceneParseError("Unknown pattern reference: \{pattern_name}")
        }
      Some(_) => raise SceneParseError("pattern reference must be a string")
      None => ()
    }
    match material_table.get("normal_pattern") {
      Some(@toml.TomlString(pattern_name)) =>
        match patterns.get(pattern_name) {
          Some(pattern) => shape.material.normal_pattern = Some(pattern.clone())
          None =>
            raise SceneParseError(
              "Unknown normal_pattern reference: \{pattern_name}",
            )
        }
      Some(_) =>
        raise SceneParseError("normal_pattern reference must be a string")
      None => ()
    }
  }
  apply_transform(shape, object_table)

  // Handle group and CSG children material propagation.
  // This matters because groups/CSGs can have children created with default
  // materials, and we want the parent material to apply by default.
  let object_type = get_string_required(object_table, "type")
  if object_type == "group" || object_type == "csg" {
    propagate_material(shape, shape.material)
  }
}
