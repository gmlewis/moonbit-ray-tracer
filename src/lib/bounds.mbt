///|
pub(all) struct Bounds {
  mut min : Tuple
  mut max : Tuple
} derive(Show, Eq)

///|
pub fn Bounds::new() -> Bounds {
  let min = point(@double.infinity, @double.infinity, @double.infinity)
  let max = point(
    @double.neg_infinity, @double.neg_infinity, @double.neg_infinity,
  )
  { min, max }
}

///|
pub fn transform(self : Bounds, transform : Matrix) -> Bounds {
  let b = Bounds::new()
  b
  ..update(transform.mul_tuple(point(self.min.x, self.min.y, self.min.z)))
  ..update(transform.mul_tuple(point(self.max.x, self.min.y, self.min.z)))
  ..update(transform.mul_tuple(point(self.max.x, self.max.y, self.min.z)))
  ..update(transform.mul_tuple(point(self.min.x, self.max.y, self.min.z)))
  ..update(transform.mul_tuple(point(self.min.x, self.min.y, self.max.z)))
  ..update(transform.mul_tuple(point(self.max.x, self.min.y, self.max.z)))
  ..update(transform.mul_tuple(point(self.max.x, self.max.y, self.max.z)))
  ..update(transform.mul_tuple(point(self.min.x, self.max.y, self.max.z)))
  b
}

///|
pub fn enlarge(self : Bounds, other : Bounds) -> Unit {
  self
  ..update(point(other.min.x, other.min.y, other.min.z))
  ..update(point(other.max.x, other.min.y, other.min.z))
  ..update(point(other.max.x, other.max.y, other.min.z))
  ..update(point(other.min.x, other.max.y, other.min.z))
  ..update(point(other.min.x, other.min.y, other.max.z))
  ..update(point(other.max.x, other.min.y, other.max.z))
  ..update(point(other.max.x, other.max.y, other.max.z))
  ..update(point(other.min.x, other.max.y, other.max.z))
}

///|
pub fn update(self : Bounds, point : Tuple) -> Unit {
  if point.x < self.min.x {
    self.min.x = point.x
  }
  if point.y < self.min.y {
    self.min.y = point.y
  }
  if point.z < self.min.z {
    self.min.z = point.z
  }
  if point.x > self.max.x {
    self.max.x = point.x
  }
  if point.y > self.max.y {
    self.max.y = point.y
  }
  if point.z > self.max.z {
    self.max.z = point.z
  }
}

///|
pub fn local_intersect(
  self : Bounds,
  ray : Ray,
  shape : Shape
) -> Intersections {
  let (xtmin, xtmax) = check_axis(
    ray.origin.x,
    ray.direction.x,
    self.min.x,
    self.max.x,
  )
  let (ytmin, ytmax) = check_axis(
    ray.origin.y,
    ray.direction.y,
    self.min.y,
    self.max.y,
  )
  let (ztmin, ztmax) = check_axis(
    ray.origin.z,
    ray.direction.z,
    self.min.z,
    self.max.z,
  )
  let tmin = @cmp.maximum(xtmin, @cmp.maximum(ytmin, ztmin))
  let tmax = @cmp.minimum(xtmax, @cmp.minimum(ytmax, ztmax))
  if tmin > tmax {
    return intersections([])
  }
  intersections([intersection(tmin, shape), intersection(tmax, shape)])
}
