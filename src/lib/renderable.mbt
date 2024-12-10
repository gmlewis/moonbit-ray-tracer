///|
pub(all) enum Renderable {
  Object(Object)
  Group(Group)
  Triangle(Triangle)
  SmoothTriangle(SmoothTriangle)
}

///|
pub fn to_string(self : Renderable) -> String {
  match self {
    Object(object) => object.to_string()
    Group(group) => group.to_string()
    Triangle(triangle) => triangle.to_string()
    SmoothTriangle(triangle) => triangle.to_string()
  }
}

///|
pub fn output(self : Renderable, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}
