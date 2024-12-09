test "Intersecting a cone with a ray (p.248)" {
  let shape = @lib.cone()
  let tests = [
    (point(0, 0, -5), vector(0, 0, 1), 5.0, 5.0),
    (point(0, 0, -5), vector(1, 1, 1), 8.66025, 8.66025),
    (point(1, 1, -5), vector(-0.5, -1, 1), 4.55006, 49.44994),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = shape.local_intersect(r)
    assert_eq!(xs.count, 2)
    assert_eq!(round_to_fixed(xs[0].t, 5), tt.2)
    assert_eq!(round_to_fixed(xs[1].t, 5), tt.3)
  }
}

test "Intersecting a cone with a ray parallel to one of its halves (p.248)" {
  let shape = @lib.cone()
  let direction = vector(0, 1, 1).normalize()
  let r = ray(point(0, 0, -1), direction)
  let xs = shape.local_intersect(r)
  assert_eq!(xs.count, 1)
  assert_eq!(round_to_fixed(xs[0].t, 5), 0.35355)
}

test "Intersecting a cone's end caps (p.248)" {
  let shape = @lib.cone(minimum=-0.5, maximum=0.5, closed=true)
  let tests = [
    (point(0, 0, -5), vector(0, 1, 0), 0),
    (point(0, 0, -0.25), vector(0, 1, 1), 2),
    (point(0, 0, -0.25), vector(0, 1, 0), 4),
  ]
  for tt in tests {
    let direction = tt.1.normalize()
    let r = ray(tt.0, direction)
    let xs = shape.local_intersect(r)
    assert_eq!(xs.count, tt.2)
  }
}

test "Computing the normal vector on a cone (p.249)" {
  let shape = @lib.cone()
  let tests = [
    (point(0, 0, 0), vector(0, 0, 0)),
    (point(1, 1, 1), vector(1, -2.0.sqrt(), 1)),
    (point(-1, -1, 0), vector(-1, 1, 0)),
  ]
  for tt in tests {
    let n = shape.local_normal_at(tt.0)
    assert_eq!(n, tt.1)
  }
}
