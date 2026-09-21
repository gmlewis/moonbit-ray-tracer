///|
test "A ray intersects a cube (p.224)" {
  let tests = [
    ("+x", @lib.point(5, 0.5, 0), @lib.vector(-1, 0, 0), 4.0, 6.0),
    ("-x", @lib.point(-5, 0.5, 0), @lib.vector(1, 0, 0), 4, 6),
    ("+y", @lib.point(0.5, 5, 0), @lib.vector(0, -1, 0), 4, 6),
    ("-y", @lib.point(0.5, -5, 0), @lib.vector(0, 1, 0), 4, 6),
    ("+z", @lib.point(0.5, 0, 5), @lib.vector(0, 0, -1), 4, 6),
    ("-z", @lib.point(0.5, 0, -5), @lib.vector(0, 0, 1), 4, 6),
    ("inside", @lib.point(0, 0.5, 0), @lib.vector(0, 0, 1), -1, 1),
  ]
  let c = @lib.cube()
  for tt in tests {
    let origin = tt.1
    let direction = tt.2
    let r = @lib.ray(origin, direction)
    let xs = c.local_intersect(r)
    assert_eq(xs.count, 2)
    assert_eq(xs[0].t, tt.3)
    assert_eq(xs[1].t, tt.4)
  }
}

///|
test "A ray misses a cube (p.228)" {
  let tests = [
    (@lib.point(-2, 0, 0), @lib.vector(0.2673, 0.5345, 0.8018)),
    (@lib.point(0, -2, 0), @lib.vector(0.8018, 0.2673, 0.5345)),
    (@lib.point(0, 0, -2), @lib.vector(0.5345, 0.8018, 0.2673)),
    (@lib.point(2, 0, 2), @lib.vector(0, 0, -1)),
    (@lib.point(0, 2, 2), @lib.vector(0, -1, 0)),
    (@lib.point(2, 2, 0), @lib.vector(-1, 0, 0)),
  ]
  let c = @lib.cube()
  for tt in tests {
    let origin = tt.0
    let direction = tt.1
    let r = @lib.ray(origin, direction)
    let xs = c.local_intersect(r)
    assert_eq(xs.count, 0)
  }
}

///|
test "The normal on the surface of a cube (p.230)" {
  let tests = [
    (@lib.point(1, 0.5, -0.8), @lib.vector(1, 0, 0)),
    (@lib.point(-1, -0.2, 0.9), @lib.vector(-1, 0, 0)),
    (@lib.point(-0.4, 1, -0.1), @lib.vector(0, 1, 0)),
    (@lib.point(0.3, -1, -0.7), @lib.vector(0, -1, 0)),
    (@lib.point(-0.6, 0.3, 1), @lib.vector(0, 0, 1)),
    (@lib.point(0.4, 0.4, -1), @lib.vector(0, 0, -1)),
    (@lib.point(1, 1, 1), @lib.vector(1, 0, 0)),
    (@lib.point(-1, -1, -1), @lib.vector(-1, 0, 0)),
  ]
  let c = @lib.cube()
  for tt in tests {
    let point = tt.0
    let normal = c.local_normal_at(point)
    let want = tt.1
    assert_eq(normal, want)
  }
}
