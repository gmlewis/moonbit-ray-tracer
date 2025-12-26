///|
pub(all) struct SmoothTriangleUV {
  p1 : Tuple
  p2 : Tuple
  p3 : Tuple
  n1 : Tuple
  n2 : Tuple
  n3 : Tuple
  uv1 : (Double, Double)
  uv2 : (Double, Double)
  uv3 : (Double, Double)
  e1 : Tuple
  e2 : Tuple
  bounds : Bounds
} derive(Show, Eq)

///|
pub fn smooth_triangle_uv(
  p1 : Tuple,
  p2 : Tuple,
  p3 : Tuple,
  n1 : Tuple,
  n2 : Tuple,
  n3 : Tuple,
  uv1 : (Double, Double),
  uv2 : (Double, Double),
  uv3 : (Double, Double),
) -> Shape {
  let bounds = Bounds::new()
  bounds..update(p1)..update(p2)..update(p3)
  let e1 = p2 - p1
  let e2 = p3 - p1
  Shape::new(
    SmoothTriangleUV({ p1, p2, p3, n1, n2, n3, uv1, uv2, uv3, e1, e2, bounds }),
  )
}

///|
pub fn SmoothTriangleUV::bounds(self : SmoothTriangleUV) -> Bounds {
  self.bounds
}

///|
pub fn SmoothTriangleUV::clone(self : SmoothTriangleUV) -> SmoothTriangleUV {
  {
    p1: self.p1,
    p2: self.p2,
    p3: self.p3,
    n1: self.n1,
    n2: self.n2,
    n3: self.n3,
    uv1: self.uv1,
    uv2: self.uv2,
    uv3: self.uv3,
    e1: self.e1,
    e2: self.e2,
    bounds: self.bounds,
  }
}

///|
pub fn SmoothTriangleUV::local_normal_at(
  self : SmoothTriangleUV,
  _point : Tuple,
  hit : Intersection,
) -> Tuple {
  self.n2.mul_scalar(hit.u) +
  self.n3.mul_scalar(hit.v) +
  self.n1.mul_scalar(1.0 - hit.u - hit.v)
}

///|
pub fn SmoothTriangleUV::local_intersect(
  self : SmoothTriangleUV,
  ray : Ray,
) -> Array[(Double, Double, Double)] {
  let dir_cross_e2 = ray.direction.cross(self.e2)
  let det = self.e1.dot(dir_cross_e2)
  if det.abs() < EPSILON {
    return []
  }
  let f = 1.0 / det
  let p1_to_origin = ray.origin - self.p1
  let u = f * p1_to_origin.dot(dir_cross_e2)
  if u < 0 || u > 1 {
    return []
  }
  let origin_cross_e1 = p1_to_origin.cross(self.e1)
  let v = f * ray.direction.dot(origin_cross_e1)
  if v < 0 || u + v > 1 {
    return []
  }
  let t = f * self.e2.dot(origin_cross_e1)
  return [(t, u, v)]
}
