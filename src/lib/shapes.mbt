///|
pub(open) trait Object {
  local_intersect(Self, Ray) -> Array[Double]
  local_normal_at(Self, Tuple) -> Tuple
  output(Self, Logger) -> Unit
  to_string(Self) -> String
}

///|
// pub impl Eq for Object with op_equal(self, other) { self == other }

///|
pub(all) struct Shape {
  object : Object
  mut material : Material
  // Do not modify transform or inv_transform directly.
  // Instead, use `set_transform`.
  mut transform : Matrix
  mut inv_transform : Matrix
}

///|
pub fn Shape::to_string(_self : Shape) -> String {
  // self.object.to_string()
  "shape()"
}

///|
pub fn output(self : Shape, logger : Logger) -> Unit {
  logger.write_string(self.object.to_string())
}

///|
pub fn op_equal(self : Shape, other : Shape) -> Bool {
  // self.object == other.object &&
  self.material == other.material && self.transform == other.transform
}

///|
pub fn Shape::new(object : Object) -> Shape {
  let material = material()
  let transform = mat4ident()
  let inv_transform = mat4ident()
  { object, material, transform, inv_transform }
}

///|
pub fn set_transform(self : Shape, transform : Matrix) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn intersect(self : Shape, ray : Ray) -> Intersections {
  let local_ray = ray.transform(self.inv_transform)
  let ts = self.object.local_intersect(local_ray)
  intersections(ts.map(fn(t) { intersection(t, self) }))
}

///|
pub fn normal_at(self : Shape, point : Tuple) -> Tuple {
  let local_point = self.inv_transform.mul_tuple(point)
  let local_normal = self.object.local_normal_at(local_point)
  let world_normal = self.inv_transform.transpose().mul_tuple(local_normal)
  world_normal.w = 0
  world_normal.normalize()
}
