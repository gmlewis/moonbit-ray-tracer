///|
pub(all) enum Renderable {
  Object(&Object)
  Group(Group)
  Triangle(Triangle)
  SmoothTriangle(SmoothTriangle)
  CSG(CSG)
  TriangleUV(TriangleUV)
  SmoothTriangleUV(SmoothTriangleUV)
}

///|
pub fn Renderable::to_string(self : Renderable) -> String {
  match self {
    Object(object) => object.to_string()
    Group(group) => group.to_string()
    Triangle(triangle) => triangle.to_string()
    SmoothTriangle(triangle) => triangle.to_string()
    CSG(csg) => csg.to_string()
    TriangleUV(triangle) => triangle.to_string()
    SmoothTriangleUV(triangle) => triangle.to_string()
  }
}

///|
pub impl Show for Renderable with output(self, logger) {
  logger.write_string(self.to_string())
}
