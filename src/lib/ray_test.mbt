///|
let ray = @lib.ray

test "Creating and querying a ray (p.92)" {
  let origin = point(1, 2, 3)
  let direction = vector(4, 5, 6)
  let r = ray(origin, direction)
  assert_eq!(r.origin, origin)
  assert_eq!(r.direction, direction)
}

test "Computing a point from a distance (p.92)" {
  let r = ray(point(2, 3, 4), vector(1, 0, 0))
  assert_eq!(r.position(0), point(2, 3, 4))
  assert_eq!(r.position(1), point(3, 3, 4))
  assert_eq!(r.position(-1), point(1, 3, 4))
  assert_eq!(r.position(2.5), point(4.5, 3, 4))
}
