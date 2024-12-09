///| Plane represents an infinite plane along the x and z axes.
pub(all) struct Plane {} derive(Eq)

///|
let _Plane : Object = Plane::{  }

///|
pub fn plane() -> Shape {
  let plane = Plane::{  }
  Shape::new_object(plane)
}

///|
pub fn op_equal(self : Plane, other : Plane) -> Bool {
  self == other
}

///|
pub fn Plane::to_string(_self : Plane) -> String {
  "plane()"
}

///|
pub fn output(self : Plane, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn Plane::local_intersect(_self : Plane, ray : Ray) -> Array[Double] {
  if ray.direction.y.abs() < EPSILON {
    return []
  }
  let t = -ray.origin.y / ray.direction.y
  [t]
}

///|
pub fn Plane::local_normal_at(_self : Plane, _local_point : Tuple) -> Tuple {
  vector(0, 1, 0)
}

///|
pub fn Plane::bounds(_self : Plane) -> Bounds {
  let min = point(@double.neg_infinity, 0, @double.neg_infinity)
  let max = point(@double.infinity, 0, @double.infinity)
  { min, max }
}
