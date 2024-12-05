///|
let world = @lib.world

///|
let default_world = @lib.default_world

test "Creating a world (p.134)" {
  let w = world()
  assert_eq!(w.objects, [])
  assert_eq!(w.lights, [])
}

test "The default world (p.134)" {
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  let s1 = sphere()
  s1.material.color = color(0.8, 1, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2
  let s2 = sphere()..set_transform(scaling(0.5, 0.5, 0.5))
  let w = default_world()
  assert_eq!(w.objects, [s1, s2])
  assert_eq!(w.lights, [light])
}

test "Intersect a world with a ray (p.134)" {
  let w = default_world()
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let xs = w.intersect_world(r)
  assert_eq!(xs.count, 4)
  assert_eq!(xs[0].t, 4)
  assert_eq!(xs[1].t, 4.5)
  assert_eq!(xs[2].t, 5.5)
  assert_eq!(xs[3].t, 6)
}
