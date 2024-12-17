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

test "Calculating a minor of a 3x3 matrix (p.64)" {
  let a = mat3(
    3, 5, 0, // row 0
     2, -1, -7, // row 1
     6, -1, 5, // row 2
  )
  let b = a.submatrix(1, 0)
  assert_eq!(b.determinant(), 25)
  assert_eq!(a.minor(1, 0), 25)
}

test "Calculating a cofactor of a 3x3 matrix (p.64)" {
  let a = mat3(
    3, 5, 0, // row 0
     2, -1, -7, // row 1
     6, -1, 5, // row 2
  )
  assert_eq!(a.minor(0, 0), -12)
  assert_eq!(a.cofactor(0, 0), -12)
  assert_eq!(a.minor(1, 0), 25)
  assert_eq!(a.cofactor(1, 0), -25)
}

test "Calculating the determinant of a 3x3 matrix (p.65)" {
  let a = mat3(
    1, 2, 6, // row 0
     -5, 8, -4, // row 1
     2, 6, 4, // row 2
  )
  assert_eq!(a.cofactor(0, 0), 56)
  assert_eq!(a.cofactor(0, 1), 12)
  assert_eq!(a.cofactor(0, 2), -46)
  assert_eq!(a.determinant(), -196)
}
