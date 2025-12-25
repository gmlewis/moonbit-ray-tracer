///|
pub(all) struct Triangle {
  p1 : Tuple
  p2 : Tuple
  p3 : Tuple
  e1 : Tuple
  e2 : Tuple
  normal : Tuple
  bounds : Bounds
} derive(Show, Eq)

///|
pub fn triangle(p1 : Tuple, p2 : Tuple, p3 : Tuple) -> Shape {
  let bounds = Bounds::new()
  bounds..update(p1)..update(p2)..update(p3)
  let e1 = p2 - p1
  let e2 = p3 - p1
  let normal = e2.cross(e1).normalize()
  Shape::new_triangle({ p1, p2, p3, e1, e2, normal, bounds })
}

///|
pub fn Shape::new_triangle(triangle : Triangle) -> Shape {
  Shape::new(Triangle(triangle))
}

///|
pub fn Triangle::bounds(self : Triangle) -> Bounds {
  self.bounds
}

///|
pub fn Triangle::clone(self : Triangle) -> Triangle {
  {
    p1: self.p1,
    p2: self.p2,
    p3: self.p3,
    e1: self.e1,
    e2: self.e2,
    normal: self.normal,
    bounds: self.bounds,
  }
}

///|
pub fn Triangle::local_normal_at(self : Triangle, _point : Tuple) -> Tuple {
  self.normal
}

///|
pub fn Triangle::local_intersect(
  self : Triangle,
  ray : Ray,
) -> Array[(Double, Double, Double)] {
  let dir_cross_e2 = ray.direction.cross(self.e2)
  let det = self.e1.dot(dir_cross_e2)
  if det.abs() < EPSILON {
    return []
  }

  //
  let f = 1.0 / det
  let p1_to_origin = ray.origin - self.p1
  let u = f * p1_to_origin.dot(dir_cross_e2)
  if u < 0 || u > 1 {
    return []
  }

  //
  let origin_cross_e1 = p1_to_origin.cross(self.e1)
  let v = f * ray.direction.dot(origin_cross_e1)
  if v < 0 || u + v > 1 {
    return []
  }

  //
  let t = f * self.e2.dot(origin_cross_e1)
  return [(t, u, v)]
}
