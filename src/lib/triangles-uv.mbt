///|
pub(all) struct TriangleUV {
  p1 : Tuple
  p2 : Tuple
  p3 : Tuple
  uv1 : (Double, Double)
  uv2 : (Double, Double)
  uv3 : (Double, Double)
  e1 : Tuple
  e2 : Tuple
  normal : Tuple
  bounds : Bounds
} derive(Show, Eq)

///|
pub fn triangle_uv(
  p1 : Tuple,
  p2 : Tuple,
  p3 : Tuple,
  uv1 : (Double, Double),
  uv2 : (Double, Double),
  uv3 : (Double, Double),
) -> Shape {
  let bounds = Bounds::new()
  bounds..update(p1)..update(p2)..update(p3)
  let e1 = p2 - p1
  let e2 = p3 - p1
  let normal = e2.cross(e1).normalize()
  Shape::new(TriangleUV({ p1, p2, p3, uv1, uv2, uv3, e1, e2, normal, bounds }))
}

///|
pub fn TriangleUV::bounds(self : TriangleUV) -> Bounds {
  self.bounds
}

///|
pub fn TriangleUV::clone(self : TriangleUV) -> TriangleUV {
  {
    p1: self.p1,
    p2: self.p2,
    p3: self.p3,
    uv1: self.uv1,
    uv2: self.uv2,
    uv3: self.uv3,
    e1: self.e1,
    e2: self.e2,
    normal: self.normal,
    bounds: self.bounds,
  }
}

///|
pub fn TriangleUV::local_normal_at(self : TriangleUV, _point : Tuple) -> Tuple {
  self.normal
}

///|
pub fn TriangleUV::local_intersect(
  self : TriangleUV,
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
