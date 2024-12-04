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
