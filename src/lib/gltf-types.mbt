///|
pub(all) struct GltfAccessor {
  buffer_view : Int?
  byte_offset : Int
  component_type : Int
  count : Int
  max : Array[Double]?
  min : Array[Double]?
  type_ : String
}

///|
pub(all) struct GltfBufferView {
  buffer : Int
  byte_offset : Int
  byte_length : Int
  byte_stride : Int?
  target : Int?
}

///|
pub(all) struct GltfBuffer {
  uri : String?
  byte_length : Int
}

///|
pub(all) struct GltfMeshPrimitive {
  attributes : Map[String, Int]
  indices : Int?
  material : Int?
  mode : Int
}

///|
pub(all) struct GltfMesh {
  primitives : Array[GltfMeshPrimitive]
  name : String?
}

///|
pub(all) struct GltfNode {
  mesh : Int?
  children : Array[Int]?
  matrix : Array[Double]?
  translation : Array[Double]?
  rotation : Array[Double]?
  scale : Array[Double]?
  name : String?
}

///|
pub(all) struct GltfScene {
  nodes : Array[Int]
  name : String?
}

///|
pub(all) struct GltfTextureInfo {
  index : Int
  tex_coord : Int?
}

///|
pub(all) struct GltfNormalTextureInfo {
  index : Int
  tex_coord : Int?
  scale : Double?
}

///|
pub(all) struct GltfTexture {
  sampler : Int?
  source : Int?
  name : String?
}

///|
pub(all) struct GltfImage {
  uri : String?
  buffer_view : Int?
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
  scene : Int?
  materials : Array[GltfMaterial]
  textures : Array[GltfTexture]
  images : Array[GltfImage]
}
