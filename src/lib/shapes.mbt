///|
pub(open) trait Object {
  local_intersect(Self, Ray) -> Array[Double] // Intersections
  local_normal_at(Self, Tuple) -> Tuple
  // https://github.com/moonbitlang/core/issues/1304
  output(Self, Logger) -> Unit
  to_string(Self) -> String
}
// pub impl Eq for Object with op_equal(self, other) { self == other }

///|
pub(all) struct Shape {
  object : Renderable
  mut material : Material
  // Do not modify transform or inv_transform directly.
  // Instead, use `set_transform`.
  mut transform : Matrix
  mut inv_transform : Matrix
  mut parent : Shape?
}

///|
pub fn Shape::to_string(self : Shape) -> String {
  self.object.to_string()
}

///|
pub fn output(self : Shape, logger : Logger) -> Unit {
  logger.write_string(self.object.to_string())
}

///|
pub fn op_equal(self : Shape, other : Shape) -> Bool {
  // https://github.com/moonbitlang/core/issues/1304#issuecomment-2523373703
  // self.object == other.object &&
  self.material == other.material && self.transform == other.transform
}

///|
pub fn Shape::new_object(object : Object) -> Shape {
  Shape::new(Object(object))
}

///|
pub fn Shape::new_group(group : Group) -> Shape {
  Shape::new(Group(group))
}

///|
pub fn Shape::new(object : Renderable) -> Shape {
  let material = material()
  let transform = mat4ident()
  let inv_transform = mat4ident()
  let parent = None
  { object, material, transform, inv_transform, parent }
}

///|
pub fn set_transform(self : Shape, transform : Matrix) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn intersect(self : Shape, ray : Ray) -> Intersections {
  let local_ray = ray.transform(self.inv_transform)
  self.local_intersect(local_ray)
}

///|
pub fn local_intersect(self : Shape, local_ray : Ray) -> Intersections {
  match self.object {
    Object(object) => {
      let ts = object.local_intersect(local_ray)
      intersections(ts.map(fn(t) { intersection(t, self) }))
    }
    Group(group) => group.local_intersect(self, local_ray)
  }
}

///|
pub fn normal_at(self : Shape, point : Tuple) -> Tuple {
  let local_point = self.inv_transform.mul_tuple(point)
  let local_normal = self.object.local_normal_at(local_point)
  let world_normal = self.inv_transform.transpose().mul_tuple(local_normal)
  world_normal.w = 0
  world_normal.normalize()
}

///|
pub fn local_normal_at(self : Shape, local_point : Tuple) -> Tuple {
  self.object.local_normal_at(local_point)
}

///|
pub fn children(self : Shape) -> Array[Shape] {
  match self.object {
    Object(_) => []
    Group(group) => group.children
  }
}

///|
pub fn add_child(self : Shape, child : Shape) -> Unit {
  match self.object {
    Group(group) => {
      group.children.push(child)
      child.parent = Some(self)
    }
    Object(_) => ()
  }
}

///|
pub fn world_to_object(self : Shape, point : Tuple) -> Tuple {
  match self.parent {
    Some(parent) => {
      let point = parent.world_to_object(point)
      self.inv_transform.mul_tuple(point)
    }
    _ => self.inv_transform.mul_tuple(point)
  }
}

///|
pub fn normal_to_world(self : Shape, normal : Tuple) -> Tuple {
  let normal = self.inv_transform.transpose().mul_tuple(normal)
  normal.w = 0
  let normal = normal.normalize()
  match self.parent {
    Some(parent) => parent.normal_to_world(normal)
    _ => normal
  }
}
