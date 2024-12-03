///|
let mat3 = @lib.mat3

test "A 3x3 matrix ought to be representable (p.54)" {
  let m = mat3(
    -3, 5, 0, // row 0
     1, -2, -7, // row 1
     0, 1, 1, // row 2
  )
  assert_eq!(m[0][0], -3)
  assert_eq!(m[1][1], -2)
  assert_eq!(m[2][2], 1)
}

test "A submatrix of a 3x3 matrix is a 2x2 matrix (p.63)" {
  let a = mat3(
    1, 5, 0, // row 0
     -3, 2, 7, // row 1
     0, 6, -3, // row 2
  )
  let want = mat2(
    -3, 2, // row 0
     0, 6, // row 1
  )
  assert_eq!(a.submatrix(0, 2), want)
}
