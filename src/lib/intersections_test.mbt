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
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, 1)
  assert_eq!(xs[1].t, 2)
}

test "Intersect sets the object on the intersection (p.99)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].object, s)
  assert_eq!(xs[1].object, s)
}

test "The hit, when all intersections have positive t (p.101)" {
  let s = sphere()
  let i1 = intersection(1, s)
  let i2 = intersection(2, s)
  let xs = intersections([i1, i2])
  let i = xs.hit()
  assert_eq!(i, Some(i1))
}

test "The hit, when some intersections have negative t (p.102)" {
  let s = sphere()
  let i1 = intersection(-1, s)
  let i2 = intersection(1, s)
  let xs = intersections([i2, i1])
  let i = xs.hit()
  assert_eq!(i, Some(i2))
}

test "The hit, when all intersections have negative t (p.102)" {
  let s = sphere()
  let i1 = intersection(-2, s)
  let i2 = intersection(-1, s)
  let xs = intersections([i2, i1])
  let i = xs.hit()
  assert_eq!(i, None)
}

test "The hit is always the lowest non-negative intersection (p.102)" {
  let s = sphere()
  let i1 = intersection(5, s)
  let i2 = intersection(7, s)
  let i3 = intersection(-3, s)
  let i4 = intersection(2, s)
  let xs = intersections([i1, i2, i3, i4])
  let i = xs.hit()
  assert_eq!(i, Some(i4))
}
