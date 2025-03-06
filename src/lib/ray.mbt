///| Ray represents an origin and direction.
pub(all) struct Ray {
  origin : Tuple
  direction : Tuple
}

///|
pub fn ray(origin : Tuple, direction : Tuple) -> Ray {
  { origin, direction }
}

///|
pub impl Show for Ray with to_string(self) {
  "ray(\{self.origin}, \{self.direction})"
}

///|
pub impl Show for Ray with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl Eq for Ray with op_equal(self, other) {
  self.origin == other.origin && self.direction == other.direction
}

///|
pub fn position(self : Ray, t : Double) -> Tuple {
  self.origin + self.direction.mul_scalar(t)
}

///|
pub fn Ray::transform(self : Ray, m : Matrix) -> Ray {
  let origin = m.mul_tuple(self.origin)
  let direction = m.mul_tuple(self.direction)
  { origin, direction }
}
