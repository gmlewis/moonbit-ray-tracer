///|
let pi : Double = @math.PI

///|
let rotation_x = @lib.rotation_x

///|
let rotation_y = @lib.rotation_y

///|
let rotation_z = @lib.rotation_z

///|
let scaling = @lib.scaling

///|
let shearing = @lib.shearing

///|
let translation = @lib.translation

///|
let view_transform = @lib.view_transform

test "Multiplying by a translation matrix (p.73)" {
  let transform = translation(5, -3, 2)
  let p = point(-3, 4, 5)
  assert_eq!(transform.mul_tuple(p), point(2, 1, 7))
}

test "Multiplying by the inverse of a translation matrix (p.73)" {
  let transform = translation(5, -3, 2)
  let inv = transform.inverse()
  let p = point(-3, 4, 5)
  assert_eq!(inv.mul_tuple(p), point(-8, 7, 3))
}

test "Translation does not affect vectors (p.74)" {
  let transform = translation(5, -3, 2)
  let v = vector(-3, 4, 5)
  assert_eq!(transform.mul_tuple(v), v)
}

test "A scaling matrix applied to a point" {
  let transform = scaling(2, 3, 4)
  let p = point(-4, 6, 8)
  assert_eq!(transform.mul_tuple(p), point(-8, 18, 32))
}

test "A scaling matrix applied to a vector" {
  let transform = scaling(2, 3, 4)
  let v = vector(-4, 6, 8)
  assert_eq!(transform.mul_tuple(v), vector(-8, 18, 32))
}

test "Multiplying by the inverse of a scaling matrix" {
  let transform = scaling(2, 3, 4)
  let inv = transform.inverse()
  let v = vector(-4, 6, 8)
  assert_eq!(inv.mul_tuple(v), vector(-2, 2, 2))
}

test "Reflection is scaling by a negative value" {
  let transform = scaling(-1, 1, 1)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(-2, 3, 4))
}

test "Rotating a point around the x axis (p.79)" {
  let p = point(0, 1, 0)
  let half_quarter = rotation_x(pi / 4)
  let full_quarter = rotation_x(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq!(half_quarter.mul_tuple(p), point(0, v, v))
  assert_eq!(full_quarter.mul_tuple(p), point(0, 0, 1))
}

test "The inverse of an x-rotation rotates in the opposite direction (p.80)" {
  let p = point(0, 1, 0)
  let half_quarter = rotation_x(pi / 4)
  let inv = half_quarter.inverse()
  let v = 2.0.sqrt() / 2
  assert_eq!(inv.mul_tuple(p), point(0, v, -v))
}

test "Rotating a point around the y axis (p.80)" {
  let p = point(0, 0, 1)
  let half_quarter = rotation_y(pi / 4)
  let full_quarter = rotation_y(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq!(half_quarter.mul_tuple(p), point(v, 0, v))
  assert_eq!(full_quarter.mul_tuple(p), point(1, 0, 0))
}

test "Rotating a point around the z axis (p.81)" {
  let p = point(0, 1, 0)
  let half_quarter = rotation_z(pi / 4)
  let full_quarter = rotation_z(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq!(half_quarter.mul_tuple(p), point(-v, v, 0))
  assert_eq!(full_quarter.mul_tuple(p), point(-1, 0, 0))
}

test "A shearing transformation moves x in proportion to y (p.84)" {
  let transform = shearing(1, 0, 0, 0, 0, 0)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(5, 3, 4))
}

test "A shearing transformation moves x in proportion to z (p.84)" {
  let transform = shearing(0, 1, 0, 0, 0, 0)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(6, 3, 4))
}

test "A shearing transformation moves y in proportion to x (p.84)" {
  let transform = shearing(0, 0, 1, 0, 0, 0)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(2, 5, 4))
}

test "A shearing transformation moves y in proportion to z (p.84)" {
  let transform = shearing(0, 0, 0, 1, 0, 0)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(2, 7, 4))
}

test "A shearing transformation moves z in proportion to x (p.84)" {
  let transform = shearing(0, 0, 0, 0, 1, 0)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(2, 3, 6))
}

test "A shearing transformation moves z in proportion to y (p.84)" {
  let transform = shearing(0, 0, 0, 0, 0, 1)
  let p = point(2, 3, 4)
  assert_eq!(transform.mul_tuple(p), point(2, 3, 7))
}

test "Individual transformations are applied in sequence (p.86)" {
  let p = point(1, 0, 1)
  let a = rotation_x(pi / 2)
  let b = scaling(5, 5, 5)
  let c = translation(10, 5, 7)
  // apply rotation first
  let p2 = a.mul_tuple(p)
  assert_eq!(p2, point(1, -1, 0))
  // then apply scaling
  let p3 = b.mul_tuple(p2)
  assert_eq!(p3, point(5, -5, 0))
  // then apply translation
  let p4 = c.mul_tuple(p3)
  assert_eq!(p4, point(15, 0, 7))
}

test "Chained transformations must be applied in reverse order (p.87)" {
  let p = point(1, 0, 1)
  let a = rotation_x(pi / 2)
  let b = scaling(5, 5, 5)
  let c = translation(10, 5, 7)
  let t = c * b * a
  assert_eq!(t.mul_tuple(p), point(15, 0, 7))
}

test "Fluent API transformations work in MoonBit (p.87)" {
  let p = point(1, 0, 1)
  let t = mat4ident().rotate_x(pi / 2).scale(5, 5, 5).translate(10, 5, 7)
  assert_eq!(t.mul_tuple(p), point(15, 0, 7))
}

test "The transformation matrix for the default orientation (p.140)" {
  let from = point(0, 0, 0)
  let to = point(0, 0, -1)
  let up = vector(0, 1, 0)
  let t = view_transform(from, to, up)
  assert_eq!(t, mat4ident())
}

test "A transformation matrix looking in positive z direction (p.141)" {
  let from = point(0, 0, 0)
  let to = point(0, 0, 1)
  let up = vector(0, 1, 0)
  let t = view_transform(from, to, up)
  assert_eq!(t, scaling(-1, 1, -1))
}

test "The view transformation moves the world (p.141)" {
  let from = point(0, 0, 8)
  let to = point(0, 0, 0)
  let up = vector(0, 1, 0)
  let t = view_transform(from, to, up)
  assert_eq!(t, translation(0, 0, -8))
}

test "An arbitrary view transformation (p.141)" {
  let from = point(1, 3, 2)
  let to = point(4, -2, 8)
  let up = vector(1, 1, 0)
  let t = view_transform(from, to, up)
  let want = mat4(
    -0.50709, 0.50709, 0.67612, -2.36643, // row 0
     0.76772, 0.60609, 0.12122, -2.82843, // row 1
     -0.35857, 0.59761, -0.71714, 0, // row 2
     0, 0, 0, 1, // row 3
  )
  assert_eq!(t, want)
}
