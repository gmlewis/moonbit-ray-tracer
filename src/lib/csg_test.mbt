///|
test "CSG is created with an operation and two shapes (p.293)" {
  let s1 = sphere()
  let s2 = cube()
  let parent = csg(Union, s1, s2)
  guard let CSG(c) = parent.object
  assert_eq!(c.operation, Union)
  assert_eq!(c.left, s1)
  assert_eq!(c.right, s2)
  assert_eq!(s1.parent, Some(parent))
}

///|
test "Evaluating the rule for a CSG operation (p.294)" {
  let tests = [
    (@lib.Union, true, true, true, false),
    (Union, true, true, false, true),
    (Union, true, false, true, false),
    (Union, true, false, false, true),
    (Union, false, true, true, false),
    (Union, false, true, false, false),
    (Union, false, false, true, true),
    (Union, false, false, false, true),
    (Intersection, true, true, true, true),
    (Intersection, true, true, false, false),
    (Intersection, true, false, true, true),
    (Intersection, true, false, false, false),
    (Intersection, false, true, true, true),
    (Intersection, false, true, false, true),
    (Intersection, false, false, true, false),
    (Intersection, false, false, false, false),
    (Difference, true, true, true, false),
    (Difference, true, true, false, true),
    (Difference, true, false, true, false),
    (Difference, true, false, false, true),
    (Difference, false, true, true, true),
    (Difference, false, true, false, true),
    (Difference, false, false, true, false),
    (Difference, false, false, false, false),
  ]
  for tt in tests {
    let got = intersection_allowed(tt.0, tt.1, tt.2, tt.3)
    assert_eq!((tt.0, tt.1, tt.2, tt.3, got), tt)
  }
}

///|
test "Filtering a list of intersections (p.297)" {
  let tests = [(@lib.Union, 0, 3), (Intersection, 1, 2), (Difference, 0, 1)]
  let s1 = sphere()
  let s2 = cube()
  for tt in tests {
    guard let CSG(c) = csg(tt.0, s1, s2).object
    let xs = intersections([
      @lib.intersection(1, s1),
      @lib.intersection(2, s2),
      @lib.intersection(3, s1),
      @lib.intersection(4, s2),
    ])
    let result = c.filter_intersections(xs)
    assert_eq!(result.count, 2)
    assert_eq!(result[0], xs[tt.1])
    assert_eq!(result[1], xs[tt.2])
  }
}

///|
test "A ray misses a CSG object (p.299)" {
  let c = csg(Union, sphere(), cube())
  let r = ray(point(0, 2, -5), vector(0, 0, 1))
  let xs = c.local_intersect(r)
  assert_eq!(xs.count, 0)
}

///|
test "A ray hits a CSG object (p.299)" {
  let s1 = sphere()
  let s2 = sphere()..set_transform(translation(0, 0, 0.5))
  let c = csg(Union, s1, s2)
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let xs = c.local_intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, 4)
  assert_eq!(xs[0].shape, s1)
  assert_eq!(xs[1].t, 6.5)
  assert_eq!(xs[1].shape, s2)
}
