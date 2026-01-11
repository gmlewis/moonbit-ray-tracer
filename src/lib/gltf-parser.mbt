///|
fn get_string(json : Json) -> String? {
  match json {
    String(s) => Some(s)
    _ => None
  }
}

///|
fn get_int(json : Json) -> Int? {
  match json {
    Number(n, ..) => Some(n.to_int())
    _ => None
  }
}

///|
fn get_double(json : Json) -> Double? {
  match json {
    Number(n, ..) => Some(n)
    _ => None
  }
}

///|
fn get_array(json : Json) -> Array[Json]? {
  match json {
    Array(a) => Some(a)
    _ => None
  }
}

///|
fn get_object(json : Json) -> Map[String, Json]? {
  match json {
    Object(o) => Some(o)
    _ => None
  }
}

///|
fn parse_accessor(json : Json) -> GltfAccessor? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let buffer_view = match obj.get("bufferView") {
    Some(v) => get_int(v)
    None => None
  }
  let byte_offset = match obj.get("byteOffset") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => 0
      }
    None => 0
  }
  let component_type = match obj.get("componentType") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  let count = match obj.get("count") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  let type_ = match obj.get("type") {
    Some(v) =>
      match get_string(v) {
        Some(s) => s
        None => return None
      }
    None => return None
  }
  let max = match obj.get("max") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let min = match obj.get("min") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  Some({ buffer_view, byte_offset, component_type, count, max, min, type_ })
}

///|
fn parse_buffer_view(json : Json) -> GltfBufferView? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let buffer = match obj.get("buffer") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  let byte_offset = match obj.get("byteOffset") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => 0
      }
    None => 0
  }
  let byte_length = match obj.get("byteLength") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  let byte_stride = match obj.get("byteStride") {
    Some(v) => get_int(v)
    None => None
  }
  let target = match obj.get("target") {
    Some(v) => get_int(v)
    None => None
  }
  Some({ buffer, byte_offset, byte_length, byte_stride, target })
}

///|
fn parse_buffer(json : Json) -> GltfBuffer? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let uri = match obj.get("uri") {
    Some(v) => get_string(v)
    None => None
  }
  let byte_length = match obj.get("byteLength") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  Some({ uri, byte_length })
}

///|
fn parse_mesh_primitive(json : Json) -> GltfMeshPrimitive? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let attr_obj = match obj.get("attributes") {
    Some(v) =>
      match get_object(v) {
        Some(o) => o
        None => return None
      }
    None => return None
  }
  let attributes = Map::new()
  attr_obj.each(fn(k, v) {
    match get_int(v) {
      Some(i) => attributes.set(k, i)
      _ => ()
    }
  })
  let indices = match obj.get("indices") {
    Some(v) => get_int(v)
    None => None
  }
  let material = match obj.get("material") {
    Some(v) => get_int(v)
    None => None
  }
  let mode = match obj.get("mode") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => 4
      }
    None => 4
  }
  Some({ attributes, indices, material, mode })
}

///|
fn parse_mesh(json : Json) -> GltfMesh? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let primitives = match obj.get("primitives") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_mesh_primitive)
        None => return None
      }
    None => return None
  }
  let name = match obj.get("name") {
    Some(v) => get_string(v)
    None => None
  }
  Some({ primitives, name })
}

///|
fn parse_node(json : Json) -> GltfNode? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let mesh = match obj.get("mesh") {
    Some(v) => get_int(v)
    None => None
  }
  let children = match obj.get("children") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_int))
        None => None
      }
    None => None
  }
  let matrix = match obj.get("matrix") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let translation = match obj.get("translation") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let rotation = match obj.get("rotation") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let scale = match obj.get("scale") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let name = match obj.get("name") {
    Some(v) => get_string(v)
    None => None
  }
  Some({ mesh, children, matrix, translation, rotation, scale, name })
}

///|
fn parse_scene_gltf(json : Json) -> GltfScene? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let nodes = match obj.get("nodes") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(get_int)
        None => return None
      }
    None => return None
  }
  let name = match obj.get("name") {
    Some(v) => get_string(v)
    None => None
  }
  Some({ nodes, name })
}

///|

///|
fn parse_texture_info(json : Json) -> GltfTextureInfo? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let index = match obj.get("index") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  let tex_coord = match obj.get("texCoord") {
    Some(v) => get_int(v)
    None => None
  }
  Some({ index, tex_coord })
}

///|
fn parse_normal_texture_info(json : Json) -> GltfNormalTextureInfo? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let index = match obj.get("index") {
    Some(v) =>
      match get_int(v) {
        Some(i) => i
        None => return None
      }
    None => return None
  }
  let tex_coord = match obj.get("texCoord") {
    Some(v) => get_int(v)
    None => None
  }
  let scale = match obj.get("scale") {
    Some(v) => get_double(v)
    None => None
  }
  Some({ index, tex_coord, scale })
}

///|
fn parse_texture(json : Json) -> GltfTexture? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let sampler = match obj.get("sampler") {
    Some(v) => get_int(v)
    None => None
  }
  let source = match obj.get("source") {
    Some(v) => get_int(v)
    None => None
  }
  let name = match obj.get("name") {
    Some(v) => get_string(v)
    None => None
  }
  Some({ sampler, source, name })
}

///|
fn parse_image(json : Json) -> GltfImage? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let uri = match obj.get("uri") {
    Some(v) => get_string(v)
    None => None
  }
  let buffer_view = match obj.get("bufferView") {
    Some(v) => get_int(v)
    None => None
  }
  let mime_type = match obj.get("mimeType") {
    Some(v) => get_string(v)
    None => None
  }
  let name = match obj.get("name") {
    Some(v) => get_string(v)
    None => None
  }
  Some({ uri, buffer_view, mime_type, name })
}

///|
fn parse_material_pbr(json : Json) -> GltfMaterialPbr? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let base_color_factor = match obj.get("baseColorFactor") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let base_color_texture = match obj.get("baseColorTexture") {
    Some(v) => parse_texture_info(v)
    None => None
  }
  let metallic_factor = match obj.get("metallicFactor") {
    Some(v) => get_double(v)
    None => None
  }
  let roughness_factor = match obj.get("roughnessFactor") {
    Some(v) => get_double(v)
    None => None
  }
  let metallic_roughness_texture = match obj.get("metallicRoughnessTexture") {
    Some(v) => parse_texture_info(v)
    None => None
  }
  Some({
    base_color_factor,
    base_color_texture,
    metallic_factor,
    roughness_factor,
    metallic_roughness_texture,
  })
}

///|
fn parse_material_gltf(json : Json) -> GltfMaterial? {
  let obj = match get_object(json) {
    Some(o) => o
    None => return None
  }
  let pbr_metallic_roughness = match obj.get("pbrMetallicRoughness") {
    Some(v) => parse_material_pbr(v)
    None => None
  }
  let normal_texture = match obj.get("normalTexture") {
    Some(v) => parse_normal_texture_info(v)
    None => None
  }
  let occlusion_texture = match obj.get("occlusionTexture") {
    Some(v) => parse_texture_info(v)
    None => None
  }
  let emissive_texture = match obj.get("emissiveTexture") {
    Some(v) => parse_texture_info(v)
    None => None
  }
  let emissive_factor = match obj.get("emissiveFactor") {
    Some(v) =>
      match get_array(v) {
        Some(a) => Some(a.filter_map(get_double))
        None => None
      }
    None => None
  }
  let name = match obj.get("name") {
    Some(v) => get_string(v)
    None => None
  }
  Some({
    pbr_metallic_roughness,
    normal_texture,
    occlusion_texture,
    emissive_texture,
    emissive_factor,
    name,
  })
}

///|
pub fn parse_gltf(json_val : Json) -> Gltf? {
  let obj = match get_object(json_val) {
    Some(o) => o
    None => return None
  }
  let accessors = match obj.get("accessors") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_accessor)
        None => []
      }
    None => []
  }
  let buffer_views = match obj.get("bufferViews") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_buffer_view)
        None => []
      }
    None => []
  }
  let buffers = match obj.get("buffers") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_buffer)
        None => []
      }
    None => []
  }
  let meshes = match obj.get("meshes") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_mesh)
        None => []
      }
    None => []
  }
  let nodes = match obj.get("nodes") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_node)
        None => []
      }
    None => []
  }
  let scenes = match obj.get("scenes") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_scene_gltf)
        None => []
      }
    None => []
  }
  let scene = match obj.get("scene") {
    Some(v) => get_int(v)
    None => None
  }
  let materials = match obj.get("materials") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_material_gltf)
        None => []
      }
    None => []
  }
  let textures = match obj.get("textures") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_texture)
        None => []
      }
    None => []
  }
  let images = match obj.get("images") {
    Some(v) =>
      match get_array(v) {
        Some(a) => a.filter_map(parse_image)
        None => []
      }
    None => []
  }
  Some({
    accessors,
    buffer_views,
    buffers,
    meshes,
    nodes,
    scenes,
    scene,
    materials,
    textures,
    images,
  })
}
