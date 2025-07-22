///|
pub fn mat3(
  r0c0 : Double,
  r0c1 : Double,
  r0c2 : Double,
  r1c0 : Double,
  r1c1 : Double,
  r1c2 : Double,
  r2c0 : Double,
  r2c1 : Double,
  r2c2 : Double,
) -> Matrix {
  [[r0c0, r0c1, r0c2], [r1c0, r1c1, r1c2], [r2c0, r2c1, r2c2]]
}
