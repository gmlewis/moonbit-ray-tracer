///|
let sphere = @lib.sphere

test "A ray intersects a sphere at two points (p.94)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, 4.0)
  assert_eq!(xs[1].t, 6.0)
}

test "A ray intersects a sphere at a tangent (p.95)" {
  let r = ray(point(0, 1, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, 5.0)
  assert_eq!(xs[1].t, 5.0)
}

test "A ray misses a sphere (p.96)" {
  let r = ray(point(0, 2, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 0)
}

test "A ray originates inside a sphere (p.96)" {
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, -1.0)
  assert_eq!(xs[1].t, 1.0)
}

test "A sphere is behind a ray (p.97)" {
  let r = ray(point(0, 0, 5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, -6.0)
  assert_eq!(xs[1].t, -4.0)
}

test "A sphere's default transformation (p.105)" {
  let s = sphere()
  assert_eq!(s.transform, mat4ident())
}

test "Changing a sphere's transformation (p.106)" {
  let s = sphere()
  let t = translation(2, 3, 4)
  s.set_transform(t)
  assert_eq!(s.transform, t)
}

test "Intersecting a scaled sphere with a ray (p.106)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  s.set_transform(scaling(2, 2, 2))
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, 3)
  assert_eq!(xs[1].t, 7)
}

test "Intersecting a translated sphere with a ray (p.106)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  s.set_transform(translation(5, 0, 0))
  let xs = s.intersect(r)
  assert_eq!(xs.count, 0)
}
