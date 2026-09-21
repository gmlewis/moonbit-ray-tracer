///|
/// Plane represents an infinite plane along the x and z axes.
pub(all) struct Plane {} derive(Debug, Eq)

///|
pub extend Plane with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Plane with Eq::{not_equal}

///|
pub extend Plane with Debug::{to_repr}

///|
let _Plane : &Object = Plane::{ }

///|
pub fn plane() -> Shape {
  let plane = Plane::{ }
  Shape::new_object(plane)
}

///|

///|
pub extend Plane with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Plane with Show::{output}

///|
pub impl Show for Plane with fn output(_self, logger) {
  logger.write_string("plane()")
}

///|

///|
pub extend Plane with Object::{bounds, clone, local_intersect, local_normal_at}

///|
pub impl Object for Plane with fn local_intersect(_self, ray) {
  if ray.direction.y.abs() < EPSILON {
    return []
  }
  let t = -ray.origin.y / ray.direction.y
  [t]
}

///|
pub impl Object for Plane with fn local_normal_at(_self, _local_point) {
  vector(0, 1, 0)
}

///|
pub impl Object for Plane with fn bounds(_self) {
  let min = point(@double.neg_infinity, 0, @double.neg_infinity)
  let max = point(@double.infinity, 0, @double.infinity)
  { min, max, }
}

///|
pub impl Object for Plane with fn clone(_self) {
  Plane::{ }
}
