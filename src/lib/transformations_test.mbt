///|
let pi : Double = @math.PI

///|
let rotation_x = @lib.rotation_x

///|
let scaling = @lib.scaling

///|
let translation = @lib.translation

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

test "Rotating a point around the x axis" {
  let p = point(0, 1, 0)
  let half_quarter = rotation_x(pi / 4)
  let full_quarter = rotation_x(pi / 2)
  let v = 2.0.sqrt() / 2
  assert_eq!(half_quarter.mul_tuple(p), point(0, v, v))
  assert_eq!(full_quarter.mul_tuple(p), point(0, 0, 1))
}

test "The inverse of an x-rotation rotates in the opposite direction" {
  let p = point(0, 1, 0)
  let half_quarter = rotation_x(pi / 4)
  let inv = half_quarter.inverse()
  let v = 2.0.sqrt() / 2
  assert_eq!(inv.mul_tuple(p), point(0, v, -v))
}
