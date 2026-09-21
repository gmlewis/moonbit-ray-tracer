///|
test "Intersecting a cone with a ray (p.248)" {
  let shape = @lib.cone()
  let tests = [
    (@lib.point(0, 0, -5), @lib.vector(0, 0, 1), 5.0, 5.0),
    (@lib.point(0, 0, -5), @lib.vector(1, 1, 1), 8.66025, 8.66025),
    (@lib.point(1, 1, -5), @lib.vector(-0.5, -1, 1), 4.55006, 49.44994),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = @lib.ray(tt.0, direction)
    let xs = shape.local_intersect(r)
    assert_eq(xs.count, 2)
    assert_eq(@lib.round_to_fixed(xs[0].t, 5), tt.2)
    assert_eq(@lib.round_to_fixed(xs[1].t, 5), tt.3)
  }
}

///|
test "Intersecting a cone with a ray parallel to one of its halves (p.248)" {
  let shape = @lib.cone()
  let direction = @lib.vector(0, 1, 1).normalize()
  let r = @lib.ray(@lib.point(0, 0, -1), direction)
  let xs = shape.local_intersect(r)
  assert_eq(xs.count, 1)
  assert_eq(@lib.round_to_fixed(xs[0].t, 5), 0.70711)
}

///|
test "Intersecting a cone's end caps (p.248)" {
  let shape = @lib.cone(minimum=-0.5, maximum=0.5, closed=true)
  let tests = [
    (@lib.point(0, 0, -5), @lib.vector(0, 1, 0), 0),
    (@lib.point(0, 0, -0.25), @lib.vector(0, 1, 1), 2),
    (@lib.point(0, 0, -0.25), @lib.vector(0, 1, 0), 4),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = @lib.ray(tt.0, direction)
    let xs = shape.local_intersect(r)
    assert_eq(xs.count, tt.2)
  }
}

///|
test "Computing the normal vector on a cone (p.249)" {
  let shape = @lib.cone()
  let tests = [
    (@lib.point(0, 0, 0), @lib.vector(0, 0, 0)),
    (@lib.point(1, 1, 1), @lib.vector(1, -2.0.sqrt(), 1)),
    (@lib.point(-1, -1, 0), @lib.vector(-1, 1, 0)),
  ]
  for tt in tests {
    let n = shape.local_normal_at(tt.0)
    assert_eq(n, tt.1)
  }
}
