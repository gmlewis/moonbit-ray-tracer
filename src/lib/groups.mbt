///|
pub(all) struct Group {
  children : Array[Shape]
}

///|
pub fn group() -> Shape {
  Shape::new_group(Group::{ children: [] })
}

///|
pub fn to_string(self : Group) -> String {
  "group()"
}

///|
pub fn output(self : Group, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn local_intersect(self : Group, ray : Ray) -> Array[Double] {
  if self.children.length() == 0 {
    return []
  }
  let xs = []
  for child in self.children {
    let child_xs = child.intersect(ray)
    xs.append(child_xs.to_ts())
  }
  xs
}

///|
pub fn local_normal_at(self : Group, point : Tuple) -> Tuple {
  ...
}
