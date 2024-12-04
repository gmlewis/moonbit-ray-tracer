///|
pub(all) struct Intersection {
  t : Double
  object : Sphere
} derive(Show, Eq)

///|
pub fn intersection(t : Double, object : Sphere) -> Intersection {
  { t, object }
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
