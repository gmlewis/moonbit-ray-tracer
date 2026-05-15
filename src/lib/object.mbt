///|
pub(open) trait Object: Debug + Show {
  local_intersect(Self, Ray) -> Array[Double] // Intersections
  local_normal_at(Self, Tuple) -> Tuple
  bounds(Self) -> Bounds
  clone(Self) -> &Object
}
