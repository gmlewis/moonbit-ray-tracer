///|
/// Scene parsing errors
pub suberror SceneParseError {
  SceneParseError(String)
} derive(Show, Eq)

///|
/// Parsed scene structure containing all scene components
pub(all) struct ParsedScene {
  world : World
  camera : Camera
  render_settings : RenderSettings
  metadata : SceneMetadata
  templates : Map[String, Shape]
}

///|
/// Render settings from scene file
pub(all) struct RenderSettings {
  mut width : Int
  mut height : Int
  mut samples : Int
  mut max_bounces : Int
  mut background : Color
  mut divide : Int
  mut exposure : Double
} derive(Show, Eq)

///|
/// Scene metadata
pub(all) struct SceneMetadata {
  name : String
  description : String
  version : String
} derive(Show, Eq)

///|
/// Helper functions for extracting values from TOML tables
fn get_string_or_default(
  table : Map[String, @toml.TomlValue],
  key : String,
  default_value : String,
) -> String {
  match table.get(key) {
    Some(@toml.TomlString(s)) => s
    Some(_) => default_value
    None => default_value
  }
}

///|
fn get_string_required(
  table : Map[String, @toml.TomlValue],
  key : String,
) -> String raise SceneParseError {
  match table.get(key) {
    Some(@toml.TomlString(s)) => s
    Some(_) => raise SceneParseError("\{key} must be a string")
    None => raise SceneParseError("\{key} is required")
  }
}

///|
fn get_int_or_default(
  table : Map[String, @toml.TomlValue],
  key : String,
  default_value : Int,
) -> Int {
  match table.get(key) {
    Some(@toml.TomlInteger(i)) => i.to_int()
    Some(@toml.TomlFloat(f)) => f.to_int() // Allow float that's actually an int
    Some(_) => default_value
    None => default_value
  }
}

///|
fn get_float_or_default(
  table : Map[String, @toml.TomlValue],
  key : String,
  default_value : Double,
) -> Double {
  match table.get(key) {
    Some(@toml.TomlFloat(f)) => f
    Some(@toml.TomlInteger(i)) => i.to_double()
    Some(_) => default_value
    None => default_value
  }
}

///|
fn get_float_required(
  table : Map[String, @toml.TomlValue],
  key : String,
) -> Double raise SceneParseError {
  match table.get(key) {
    Some(@toml.TomlFloat(f)) => f
    Some(@toml.TomlInteger(i)) => i.to_double()
    Some(_) => raise SceneParseError("\{key} must be a number")
    None => raise SceneParseError("\{key} is required")
  }
}

///|
fn get_bool_or_default(
  table : Map[String, @toml.TomlValue],
  key : String,
  default_value : Bool,
) -> Bool {
  match table.get(key) {
    Some(@toml.TomlBoolean(b)) => b
    Some(_) => default_value
    None => default_value
  }
}

///|
fn get_vector3(
  table : Map[String, @toml.TomlValue],
  key : String,
) -> (Double, Double, Double) raise SceneParseError {
  match table.get(key) {
    Some(value) => parse_vector3(value)
    None => raise SceneParseError("\{key} is required")
  }
}

///|
fn parse_scene_metadata(
  root : Map[String, @toml.TomlValue],
) -> SceneMetadata raise SceneParseError {
  let scene_table = match root.get("scene") {
    Some(@toml.TomlTable(table)) => table
    Some(_) => raise SceneParseError("scene section must be a table")
    None => raise SceneParseError("scene section is required")
  }
  let name = get_string_or_default(scene_table, "name", "Untitled Scene")
  let description = get_string_or_default(scene_table, "description", "")
  let version = get_string_or_default(scene_table, "version", "1.0")
  { name, description, version }
}

///|
fn parse_render_settings(
  root : Map[String, @toml.TomlValue],
) -> RenderSettings raise SceneParseError {
  let scene_table = match root.get("scene") {
    Some(@toml.TomlTable(table)) => table
    Some(_) => raise SceneParseError("scene section must be a table")
    None => raise SceneParseError("scene section is required")
  }
  let render_table = match scene_table.get("render") {
    Some(@toml.TomlTable(table)) => table
    Some(_) => raise SceneParseError("scene.render must be a table")
    None => Map::new() // Use defaults if not specified
  }
  let width = get_int_or_default(render_table, "width", 800)
  if width <= 0 {
    raise SceneParseError("scene.render.width must be positive")
  }
  let height = get_int_or_default(render_table, "height", 600)
  if height <= 0 {
    raise SceneParseError("scene.render.height must be positive")
  }
  let samples = get_int_or_default(render_table, "samples", 1)
  if samples < 1 {
    raise SceneParseError("scene.render.samples must be at least 1")
  }
  let max_bounces = get_int_or_default(render_table, "max_bounces", 4)
  if max_bounces < 0 {
    raise SceneParseError("scene.render.max_bounces must be non-negative")
  }
  let background = match render_table.get("background") {
    Some(value) => parse_color(value)
    None => color(0.0, 0.0, 0.0) // Default black background
  }
  let divide = get_int_or_default(render_table, "divide", 0)
  let exposure = get_float_or_default(render_table, "exposure", 1.0)
  { width, height, samples, max_bounces, background, divide, exposure }
}

///|
fn parse_camera(
  root : Map[String, @toml.TomlValue],
  render_settings : RenderSettings,
) -> Camera raise SceneParseError {
  let camera_table = match root.get("camera") {
    Some(@toml.TomlTable(table)) => table
    Some(_) => raise SceneParseError("camera section must be a table")
    None => raise SceneParseError("camera section is required")
  }
  let position = get_vector3(camera_table, "position")
  let look_at = get_vector3(camera_table, "look_at")
  let up = get_vector3(camera_table, "up")
  let field_of_view = get_float_required(camera_table, "field_of_view")
  let camera = camera(
    render_settings.width,
    render_settings.height,
    field_of_view,
  )
  camera.transform = view_transform(
    point(position.0, position.1, position.2),
    point(look_at.0, look_at.1, look_at.2),
    vector(up.0, up.1, up.2),
  )
  camera
}

///|
fn parse_materials(
  root : Map[String, @toml.TomlValue],
) -> Map[String, Material] raise SceneParseError {
  let materials = Map::new()
  match root.get("materials") {
    Some(@toml.TomlTable(materials_table)) =>
      materials_table.each(fn(name, material_value) {
        let material = parse_material(material_value) catch {
          e => {
            println("Error parsing material \{name}: \{e}")
            material()
          }
        }
        materials.set(name, material)
      })
    Some(_) => raise SceneParseError("materials section must be a table")
    None => () // No materials defined
  }
  materials
}

///|
fn parse_material(value : @toml.TomlValue) -> Material raise SceneParseError {
  let material_table = match value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("material must be a table")
  }
  let mat = material()

  // Parse color
  mat.color = match material_table.get("color") {
    Some(color_value) => parse_color(color_value)
    None => color(1.0, 1.0, 1.0) // Default white
  }
  mat.ambient = get_float_or_default(material_table, "ambient", mat.ambient)
  if mat.ambient < 0.0 {
    raise SceneParseError("material ambient must be non-negative")
  }
  mat.diffuse = get_float_or_default(material_table, "diffuse", 0.9)
  if mat.diffuse < 0.0 {
    raise SceneParseError("material diffuse must be non-negative")
  }
  mat.specular = get_float_or_default(material_table, "specular", 0.9)
  if mat.specular < 0.0 {
    raise SceneParseError("material specular must be non-negative")
  }
  mat.shininess = get_float_or_default(material_table, "shininess", 200.0)
  if mat.shininess < 0.0 {
    raise SceneParseError("material shininess must be non-negative")
  }
  mat.reflective = get_float_or_default(material_table, "reflective", 0.0)
  if mat.reflective < 0.0 || mat.reflective > 1.0 {
    raise SceneParseError("material reflective must be between 0 and 1")
  }
  mat.transparency = get_float_or_default(material_table, "transparency", 0.0)
  if mat.transparency < 0.0 || mat.transparency > 1.0 {
    raise SceneParseError("material transparency must be between 0 and 1")
  }
  mat.refractive_index = get_float_or_default(
    material_table, "refractive_index", 1.0,
  )
  if mat.refractive_index < 1.0 {
    raise SceneParseError("material refractive_index must be at least 1.0")
  }
  mat.metallic = get_float_or_default(material_table, "metallic", 0.0)
  if mat.metallic < 0.0 || mat.metallic > 1.0 {
    raise SceneParseError("material metallic must be between 0 and 1")
  }
  mat.roughness = get_float_or_default(material_table, "roughness", 0.5)
  if mat.roughness < 0.0 || mat.roughness > 1.0 {
    raise SceneParseError("material roughness must be between 0 and 1")
  }
  mat.lighting_mode = match
    get_string_or_default(material_table, "lighting_mode", "phong") {
    "phong" => Phong
    "pbr" => PBR
    mode => raise SceneParseError("Unknown lighting mode: \{mode}")
  }

  // Pattern will be set later when patterns are resolved

  mat
}

///|
fn resolve_material_patterns(
  root : Map[String, @toml.TomlValue],
  materials : Map[String, Material],
  patterns : Map[String, Pattern],
) -> Unit {
  match root.get("materials") {
    Some(@toml.TomlTable(materials_table)) =>
      materials_table.each(fn(name, material_value) {
        match material_value {
          @toml.TomlTable(table) =>
            match table.get("pattern") {
              Some(@toml.TomlString(pattern_name)) =>
                match (materials.get(name), patterns.get(pattern_name)) {
                  (Some(mat), Some(p)) => mat.pattern = Some(p.clone())
                  _ => ()
                }
              _ => ()
            }
          _ => ()
        }
      })
    _ => ()
  }
}

///|
fn parse_templates(
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
        let shape = parse_object(template_value, materials, patterns, templates)
        templates.set(name, shape)
      }
    }
    _ => ()
  }
  templates
}

///|
fn parse_patterns(
  root : Map[String, @toml.TomlValue],
) -> Map[String, Pattern] raise SceneParseError {
  let patterns = Map::new()
  match root.get("patterns") {
    Some(@toml.TomlTable(patterns_table)) => {
      let keys = []
      patterns_table.each(fn(name, _) { keys.push(name) })
      for name in keys {
        let pattern_value = patterns_table.get(name).unwrap()
        let pattern = parse_pattern(pattern_value) catch {
          e => {
            println("Error parsing pattern \{name}: \{e}")
            stripe_pattern([color(1, 0, 1), color(0, 0, 0)]) // fallback
          }
        }
        patterns.set(name, pattern)
      }
    }
    Some(_) => raise SceneParseError("patterns section must be a table")
    None => () // No patterns defined
  }
  patterns
}

///|
fn parse_pattern(value : @toml.TomlValue) -> Pattern raise SceneParseError {
  let pattern_table = match value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("pattern must be a table")
  }
  let pattern_type = get_string_required(pattern_table, "type")
  fn get_colors_optional() -> Array[Color] raise SceneParseError {
    match pattern_table.get("colors") {
      Some(@toml.TomlArray(arr)) => {
        let colors = Array::new()
        for i = 0; i < arr.length(); i = i + 1 {
          colors.push(parse_color(arr[i]))
        }
        colors
      }
      Some(_) => raise SceneParseError("pattern colors must be an array")
      None => []
    }
  }

  fn get_colors_required() -> Array[Color] raise SceneParseError {
    let colors = get_colors_optional()
    if colors.length() == 0 {
      raise SceneParseError("pattern colors are required")
    }
    colors
  }

  fn get_pattern_required(key : String) -> Pattern raise SceneParseError {
    match pattern_table.get(key) {
      Some(p) => parse_pattern(p)
      None => raise SceneParseError("pattern field is required: \{key}")
    }
  }

  let pattern = match pattern_type {
    "checkers" => checkers_pattern(get_colors_required())
    "stripes" => stripe_pattern(get_colors_required())
    "gradient" => gradient_pattern(get_colors_required())
    "rings" => ring_pattern(get_colors_required())
    "gradient_rings" => gradient_ring_pattern(get_colors_required())
    "gradient_checkers" => gradient_checkers_pattern(get_colors_required())

    // Procedural noise
    "noise" => {
      let seed = get_int_or_default(pattern_table, "seed", 0)
      let scale = get_float_or_default(pattern_table, "scale", 1.0)
      noise_pattern(seed~, scale~)
    }
    "fbm" => {
      let seed = get_int_or_default(pattern_table, "seed", 0)
      let scale = get_float_or_default(pattern_table, "scale", 1.0)
      let octaves = get_int_or_default(pattern_table, "octaves", 5)
      let lacunarity = get_float_or_default(pattern_table, "lacunarity", 2.0)
      let gain = get_float_or_default(pattern_table, "gain", 0.5)
      fbm_pattern(seed~, scale~, octaves~, lacunarity~, gain~)
    }
    "marble" => {
      let colors = get_colors_required()
      let seed = get_int_or_default(pattern_table, "seed", 0)
      let scale = get_float_or_default(pattern_table, "scale", 1.0)
      let octaves = get_int_or_default(pattern_table, "octaves", 5)
      let lacunarity = get_float_or_default(pattern_table, "lacunarity", 2.0)
      let gain = get_float_or_default(pattern_table, "gain", 0.5)
      let frequency = get_float_or_default(pattern_table, "frequency", 5.0)
      let strength = get_float_or_default(pattern_table, "strength", 2.0)
      marble_pattern(
        colors,
        seed~,
        scale~,
        octaves~,
        lacunarity~,
        gain~,
        frequency~,
        strength~,
      )
    }
    "wood" => {
      let colors = get_colors_required()
      let seed = get_int_or_default(pattern_table, "seed", 0)
      let scale = get_float_or_default(pattern_table, "scale", 1.0)
      let octaves = get_int_or_default(pattern_table, "octaves", 5)
      let lacunarity = get_float_or_default(pattern_table, "lacunarity", 2.0)
      let gain = get_float_or_default(pattern_table, "gain", 0.5)
      let ring_frequency = get_float_or_default(
        pattern_table, "ring_frequency", 6.0,
      )
      let turbulence = get_float_or_default(pattern_table, "turbulence", 0.5)
      wood_pattern(
        colors,
        seed~,
        scale~,
        octaves~,
        lacunarity~,
        gain~,
        ring_frequency~,
        turbulence~,
      )
    }
    "voronoi" => {
      let seed = get_int_or_default(pattern_table, "seed", 0)
      let scale = get_float_or_default(pattern_table, "scale", 1.0)
      let jitter = get_float_or_default(pattern_table, "jitter", 1.0)
      let edge_scale = get_float_or_default(pattern_table, "edge_scale", 12.0)
      let mode = match
        get_string_or_default(pattern_table, "mode", "distance") {
        "cells" => VoronoiMode::Cells
        "edges" => VoronoiMode::Edges
        "crackle" => VoronoiMode::Crackle
        _ => VoronoiMode::Distance
      }
      voronoi_pattern(seed~, scale~, jitter~, mode~, edge_scale~)
    }

    // More looks
    "levels" => {
      let p = get_pattern_required("pattern")
      let in_min = get_float_or_default(pattern_table, "in_min", 0.0)
      let in_max = get_float_or_default(pattern_table, "in_max", 1.0)
      let out_min = get_float_or_default(pattern_table, "out_min", 0.0)
      let out_max = get_float_or_default(pattern_table, "out_max", 1.0)
      let gamma = get_float_or_default(pattern_table, "gamma", 1.0)
      levels_pattern(p, in_min~, in_max~, out_min~, out_max~, gamma~)
    }
    "threshold" => {
      let p = get_pattern_required("pattern")
      let threshold = get_float_or_default(pattern_table, "threshold", 0.5)
      let colors = get_colors_optional()
      if colors.length() >= 2 {
        threshold_pattern(p, threshold~, low=colors[0], high=colors[1])
      } else {
        threshold_pattern(p, threshold~)
      }
    }
    "posterize" => {
      let p = get_pattern_required("pattern")
      let steps = get_int_or_default(pattern_table, "steps", 4)
      posterize_pattern(p, steps~)
    }
    "gradient_map" => {
      let p = get_pattern_required("pattern")
      let colors = get_colors_required()
      gradient_map_pattern(p, colors)
    }
    "triplanar" => {
      let p = get_pattern_required("pattern")
      let scale = get_float_or_default(pattern_table, "scale", 1.0)
      let sharpness = get_float_or_default(pattern_table, "sharpness", 1.0)
      triplanar_pattern(p, scale~, sharpness~)
    }

    // Compositing / fun combinations
    "invert" => invert_pattern(get_pattern_required("pattern"))
    "mix" => {
      let a = get_pattern_required("a")
      let b = get_pattern_required("b")
      let mask = get_pattern_required("mask")
      mix_pattern(a, b, mask)
    }
    "warp" => {
      let base = get_pattern_required("base")
      let warp = get_pattern_required("warp")
      let amplitude = get_float_or_default(pattern_table, "amplitude", 0.25)
      warp_pattern(base, warp, amplitude~)
    }
    "texture" => {
      let _file = get_string_required(pattern_table, "file")
      // Texture loading is only supported in async parse_scene_file
      texture(canvas(1, 1))
    }
    _ => raise SceneParseError("Unknown pattern type: \{pattern_type}")
  }

  // Apply pattern transform if specified
  match pattern_table.get("transform") {
    Some(transform_value) => {
      let transform = parse_transform(transform_value)
      pattern.set_pattern_transform(transform)
    }
    None => ()
  }
  pattern
}

///|
fn parse_lights(
  root : Map[String, @toml.TomlValue],
) -> Array[Light] raise SceneParseError {
  let lights = Array::new()
  match root.get("lights") {
    Some(@toml.TomlArray(lights_array)) =>
      for i = 0; i < lights_array.length(); i = i + 1 {
        lights.push(parse_light(lights_array[i]))
      }
    Some(_) => raise SceneParseError("lights section must be an array")
    None => () // No lights defined
  }
  lights
}

///|
fn parse_light(value : @toml.TomlValue) -> Light raise SceneParseError {
  let light_table = match value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("light must be a table")
  }
  let light_type = get_string_required(light_table, "type")
  let position = get_vector3(light_table, "position")
  let intensity_color = match light_table.get("intensity") {
    Some(color_value) => parse_color(color_value)
    None => raise SceneParseError("light intensity is required")
  }
  match light_type {
    "point" =>
      point_light(point(position.0, position.1, position.2), intensity_color)
    "area" => {
      let u_vec = get_vector3(light_table, "u_vec")
      let v_vec = get_vector3(light_table, "v_vec")
      let u_steps = get_int_or_default(light_table, "u_steps", 1)
      let v_steps = get_int_or_default(light_table, "v_steps", 1)
      area_light(
        point(position.0, position.1, position.2),
        vector(u_vec.0, u_vec.1, u_vec.2),
        u_steps,
        vector(v_vec.0, v_vec.1, v_vec.2),
        v_steps,
        intensity_color,
      )
    }
    _ => raise SceneParseError("Unknown light type: \{light_type}")
  }
}

///|
fn parse_objects(
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
          parse_object(objects_array[i], materials, patterns, templates),
        )
      }
    Some(_) => raise SceneParseError("objects section must be an array")
    None => () // No objects defined
  }
  shapes
}

///|
fn parse_object(
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
      // Parse cylinder properties if specified
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
        Some(_) => raise SceneParseError("cylinder properties must be a table")
        None => cylinder() // Use defaults
      }
    "cone" =>
      // Parse cone properties if specified
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
        Some(_) => raise SceneParseError("cone properties must be a table")
        None => cone() // Use defaults
      }
    "triangle" =>
      match object_table.get("properties") {
        Some(@toml.TomlTable(props_table)) => {
          let vertices_value = match props_table.get("vertices") {
            Some(value) => value
            None => raise SceneParseError("triangle vertices are required")
          }
          let vertices = parse_vertices(vertices_value)
          if vertices.length() != 3 {
            raise SceneParseError("triangle must have exactly 3 vertices")
          }

          // Check if normals are provided for smooth triangle
          match props_table.get("normals") {
            Some(normals_value) => {
              let normals = parse_vertices(normals_value) // Same format as vertices
              if normals.length() != 3 {
                raise SceneParseError("triangle must have exactly 3 normals")
              }
              smooth_triangle(
                vertices[0],
                vertices[1],
                vertices[2],
                normals[0],
                normals[1],
                normals[2],
              )
            }
            None => triangle(vertices[0], vertices[1], vertices[2])
          }
        }
        Some(_) => raise SceneParseError("triangle properties must be a table")
        None => raise SceneParseError("triangle properties are required")
      }
    "group" => {
      let g = group()
      match object_table.get("children") {
        Some(@toml.TomlArray(children_array)) =>
          for i = 0; i < children_array.length(); i = i + 1 {
            let child = parse_object(
              children_array[i],
              materials,
              patterns,
              templates,
            )
            g.add_child(child)
          }
        Some(_) => raise SceneParseError("group children must be an array")
        None => () // Empty group
      }
      g
    }
    "csg" =>
      match object_table.get("properties") {
        Some(@toml.TomlTable(props_table)) => {
          let operation = get_string_required(props_table, "operation")
          let csg_op = match operation {
            "union" => Union
            "intersection" => Intersection
            "difference" => Difference
            _ => raise SceneParseError("Unknown CSG operation: \{operation}")
          }
          let left_shape = match object_table.get("left") {
            Some(left_value) =>
              parse_object(left_value, materials, patterns, templates)
            None => raise SceneParseError("CSG left object is required")
          }
          let right_shape = match object_table.get("right") {
            Some(right_value) =>
              parse_object(right_value, materials, patterns, templates)
            None => raise SceneParseError("CSG right object is required")
          }
          csg(csg_op, left_shape, right_shape)
        }
        Some(_) => raise SceneParseError("CSG properties must be a table")
        None => raise SceneParseError("CSG properties are required")
      }
    "gltf" => {
      let _file = get_string_required(object_table, "file")
      // Only supported in parse_scene_file
      group()
    }
    "obj" => {
      let _file = get_string_required(object_table, "file")
      // Only supported in parse_scene_file
      group()
    }
    _ => raise SceneParseError("Unknown object type: \{object_type}")
  }

  // Apply material (either reference or inline)
  if (object_type != "gltf" && object_type != "obj") ||
    object_table.get("material") is Some(_) {
    apply_material_and_transform_sync(shape, object_table, materials, patterns)
  } else {
    // Still need to apply transform
    apply_transform_sync(shape, object_table)
  }
  shape
}

///|
fn apply_transform_sync(
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
    }
    _ => ()
  }
}

///|
fn apply_material_and_transform_sync(
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
    // Material reference
    let material_name = get_string_required(object_table, "material")
    match materials.get(material_name) {
      Some(mat) => {
        // Copy the material to avoid sharing mutable state
        shape.material.color = mat.color
        shape.material.ambient = mat.ambient
        shape.material.diffuse = mat.diffuse
        shape.material.specular = mat.specular
        shape.material.shininess = mat.shininess
        shape.material.reflective = mat.reflective
        shape.material.transparency = mat.transparency
        shape.material.refractive_index = mat.refractive_index
        shape.material.pattern = mat.pattern
        shape.material.metallic = mat.metallic
        shape.material.roughness = mat.roughness
        shape.material.lighting_mode = mat.lighting_mode
      }
      None =>
        raise SceneParseError("Unknown material reference: \{material_name}")
    }
  }
  if has_material_inline {
    // Inline material definition
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
    shape.material.metallic = parsed_material.metallic
    shape.material.roughness = parsed_material.roughness
    shape.material.lighting_mode = parsed_material.lighting_mode
    // Pattern will be resolved below
  }

  // Resolve pattern reference if present in inline material
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
  }

  // Finalize with transforms
  apply_transform_sync(shape, object_table)

  // Handle group and CSG children material propagation
  let object_type = get_string_required(object_table, "type")
  if object_type == "group" || object_type == "csg" {
    propagate_material(shape, shape.material)
  }
}

///|
fn propagate_material(shape : Shape, mat_to_propagate : Material) -> Unit {
  let def_mat = material()
  match shape.object {
    Group(group) =>
      for child in group.children {
        // If child material is the default, replace it
        if child.material == def_mat {
          child.material = mat_to_propagate.clone()
        }
        // Recursively propagate
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
/// Parse a TOML scene file from a string
pub fn parse_scene(toml_content : String) -> ParsedScene raise SceneParseError {
  let toml_value = @toml.parse(toml_content) catch {
    e => raise SceneParseError("TOML parse error: \{e}")
  }
  let root_table = match toml_value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("Root must be a table")
  }

  // Parse metadata
  let metadata = parse_scene_metadata(root_table)

  // Parse render settings
  let render_settings = parse_render_settings(root_table)

  // Parse camera
  let camera = parse_camera(root_table, render_settings)

  // Parse materials and patterns first (needed for objects)
  let materials = parse_materials(root_table)
  let patterns = parse_patterns(root_table)

  // Resolve material patterns
  resolve_material_patterns(root_table, materials, patterns)

  // Parse templates (definitions)
  let templates = parse_templates(root_table, materials, patterns)

  // Parse lights
  let lights = parse_lights(root_table)

  // Parse objects (may reference materials, patterns and templates)
  let shapes = parse_objects(root_table, materials, patterns, templates)

  // Create world
  let world = world()
  world.lights = lights
  world.shapes = shapes
  world.background = render_settings.background
  if render_settings.divide > 0 {
    let g = group()
    for shape in world.shapes {
      g.add_child(shape)
    }
    g.divide(render_settings.divide)
    world.shapes = [g]
  }
  { world, camera, render_settings, metadata, templates }
}

///|
/// Parse a TOML scene file from a file path
pub async fn parse_scene_file(
  file_path : String,
) -> ParsedScene raise SceneParseError {
  let toml_content = @fs.read_file(file_path).text() catch {
    e => raise SceneParseError("Failed to read file \{file_path}: \{e}")
  }
  let toml_value = @toml.parse(toml_content) catch {
    e => raise SceneParseError("TOML parse error: \{e}")
  }
  let root_table = match toml_value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("Root must be a table")
  }

  // Parse metadata
  let metadata = parse_scene_metadata(root_table)

  // Parse render settings
  let render_settings = parse_render_settings(root_table)

  // Parse camera
  let camera = parse_camera(root_table, render_settings)

  // Parse materials and patterns first (needed for objects)
  let materials = parse_materials(root_table)
  let patterns = parse_patterns_async(root_table)

  // Resolve material patterns
  resolve_material_patterns(root_table, materials, patterns)

  // Parse templates (definitions)
  let templates = parse_templates_async(root_table, materials, patterns)

  // Parse lights
  let lights = parse_lights(root_table)

  // Parse objects (may reference materials, patterns and templates)
  let shapes = parse_objects_async(root_table, materials, patterns, templates)

  // Create world
  let world = world()
  world.lights = lights
  world.shapes = shapes
  world.background = render_settings.background

  // Note: Exposure will be applied during tone mapping in the render loop or final stage

  // Parse environment map
  match root_table.get("environment") {
    Some(env_value) => {
      let env_pattern = parse_pattern_async(env_value)
      world.environment_map = Some(env_pattern)
    }
    None => ()
  }
  if render_settings.divide > 0 {
    let g = group()
    for shape in world.shapes {
      g.add_child(shape)
    }
    println("Dividing world into BVH (limit=\{render_settings.divide})...")
    g.divide(render_settings.divide)
    println("World divided.")
    world.shapes = [g]
  }
  { world, camera, render_settings, metadata, templates }
}

///|
async fn parse_patterns_async(
  root : Map[String, @toml.TomlValue],
) -> Map[String, Pattern] raise SceneParseError {
  let patterns = Map::new()
  match root.get("patterns") {
    Some(@toml.TomlTable(patterns_table)) => {
      // iterate is synchronous, so we can't inside.
      // Use an array of keys to iterate asynchronously.
      let keys = []
      patterns_table.each(fn(name, _) { keys.push(name) })
      for name in keys {
        let pattern_value = patterns_table.get(name).unwrap()
        let pattern = parse_pattern_async(pattern_value)
        patterns.set(name, pattern)
      }
    }
    Some(_) => raise SceneParseError("patterns section must be a table")
    None => () // No patterns defined
  }
  patterns
}

///|
async fn parse_pattern_async(
  value : @toml.TomlValue,
) -> Pattern raise SceneParseError {
  let pattern_table = match value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("pattern must be a table")
  }
  let pattern_type = get_string_required(pattern_table, "type")
  if pattern_type == "texture" {
    let file = get_string_required(pattern_table, "file")
    let bytes = @fs.read_file(file).binary() catch {
      e => raise SceneParseError("Failed to read texture file \{file}: \{e}")
    }
    let canvas = if file.has_suffix(".hdr") {
      let hdr_img = @hdr.decode(bytes) catch {
        e => raise SceneParseError("Failed to decode HDR texture \{file}: \{e}")
      }
      Canvas::from_hdr(hdr_img)
    } else {
      match Canvas::from_png(bytes) {
        Some(c) => c
        None => raise SceneParseError("Failed to decode PNG texture \{file}")
      }
    }
    let mapping_type = get_string_or_default(pattern_table, "mapping", "planar")
    let mapping : &Mapping = match mapping_type {
      "spherical" => SphericalMapping::{  } as &Mapping
      "planar" => PlanarMapping::{  } as &Mapping
      "cylindrical" => CylindricalMapping::{  } as &Mapping
      "cubic" => CubicMapping::{  } as &Mapping
      _ => raise SceneParseError("Unknown mapping type: \{mapping_type}")
    }
    let pattern = texture(canvas, mapping~)
    // Apply pattern transform if specified
    match pattern_table.get("transform") {
      Some(transform_value) => {
        let transform = parse_transform(transform_value)
        pattern.set_pattern_transform(transform)
      }
      None => ()
    }
    return pattern
  }

  // For other patterns, use the synchronous version
  parse_pattern(value)
}

///|
fn parse_color(value : @toml.TomlValue) -> Color raise SceneParseError {
  let color_array = match value {
    @toml.TomlArray(arr) => arr
    _ => raise SceneParseError("color must be an array")
  }
  if color_array.length() != 3 {
    raise SceneParseError("color must have exactly 3 components [R, G, B]")
  }
  let r = match color_array[0] {
    @toml.TomlFloat(f) => f
    @toml.TomlInteger(i) => i.to_double()
    _ => raise SceneParseError("color component must be a number")
  }
  let g = match color_array[1] {
    @toml.TomlFloat(f) => f
    @toml.TomlInteger(i) => i.to_double()
    _ => raise SceneParseError("color component must be a number")
  }
  let b = match color_array[2] {
    @toml.TomlFloat(f) => f
    @toml.TomlInteger(i) => i.to_double()
    _ => raise SceneParseError("color component must be a number")
  }
  color(r, g, b)
}

///|
fn parse_vector3(
  value : @toml.TomlValue,
) -> (Double, Double, Double) raise SceneParseError {
  let vector_array = match value {
    @toml.TomlArray(arr) => arr
    _ => raise SceneParseError("vector3 must be an array")
  }
  if vector_array.length() != 3 {
    raise SceneParseError("vector3 must have exactly 3 components [X, Y, Z]")
  }
  let x = match vector_array[0] {
    @toml.TomlFloat(f) => f
    @toml.TomlInteger(i) => i.to_double()
    _ => raise SceneParseError("vector3 component must be a number")
  }
  let y = match vector_array[1] {
    @toml.TomlFloat(f) => f
    @toml.TomlInteger(i) => i.to_double()
    _ => raise SceneParseError("vector3 component must be a number")
  }
  let z = match vector_array[2] {
    @toml.TomlFloat(f) => f
    @toml.TomlInteger(i) => i.to_double()
    _ => raise SceneParseError("vector3 component must be a number")
  }
  (x, y, z)
}

///|
fn parse_vertices(
  value : @toml.TomlValue,
) -> Array[Tuple] raise SceneParseError {
  let vertices_array = match value {
    @toml.TomlArray(arr) => arr
    _ => raise SceneParseError("vertices must be an array")
  }
  let vertices = Array::new()
  for i = 0; i < vertices_array.length(); i = i + 1 {
    let vertex = parse_vector3(vertices_array[i])
    vertices.push(point(vertex.0, vertex.1, vertex.2))
  }
  vertices
}

///|
fn parse_matrix4x4(value : @toml.TomlValue) -> Matrix raise SceneParseError {
  let matrix_array = match value {
    @toml.TomlArray(arr) => arr
    _ => raise SceneParseError("matrix must be an array")
  }
  if matrix_array.length() != 4 {
    raise SceneParseError("matrix must have exactly 4 rows")
  }
  let matrix_values = Array::new()
  for i = 0; i < 4; i = i + 1 {
    let row = match matrix_array[i] {
      @toml.TomlArray(row_arr) => {
        if row_arr.length() != 4 {
          raise SceneParseError("matrix row must have exactly 4 columns")
        }
        row_arr
      }
      _ => raise SceneParseError("matrix row must be an array")
    }
    for j = 0; j < 4; j = j + 1 {
      let value = match row[j] {
        @toml.TomlFloat(f) => f
        @toml.TomlInteger(i) => i.to_double()
        _ => raise SceneParseError("matrix element must be a number")
      }
      matrix_values.push(value)
    }
  }

  // Create matrix from row-major order values
  mat4(
    matrix_values[0],
    matrix_values[1],
    matrix_values[2],
    matrix_values[3],
    matrix_values[4],
    matrix_values[5],
    matrix_values[6],
    matrix_values[7],
    matrix_values[8],
    matrix_values[9],
    matrix_values[10],
    matrix_values[11],
    matrix_values[12],
    matrix_values[13],
    matrix_values[14],
    matrix_values[15],
  )
}

///|
fn parse_transform(value : @toml.TomlValue) -> Matrix raise SceneParseError {
  let transform_table = match value {
    @toml.TomlTable(table) => table
    _ => raise SceneParseError("transform must be a table")
  }

  // Check if matrix is specified (takes precedence)
  match transform_table.get("matrix") {
    Some(matrix_value) => parse_matrix4x4(matrix_value)
    None => {
      // Build transform from translation, rotation, scale
      let mut transform = mat4ident()

      // Apply scale first
      match transform_table.get("scale") {
        Some(scale_value) => {
          let scale = parse_vector3(scale_value)
          transform = transform.scale(scale.0, scale.1, scale.2)
        }
        None => ()
      }

      // Apply rotation second
      match transform_table.get("rotation") {
        Some(rotation_value) => {
          let rotation = parse_vector3(rotation_value)
          transform = transform
            .rotate_x(rotation.0)
            .rotate_y(rotation.1)
            .rotate_z(rotation.2)
        }
        None => ()
      }

      // Apply translation last
      match transform_table.get("translation") {
        Some(translation_value) => {
          let trans_vec = parse_vector3(translation_value)
          transform = transform.translate(trans_vec.0, trans_vec.1, trans_vec.2)
        }
        None => ()
      }
      transform
    }
  }
}
