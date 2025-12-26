///|
pub(all) struct GltfData {
  gltf : Gltf
  buffers : Array[Bytes]
}

///|
pub fn GltfData::get_accessor_reader(
  self : GltfData,
  accessor_idx : Int,
) -> (BinaryReader, Int)? {
  let accessor = match self.gltf.accessors.get(accessor_idx) {
    Some(a) => a
    None => return None
  }
  let view_idx = match accessor.buffer_view {
    Some(i) => i
    None => return None
  }
  let view = match self.gltf.buffer_views.get(view_idx) {
    Some(v) => v
    None => return None
  }
  let buffer = match self.buffers.get(view.buffer) {
    Some(b) => b
    None => return None
  }
  let stride = match view.byte_stride {
    Some(s) => s
    None =>
      match accessor.type_ {
        "SCALAR" =>
          match accessor.component_type {
            5120 | 5121 => 1
            5122 | 5123 => 2
            _ => 4
          }
        "VEC2" =>
          match accessor.component_type {
            5126 => 8
            _ => 4
          }
        "VEC3" =>
          match accessor.component_type {
            5126 => 12
            _ => 6
          }
        "VEC4" =>
          match accessor.component_type {
            5126 => 16
            _ => 8
          }
        _ => 0
      }
  }
  Some(
    (
      BinaryReader::new(buffer, offset=view.byte_offset + accessor.byte_offset),
      stride,
    ),
  )
}

///|
fn GltfData::read_vec3(
  self : GltfData,
  accessor_idx : Int,
  is_point : Bool,
) -> Array[Tuple] {
  let accessor = match self.gltf.accessors.get(accessor_idx) {
    Some(a) => a
    None => return []
  }
  let (reader, stride) = match self.get_accessor_reader(accessor_idx) {
    Some(r) => r
    None => return []
  }
  let res = []
  for i in 0..<accessor.count {
    let start_offset = reader.offset
    let x = reader.read_float32().to_double()
    let y = reader.read_float32().to_double()
    let z = reader.read_float32().to_double()
    if is_point {
      res.push(point(x, y, -z))
    } else {
      res.push(vector(x, y, -z))
    }
    if stride > 12 {
      reader.offset = start_offset + stride
    }
  }
  res
}

///|
pub fn GltfData::read_indices(
  self : GltfData,
  accessor_idx : Int,
) -> Array[Int] {
  let accessor = match self.gltf.accessors.get(accessor_idx) {
    Some(a) => a
    None => return []
  }
  let (reader, stride) = match self.get_accessor_reader(accessor_idx) {
    Some(r) => r
    None => return []
  }
  let res = []
  for i in 0..<accessor.count {
    let start_offset = reader.offset
    let idx = match accessor.component_type {
      5121 => reader.read_uint8().reinterpret_as_int()
      5123 => reader.read_uint16().reinterpret_as_int()
      5125 => reader.read_uint32().reinterpret_as_int()
      _ => 0
    }
    res.push(idx)
    if stride > 0 {
      reader.offset = start_offset + stride
    }
  }
  res
}

///|

///|
pub async fn load_gltf_file(path : String) -> Shape raise SceneParseError {
  let bytes = @fs.read_file(path).binary() catch {
    e => raise SceneParseError("Failed to read GLTF file: \{e}")
  }

  // Check for GLB magic
  if bytes.length() >= 12 &&
    bytes[0] == (0x67).to_byte() &&
    bytes[1] == (0x6C).to_byte() &&
    bytes[2] == (0x54).to_byte() &&
    bytes[3] == (0x46).to_byte() {
    return load_glb(bytes, path)
  }

  // Fallback to JSON
  let json_str = bytes.to_string()
  let json_val = @json.parse(json_str) catch {
    e => raise SceneParseError("JSON parse error: \{e}")
  }
  let gltf = match parse_gltf(json_val) {
    Some(g) => g
    None => raise SceneParseError("Failed to parse GLTF JSON structure")
  }
  let buffers = []
  let dir = get_directory(path)
  for b in gltf.buffers {
    match b.uri {
      Some(uri) =>
        if uri.has_prefix("data:") {
          match decode_base64_uri(uri) {
            Some(bytes) => buffers.push(bytes)
            None => raise SceneParseError("Failed to decode base64 URI")
          }
        } else {
          let bin_path = if dir == "." { uri } else { dir + "/" + uri }
          let bytes = @fs.read_file(bin_path).binary() catch {
            e =>
              raise SceneParseError("Failed to read bin file \{bin_path}: \{e}")
          }
          buffers.push(bytes)
        }
      None => ()
    }
  }
  let data = GltfData::{ gltf, buffers }
  data.to_shape()
}

///|
fn load_glb(bytes : Bytes, _path : String) -> Shape raise SceneParseError {
  let reader = BinaryReader::new(bytes)
  let _magic = reader.read_uint32()
  let _version = reader.read_uint32()
  let _length = reader.read_uint32()
  let mut gltf_opt : Gltf? = None
  let buffers = []
  while reader.offset < bytes.length() {
    let chunk_length = reader.read_uint32().reinterpret_as_int()
    let chunk_type = reader.read_uint32()
    if chunk_type == 0x4E4F534A { // JSON
      let json_buf = Array::make(chunk_length, (0).to_byte())
      for i in 0..<chunk_length {
        json_buf[i] = bytes[reader.offset + i]
      }
      reader.offset += chunk_length
      let json_str = @base64.bytes2str(Bytes::from_array(json_buf))
      let json_val = @json.parse(json_str) catch {
        e => raise SceneParseError("GLB JSON parse error: \{e}")
      }
      gltf_opt = parse_gltf(json_val)
    } else if chunk_type == 0x004E4942 { // BIN
      let bin_buf = Array::make(chunk_length, (0).to_byte())
      for i in 0..<chunk_length {
        bin_buf[i] = bytes[reader.offset + i]
      }
      reader.offset += chunk_length
      buffers.push(Bytes::from_array(bin_buf))
    } else {
      reader.offset += chunk_length
    }
  }
  let gltf = match gltf_opt {
    Some(g) => g
    None => raise SceneParseError("GLB missing JSON chunk")
  }
  let data = GltfData::{ gltf, buffers }
  data.to_shape()
}

///|
fn GltfData::to_shape(self : GltfData) -> Shape {
  let g = group()
  let scene_idx = match self.gltf.scene {
    Some(i) => i
    None => 0
  }
  if self.gltf.scenes.length() > scene_idx {
    let scene = self.gltf.scenes[scene_idx]
    for node_idx in scene.nodes {
      g.add_child(self.load_node(node_idx))
    }
  }
  g
}

///|
pub fn GltfData::load_node(self : GltfData, node_idx : Int) -> Shape {
  let node = match self.gltf.nodes.get(node_idx) {
    Some(n) => n
    None => return group()
  }
  let g = group()

  // Handle mesh
  match node.mesh {
    Some(mesh_idx) => {
      let mesh_shape = self.load_mesh(mesh_idx)
      g.add_child(mesh_shape)
    }
    None => ()
  }

  // Handle transformations
  let mut transform = mat4ident()
  match node.matrix {
    Some(m) =>
      if m.length() == 16 {
        transform = mat4(
          m[0],
          m[4],
          m[8],
          m[12],
          m[1],
          m[5],
          m[9],
          m[13],
          m[2],
          m[6],
          m[10],
          m[14],
          m[3],
          m[7],
          m[11],
          m[15],
        )
      }
    None => {
      match node.scale {
        Some(s) =>
          if s.length() == 3 {
            transform = transform.scale(s[0], s[1], s[2])
          }
        None => ()
      }
      match node.rotation {
        Some(r) =>
          if r.length() == 4 {
            // Quaternion to Matrix
            let qx = r[0]
            let qy = r[1]
            let qz = r[2]
            let qw = r[3]
            let m = mat4(
              1.0 - 2.0 * qy * qy - 2.0 * qz * qz,
              2.0 * qx * qy - 2.0 * qz * qw,
              2.0 * qx * qz + 2.0 * qy * qw,
              0.0,
              2.0 * qx * qy + 2.0 * qz * qw,
              1.0 - 2.0 * qx * qx - 2.0 * qz * qz,
              2.0 * qy * qz - 2.0 * qx * qw,
              0.0,
              2.0 * qx * qz - 2.0 * qy * qw,
              2.0 * qy * qz + 2.0 * qx * qw,
              1.0 - 2.0 * qx * qx - 2.0 * qy * qy,
              0.0,
              0.0,
              0.0,
              0.0,
              1.0,
            )
            transform = transform * m.transpose()
          }
        None => ()
      }
      match node.translation {
        Some(t) =>
          if t.length() == 3 {
            transform = transform.translate(t[0], t[1], t[2])
          }
        None => ()
      }
    }
  }
  g.set_transform(transform)

  // Handle children
  match node.children {
    Some(children) =>
      for child_idx in children {
        g.add_child(self.load_node(child_idx))
      }
    None => ()
  }
  g
}

///|
pub fn GltfData::read_vec2(
  self : GltfData,
  accessor_idx : Int,
) -> Array[(Double, Double)] {
  let accessor = match self.gltf.accessors.get(accessor_idx) {
    Some(a) => a
    None => return []
  }
  let (reader, stride) = match self.get_accessor_reader(accessor_idx) {
    Some(r) => r
    None => return []
  }
  let res = []
  for i in 0..<accessor.count {
    let start_offset = reader.offset
    let u = reader.read_float32().to_double()
    let v = reader.read_float32().to_double()
    // GLTF UVs are top-left origin
    res.push((u, v))
    if stride > 8 {
      reader.offset = start_offset + stride
    }
  }
  res
}

///|
pub fn GltfData::load_mesh(self : GltfData, mesh_idx : Int) -> Shape {
  let mesh = match self.gltf.meshes.get(mesh_idx) {
    Some(m) => m
    None => return group()
  }
  let g = group()
  for primitive in mesh.primitives {
    let pos_idx = match primitive.attributes.get("POSITION") {
      Some(i) => i
      None => continue
    }
    let positions = self.read_vec3(pos_idx, true)
    let normal_idx = primitive.attributes.get("NORMAL")
    let normals = match normal_idx {
      Some(i) => self.read_vec3(i, false)
      None => []
    }
    let uv_idx = primitive.attributes.get("TEXCOORD_0")
    let uvs = match uv_idx {
      Some(i) => self.read_vec2(i)
      None => []
    }
    let material = match primitive.material {
      Some(mat_idx) => self.load_material(mat_idx)
      None => material()
    }
    match primitive.indices {
      Some(indices_idx) => {
        let indices = self.read_indices(indices_idx)
        for i = 0; i < indices.length(); i = i + 3 {
          let i1 = indices[i]
          let i2 = indices[i + 1]
          let i3 = indices[i + 2]
          let tri = if uvs.length() > 0 {
            if normals.length() > 0 {
              smooth_triangle_uv(
                positions[i1],
                positions[i2],
                positions[i3],
                normals[i1],
                normals[i2],
                normals[i3],
                uvs[i1],
                uvs[i2],
                uvs[i3],
              )
            } else {
              triangle_uv(
                positions[i1],
                positions[i2],
                positions[i3],
                uvs[i1],
                uvs[i2],
                uvs[i3],
              )
            }
          } else if normals.length() > 0 {
            smooth_triangle(
              positions[i1],
              positions[i2],
              positions[i3],
              normals[i1],
              normals[i2],
              normals[i3],
            )
          } else {
            triangle(positions[i1], positions[i2], positions[i3])
          }
          tri.material = material.clone()
          g.add_child(tri)
        }
      }
      None =>
        // Non-indexed
        for i = 0; i < positions.length(); i = i + 3 {
          let tri = if uvs.length() > 0 {
            if normals.length() > 0 {
              smooth_triangle_uv(
                positions[i],
                positions[i + 1],
                positions[i + 2],
                normals[i],
                normals[i + 1],
                normals[i + 2],
                uvs[i],
                uvs[i + 1],
                uvs[i + 2],
              )
            } else {
              triangle_uv(
                positions[i],
                positions[i + 1],
                positions[i + 2],
                uvs[i],
                uvs[i + 1],
                uvs[i + 2],
              )
            }
          } else if normals.length() > 0 {
            smooth_triangle(
              positions[i],
              positions[i + 1],
              positions[i + 2],
              normals[i],
              normals[i + 1],
              normals[i + 2],
            )
          } else {
            triangle(positions[i], positions[i + 1], positions[i + 2])
          }
          tri.material = material.clone()
          g.add_child(tri)
        }
    }
  }
  g
}

///|

///|
pub fn GltfData::load_material(self : GltfData, mat_idx : Int) -> Material {
  let mat = material()
  let g_mat = match self.gltf.materials.get(mat_idx) {
    Some(m) => m
    None => return mat
  }
  mat.lighting_mode = PBR
  match g_mat.pbr_metallic_roughness {
    Some(pbr) => {
      match pbr.base_color_factor {
        Some(c) => if c.length() >= 3 { mat.color = color(c[0], c[1], c[2]) }
        None => ()
      }
      mat.metallic = match pbr.metallic_factor {
        Some(f) => f
        None => 1.0
      }
      mat.roughness = match pbr.roughness_factor {
        Some(f) => f
        None => 1.0
      }
      match pbr.base_color_texture {
        Some(info) =>
          match self.load_material_texture(info.index) {
            Some(tex) => mat.pattern = Some(tex)
            None => ()
          }
        None => ()
      }
    }
    None => ()
  }
  mat
}

///|
pub fn GltfData::load_material_texture(
  self : GltfData,
  tex_idx : Int,
) -> Pattern? {
  let tex = match self.gltf.textures.get(tex_idx) {
    Some(t) => t
    None => return None
  }
  let source_idx = match tex.source {
    Some(i) => i
    None => return None
  }
  let image = match self.gltf.images.get(source_idx) {
    Some(img) => img
    None => return None
  }

  // Skip JPEG decoding if mime type is known, as it will just fail and spam logs
  match image.mime_type {
    Some("image/jpeg") => return None
    _ => ()
  }
  let bytes = match self.load_image(image) {
    Some(b) => b
    None => return None
  }

  // Check PNG magic
  if bytes.length() < 8 ||
    bytes[0] != (0x89).to_byte() ||
    bytes[1] != (0x50).to_byte() {
    return None
  }
  let canvas = match Canvas::from_png(bytes) {
    Some(c) => c
    None => return None
  }
  Some(texture(canvas))
}

///|
fn GltfData::load_image(self : GltfData, image : GltfImage) -> Bytes? {
  match image.uri {
    Some(uri) => {
      if uri.has_prefix("data:") {
        return decode_base64_uri(uri)
      }
      // External file not supported here since this is sync, but we already loaded all buffers
      return None
    }
    None => ()
  }
  match image.buffer_view {
    Some(view_idx) => {
      let view = match self.gltf.buffer_views.get(view_idx) {
        Some(v) => v
        None => return None
      }
      let buffer = match self.buffers.get(view.buffer) {
        Some(b) => b
        None => return None
      }
      let buf = Array::make(view.byte_length, (0).to_byte())
      for i in 0..<view.byte_length {
        buf[i] = buffer[view.byte_offset + i]
      }
      return Some(Bytes::from_array(buf))
    }
    None => ()
  }
  None
}
