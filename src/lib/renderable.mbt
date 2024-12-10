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

///|
pub fn local_intersect(self : Renderable, ray : Ray) -> Array[Double] {
  match self {
    Object(object) => object.local_intersect(ray)
    _ => [] // Group is handled by Shape::local_intersect
  }
}

///|
pub fn local_normal_at(self : Renderable, point : Tuple) -> Tuple {
  match self {
    Object(object) => object.local_normal_at(point)
    Group(group) => group.local_normal_at(point)
    Triangle(triangle) => triangle.local_normal_at(point)
  }
}
