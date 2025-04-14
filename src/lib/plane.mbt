///|
/// Plane represents an infinite plane along the x and z axes.
pub(all) struct Plane {} derive(Show, Eq)

///|
let _Plane : &Object = Plane::{  }

///|
pub fn plane() -> Shape {
  let plane = Plane::{  }
  Shape::new_object(plane)
}

///|
pub impl Show for Plane with to_string(_self) {
  "plane()"
}

///|
pub impl Object for Plane with local_intersect(_self, ray) {
  if ray.direction.y.abs() < EPSILON {
    return []
  }
  let t = -ray.origin.y / ray.direction.y
  [t]
}

///|
pub impl Object for Plane with local_normal_at(_self, _local_point) {
  vector(0, 1, 0)
}

///|
pub impl Object for Plane with bounds(_self) {
  let min = point(@double.neg_infinity, 0, @double.neg_infinity)
  let max = point(@double.infinity, 0, @double.infinity)
  { min, max }
}
