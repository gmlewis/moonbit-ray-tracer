///|
let pi : Double = @math.PI

///|
test "Multiplying by a translation matrix (p.73)" {
  let transform = @lib.translation(5, -3, 2)
  let p = @lib.point(-3, 4, 5)
  assert_eq(transform.mul_tuple(p), @lib.point(2, 1, 7))
}

///|
test "Multiplying by the inverse of a translation matrix (p.73)" {
  let transform = @lib.translation(5, -3, 2)
  let inv = transform.inverse()
  let p = @lib.point(-3, 4, 5)
  assert_eq(inv.mul_tuple(p), @lib.point(-8, 7, 3))
}

///|
test "Translation does not affect vectors (p.74)" {
  let transform = @lib.translation(5, -3, 2)
  let v = @lib.vector(-3, 4, 5)
  assert_eq(transform.mul_tuple(v), v)
}

///|
test "A scaling matrix applied to a point" {
  let transform = @lib.scaling(2, 3, 4)
  let p = @lib.point(-4, 6, 8)
  assert_eq(transform.mul_tuple(p), @lib.point(-8, 18, 32))
}

///|
test "A scaling matrix applied to a vector" {
  let transform = @lib.scaling(2, 3, 4)
  let v = @lib.vector(-4, 6, 8)
  assert_eq(transform.mul_tuple(v), @lib.vector(-8, 18, 32))
}

///|
test "Multiplying by the inverse of a scaling matrix" {
  let transform = @lib.scaling(2, 3, 4)
  let inv = transform.inverse()
  let v = @lib.vector(-4, 6, 8)
  assert_eq(inv.mul_tuple(v), @lib.vector(-2, 2, 2))
}

///|
test "Reflection is scaling by a negative value" {
  let transform = @lib.scaling(-1, 1, 1)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(-2, 3, 4))
}

///|
test "Rotating a point around the x axis (p.79)" {
  let p = @lib.point(0, 1, 0)
  let half_quarter = @lib.rotation_x(pi / 4)
  let full_quarter = @lib.rotation_x(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq(half_quarter.mul_tuple(p), @lib.point(0, v, v))
  assert_eq(full_quarter.mul_tuple(p), @lib.point(0, 0, 1))
}

///|
test "The inverse of an x-rotation rotates in the opposite direction (p.80)" {
  let p = @lib.point(0, 1, 0)
  let half_quarter = @lib.rotation_x(pi / 4)
  let inv = half_quarter.inverse()
  let v = 2.0.sqrt() / 2
  assert_eq(inv.mul_tuple(p), @lib.point(0, v, -v))
}

///|
test "Rotating a point around the y axis (p.80)" {
  let p = @lib.point(0, 0, 1)
  let half_quarter = @lib.rotation_y(pi / 4)
  let full_quarter = @lib.rotation_y(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq(half_quarter.mul_tuple(p), @lib.point(v, 0, v))
  assert_eq(full_quarter.mul_tuple(p), @lib.point(1, 0, 0))
}

///|
test "Rotating a point around the z axis (p.81)" {
  let p = @lib.point(0, 1, 0)
  let half_quarter = @lib.rotation_z(pi / 4)
  let full_quarter = @lib.rotation_z(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq(half_quarter.mul_tuple(p), @lib.point(-v, v, 0))
  assert_eq(full_quarter.mul_tuple(p), @lib.point(-1, 0, 0))
}

///|
test "A shearing transformation moves x in proportion to y (p.84)" {
  let transform = @lib.shearing(1, 0, 0, 0, 0, 0)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(5, 3, 4))
}

///|
test "A shearing transformation moves x in proportion to z (p.84)" {
  let transform = @lib.shearing(0, 1, 0, 0, 0, 0)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(6, 3, 4))
}

///|
test "A shearing transformation moves y in proportion to x (p.84)" {
  let transform = @lib.shearing(0, 0, 1, 0, 0, 0)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(2, 5, 4))
}

///|
test "A shearing transformation moves y in proportion to z (p.84)" {
  let transform = @lib.shearing(0, 0, 0, 1, 0, 0)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(2, 7, 4))
}

///|
test "A shearing transformation moves z in proportion to x (p.84)" {
  let transform = @lib.shearing(0, 0, 0, 0, 1, 0)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(2, 3, 6))
}

///|
test "A shearing transformation moves z in proportion to y (p.84)" {
  let transform = @lib.shearing(0, 0, 0, 0, 0, 1)
  let p = @lib.point(2, 3, 4)
  assert_eq(transform.mul_tuple(p), @lib.point(2, 3, 7))
}

///|
test "Individual transformations are applied in sequence (p.86)" {
  let p = @lib.point(1, 0, 1)
  let a = @lib.rotation_x(pi / 2)
  let b = @lib.scaling(5, 5, 5)
  let c = @lib.translation(10, 5, 7)
  // apply rotation first
  let p2 = a.mul_tuple(p)
  assert_eq(p2, @lib.point(1, -1, 0))
  // then apply scaling
  let p3 = b.mul_tuple(p2)
  assert_eq(p3, @lib.point(5, -5, 0))
  // then apply translation
  let p4 = c.mul_tuple(p3)
  assert_eq(p4, @lib.point(15, 0, 7))
}

///|
test "Chained transformations must be applied in reverse order (p.87)" {
  let p = @lib.point(1, 0, 1)
  let a = @lib.rotation_x(pi / 2)
  let b = @lib.scaling(5, 5, 5)
  let c = @lib.translation(10, 5, 7)
  let t = c * b * a
  assert_eq(t.mul_tuple(p), @lib.point(15, 0, 7))
}

///|
test "Fluent API transformations work in MoonBit (p.87)" {
  let p = @lib.point(1, 0, 1)
  let t = @lib.mat4ident().rotate_x(pi / 2).scale(5, 5, 5).translate(10, 5, 7)
  assert_eq(t.mul_tuple(p), @lib.point(15, 0, 7))
}

///|
test "The transformation matrix for the default orientation (p.140)" {
  let from = @lib.point(0, 0, 0)
  let to = @lib.point(0, 0, -1)
  let up = @lib.vector(0, 1, 0)
  let t = @lib.view_transform(from, to, up)
  assert_eq(t, @lib.mat4ident())
}

///|
test "A transformation matrix looking in positive z direction (p.141)" {
  let from = @lib.point(0, 0, 0)
  let to = @lib.point(0, 0, 1)
  let up = @lib.vector(0, 1, 0)
  let t = @lib.view_transform(from, to, up)
  assert_eq(t, @lib.scaling(-1, 1, -1))
}

///|
test "The view transformation moves the world (p.141)" {
  let from = @lib.point(0, 0, 8)
  let to = @lib.point(0, 0, 0)
  let up = @lib.vector(0, 1, 0)
  let t = @lib.view_transform(from, to, up)
  assert_eq(t, @lib.translation(0, 0, -8))
}

///|
test "An arbitrary view transformation (p.141)" {
  let from = @lib.point(1, 3, 2)
  let to = @lib.point(4, -2, 8)
  let up = @lib.vector(1, 1, 0)
  let t = @lib.view_transform(from, to, up)
  let want = @lib.mat4(
    -0.50709, 0.50709, 0.67612, -2.36643, // row 0
     0.76772, 0.60609, 0.12122, -2.82843, // row 1
     -0.35857, 0.59761, -0.71714, 0, // row 2
     0, 0, 0, 1, // row 3
  )
  assert_eq(t, want)
}
