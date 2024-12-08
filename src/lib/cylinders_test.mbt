///|
let cylinder = @lib.cylinder

///|
let round_to_fixed = @lib.round_to_fixed

test "A ray misses a cylinder (p.235)" {
  let cyl = cylinder()
  let tests = [
    (point(1, 0, 0), vector(0, 1, 0)),
    (point(0, 0, 0), vector(0, 1, 0)),
    (point(0, 0, -5), vector(1, 1, 1)),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = cyl.local_intersect(r)
    assert_eq!(xs.count, 0)
  }
}

test "A ray strikes a cylinder (p.236)" {
  let cyl = cylinder()
  let tests = [
    (point(1, 0, -5), vector(0, 0, 1), 5.0, 5.0),
    (point(0, 0, -5), vector(0, 0, 1), 4, 6),
    (point(0.5, 0, -5), vector(0.1, 1, 1), 6.80798, 7.08872),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = cyl.local_intersect(r)
    assert_eq!(xs.count, 2)
    assert_eq!(round_to_fixed(xs[0].t, 5), tt.2)
    assert_eq!(round_to_fixed(xs[1].t, 5), tt.3)
  }
}

test "Normal vector on a cylinder (p.238)" {
  let cyl = cylinder()
  let tests = [
    (point(1, 0, 0), vector(1, 0, 0)),
    (point(0, 5, -1), vector(0, 0, -1)),
    (point(0, -2, 1), vector(0, 0, 1)),
    (point(-1, 1, 0), vector(-1, 0, 0)),
  ]
  for tt in tests {
    let n = cyl.local_normal_at(tt.0)
    assert_eq!(n, tt.1)
  }
}
