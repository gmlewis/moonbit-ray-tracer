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

test "Shading an intersection (p.137)" {
  let w = default_world()
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let shape = w.objects[0]
  let i = intersection(4, shape)
  let comps = i.prepare_computations(r)
  let c = w.shade_hit(comps)
  assert_eq!(c, color(0.38066, 0.47583, 0.2855))
}

test "Shading an intersection from the inside (p.137)" {
  let w = default_world()
  w.lights = [point_light(point(0, 0.25, 0), color(1, 1, 1))]
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let shape = w.objects[1]
  let i = intersection(0.5, shape)
  let comps = i.prepare_computations(r)
  let c = w.shade_hit(comps)
  assert_eq!(c, color(0.90498, 0.90498, 0.90498))
}

test "The color when a ray misses (p.138)" {
  let w = default_world()
  let r = ray(point(0, 0, -5), vector(0, 1, 0))
  let c = w.color_at(r)
  assert_eq!(c, color(0, 0, 0))
}

test "The color when a ray hits (p.138)" {
  let w = default_world()
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let c = w.color_at(r)
  assert_eq!(c, color(0.38066, 0.47583, 0.2855))
}

test "The color with an intersection behind the ray (p.139)" {
  let w = default_world()
  let outer = w.objects[0]
  outer.material.ambient = 1
  let inner = w.objects[1]
  inner.material.ambient = 1
  let r = ray(point(0, 0, 0.75), vector(0, 0, -1))
  let c = w.color_at(r)
  assert_eq!(c, inner.material.color)
}
