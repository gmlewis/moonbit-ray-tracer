///|
// Probe: verifies that a GLB which includes glTF `material.normalTexture`
// is parsed with that field present. This is a precursor to implementing
// image-based tangent-space normal mapping.

///|
fn read_u32_le(bytes : Bytes, offset : Int) -> UInt {
  let b0 = bytes[offset].to_int()
  let b1 = bytes[offset + 1].to_int()
  let b2 = bytes[offset + 2].to_int()
  let b3 = bytes[offset + 3].to_int()
  (b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)).reinterpret_as_uint()
}

///|
async test "GLB normalTexture is parsed (probe)" {
  let bytes = @fs.read_file("examples/assets/CompareNormal.glb").binary() catch {
    e => abort("failed to read CompareNormal.glb: \{e}")
  }
  assert_true(bytes.length() >= 12)

  // GLB header: magic, version, length (all u32 little-endian)
  let magic = read_u32_le(bytes, 0)
  assert_true(magic == 0x46546C67) // "glTF"
  let mut offset = 12
  let mut json_str_opt : String? = None

  // Chunks: [chunkLength u32, chunkType u32, chunkData]
  while offset + 8 <= bytes.length() {
    let chunk_length = read_u32_le(bytes, offset).reinterpret_as_int()
    let chunk_type = read_u32_le(bytes, offset + 4)
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
    }
    offset += chunk_length
  }
  let json_str = match json_str_opt {
    Some(s) => s
    None => abort("GLB missing JSON chunk")
  }
  let json_val = @json.parse(json_str) catch {
    e => abort("GLB JSON parse error: \{e}")
  }
  let gltf = match parse_gltf(json_val) {
    Some(g) => g
    None => abort("Failed to parse glTF JSON structure")
  }
  let mut has_normal_texture = false
  for m in gltf.materials {
    match m.normal_texture {
      Some(_) => {
        has_normal_texture = true
        break
      }
      None => ()
    }
  }
  assert_true(has_normal_texture)
}
