///|
test "Creating and querying a ray (p.92)" {
  let origin = point(1, 2, 3)
  let direction = vector(4, 5, 6)
  let r = ray(origin, direction)
  assert_eq!(r.origin, origin)
  assert_eq!(r.direction, direction)
}

///|
test "Computing a point from a distance (p.92)" {
  let r = ray(point(2, 3, 4), vector(1, 0, 0))
  assert_eq!(r.position(0), point(2, 3, 4))
  assert_eq!(r.position(1), point(3, 3, 4))
  assert_eq!(r.position(-1), point(1, 3, 4))
  assert_eq!(r.position(2.5), point(4.5, 3, 4))
}

///|
test "Translating a ray (p.105)" {
  let r = ray(point(1, 2, 3), vector(0, 1, 0))
  let m = translation(3, 4, 5)
  let r2 = r.transform(m)
  assert_eq!(r2.origin, point(4, 6, 8))
  assert_eq!(r2.direction, vector(0, 1, 0))
}

///|
test "Scaling a ray (p.105)" {
  let r = ray(point(1, 2, 3), vector(0, 1, 0))
  let m = scaling(2, 3, 4)
  let r2 = r.transform(m)
  assert_eq!(r2.origin, point(2, 6, 12))
  assert_eq!(r2.direction, vector(0, 3, 0))
}
