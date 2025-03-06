///|
pub(all) enum Renderable {
  Object(&Object)
  Group(Group)
  Triangle(Triangle)
  SmoothTriangle(SmoothTriangle)
  CSG(CSG)
}

///|
pub impl Show for Renderable with to_string(self) {
  match self {
    Object(object) => object.to_string()
    Group(group) => group.to_string()
    Triangle(triangle) => triangle.to_string()
    SmoothTriangle(triangle) => triangle.to_string()
    CSG(csg) => csg.to_string()
  }
}

///|
pub impl Show for Renderable with output(self, logger) {
  logger.write_string(self.to_string())
}
