///|
let sphere = @lib.sphere

test "A ray intersects a sphere at two points (p.94)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.length(), 2)
  assert_eq!(xs[0].t, 4.0)
  assert_eq!(xs[1].t, 6.0)
}

test "A ray intersects a sphere at a tangent (p.95)" {
  let r = ray(point(0, 1, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.length(), 2)
  assert_eq!(xs[0].t, 5.0)
  assert_eq!(xs[1].t, 5.0)
}

test "A ray misses a sphere (p.96)" {
  let r = ray(point(0, 2, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.length(), 0)
}

test "A ray originates inside a sphere (p.96)" {
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.length(), 2)
  assert_eq!(xs[0].t, -1.0)
  assert_eq!(xs[1].t, 1.0)
}

test "A sphere is behind a ray (p.97)" {
  let r = ray(point(0, 0, 5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.length(), 2)
  assert_eq!(xs[0].t, -6.0)
  assert_eq!(xs[1].t, -4.0)
}
