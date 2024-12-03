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
