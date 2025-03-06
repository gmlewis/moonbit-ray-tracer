///|
pub(open) trait Object: Show {
  local_intersect(Self, Ray) -> Array[Double] // Intersections
  local_normal_at(Self, Tuple) -> Tuple
  bounds(Self) -> Bounds
}
// pub impl Eq for Object with op_equal(self, other) { self == other }
