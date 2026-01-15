///|
pub(all) struct Intersection {
  t : Double
  shape : Shape
  u : Double
  v : Double
  mut uv_u : Double
  mut uv_v : Double
  mut has_uv : Bool
  mut uv_u1 : Double
  mut uv_v1 : Double
  mut has_uv1 : Bool
}

///|
pub fn intersection(
  t : Double,
  shape : Shape,
  u? : Double = 0,
  v? : Double = 0,
) -> Intersection {
  {
    t,
    shape,
    u,
    v,
    uv_u: 0.0,
    uv_v: 0.0,
    has_uv: false,
    uv_u1: 0.0,
    uv_v1: 0.0,
    has_uv1: false,
  }
}

///|
pub impl Eq for Intersection with equal(self, other) {
  self.t == other.t // && self.object == other.object
}

///|
pub fn Intersection::to_string(self : Intersection) -> String {
  "intersection(\{self.t})"
}

///|
pub impl Show for Intersection with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) struct Intersections {
  count : Int
  xs : Array[Intersection]
  hit : Intersection?
}

///|
pub fn Intersections::from_ts(
  ts : Array[Double],
  shape : Shape,
) -> Intersections {
  let xs = ts.map(fn(t) { intersection(t, shape) })
  intersections(xs)
}

///|
pub fn Intersections::to_ts(self : Intersections) -> Array[Double] {
  self.xs.map(fn(i) { i.t })
}

///|
pub fn intersections(xs : Array[Intersection]) -> Intersections {
  let count = xs.length()
  if xs.length() > 1 {
    xs.sort_by(fn(a, b) {
      if a.t < b.t {
        -1
      } else if a.t > b.t {
        1
      } else {
        0
      }
    })
  }
  let mut hit = None
  for x in xs {
    if x.t >= 0 {
      hit = Some(x)
      break
    }
  }
  { count, xs, hit }
}

// ///
// pub fn length(self : Intersections) -> Int {
//   self.xs.length()
// }

///|
pub fn Intersections::op_get(self : Intersections, i : Int) -> Intersection {
  self.xs[i]
}

///|
pub fn Intersections::hit(self : Intersections) -> Intersection? {
  self.hit
}

///|
pub(all) struct Computations {
  t : Double
  shape : Shape
  point : Tuple
  eyev : Tuple
  normalv : Tuple
  reflectv : Tuple
  inside : Bool
  over_point : Tuple
  under_point : Tuple
  n1 : Double // entering index of refraction
  n2 : Double // leaving index of refraction
  uv_u : Double
  uv_v : Double
  has_uv : Bool
  uv_u1 : Double
  uv_v1 : Double
  has_uv1 : Bool
}

///|
pub fn Intersection::prepare_computations(
  self : Intersection,
  ray : Ray,
  xs? : Intersections,
) -> Computations {
  let xs = match xs {
    None => intersections([self])
    Some(xs) => xs
  }
  let t = self.t
  let shape = self.shape
  let mut point = ray.position(t)
  let eyev = -ray.direction
  let mut normalv = shape.normal_at(point, hit=Some(self))
  let inside = normalv.dot(eyev) < 0
  if inside {
    normalv = -normalv
  }

  // Optional displacement mapping: offset the hit point along the (possibly
  // flipped) geometric normal. This is a simple shading-time displacement and
  // does not change silhouette (no tessellation).
  match shape.material.displacement_pattern {
    Some(pat) => {
      let strength = shape.material.displacement_strength
      if strength != 0.0 {
        let uv = if self.has_uv { Some((self.uv_u, self.uv_v)) } else { None }
        let h = pat
          .pattern_at_shape(shape, point, normal=normalv, uv?)
          .luminance()
        // Map height [0,1] to displacement [-strength,+strength].
        let disp = (h - 0.5) * 2.0 * strength
        point = point + normalv.mul_scalar(disp)
      }
    }
    None => ()
  }
  let delta = normalv.mul_scalar(EPSILON)
  let over_point = point + delta
  let under_point = point - delta
  let reflectv = ray.direction.reflect(normalv)

  // calculate indexices of refraction
  let mut n1 = 1.0
  let mut n2 = 1.0
  let containers : Array[Shape] = []
  let index_of = fn(s) {
    for index, shape in containers {
      if s == shape {
        return index
      }
    }
    return -1
  }

  //
  for i in xs.xs {
    if i == self {
      if containers.length() == 0 {
        n1 = 1.0
      } else {
        n1 = containers[containers.length() - 1].material.refractive_index
      }
    }
    let index = index_of(i.shape)
    if index >= 0 {
      ignore(containers.remove(index))
    } else {
      containers.push(i.shape)
    }
    if i == self {
      if containers.length() == 0 {
        n2 = 1.0
      } else {
        n2 = containers[containers.length() - 1].material.refractive_index
      }
      break
    }
  }

  //
  {
    t,
    shape,
    point,
    eyev,
    normalv,
    reflectv,
    inside,
    over_point,
    under_point,
    n1,
    n2,
    uv_u: self.uv_u,
    uv_v: self.uv_v,
    has_uv: self.has_uv,
    uv_u1: self.uv_u1,
    uv_v1: self.uv_v1,
    has_uv1: self.has_uv1,
  }
}

///|
pub fn Computations::schlick(self : Computations) -> Double {
  // find the cosine of the angle between the eye and normal vectors
  let mut cos = self.eyev.dot(self.normalv)
  // total internal reflection can only occur if n1 > n2
  if self.n1 > self.n2 {
    let n = self.n1 / self.n2
    let sin2_t = n * n * (1.0 - cos * cos)
    if sin2_t > 1 {
      return 1
    }
    // compute consine of theta_t using trig identity
    let cos_t = (1.0 - sin2_t).sqrt()
    // when n1 > n2, use cos(theta_2) instead
    cos = cos_t
  }
  let r0 = (self.n1 - self.n2) / (self.n1 + self.n2)
  let r0 = r0 * r0
  let f = 1.0 - cos
  let f = f * f * f * f * f
  r0 + (1.0 - r0) * f
}
