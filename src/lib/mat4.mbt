///|
pub(all) type MatrixRow Array[Double] derive(Show)

///|
pub fn op_get(self : MatrixRow, col : Int) -> Double {
  self._[col]
}

///|
pub(all) type Matrix Array[MatrixRow] derive(Show)

///|
pub fn op_get(self : Matrix, row : Int) -> MatrixRow {
  self._[row]
}

///|
pub fn mat4(
  r0c0 : Double,
  r0c1 : Double,
  r0c2 : Double,
  r0c3 : Double,
  r1c0 : Double,
  r1c1 : Double,
  r1c2 : Double,
  r1c3 : Double,
  r2c0 : Double,
  r2c1 : Double,
  r2c2 : Double,
  r2c3 : Double,
  r3c0 : Double,
  r3c1 : Double,
  r3c2 : Double,
  r3c3 : Double
) -> Matrix {
  [
    [r0c0, r0c1, r0c2, r0c3],
    [r1c0, r1c1, r1c2, r1c3],
    [r2c0, r2c1, r2c2, r2c3],
    [r3c0, r3c1, r3c2, r3c3],
  ]
}
