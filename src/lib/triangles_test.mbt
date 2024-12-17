test "Creating a triangle (p.267)" {
  let p1 = point(0, 1, 0)
  let p2 = point(-1, 0, 0)
  let p3 = point(1, 0, 0)
  guard let Triangle(t) = triangle(p1, p2, p3).object
  assert_eq!(t.p1, p1)
  assert_eq!(t.p2, p2)
  assert_eq!(t.p3, p3)
  assert_eq!(t.e1, vector(-1, -1, 0))
  assert_eq!(t.e2, vector(1, -1, 0))
  assert_eq!(t.normal, vector(0, 0, -1))
}

test "Finding the normal on a triangle (p.267)" {
  guard let Triangle(t) = triangle(
      point(0, 1, 0),
      point(-1, 0, 0),
      point(1, 0, 0),
    ).object
  let n1 = t.local_normal_at(point(0, 0.5, 0))
  let n2 = t.local_normal_at(point(-0.5, 0.75, 0))
  let n3 = t.local_normal_at(point(0.5, 0.25, 0))
  assert_eq!(n1, t.normal)
  assert_eq!(n2, t.normal)
  assert_eq!(n3, t.normal)
}

test "Intersecting a ray parallel to the triangle (p.268)" {
  let t = triangle(point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0))
  let r = ray(point(0, -1, -2), vector(0, 1, 0))
  let xs = t.local_intersect(r)
  assert_eq!(xs.count, 0)
}

test "A ray misses the p1-p3 edge (p.269)" {
  let t = triangle(point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0))
  let r = ray(point(1, 1, -2), vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq!(xs.count, 0)
}

test "A ray misses the p1-p2 edge (p.269)" {
  let t = triangle(point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0))
  let r = ray(point(-1, 1, -2), vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq!(xs.count, 0)
}

test "A ray misses the p2-p3 edge (p.269)" {
  let t = triangle(point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0))
  let r = ray(point(0, -1, -2), vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq!(xs.count, 0)
}

test "A ray strikes a triangle (p.269)" {
  let t = triangle(point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0))
  let r = ray(point(0, 0.5, -2), vector(0, 0, 1))
  let xs = t.local_intersect(r)
  assert_eq!(xs.count, 1)
  assert_eq!(xs[0].t, 2)
}
