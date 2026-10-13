///|
pub(all) struct GltfAccessor {
  buffer_view : Int32?
  byte_offset : Int32
  component_type : Int32
  count : Int32
  max : Array[Double]?
  min : Array[Double]?
  type_ : String
}

///|
pub(all) struct GltfBufferView {
  buffer : Int32
  byte_offset : Int32
  byte_length : Int32
  byte_stride : Int32?
  target : Int32?
}

///|
pub(all) struct GltfBuffer {
  uri : String?
  byte_length : Int32
}

///|
pub(all) struct GltfMeshPrimitive {
  attributes : Map[String, Int32]
  indices : Int32?
  material : Int32?
  mode : Int32
}

///|
pub(all) struct GltfMesh {
  primitives : Array[GltfMeshPrimitive]
  name : String?
}

///|
pub(all) struct GltfNode {
  mesh : Int32?
  children : Array[Int32]?
  matrix : Array[Double]?
  translation : Array[Double]?
  rotation : Array[Double]?
  scale : Array[Double]?
  name : String?
}

///|
pub(all) struct GltfScene {
  nodes : Array[Int32]
  name : String?
}

///|
pub(all) struct GltfTextureInfo {
  index : Int32
  tex_coord : Int32?
}

///|
pub(all) struct GltfNormalTextureInfo {
  index : Int32
  tex_coord : Int32?
  scale : Double?
}

///|
pub(all) struct GltfTexture {
  sampler : Int32?
  source : Int32?
  name : String?
}

///|
pub(all) struct GltfImage {
  uri : String?
  buffer_view : Int32?
  mime_type : String?
  name : String?
}

///|
pub(all) struct GltfMaterialPbr {
  base_color_factor : Array[Double]?
  base_color_texture : GltfTextureInfo?
  metallic_factor : Double?
  roughness_factor : Double?
  metallic_roughness_texture : GltfTextureInfo?
}

///|
pub(all) struct GltfMaterial {
  pbr_metallic_roughness : GltfMaterialPbr?
  normal_texture : GltfNormalTextureInfo?
  occlusion_texture : GltfTextureInfo?
  emissive_texture : GltfTextureInfo?
  emissive_factor : Array[Double]?
  name : String?
}

///|
pub(all) struct Gltf {
  accessors : Array[GltfAccessor]
  buffer_views : Array[GltfBufferView]
  buffers : Array[GltfBuffer]
  meshes : Array[GltfMesh]
  nodes : Array[GltfNode]
  scenes : Array[GltfScene]
  scene : Int32?
  materials : Array[GltfMaterial]
  textures : Array[GltfTexture]
  images : Array[GltfImage]
}
