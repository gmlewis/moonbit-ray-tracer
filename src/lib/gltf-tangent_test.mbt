///|
// Validates that when a glTF primitive provides ATTRIBUTE `TANGENT`, we ingest it
// and use it to build the triangle's tangent basis (including handedness).

///|
fn read_u32_le_glb(bytes : Bytes, offset : Int) -> UInt {
  let b0 = bytes[offset].to_int()
  let b1 = bytes[offset + 1].to_int()
  let b2 = bytes[offset + 2].to_int()
  let b3 = bytes[offset + 3].to_int()
  (b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)).reinterpret_as_uint()
}

///|
fn read_glb_json_and_bin(bytes : Bytes) -> (String, Bytes) {
  if bytes.length() < 12 {
    abort("invalid GLB: too small")
  }
  let magic = read_u32_le_glb(bytes, 0)
  if magic != 0x46546C67 { // "glTF"
    abort("invalid GLB: bad magic")
  }
  let mut offset = 12
  let mut json_str_opt : String? = None
  let mut bin_opt : Bytes? = None
  while offset + 8 <= bytes.length() {
    let chunk_length = read_u32_le_glb(bytes, offset).reinterpret_as_int()
    let chunk_type = read_u32_le_glb(bytes, offset + 4)
    offset += 8
    if chunk_length < 0 || offset + chunk_length > bytes.length() {
      abort("invalid GLB chunk length")
    }
    if chunk_type == 0x4E4F534A { // JSON
      let json_buf = Array::make(chunk_length, (0).to_byte())
      for i in 0..<chunk_length {
        json_buf[i] = bytes[offset + i]
      }
      json_str_opt = Some(@base64.bytes2str(Bytes::from_array(json_buf)))
    } else if chunk_type == 0x004E4942 { // BIN
      let bin_buf = Array::make(chunk_length, (0).to_byte())
      for i in 0..<chunk_length {
        bin_buf[i] = bytes[offset + i]
      }
      bin_opt = Some(Bytes::from_array(bin_buf))
    }
    offset += chunk_length
  }
  let json_str = match json_str_opt {
    Some(s) => s
    None => abort("GLB missing JSON chunk")
  }
  let bin = match bin_opt {
    Some(b) => b
    None => abort("GLB missing BIN chunk")
  }
  (json_str, bin)
}

///|
fn accessor_stride(accessor : GltfAccessor) -> Int {
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

///|
fn get_reader(
  gltf : Gltf,
  bin : Bytes,
  accessor_idx : Int,
) -> (BinaryReader, Int) {
  let accessor = match gltf.accessors.get(accessor_idx) {
    Some(a) => a
    None => abort("missing accessor")
  }
  let view_idx = match accessor.buffer_view {
    Some(i) => i
    None => abort("missing bufferView")
  }
  let view = match gltf.buffer_views.get(view_idx) {
    Some(v) => v
    None => abort("missing bufferView")
  }
  // In GLB we only support the first buffer (the BIN chunk).
  if view.buffer != 0 {
    abort("unexpected GLB buffer index")
  }
  let stride = match view.byte_stride {
    Some(s) => s
    None => accessor_stride(accessor)
  }
  (
    BinaryReader::new(bin, offset=view.byte_offset + accessor.byte_offset),
    stride,
  )
}

///|
fn read_indices_first3(
  gltf : Gltf,
  bin : Bytes,
  accessor_idx : Int,
) -> (Int, Int, Int) {
  let accessor = match gltf.accessors.get(accessor_idx) {
    Some(a) => a
    None => abort("missing indices accessor")
  }
  let (reader, stride) = get_reader(gltf, bin, accessor_idx)
  if accessor.count < 3 {
    abort("indices accessor too small")
  }
  fn read_one(reader : BinaryReader, component_type : Int) -> Int {
    match component_type {
      5121 => reader.read_uint8().reinterpret_as_int()
      5123 => reader.read_uint16().reinterpret_as_int()
      5125 => reader.read_uint32().reinterpret_as_int()
      _ => abort("unsupported indices component type")
    }
  }

  let start0 = reader.offset
  let i1 = read_one(reader, accessor.component_type)
  if stride > 0 {
    reader.offset = start0 + stride
  }
  let start1 = reader.offset
  let i2 = read_one(reader, accessor.component_type)
  if stride > 0 {
    reader.offset = start1 + stride
  }
  let start2 = reader.offset
  let i3 = read_one(reader, accessor.component_type)
  if stride > 0 {
    reader.offset = start2 + stride
  }
  (i1, i2, i3)
}

///|
fn read_vec3_at(
  gltf : Gltf,
  bin : Bytes,
  accessor_idx : Int,
  i : Int,
  is_point : Bool,
) -> Tuple {
  let (reader, stride) = get_reader(gltf, bin, accessor_idx)
  reader.offset = reader.offset + i * stride
  let x = reader.read_float32().to_double()
  let y = reader.read_float32().to_double()
  let z = reader.read_float32().to_double()
  if is_point {
    point(x, y, -z)
  } else {
    vector(x, y, -z)
  }
}

///|
fn read_tangent_at(
  gltf : Gltf,
  bin : Bytes,
  accessor_idx : Int,
  i : Int,
) -> (Tuple, Double) {
  let (reader, stride) = get_reader(gltf, bin, accessor_idx)
  reader.offset = reader.offset + i * stride
  let x = reader.read_float32().to_double()
  let y = reader.read_float32().to_double()
  let z = reader.read_float32().to_double()
  let w = reader.read_float32().to_double()

  // Loader flips Z; that reflection flips handedness (w).
  let sign = if w < 0.0 { 1.0 } else { -1.0 }
  (vector(x, y, -z), sign)
}

///|
fn find_first_uv_triangle(shape : Shape) -> Shape? {
  match shape.object {
    TriangleUV(_) => Some(shape)
    SmoothTriangleUV(_) => Some(shape)
    _ => {
      for child in shape.children() {
        match find_first_uv_triangle(child) {
          Some(s) => return Some(s)
          None => ()
        }
      }
      None
    }
  }
}

///|
async test "GLB TANGENT attribute is used for tangent basis" {
  let path = "examples/assets/VertexColorTest.glb"
  let bytes = @fs.read_file(path).binary() catch {
    e => abort("failed to read VertexColorTest.glb: \{e}")
  }
  let (json_str, bin) = read_glb_json_and_bin(bytes)
  let json_val = @json.parse(json_str) catch {
    e => abort("GLB JSON parse error: \{e}")
  }
  let gltf = match parse_gltf(json_val) {
    Some(g) => g
    None => abort("Failed to parse glTF JSON structure")
  }
  let mut pos_idx_opt : Int? = None
  let mut nrm_idx_opt : Int? = None
  let mut tan_idx_opt : Int? = None
  let mut ind_idx_opt : Int? = None
  for mesh in gltf.meshes {
    for prim in mesh.primitives {
      // Only handle triangle primitives.
      if prim.mode != 4 {
        continue
      }
      let pos_idx = match prim.attributes.get("POSITION") {
        Some(i) => i
        None => continue
      }
      let nrm_idx = match prim.attributes.get("NORMAL") {
        Some(i) => i
        None => continue
      }
      let tan_idx = match prim.attributes.get("TANGENT") {
        Some(i) => i
        None => continue
      }
      let ind_idx = match prim.indices {
        Some(i) => i
        None => continue
      }
      pos_idx_opt = Some(pos_idx)
      nrm_idx_opt = Some(nrm_idx)
      tan_idx_opt = Some(tan_idx)
      ind_idx_opt = Some(ind_idx)
      break
    }
    match ind_idx_opt {
      Some(_) => break
      None => ()
    }
  }
  let pos_idx = match pos_idx_opt {
    Some(i) => i
    None => abort("no primitive with POSITION/NORMAL/TANGENT found")
  }
  let nrm_idx = match nrm_idx_opt {
    Some(i) => i
    None => abort("no primitive with POSITION/NORMAL/TANGENT found")
  }
  let tan_idx = match tan_idx_opt {
    Some(i) => i
    None => abort("no primitive with POSITION/NORMAL/TANGENT found")
  }
  let ind_idx = match ind_idx_opt {
    Some(i) => i
    None => abort("no primitive with POSITION/NORMAL/TANGENT found")
  }
  let (i1, i2, i3) = read_indices_first3(gltf, bin, ind_idx)
  let p1 = read_vec3_at(gltf, bin, pos_idx, i1, true)
  let p2 = read_vec3_at(gltf, bin, pos_idx, i2, true)
  let p3 = read_vec3_at(gltf, bin, pos_idx, i3, true)
  let _n1 = read_vec3_at(gltf, bin, nrm_idx, i1, false)
  let _n2 = read_vec3_at(gltf, bin, nrm_idx, i2, false)
  let _n3 = read_vec3_at(gltf, bin, nrm_idx, i3, false)
  let (t1, s1) = read_tangent_at(gltf, bin, tan_idx, i1)
  let (t2, s2) = read_tangent_at(gltf, bin, tan_idx, i2)
  let (t3, s3) = read_tangent_at(gltf, bin, tan_idx, i3)
  let e1 = p2 - p1
  let e2 = p3 - p1
  let n = e2.cross(e1).normalize()
  let t = t1 + t2 + t3
  assert_true(t.magnitude() > 1.e-12)
  let mut tu = t.normalize()
  tu = (tu - n.mul_scalar(n.dot(tu))).normalize()
  assert_true(tu.magnitude() > 1.e-12)
  let s = s1 + s2 + s3
  let sign = if s < 0.0 { -1.0 } else { 1.0 }
  let tv = n.cross(tu).mul_scalar(sign).normalize()
  let shape = load_gltf_file(path)
  let tri_shape = match find_first_uv_triangle(shape) {
    Some(s) => s
    None => abort("no UV triangle found")
  }
  match tri_shape.object {
    TriangleUV(t) => {
      assert_true(t.tangent_u.dot(tu) > 0.999)
      assert_true(t.tangent_v.dot(tv) > 0.999)
    }
    SmoothTriangleUV(t) => {
      assert_true(t.tangent_u.dot(tu) > 0.999)
      assert_true(t.tangent_v.dot(tv) > 0.999)
    }
    _ => abort("unexpected shape kind")
  }
}
