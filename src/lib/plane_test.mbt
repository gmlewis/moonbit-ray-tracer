///|
test "The normal of a plane is constant everywhere (p.170)" {
  let p = @lib.plane()
  let n1 = p.local_normal_at(@lib.point(0, 0, 0))
  let n2 = p.local_normal_at(@lib.point(10, 0, -10))
  let n3 = p.local_normal_at(@lib.point(-5, 0, 150))
  assert_eq(n1, @lib.vector(0, 1, 0))
  assert_eq(n2, @lib.vector(0, 1, 0))
  assert_eq(n3, @lib.vector(0, 1, 0))
}

///|
test "Intersect with a ray parallel to the plane (p.171)" {
  let p = @lib.plane()
  let r = @lib.ray(@lib.point(0, 10, 0), @lib.vector(0, 0, 1))
  let xs = p.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "Intersect with a coplanar ray (p.171)" {
  let p = @lib.plane()
  let r = @lib.ray(@lib.point(0, 0, 0), @lib.vector(0, 0, 1))
  let xs = p.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "A ray intersecting a plane from above (p.171)" {
  let p = @lib.plane()
  let r = @lib.ray(@lib.point(0, 1, 0), @lib.vector(0, -1, 0))
  let xs = p.local_intersect(r)
  assert_eq(xs.count, 1)
  assert_eq(xs[0].t, 1)
  assert_eq(xs[0].shape, p)
}

///|
test "A ray intersecting a plane from below (p.171)" {
  let p = @lib.plane()
  let r = @lib.ray(@lib.point(0, -1, 0), @lib.vector(0, 1, 0))
  let xs = p.local_intersect(r)
  assert_eq(xs.count, 1)
  assert_eq(xs[0].t, 1)
  assert_eq(xs[0].shape, p)
}
