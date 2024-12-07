///|
let intersection = @lib.intersection

///|
let intersections = @lib.intersections

test "An intersection encapsulates t and shape (p.99)" {
  let s = sphere()
  let i = intersection(3.5, s)
  assert_eq!(i.t, 3.5)
  assert_eq!(i.shape, s)
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

test "Intersect sets the shape on the intersection (p.99)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].shape, s)
  assert_eq!(xs[1].shape, s)
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

test "Precomputing the state of an intersection (p.135)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = sphere()
  let i = intersection(4, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.t, i.t)
  assert_eq!(comps.shape, i.shape)
  assert_eq!(comps.point, point(0, 0, -1))
  assert_eq!(comps.eyev, vector(0, 0, -1))
  assert_eq!(comps.normalv, vector(0, 0, -1))
}

test "The hit, when an intersection occurs on the outside (p.136)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = sphere()
  let i = intersection(4, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.inside, false)
}

test "The hit, when an intersection occurs on the inside (p.136)" {
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let shape = sphere()
  let i = intersection(1, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.point, point(0, 0, 1))
  assert_eq!(comps.eyev, vector(0, 0, -1))
  assert_eq!(comps.inside, true)
  // normal would have been (0,0,1), but is inverted!
  assert_eq!(comps.normalv, vector(0, 0, -1))
}

test "The hit should offset the point (p.161)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = sphere()..set_transform(translation(0, 0, 1))
  let i = intersection(5, shape)
  let comps = i.prepare_computations(r)
  assert_true!(comps.over_point.z < -@lib.EPSILON / 2)
  assert_true!(comps.point.z > comps.over_point.z)
}

test "Precomputing the reflection vector (p.196)" {
  let shape = plane()
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 1, -1), vector(0, -sq2, sq2))
  let i = intersection(sq2, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.reflectv, vector(0, sq2, sq2))
}
