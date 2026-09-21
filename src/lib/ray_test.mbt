///|
test "Creating and querying a ray (p.92)" {
  let origin = @lib.point(1, 2, 3)
  let direction = @lib.vector(4, 5, 6)
  let r = @lib.ray(origin, direction)
  assert_eq(r.origin, origin)
  assert_eq(r.direction, direction)
}

///|
test "Computing a point from a distance (p.92)" {
  let r = @lib.ray(@lib.point(2, 3, 4), @lib.vector(1, 0, 0))
  assert_eq(r.position(0), @lib.point(2, 3, 4))
  assert_eq(r.position(1), @lib.point(3, 3, 4))
  assert_eq(r.position(-1), @lib.point(1, 3, 4))
  assert_eq(r.position(2.5), @lib.point(4.5, 3, 4))
}

///|
test "Translating a ray (p.105)" {
  let r = @lib.ray(@lib.point(1, 2, 3), @lib.vector(0, 1, 0))
  let m = @lib.translation(3, 4, 5)
  let r2 = r.transform(m)
  assert_eq(r2.origin, @lib.point(4, 6, 8))
  assert_eq(r2.direction, @lib.vector(0, 1, 0))
}

///|
test "Scaling a ray (p.105)" {
  let r = @lib.ray(@lib.point(1, 2, 3), @lib.vector(0, 1, 0))
  let m = @lib.scaling(2, 3, 4)
  let r2 = r.transform(m)
  assert_eq(r2.origin, @lib.point(2, 6, 12))
  assert_eq(r2.direction, @lib.vector(0, 3, 0))
}
