///|
pub(all) struct Group {
  children : Array[Shape]
  mut bounds : Bounds?
}

///|
pub fn group() -> Shape {
  Shape::new_group(Group::{ children: [], bounds: None })
}

///|
pub fn Shape::new_group(group : Group) -> Shape {
  Shape::new(Group(group))
}

///|
pub fn Group::to_string(_self : Group) -> String {
  "group()"
}

///|
pub fn Group::output(self : Group, logger : &Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn Group::local_intersect(
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
pub fn Group::local_normal_at(_self : Group, _point : Tuple) -> Tuple {
  vector(0, 0, 0) // should not happen.
}

///|
pub fn Group::bounds(self : Group) -> Bounds {
  match self.bounds {
    Some(bounds) => return bounds
    _ => ()
  }
  let bounds = Bounds::new()
  for child in self.children {
    let cb = child.bounds() // already transformed
    bounds.update(cb.min)
    bounds.update(cb.max)
  }
  self.bounds = Some(bounds)
  bounds
}
