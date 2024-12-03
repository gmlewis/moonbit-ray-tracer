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
