///|
test "Constructing and inspecting a 4x4 matrix (p.54)" {
  let m = mat4(
    1, 2, 3, 4, // row 0
     5.5, 6.5, 7.5, 8.5, // row 1
     9, 10, 11, 12, // row 2
     13.5, 14.5, 15.5, 16.5, // row 3
  )
  assert_eq!(m[0][0], 1)
  assert_eq!(m[0][3], 4)
  assert_eq!(m[1][0], 5.5)
  assert_eq!(m[1][2], 7.5)
  assert_eq!(m[2][2], 11)
  assert_eq!(m[3][0], 13.5)
  assert_eq!(m[3][2], 15.5)
}

///|
test "Matrix equality with identical matrices (p.55)" {
  let a = mat4(
    1, 2, 3, 4, // row 0
     5, 6, 7, 8, // row 1
     9, 10, 11, 12, // row 2
     13, 14, 15, 16, // row 3
  )
  let b = mat4(
    1, 2, 3, 4, // row 0
     5, 6, 7, 8, // row 1
     9, 10, 11, 12, // row 2
     13, 14, 15, 16, // row 3
  )
  assert_eq!(a, b)
}

///|
test "Matrix equality with different matrices (p.55)" {
  let a = mat4(
    1, 2, 3, 4, // row 0
     5, 6, 7, 8, // row 1
     9, 8, 7, 6, // row 2
     5, 4, 3, 2, // row 3
  )
  let b = mat4(
    2, 3, 4, 5, // row 0
     6, 7, 8, 9, // row 1
     8, 7, 6, 5, // row 2
     4, 3, 2, 1, // row 3
  )
  assert_not_eq!(a, b)
}

///|
test "Multiplying two matrices" {
  let a = mat4(
    1, 2, 3, 4, // row 0
     5, 6, 7, 8, // row 1
     9, 8, 7, 6, // row 2
     5, 4, 3, 2, // row 3
  )
  let b = mat4(
    -2, 1, 2, 3, // row 0
     3, 2, 1, -1, // row 1
     4, 3, 6, 5, // row 2
     1, 2, 7, 8, // row 3
  )
  let want = mat4(
    20, 22, 50, 48, // row 0
     44, 54, 114, 108, // row 1
     40, 58, 110, 102, // row 2
     16, 26, 46, 42, // row 3
  )
  assert_eq!(a * b, want)
}

///|
test "A matrix multiplied by a tuple (p.57)" {
  let a = mat4(
    1, 2, 3, 4, // row 0
     2, 4, 4, 2, // row 1
     8, 6, 4, 1, // row 2
     0, 0, 0, 1, // row 3
  )
  let b = tuple(1, 2, 3, 1)
  assert_eq!(a.mul_tuple(b), tuple(18, 24, 33, 1))
}

///|
test "Multiplying a matrix by the identity matrix (p.60)" {
  let a = mat4(
    0, 1, 2, 4, // row 0
     1, 2, 4, 8, // row 1
     2, 4, 8, 16, // row 2
     4, 8, 16, 32, // row 3
  )
  assert_eq!(a * mat4ident(), a)
}

///|
test "Multiplying the identity matrix by a tuple (p.60)" {
  let a = tuple(1, 2, 3, 4)
  assert_eq!(mat4ident().mul_tuple(a), a)
}

///|
test "Transposing a matrix (p.61)" {
  let a = mat4(
    0, 9, 3, 0, // row 0
     9, 8, 0, 8, // row 1
     1, 8, 5, 3, // row 2
     0, 0, 5, 8, // row 3
  )
  let want = mat4(
    0, 9, 1, 0, // row 0
     9, 8, 8, 0, // row 1
     3, 0, 5, 5, // row 2
     0, 8, 3, 8, // row 3
  )
  assert_eq!(a.transpose(), want)
}

///|
test "Transposing the identity matrix (p.61)" {
  let a = mat4ident().transpose()
  let want = mat4ident()
  assert_eq!(a, want)
}

///|
test "A submatrix of a 4x4 matrix is a 3x3 matrix (p.63)" {
  let a = mat4(
    -6, 1, 1, 6, // row 0
     -8, 5, 8, 6, // row 1
     -1, 0, 8, 2, // row 2
     -7, 1, -1, 1, // row 3
  )
  let want = mat3(
    -6, 1, 6, // row 0
     -8, 8, 6, // row 1
     -7, -1, 1, // row 2
  )
  assert_eq!(a.submatrix(2, 1), want)
}

///|
test "Calculating the determinant of a 4x4 matrix (p.65)" {
  let a = mat4(
    -2, -8, 3, 5, // row 0
     -3, 1, 7, 3, // row 1
     1, 2, -9, 6, // row 2
     -6, 7, 7, -9, // row 3
  )
  assert_eq!(a.cofactor(0, 0), 690)
  assert_eq!(a.cofactor(0, 1), 447)
  assert_eq!(a.cofactor(0, 2), 210)
  assert_eq!(a.cofactor(0, 3), 51)
  assert_eq!(a.determinant(), -4071)
}

///|
test "Testing an invertible matrix for invertibility (p.66)" {
  let a = mat4(
    6, 4, 4, 4, // row 0
     5, 5, 7, 6, // row 1
     4, -9, 3, -7, // row 2
     9, 1, 7, -6, // row 3
  )
  assert_eq!(a.determinant(), -2120)
  assert_true!(a.is_invertible())
}

///|
test "Testing a non-invertible matrix for invertibility (p.67)" {
  let a = mat4(
    -4, 2, -2, -3, // row 0
     9, 6, 2, 6, // row 1
     0, -5, 1, -5, // row 2
     0, 0, 0, 0, // row 3
  )
  assert_eq!(a.determinant(), 0)
  assert_false!(a.is_invertible())
}

///|
test "Calculating the inverse of a matrix (p.67)" {
  let a = mat4(
    -5, 2, 6, -8, // row 0
     1, -5, 1, 8, // row 1
     7, 7, -6, -7, // row 2
     1, -3, 7, 4, // row 3
  )
  let b = a.inverse()
  assert_eq!(a.determinant(), 532)
  assert_eq!(a.cofactor(2, 3), -160)
  assert_eq!(b[3][2], -160.0 / 532)
  assert_eq!(a.cofactor(3, 2), 105)
  assert_eq!(b[2][3], 105.0 / 532)
  let want = mat4(
    0.21805, 0.45113, 0.24060, -0.04511, // row 0
     -0.80827, -1.45677, -0.44361, 0.52068, // row 1
     -0.07895, -0.22368, -0.05263, 0.19737, // row 2
     -0.52256, -0.81391, -0.30075, 0.30639, // row 3
  )
  assert_eq!(b, want)
}

///|
test "Calculating the inverse of another matrix (p.68)" {
  let a = mat4(
    8, -5, 9, 2, // row 0
     7, 5, 6, 1, // row 1
     -6, 0, 9, 6, // row 2
     -3, 0, -9, -4, // row 3
  )
  let want = mat4(
    -0.15385, -0.15385, -0.28205, -0.53846, // row 0
     -0.07692, 0.12308, 0.02564, 0.03077, // row 1
     0.35897, 0.35897, 0.43590, 0.92308, // row 2
     -0.69231, -0.69231, -0.76923, -1.92308, // row 3
  )
  assert_eq!(a.inverse(), want)
}

///|
test "Calculating the inverse of a third matrix (p.69)" {
  let a = mat4(
    9, 3, 0, 9, // row 0
     -5, -2, -6, -3, // row 1
     -4, 9, 6, 4, // row 2
     -7, 6, 6, 2, // row 3
  )
  let want = mat4(
    -0.04074, -0.07778, 0.14444, -0.22222, // row 0
     -0.07778, 0.03333, 0.36667, -0.33333, // row 1
     -0.02901, -0.1463, -0.10926, 0.12963, // row 2
     0.17778, 0.06667, -0.26667, 0.33333, // row 3
  )
  assert_eq!(a.inverse(), want)
}

///|
test "Multiplying a product by its inverse (p.69)" {
  let a = mat4(
    3, -9, 7, 3, // row 0
     3, -8, 2, -9, // row 1
     -4, 4, 4, 1, // row 2
     -6, 5, -1, 1, // row 3
  )
  let b = mat4(
    8, 2, 2, 2, // row 0
     3, -1, 7, 0, // row 1
     7, 0, 5, 4, // row 2
     6, -2, 0, 5, // row 3
  )
  let c = a * b
  assert_eq!(c * b.inverse(), a)
}
