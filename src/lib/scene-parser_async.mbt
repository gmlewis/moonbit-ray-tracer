///|
async fn parse_templates_async(
  root : Map[String, @toml.TomlValue],
  materials : Map[String, Material],
  patterns : Map[String, Pattern],
) -> Map[String, Shape] raise SceneParseError {
  let templates = Map::new()
  match root.get("definitions") {
    Some(@toml.TomlTable(definitions_table)) => {
      let keys = []
      definitions_table.each(fn(name, _) { keys.push(name) })
      for name in keys {
        let template_value = definitions_table.get(name).unwrap()
        let shape = parse_object_async(
          template_value, materials, patterns, templates,
        )
        templates.set(name, shape)
      }
    }
    _ => ()
  }
  templates
}

///|
async fn parse_objects_async(
  root : Map[String, @toml.TomlValue],
  materials : Map[String, Material],
  patterns : Map[String, Pattern],
  templates : Map[String, Shape],
) -> Array[Shape] raise SceneParseError {
  let shapes = Array::new()
  match root.get("objects") {
    Some(@toml.TomlArray(objects_array)) =>
      for i = 0; i < objects_array.length(); i = i + 1 {
        shapes.push(
          parse_object_async(objects_array[i], materials, patterns, templates),
        )
      }
    Some(_) => raise SceneParseError("objects section must be an array")
    None => () // No objects defined
  }
  shapes
}

///|
async fn parse_object_async(
  value : @toml.TomlValue,
  materials : Map[String, Material],
  patterns : Map[String, Pattern],
  templates : Map[String, Shape],
) -> Shape raise SceneParseError {
  let object_table = match value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("object must be a table")
  }
  let object_type = get_string_required(object_table, "type")

  // Create the base shape
  let shape = match object_type {
    "reference" => {
      let name = get_string_required(object_table, "name")
      match templates.get(name) {
        Some(t) => t.clone()
        None => raise SceneParseError("Unknown template reference: \{name}")
      }
    }
    "sphere" => sphere()
    "plane" => plane()
    "cube" => cube()
    "cylinder" =>
      match object_table.get("properties") {
        Some(@toml.TomlTable(props_table)) => {
          let minimum = get_float_or_default(
            props_table, "minimum", @double.neg_infinity,
          )
          let maximum = get_float_or_default(
            props_table, "maximum", @double.infinity,
          )
          let closed = get_bool_or_default(props_table, "closed", false)
          cylinder(minimum~, maximum~, closed~)
        }
        _ => cylinder()
      }
    "cone" =>
      match object_table.get("properties") {
        Some(@toml.TomlTable(props_table)) => {
          let minimum = get_float_or_default(
            props_table, "minimum", @double.neg_infinity,
          )
          let maximum = get_float_or_default(
            props_table, "maximum", @double.infinity,
          )
          let closed = get_bool_or_default(props_table, "closed", false)
          cone(minimum~, maximum~, closed~)
        }
        _ => cone()
      }
    "triangle" =>
      // Sync logic is fine here as it doesn't involve files
      parse_object(value, materials, patterns, templates)
    "group" => {
      let g = group()
      match object_table.get("children") {
        Some(@toml.TomlArray(children_array)) =>
          for i = 0; i < children_array.length(); i = i + 1 {
            let child = parse_object_async(
              children_array[i],
              materials,
              patterns,
              templates,
            )
            g.add_child(child)
          }
        _ => ()
      }
      g
    }
    "csg" => {
      let operation = match object_table.get("properties") {
        Some(@toml.TomlTable(props_table)) =>
          get_string_required(props_table, "operation")
        _ => raise SceneParseError("CSG properties are required")
      }
      let csg_op = match operation {
        "union" => Union
        "intersection" => Intersection
        "difference" => Difference
        _ => raise SceneParseError("Unknown CSG operation: \{operation}")
      }
      let left_shape = match object_table.get("left") {
        Some(left_value) =>
          parse_object_async(left_value, materials, patterns, templates)
        None => raise SceneParseError("CSG left object is required")
      }
      let right_shape = match object_table.get("right") {
        Some(right_value) =>
          parse_object_async(right_value, materials, patterns, templates)
        None => raise SceneParseError("CSG right object is required")
      }
      csg(csg_op, left_shape, right_shape)
    }
    "gltf" => {
      let file = get_string_required(object_table, "file")
      load_gltf_file(file)
    }
    "obj" => {
      let file = get_string_required(object_table, "file")
      let content = @fs.read_file(file).text() catch {
        e => raise SceneParseError("Failed to read OBJ file \{file}: \{e}")
      }
      let obj_file = parse_obj_file(content) catch {
        e => raise SceneParseError("OBJ parse error \{file}: \{e}")
      }
      obj_file.obj_to_group()
    }
    _ => raise SceneParseError("Unknown object type: \{object_type}")
  }

  // Common material/transform logic (duplicating for now, could be extracted)
  let object_type = get_string_required(object_table, "type")
  if (object_type != "gltf" && object_type != "obj") ||
    object_table.get("material") is Some(_) {
    apply_material_and_transform(shape, object_table, materials, patterns)
  } else {
    // Still need to apply transform
    apply_transform(shape, object_table)
  }
  shape
}

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
        None => () // No pattern to transform
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
fn apply_material_and_transform(
  shape : Shape,
  object_table : Map[String, @toml.TomlValue],
  materials : Map[String, Material],
  patterns : Map[String, Pattern],
) -> Unit raise SceneParseError {
  // Extracting common logic from parse_object
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
    let material_value = object_table.get("material").unwrap()
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
    match material_value {
      @toml.TomlTable(table) => {
        match table.get("pattern") {
          Some(@toml.TomlString(pattern_name)) =>
            match patterns.get(pattern_name) {
              Some(pattern) => shape.material.pattern = Some(pattern.clone())
              None =>
                raise SceneParseError(
                  "Unknown pattern reference: \{pattern_name}",
                )
            }
          _ => ()
        }
        match table.get("normal_pattern") {
          Some(@toml.TomlString(pattern_name)) =>
            match patterns.get(pattern_name) {
              Some(pattern) =>
                shape.material.normal_pattern = Some(pattern.clone())
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
      _ => ()
    }
  }

  // Finalize with transforms
  apply_transform(shape, object_table)
}
