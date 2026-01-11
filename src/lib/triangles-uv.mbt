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
  tangent_u : Tuple
  tangent_v : Tuple
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

  // Tangent basis from positions + UVs.
  let du1 = uv2.0 - uv1.0
  let dv1 = uv2.1 - uv1.1
  let du2 = uv3.0 - uv1.0
  let dv2 = uv3.1 - uv1.1
  let denom = du1 * dv2 - du2 * dv1
  let (tangent_u0, tangent_v0) = if denom.abs() < 1.0e-12 {
    // Degenerate UV mapping; fall back to an arbitrary basis.
    let up = if normal.y.abs() < 0.9 {
      vector(0, 1, 0)
    } else {
      vector(1, 0, 0)
    }
    let tu = normal.cross(up).normalize()
    let tv = normal.cross(tu).normalize()
    (tu, tv)
  } else {
    let f = 1.0 / denom
    let tu = (e1.mul_scalar(dv2) - e2.mul_scalar(dv1)).mul_scalar(f)
    let tv = (e2.mul_scalar(du1) - e1.mul_scalar(du2)).mul_scalar(f)
    (tu, tv)
  }
  let tangent_u = (tangent_u0 - normal.mul_scalar(normal.dot(tangent_u0))).normalize()
  let tangent_v = (tangent_v0 -
  normal.mul_scalar(normal.dot(tangent_v0)) -
  tangent_u.mul_scalar(tangent_u.dot(tangent_v0))).normalize()
  Shape::new(
    TriangleUV({
      p1,
      p2,
      p3,
      uv1,
      uv2,
      uv3,
      e1,
      e2,
      normal,
      tangent_u,
      tangent_v,
      bounds,
    }),
  )
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
    tangent_u: self.tangent_u,
    tangent_v: self.tangent_v,
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
