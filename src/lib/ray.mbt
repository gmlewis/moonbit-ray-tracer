///| Ray represents an origin and direction.
pub(all) struct Ray {
  origin : Tuple
  direction : Tuple
} derive(Eq)

///|
pub fn ray(origin : Tuple, direction : Tuple) -> Ray {
  { origin, direction }
}

///|
pub fn to_string(self : Ray) -> String {
  "ray(\{self.origin}, \{self.direction})"
}

///|
pub impl Show for Ray with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn op_equal(self : Ray, other : Ray) -> Bool {
  self.origin == other.origin && self.direction == other.direction
}

///|
pub fn position(self : Ray, t : Double) -> Tuple {
  self.origin + self.direction.mul_scalar(t)
}

///|
pub fn transform(self : Ray, m : Matrix) -> Ray {
  let origin = m.mul_tuple(self.origin)
  let direction = m.mul_tuple(self.direction)
  { origin, direction }
}
