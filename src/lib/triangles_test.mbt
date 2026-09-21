///|
test "Creating a triangle (p.267)" {
  let p1 = @lib.point(0, 1, 0)
  let p2 = @lib.point(-1, 0, 0)
  let p3 = @lib.point(1, 0, 0)
  guard! @lib.triangle(p1, p2, p3).object is Triangle(t)
  assert_eq(t.p1, p1)
  assert_eq(t.p2, p2)
  assert_eq(t.p3, p3)
  assert_eq(t.e1, @lib.vector(-1, -1, 0))
  assert_eq(t.e2, @lib.vector(1, -1, 0))
  assert_eq(t.normal, @lib.vector(0, 0, -1))
}

///|
test "Finding the normal on a triangle (p.267)" {
  guard! @lib.triangle(
      @lib.point(0, 1, 0),
      @lib.point(-1, 0, 0),
      @lib.point(1, 0, 0),
    ).object
    is Triangle(t)
  let n1 = t.local_normal_at(@lib.point(0, 0.5, 0))
  let n2 = t.local_normal_at(@lib.point(-0.5, 0.75, 0))
  let n3 = t.local_normal_at(@lib.point(0.5, 0.25, 0))
  assert_eq(n1, t.normal)
  assert_eq(n2, t.normal)
  assert_eq(n3, t.normal)
}

///|
test "Intersecting a ray parallel to the triangle (p.268)" {
  let t = @lib.triangle(
    @lib.point(0, 1, 0),
    @lib.point(-1, 0, 0),
    @lib.point(1, 0, 0),
  )
  let r = @lib.ray(@lib.point(0, -1, -2), @lib.vector(0, 1, 0))
  let xs = t.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "A ray misses the p1-p3 edge (p.269)" {
  let t = @lib.triangle(
    @lib.point(0, 1, 0),
    @lib.point(-1, 0, 0),
    @lib.point(1, 0, 0),
  )
  let r = @lib.ray(@lib.point(1, 1, -2), @lib.vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "A ray misses the p1-p2 edge (p.269)" {
  let t = @lib.triangle(
    @lib.point(0, 1, 0),
    @lib.point(-1, 0, 0),
    @lib.point(1, 0, 0),
  )
  let r = @lib.ray(@lib.point(-1, 1, -2), @lib.vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "A ray misses the p2-p3 edge (p.269)" {
  let t = @lib.triangle(
    @lib.point(0, 1, 0),
    @lib.point(-1, 0, 0),
    @lib.point(1, 0, 0),
  )
  let r = @lib.ray(@lib.point(0, -1, -2), @lib.vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "A ray strikes a triangle (p.269)" {
  let t = @lib.triangle(
    @lib.point(0, 1, 0),
    @lib.point(-1, 0, 0),
    @lib.point(1, 0, 0),
  )
  let r = @lib.ray(@lib.point(0, 0.5, -2), @lib.vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq(xs.count, 1)
  assert_eq(xs[0].t, 2)
}
