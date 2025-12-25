///|
test "Creating a new group (p.253)" {
  let g = @lib.group()
  assert_eq(g.transform, mat4ident())
  assert_eq(g.children().length(), 0)
}

///|
test "Adding a child to a group (p.253)" {
  let g = @lib.group()
  let s = test_shape()
  g.add_child(s)
  let children = g.children()
  assert_eq(children.length(), 1)
  assert_eq(children[0], s)
  assert_eq(s.parent, Some(g))
}

///|
test "Intersecting a ray with an empty group (p.253)" {
  let g = @lib.group()
  let r = ray(point(0, 0, 0), vector(0, 0, 1))
  let xs = g.local_intersect(r)
  assert_eq(xs.count, 0)
}

///|
test "Intersecting a ray with a non-empty group (p.254)" {
  let s1 = sphere()
  let s2 = {
    let s = sphere()
    s.set_transform(translation(0, 0, -3))
    s
  }
  let s3 = {
    let s = sphere()
    s.set_transform(translation(5, 0, 0))
    s
  }
  let g = {
    let g = @lib.group()
    g..add_child(s1)..add_child(s2)..add_child(s3)
    g
  }
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let xs = g.local_intersect(r)
  assert_eq(xs.count, 4)
  assert_eq(xs[0].shape, s2)
  assert_eq(xs[1].shape, s2)
  assert_eq(xs[2].shape, s1)
  assert_eq(xs[3].shape, s1)
}

///|
test "Intersecting a transformed group (p.255)" {
  let s = {
    let s = sphere()
    s.set_transform(translation(5, 0, 0))
    s
  }
  let g = {
    let g = @lib.group()
    g..set_transform(scaling(2, 2, 2))..add_child(s)
    g
  }
  let r = ray(point(10, 0, -10), vector(0, 0, 1))
  let xs = g.intersect(r)
  assert_eq(xs.count, 2)
}

///|
test "partition_children splits a group's children" {
  let s1 = sphere()
  s1.set_transform(translation(-2, 0, 0))
  let s2 = sphere()
  s2.set_transform(translation(2, 0, 0))
  let s3 = sphere()
  s3.set_transform(translation(0, 0, 0))
  let g = group()
  g.add_child(s1)
  g.add_child(s2)
  g.add_child(s3)

  match g.object {
    Group(group) => {
      let (left, right) = group.partition_children()
      inspect(left.length(), content="1")
      inspect(right.length(), content="2")
      assert_eq(left[0].id, s1.id)
    }
    _ => panic()
  }
}

///|
test "Subdividing a group with enough children" {
  let s1 = sphere()
  s1.set_transform(translation(-2, 0, 0))
  let s2 = sphere()
  s2.set_transform(translation(2, 0, 0))
  let s3 = sphere()
  s3.set_transform(translation(0, 0, 0))
  let g = group()
  g.add_child(s1)
  g.add_child(s2)
  g.add_child(s3)

  g.divide(3)
  let children = g.children()
  inspect(children.length(), content="2")

  match children[0].object {
    Group(subgroup) => inspect(subgroup.children.length(), content="1")
    _ => panic()
  }
  match children[1].object {
    Group(subgroup) => inspect(subgroup.children.length(), content="2")
    _ => panic()
  }
}
