///|
let intersection = @lib.intersection

///|
let intersections = @lib.intersections

test "An intersection encapsulates t and object (p.99)" {
  let s = sphere()
  let i = intersection(3.5, s)
  assert_eq!(i.t, 3.5)
  assert_eq!(i.object, s)
}

test "Aggregating intersections (p.99)" {
  let s = sphere()
  let i1 = intersection(1, s)
  let i2 = intersection(2, s)
  let xs = intersections([i1, i2])
  assert_eq!(xs.length(), 2)
  assert_eq!(xs[0].t, 1)
  assert_eq!(xs[1].t, 2)
}

test "Intersect sets the object on the intersection" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.length(), 2)
  assert_eq!(xs[0].object, s)
  assert_eq!(xs[1].object, s)
}
