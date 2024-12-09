///|
pub(all) enum Renderable {
  Object(Object)
  Group(Group)
}

///|
pub fn to_string(self : Renderable) -> String {
  match self {
    Object(object) => object.to_string()
    Group(group) => group.to_string()
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
    Group(group) => group.local_intersect(ray)
  }
}

///|
pub fn local_normal_at(self : Renderable, point : Tuple) -> Tuple {
  match self {
    Object(object) => object.local_normal_at(point)
    Group(group) => group.local_normal_at(point)
  }
}
