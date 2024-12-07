///|
let world = @lib.world

///|
let default_world = @lib.default_world

test "Creating a world (p.134)" {
  let w = world()
  assert_eq!(w.shapes, [])
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
  assert_eq!(w.shapes, [s1, s2])
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
  let shape = w.shapes[0]
  let i = intersection(4, shape)
  let comps = i.prepare_computations(r)
  let c = w.shade_hit(comps)
  assert_eq!(c, color(0.38066, 0.47583, 0.2855))
}

test "Shading an intersection from the inside (p.137)" {
  let w = default_world()
  w.lights = [point_light(point(0, 0.25, 0), color(1, 1, 1))]
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let shape = w.shapes[1]
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
  let outer = w.shapes[0]
  outer.material.ambient = 1
  let inner = w.shapes[1]
  inner.material.ambient = 1
  let r = ray(point(0, 0, 0.75), vector(0, 0, -1))
  let c = w.color_at(r)
  assert_eq!(c, inner.material.color)
}

test "There is no shadow when nothing is collinear with point and light (p.157)" {
  let w = default_world()
  let p = point(0, 10, 0)
  assert_false!(w.is_shadowed(p))
}

test "The shadow when an object is between the point and the light (p.157)" {
  let w = default_world()
  let p = point(10, -10, 10)
  assert_true!(w.is_shadowed(p))
}

test "There is no shadow when an object is behind the light (p.158)" {
  let w = default_world()
  let p = point(-20, 20, -20)
  assert_false!(w.is_shadowed(p))
}

test "There is no shadow when an object is behind the poiny (p.159)" {
  let w = default_world()
  let p = point(-2, 2, -2)
  assert_false!(w.is_shadowed(p))
}

test "shade_hit() is given an intersection in shadow (p.160)" {
  let w = world()
  w.lights = [point_light(point(0, 0, -10), color(1, 1, 1))]
  let s1 = sphere()
  let s2 = sphere()..set_transform(translation(0, 0, 10))
  w.shapes = [s1, s2]
  let r = ray(point(0, 0, 5), vector(0, 0, 1))
  let i = intersection(4, s2)
  let comps = i.prepare_computations(r)
  let c = w.shade_hit(comps)
  assert_eq!(c, color(0.1, 0.1, 0.1))
}

test "The reflected color for a non-reflective material (p.197)" {
  let w = default_world()
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let shape = w.shapes[1]
  shape.material.ambient = 1
  let i = intersection(1, shape)
  let comps = i.prepare_computations(r)
  let color = w.reflected_color(comps, 5)
  assert_eq!(color, black)
}

test "The reflected color for a reflective material (p.197)" {
  let w = default_world()
  let shape = plane()..set_transform(translation(0, -1, 0))
  shape.material.reflective = 0.5
  w.shapes.push(shape)
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 0, -3), vector(0, -sq2, sq2))
  let i = intersection(2.0.sqrt(), shape)
  let comps = i.prepare_computations(r)
  let c = w.reflected_color(comps, 5)
  assert_eq!(c, color(0.19033, 0.23792, 0.14275))
}

test "shade_hit() with a reflective material (p.198)" {
  let w = default_world()
  let shape = plane()..set_transform(translation(0, -1, 0))
  shape.material.reflective = 0.5
  w.shapes.push(shape)
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 0, -3), vector(0, -sq2, sq2))
  let i = intersection(2.0.sqrt(), shape)
  let comps = i.prepare_computations(r)
  let c = w.shade_hit(comps)
  assert_eq!(c, color(0.87676, 0.92434, 0.82917))
}

test "color_at() with mutually reflective surfaces (p.199)" {
  let w = world()
  w.lights.push(point_light(point(0, 0, 0), color(1, 1, 1)))
  let lower = plane()..set_transform(translation(0, -1, 0))
  lower.material.reflective = 1
  w.shapes.push(lower)
  let upper = plane()..set_transform(translation(0, 1, 0))
  upper.material.reflective = 1
  w.shapes.push(upper)
  let r = ray(point(0, 0, 0), vector(0, 1, 0))
  // should terminate successfully
  let _ = w.color_at(r)

}

test "The reflected color at the maximum recursive depth (p.200)" {
  let w = default_world()
  let shape = plane()..set_transform(translation(0, -1, 0))
  shape.material.reflective = 0.5
  w.shapes.push(shape)
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 0, -3), vector(0, -sq2, sq2))
  let i = intersection(2.0.sqrt(), shape)
  let comps = i.prepare_computations(r)
  let c = w.reflected_color(comps, 0)
  assert_eq!(c, black)
}

test "The refracted color with an opaque surface (p.209)" {
  let w = default_world()
  let shape = w.shapes[0]
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let xs = intersections([intersection(4, shape), intersection(5, shape)])
  let comps = xs[0].prepare_computations(r, xs~)
  let c = w.refracted_color(comps, 5)
  assert_eq!(c, black)
}

test "The refracted color at the maximum recursive depth (p.209)" {
  let w = default_world()
  let shape = w.shapes[0]
  shape.material.transparency = 1
  shape.material.refractive_index = 1.5
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let xs = intersections([intersection(4, shape), intersection(6, shape)])
  let comps = xs[0].prepare_computations(r, xs~)
  let c = w.refracted_color(comps, 0)
  assert_eq!(c, black)
}

test "The refracted color under total internal reflection (p.210)" {
  let w = default_world()
  let shape = w.shapes[0]
  shape.material.transparency = 1
  shape.material.refractive_index = 1.5
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 0, sq2), vector(0, 1, 0))
  let xs = intersections([intersection(-sq2, shape), intersection(sq2, shape)])
  // Note: this time it is inside the sphere, so we need
  // to look at the second intersection, xs[1], not xs[0].
  let comps = xs[1].prepare_computations(r, xs~)
  let c = w.refracted_color(comps, 5)
  assert_eq!(c, color(0, 0, 0))
}

test "The refracted color with a refracted ray (p.212)" {
  let w = default_world()
  let a = w.shapes[0]
  a.material.ambient = 1
  a.material.pattern = Some(test_pattern())
  let b = w.shapes[1]
  b.material.transparency = 1
  b.material.refractive_index = 1.5
  let r = ray(point(0, 0, 0.1), vector(0, 1, 0))
  let xs = intersections(
    [
      intersection(-0.9899, a),
      intersection(-0.4899, b),
      intersection(0.4899, b),
      intersection(0.9899, a),
    ],
  )
  let comps = xs[2].prepare_computations(r, xs~)
  let c = w.refracted_color(comps, 5)
  assert_eq!(c, color(0, 0.99888, 0.04722))
}

test "shade_hit() with a transparent material (p.213)" {
  let w = default_world()
  let floor = plane()..set_transform(translation(0, -1, 0))
  floor.material.transparency = 0.5
  floor.material.refractive_index = 1.5
  w.shapes.push(floor)
  let ball = sphere()..set_transform(translation(0, -3.5, -0.5))
  ball.material.color = color(1, 0, 0)
  ball.material.ambient = 0.5
  w.shapes.push(ball)
  let sq2 = 2.0.sqrt() / 2
  let r = ray(point(0, 0, -3), vector(0, -sq2, sq2))
  let xs = intersections([intersection(2.0.sqrt(), floor)])
  let comps = xs[0].prepare_computations(r, xs~)
  let c = w.shade_hit(comps, remaining=5)
  assert_eq!(c, color(0.93642, 0.68642, 0.68642))
}
