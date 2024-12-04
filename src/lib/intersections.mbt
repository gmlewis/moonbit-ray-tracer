///|
pub(all) struct Intersection {
  t : Double
  object : Sphere
}

///|
pub fn intersection(t : Double, object : Sphere) -> Intersection {
  { t, object }
}

///|
pub(all) type Intersections Array[Intersection]

///|
pub fn intersections(xs : Array[Intersection]) -> Intersections {
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
