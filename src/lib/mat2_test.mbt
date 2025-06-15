///|
test "A 2x2 matrix ought to be representable (p.54)" {
  let m = mat2(
    -3, 5, // row 0
     1, -2, // row 1
  )
  assert_eq(m[0][0], -3)
  assert_eq(m[0][1], 5)
  assert_eq(m[1][0], 1)
  assert_eq(m[1][1], -2)
}

///|
test "Calculate the determinant of a 2x2 matrix (p.62)" {
  let a = mat2(
    1, 5, // row 0
     -3, 2, // row 1
  )
  assert_eq(a.determinant(), 17)
}
