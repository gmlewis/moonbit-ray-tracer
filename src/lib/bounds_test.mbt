///|
test "creating an empty bounding box" {
  let b = @lib.Bounds::new()
  inspect(b.min, content="point(Infinity, Infinity, Infinity)")
  inspect(b.max, content="point(-Infinity, -Infinity, -Infinity)")
}

///|
test "adding points to an empty bounding box" {
  let b = @lib.Bounds::new()
  let p1 = @lib.point(-5, 2, 0)
  let p2 = @lib.point(7, 0, -3)
  b.update(p1)
  b.update(p2)
  inspect(b.min, content="point(-5, 0, -3)")
  inspect(b.max, content="point(7, 2, 0)")
}

///|
test "intersecting a ray with a bounding box at the origin" {
  let b = @lib.Bounds::new()
  b.update(@lib.point(-1, -1, -1))
  b.update(@lib.point(1, 1, 1))
  
  let tests = [
    (@lib.point(0, 0, -5), @lib.vector(0, 0, 1), true),
    (@lib.point(0, 0, 5), @lib.vector(0, 0, -1), true),
    (@lib.point(5, 0, 0), @lib.vector(-1, 0, 0), true),
    (@lib.point(-5, 0, 0), @lib.vector(1, 0, 0), true),
    (@lib.point(0, 5, 0), @lib.vector(0, -1, 0), true),
    (@lib.point(0, -5, 0), @lib.vector(0, 1, 0), true),
    (@lib.point(0, 0, 0), @lib.vector(0, 0, 1), true),
    (@lib.point(2, 2, 2), @lib.vector(-1, -1, -1), true),
    (@lib.point(5, 5, 5), @lib.vector(0, 0, -1), false),
    (@lib.point(-5, -5, -5), @lib.vector(0, 0, 1), false),
    (@lib.point(0, 5, 0), @lib.vector(0, 0, 1), false),
    (@lib.point(0, 0, -5), @lib.vector(0, 1, 0), false),
  ]
  
  for t in tests {
    let ray = @lib.ray(t.0, t.1.normalize())
    let result = b.local_intersect(ray)
    inspect(result, content=t.2.to_string())
  }
}

///|
test "transforming a bounding box" {
  let b = @lib.Bounds::new()
  b.update(@lib.point(-1, -1, -1))
  b.update(@lib.point(1, 1, 1))
  let matrix = @lib.rotation_x(@math.PI / 4) * @lib.rotation_y(@math.PI / 4)
  let b2 = b.transform(matrix)
  inspect(b2.min, content="point(-1.41421, -1.70711, -1.70711)")
  inspect(b2.max, content="point(1.41421, 1.70711, 1.70711)")
}
