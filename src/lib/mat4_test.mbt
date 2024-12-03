///|
let mat4 = @lib.mat4

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
