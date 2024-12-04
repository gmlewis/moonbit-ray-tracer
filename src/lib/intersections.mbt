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
pub(all) type Intersections Array[Intersection]

///|
pub fn intersections(xs : Array[Intersection]) -> Intersections {
  xs.sort_by(
    fn(a, b) { if a.t < b.t { -1 } else if a.t > b.t { 1 } else { 0 } },
  )
  Intersections(xs)
}

///|
pub fn length(self : Intersections) -> Int {
  self._.length()
}

///|
pub fn op_get(self : Intersections, i : Int) -> Intersection {
  self._[i]
}

///|
pub fn hit(self : Intersections) -> Intersection? {
  for xs in self._ {
    if xs.t >= 0 {
      return Some(xs)
    }
  }
  None
}
