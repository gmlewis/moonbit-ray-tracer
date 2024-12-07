///|
let glass_sphere = @lib.glass_sphere

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

test "The normal on a sphere at a point on the x axis (p.115)" {
  let s = sphere()
  let n = s.normal_at(point(1, 0, 0))
  assert_eq!(n, vector(1, 0, 0))
}

test "The normal on a sphere at a point on the y axis (p.115)" {
  let s = sphere()
  let n = s.normal_at(point(0, 1, 0))
  assert_eq!(n, vector(0, 1, 0))
}

test "The normal on a sphere at a point on the z axis (p.115)" {
  let s = sphere()
  let n = s.normal_at(point(0, 0, 1))
  assert_eq!(n, vector(0, 0, 1))
}

test "The normal on a sphere at a non-axial point (p.116)" {
  let s = sphere()
  let c = 3.0.sqrt() / 3
  let n = s.normal_at(point(c, c, c))
  assert_eq!(n, vector(c, c, c))
}

test "The normal a normalized vector (p.116)" {
  let s = sphere()
  let c = 3.0.sqrt() / 3
  let n = s.normal_at(point(c, c, c))
  assert_eq!(n, n.normalize())
}

test "Computing the normal on a translated sphere" {
  let s = sphere()
  s.set_transform(translation(0, 1, 0))
  let n = s.normal_at(point(0, 1.70711, -0.70711))
  assert_eq!(n, vector(0, 0.70711, -0.70711))
}

test "Computing the normal on a transformed sphere" {
  let s = sphere()
  let m = scaling(1, 0.5, 1) * rotation_z(@math.PI / 5)
  s.set_transform(m)
  let sq2 = 2.0.sqrt() / 2
  let n = s.normal_at(point(0, sq2, -sq2))
  assert_eq!(n, vector(0, 0.97014, -0.24254))
}

test "A sphere has a default material (p.125)" {
  let s = sphere()
  let m = s.material
  assert_eq!(m, material())
}

test "A sphere may be assigned a material (p.125)" {
  let s = sphere()
  let m = material()
  m.ambient = 1
  s.material = m
  assert_eq!(s.material, m)
}

test "A helper for producing a sphere with a glassy material (p.204)" {
  let s = glass_sphere()
  assert_eq!(s.transform, mat4ident())
  assert_eq!(s.material.transparency, 1)
  assert_eq!(s.material.refractive_index, 1.5)
}
