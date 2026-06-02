///|
pub(open) trait Object: Debug + Show {
  fn local_intersect(Self, Ray) -> Array[Double] // Intersections
  fn local_normal_at(Self, Tuple) -> Tuple
  fn bounds(Self) -> Bounds
  fn clone(Self) -> &Object
}
