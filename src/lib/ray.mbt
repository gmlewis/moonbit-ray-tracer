///|
/// Ray represents an origin and direction.
pub(all) struct Ray {
  origin : Tuple
  direction : Tuple
} derive(Debug)

///|
pub extend Ray with Debug::{to_repr}

///|
pub fn ray(origin : Tuple, direction : Tuple) -> Ray {
  { origin, direction, }
}

///|

///|
pub extend Ray with Show::{to_string}

///|

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Ray with Show::{output}

///|
pub impl Show for Ray with fn to_string(self) {
  "ray(\{self.origin}, \{self.direction})"
}

///|
pub impl Show for Ray with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|

///|
pub extend Ray with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Ray with Eq::{not_equal}

///|
pub impl Eq for Ray with fn equal(self, other) {
  self.origin == other.origin && self.direction == other.direction
}

///|
pub fn Ray::position(self : Ray, t : Double) -> Tuple {
  self.origin + self.direction.mul_scalar(t)
}

///|
pub fn Ray::transform(self : Ray, m : Matrix) -> Ray {
  let origin = m.mul_tuple(self.origin)
  let direction = m.mul_tuple(self.direction)
  { origin, direction, }
}
