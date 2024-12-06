///|
pub(all) struct Intersection {
  t : Double
  object : Shape
}

///|
pub fn intersection(t : Double, object : Shape) -> Intersection {
  { t, object }
}

///|
pub fn op_equal(self : Intersection, other : Intersection) -> Bool {
  self.t == other.t // && self.object == other.object
}

///|
pub fn to_string(self : Intersection) -> String {
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
pub fn intersections(xs : Array[Intersection]) -> Intersections {
  let count = xs.length()
  if xs.length() > 1 {
    xs.sort_by(
      fn(a, b) { if a.t < b.t { -1 } else if a.t > b.t { 1 } else { 0 } },
    )
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
pub fn op_get(self : Intersections, i : Int) -> Intersection {
  self.xs[i]
}

///|
pub fn hit(self : Intersections) -> Intersection? {
  self.hit
}

///|
pub(all) struct Computations {
  t : Double
  object : Shape
  point : Tuple
  eyev : Tuple
  normalv : Tuple
  inside : Bool
  over_point : Tuple
}

///|
pub fn prepare_computations(self : Intersection, ray : Ray) -> Computations {
  let t = self.t
  let object = self.object
  let point = ray.position(t)
  let eyev = -ray.direction
  let mut normalv = object.normal_at(point)
  let inside = normalv.dot(eyev) < 0
  if inside {
    normalv = -normalv
  }
  let over_point = point + normalv.mul_scalar(EPSILON)
  { t, object, point, eyev, normalv, inside, over_point }
}
