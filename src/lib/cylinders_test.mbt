///|
test "A ray misses a cylinder (p.235)" {
  let cyl = @lib.cylinder()
  let tests = [
    (point(1, 0, 0), vector(0, 1, 0)),
    (point(0, 0, 0), vector(0, 1, 0)),
    (point(0, 0, -5), vector(1, 1, 1)),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = cyl.local_intersect(r)
    assert_eq(xs.count, 0)
  }
}

///|
test "A ray strikes a cylinder (p.236)" {
  let cyl = @lib.cylinder()
  let tests = [
    (point(1, 0, -5), vector(0, 0, 1), 5.0, 5.0),
    (point(0, 0, -5), vector(0, 0, 1), 4, 6),
    (point(0.5, 0, -5), vector(0.1, 1, 1), 6.80798, 7.08872),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = cyl.local_intersect(r)
    assert_eq(xs.count, 2)
    assert_eq(round_to_fixed(xs[0].t, 5), tt.2)
    assert_eq(round_to_fixed(xs[1].t, 5), tt.3)
  }
}

///|
test "Normal vector on a cylinder (p.238)" {
  let cyl = @lib.cylinder()
  let tests = [
    (point(1, 0, 0), vector(1, 0, 0)),
    (point(0, 5, -1), vector(0, 0, -1)),
    (point(0, -2, 1), vector(0, 0, 1)),
    (point(-1, 1, 0), vector(-1, 0, 0)),
  ]
  for tt in tests {
    let n = cyl.local_normal_at(tt.0)
    assert_eq(n, tt.1)
  }
}

// MoonBit has no reflection.
// test "The default minimum and maximum for a cylinder (p.239)" {
//   let cyl = @lib.cylinder()
//   assert_eq!(cyl.object.minimum, @double.neg_infinity)
//   assert_eq!(cyl.object.maximum, @double.infinity)
// }

///|
test "Intersecting a constrained cylinder (p.240)" {
  let cyl = @lib.cylinder(minimum=1, maximum=2)
  let tests = [
    (point(0, 1.5, 0), vector(0.1, 1, 0), 0),
    (point(0, 3, -5), vector(0, 0, 1), 0),
    (point(0, 0, -5), vector(0, 0, 1), 0),
    (point(0, 2, -5), vector(0, 0, 1), 0),
    (point(0, 1, -5), vector(0, 0, 1), 0),
    (point(0, 1.5, -2), vector(0, 0, 1), 2),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = cyl.local_intersect(r)
    assert_eq(xs.count, tt.2)
  }
}

// MoonBit has no reflection.
// test "The default closed value for a cylinder (p.243)" {
//   let cyl = @lib.cylinder()
//   assert_false!(cyl.closed)
// }

///|
test "Intersecting the caps of a closed cylinder (p.243)" {
  let cyl = @lib.cylinder(minimum=1, maximum=2, closed=true)
  let tests = [
    (point(0, 3, 0), vector(0, -1, 0), 2),
    (point(0, 3, -2), vector(0, -1, 2), 2),
    (point(0, 4, -2), vector(0, -1, 1), 2),
    (point(0, 0, -2), vector(0, 1, 2), 2),
    (point(0, -1, -2), vector(0, 1, 1), 2),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = cyl.local_intersect(r)
    assert_eq(xs.count, tt.2)
  }
}

///|
test "The normal vector on a cylinder's end caps (p.245)" {
  let cyl = @lib.cylinder(minimum=1, maximum=2, closed=true)
  let tests = [
    (point(0, 1, 0), vector(0, -1, 0)),
    (point(0.5, 1, 0), vector(0, -1, 0)),
    (point(0, 1, 0.5), vector(0, -1, 0)),
    (point(0, 2, 0), vector(0, 1, 0)),
    (point(0.5, 2, 0), vector(0, 1, 0)),
    (point(0, 2, 0.5), vector(0, 1, 0)),
  ]
  for tt in tests {
    let n = cyl.local_normal_at(tt.0)
    assert_eq(n, tt.1)
  }
}
