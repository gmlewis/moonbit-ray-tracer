///|
fn test_tuples() -> (Tuple, Tuple, Tuple, Tuple, Tuple, Tuple) {
  let p1 = point(0, 1, 0)
  let p2 = point(-1, 0, 0)
  let p3 = point(1, 0, 0)
  let n1 = vector(0, 1, 0)
  let n2 = vector(-1, 0, 0)
  let n3 = vector(1, 0, 0)
  (p1, p2, p3, n1, n2, n3)
}

///|
test "Constructing a smooth triangle (p.281)" {
  let (p1, p2, p3, n1, n2, n3) = test_tuples()
  guard smooth_triangle(p1, p2, p3, n1, n2, n3).object is SmoothTriangle(tri)
  assert_eq(tri.p1, p1)
  assert_eq(tri.p2, p2)
  assert_eq(tri.p3, p3)
  assert_eq(tri.n1, n1)
  assert_eq(tri.n2, n2)
  assert_eq(tri.n3, n3)
}

///|
test "An intersection with a smooth triangle stores u/v (p.282)" {
  let (p1, p2, p3, n1, n2, n3) = test_tuples()
  let tri = smooth_triangle(p1, p2, p3, n1, n2, n3)
  let r = ray(point(-0.2, 0.3, -2), vector(0, 0, 1))
  let xs = tri.local_intersect(r)
  assert_true((xs[0].u - 0.45).abs() < @lib.EPSILON)
  assert_true((xs[0].v - 0.25).abs() < @lib.EPSILON)
}

///|
test "A smooth triangle uses u/v to interpolate the normal (p.282)" {
  let (p1, p2, p3, n1, n2, n3) = test_tuples()
  let tri = smooth_triangle(p1, p2, p3, n1, n2, n3)
  let i = @lib.intersection(1, tri, u=0.45, v=0.25)
  let n = tri.normal_at(point(0, 0, 0), hit=Some(i))
  assert_eq(n, vector(-0.5547, 0.83205, 0))
}

///|
test "Preparing the normal on a smooth triangle (p.283)" {
  let (p1, p2, p3, n1, n2, n3) = test_tuples()
  let tri = smooth_triangle(p1, p2, p3, n1, n2, n3)
  let i = @lib.intersection(1, tri, u=0.45, v=0.25)
  let r = ray(point(-0.2, 0.3, -2), vector(0, 0, 1))
  let xs = intersections([i])
  let comps = i.prepare_computations(r, xs~)
  assert_eq(comps.normalv, vector(-0.5547, 0.83205, 0))
}
