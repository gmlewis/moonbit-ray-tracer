///|
test "An intersection encapsulates t and shape (p.99)" {
  let s = sphere()
  let i = @lib.intersection(3.5, s)
  assert_eq!(i.t, 3.5)
  assert_eq!(i.shape, s)
}

///|
test "Aggregating intersections (p.99)" {
  let s = sphere()
  let i1 = @lib.intersection(1, s)
  let i2 = @lib.intersection(2, s)
  let xs = intersections([i1, i2])
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].t, 1)
  assert_eq!(xs[1].t, 2)
}

///|
test "Intersect sets the shape on the intersection (p.99)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = sphere()
  let xs = s.intersect(r)
  assert_eq!(xs.count, 2)
  assert_eq!(xs[0].shape, s)
  assert_eq!(xs[1].shape, s)
}

///|
test "The hit, when all intersections have positive t (p.101)" {
  let s = sphere()
  let i1 = @lib.intersection(1, s)
  let i2 = @lib.intersection(2, s)
  let xs = intersections([i1, i2])
  let i = xs.hit()
  assert_eq!(i, Some(i1))
}

///|
test "The hit, when some intersections have negative t (p.102)" {
  let s = sphere()
  let i1 = @lib.intersection(-1, s)
  let i2 = @lib.intersection(1, s)
  let xs = intersections([i2, i1])
  let i = xs.hit()
  assert_eq!(i, Some(i2))
}

///|
test "The hit, when all intersections have negative t (p.102)" {
  let s = sphere()
  let i1 = @lib.intersection(-2, s)
  let i2 = @lib.intersection(-1, s)
  let xs = intersections([i2, i1])
  let i = xs.hit()
  assert_eq!(i, None)
}

///|
test "The hit is always the lowest non-negative intersection (p.102)" {
  let s = sphere()
  let i1 = @lib.intersection(5, s)
  let i2 = @lib.intersection(7, s)
  let i3 = @lib.intersection(-3, s)
  let i4 = @lib.intersection(2, s)
  let xs = intersections([i1, i2, i3, i4])
  let i = xs.hit()
  assert_eq!(i, Some(i4))
}

///|
test "Precomputing the state of an intersection (p.135)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = sphere()
  let i = @lib.intersection(4, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.t, i.t)
  assert_eq!(comps.shape, i.shape)
  assert_eq!(comps.point, point(0, 0, -1))
  assert_eq!(comps.eyev, vector(0, 0, -1))
  assert_eq!(comps.normalv, vector(0, 0, -1))
}

///|
test "The hit, when an intersection occurs on the outside (p.136)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = sphere()
  let i = @lib.intersection(4, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.inside, false)
}

///|
test "The hit, when an intersection occurs on the inside (p.136)" {
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let shape = sphere()
  let i = @lib.intersection(1, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.point, point(0, 0, 1))
  assert_eq!(comps.eyev, vector(0, 0, -1))
  assert_eq!(comps.inside, true)
  // normal would have been (0,0,1), but is inverted!
  assert_eq!(comps.normalv, vector(0, 0, -1))
}

///|
test "The hit should offset the point (p.161)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = {
    let s = sphere()
    s.set_transform(translation(0, 0, 1))
    s
  }
  let i = @lib.intersection(5, shape)
  let comps = i.prepare_computations(r)
  assert_true!(comps.over_point.z < -@lib.EPSILON / 2)
  assert_true!(comps.point.z > comps.over_point.z)
}

///|
test "Precomputing the reflection vector (p.196)" {
  let shape = plane()
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 1, -1), vector(0, -sq2, sq2))
  let i = @lib.intersection(sq2, shape)
  let comps = i.prepare_computations(r)
  assert_eq!(comps.reflectv, vector(0, sq2, sq2))
}

///|
test "Finding n1 and n2 at various intersections (p.205)" {
  let a = {
    let s = glass_sphere()
    s.set_transform(scaling(2, 2, 2))
    s
  }
  a.material.refractive_index = 1.5
  let b = {
    let s = glass_sphere()
    s.set_transform(translation(0, 0, -0.25))
    s
  }
  b.material.refractive_index = 2.0
  let c = {
    let s = glass_sphere()
    s.set_transform(translation(0, 0, 0.25))
    s
  }
  c.material.refractive_index = 2.5
  let r = ray(point(0, 0, -4), vector(0, 0, 1))
  let xs = intersections([
    @lib.intersection(2, a),
    @lib.intersection(2.75, b),
    @lib.intersection(3.25, c),
    @lib.intersection(4.75, b),
    @lib.intersection(5.25, c),
    @lib.intersection(6, a),
  ])

  //
  let tests = [
    (0, 1.0, 1.5),
    (1, 1.5, 2.0),
    (2, 2.0, 2.5),
    (3, 2.5, 2.5),
    (4, 2.5, 1.5),
    (5, 1.5, 1.0),
  ]
  for tt in tests {
    let comps = xs[tt.0].prepare_computations(r, xs~)
    assert_eq!(comps.n1, tt.1)
    assert_eq!(comps.n2, tt.2)
  }
}

///|
test "The under point is offset below the surface (p.208)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = {
    let s = glass_sphere()
    s.set_transform(translation(0, 0, 1))
    s
  }
  let i = @lib.intersection(5, shape)
  let xs = intersections([i])
  let comps = i.prepare_computations(r, xs~)
  assert_true!(comps.under_point.z > @lib.EPSILON / 2)
  assert_true!(comps.point.z < comps.under_point.z)
}

///|
test "The Schlick approximation under total internal reflection (p.216)" {
  let shape = glass_sphere()
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 0, sq2), vector(0, 1, 0))
  let xs = intersections([
    @lib.intersection(-sq2, shape),
    @lib.intersection(sq2, shape),
  ])
  let comps = xs[1].prepare_computations(r, xs~)
  let reflectance = comps.schlick()
  assert_eq!(reflectance, 1)
}

///|
test "The Schlick approximation with a perpendicular viewing angle (p.217)" {
  let shape = glass_sphere()
  let r = ray(point(0, 0, 0), vector(0, 1, 0))
  let xs = Intersections::from_ts([-1, 1], shape)
  let comps = xs[1].prepare_computations(r, xs~)
  let reflectance = comps.schlick()
  assert_true!((reflectance - 0.04).abs() < @lib.EPSILON)
}

///|
test "The Schlick approximation with small angle and n2 > n1 (p.217)" {
  let shape = glass_sphere()
  let r = ray(point(0, 0.99, -2), vector(0, 0, 1))
  let xs = Intersections::from_ts([1.8589], shape)
  let comps = xs[0].prepare_computations(r, xs~)
  let reflectance = comps.schlick()
  assert_true!((0.48873 - reflectance).abs() < @lib.EPSILON)
}

///|
test "An intersection can encapsulate 'u' and 'v' (p.281)" {
  let s = triangle(point(0, 1, 0), point(-1, 0, 0), point(1, 0, 0))
  let i = @lib.intersection(3.5, s, u=0.2, v=0.4)
  assert_eq!(i.u, 0.2)
  assert_eq!(i.v, 0.4)
}
