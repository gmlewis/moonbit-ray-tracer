///|
pub fn translation(x : Double, y : Double, z : Double) -> Matrix {
  mat4(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1)
}
