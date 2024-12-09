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
pub fn local_intersect(
  self : Group,
  group_shape : Shape,
  ray : Ray
) -> Intersections {
  if self.children.length() == 0 {
    return Intersections::from_ts([], group_shape)
  }
  let xs = []
  for child in self.children {
    let ts = child.intersect(ray)
    xs.append(ts.xs)
  }
  intersections(xs)
}

///|
pub fn local_normal_at(self : Group, point : Tuple) -> Tuple {
  ...
}
