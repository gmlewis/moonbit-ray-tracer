///|
test "BinaryReader::read_uint16" {
  let bytes = b"\x34\x12"
  let reader = BinaryReader::new(bytes)
  let val = reader.read_uint16()
  inspect(val, content="4660") // 0x1234
}

///|
test "BinaryReader::read_uint32" {
  let bytes = b"\x78\x56\x34\x12"
  let reader = BinaryReader::new(bytes)
  let val = reader.read_uint32()
  inspect(val, content="305419896") // 0x12345678
}

///|
test "BinaryReader::read_float32" {
  // 1.0 in float32 is 0x3f800000
  let bytes = b"\x00\x00\x80\x3f"
  let reader = BinaryReader::new(bytes)
  let val = reader.read_float32()
  inspect(val, content="1")
}

///|
test "get_directory" {
  inspect(get_directory("path/to/file.gltf"), content="path/to")
  inspect(get_directory("file.gltf"), content=".")
}

///|
test "load_node transformation" {
  let gltf = Gltf::{
    accessors: [],
    buffer_views: [],
    buffers: [],
    meshes: [],
    nodes: [
      {
        mesh: None,
        children: None,
        matrix: None,
        translation: Some([1.0, 2.0, 3.0]),
        rotation: Some([0.0, 0.0, 0.0, 1.0]), // Identity
        scale: Some([2.0, 2.0, 2.0]),
        name: None,
      },
    ],
    scenes: [],
    scene: None,
    materials: [],
    textures: [],
    images: [],
  }
  let data = GltfData::{ gltf, buffers: [] }
  let node = data.load_node(0)
  let expected = translation(1.0, 2.0, 3.0) * scaling(2.0, 2.0, 2.0)
  inspect(node.transform, content=expected.to_string())
}
