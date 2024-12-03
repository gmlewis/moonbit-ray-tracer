///|
pub(all) type MatrixRow Array[Double] derive(Show)

///|
pub fn op_get(self : MatrixRow, col : Int) -> Double {
  self._[col]
}

///|
pub fn op_set(self : MatrixRow, col : Int, v : Double) -> Unit {
  self._[col] = v
}

///|
pub(all) type Matrix Array[MatrixRow] derive(Show)

///|
pub fn op_get(self : Matrix, row : Int) -> MatrixRow {
  self._[row]
}

///|
pub fn num_rows(self : Matrix) -> Int {
  self._.length()
}

///|
pub fn num_cols(self : Matrix) -> Int {
  if self.num_rows() == 0 {
    return 0
  }
  self._[0]._.length()
}

///|
pub fn op_equal(self : Matrix, other : Matrix) -> Bool {
  let nrows = self.num_rows()
  if self.num_rows() != other.num_rows() {
    return false
  }
  if nrows == 0 { // weird, but precaution
    return true
  }
  let ncols = self.num_cols()
  if ncols != other.num_cols() {
    return false
  }
  if ncols == 0 {
    return true
  }
  for row in 0..<nrows {
    for col in 0..<ncols {
      let delta = (self._[row]._[col] - other._[row]._[col]).abs()
      if delta >= EPSILON {
        return false
      }
    }
  }
  true
}

///| Matrix multiplication - currently, only 4x4 is handled.
pub fn op_mul(self : Matrix, o : Matrix) -> Matrix {
  let m = mat4zero()
  for row in 0..<4 {
    for col in 0..<4 {
      m[row][col] = self[row][0] * o[0][col] +
        self[row][1] * o[1][col] +
        self[row][2] * o[2][col] +
        self[row][3] * o[3][col]
    }
  }
  m
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

///|
pub fn mat4zero() -> Matrix {
  [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
}

///|
pub fn mat4ident() -> Matrix {
  [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
}

///| Multiple matrix by single-column tuple.
pub fn mul_tuple(self : Matrix, o : Tuple) -> Tuple {
  let m = tuple(0, 0, 0, 0)
  for row in 0..<4 {
    m[row] = self[row][0] * o.x +
      self[row][1] * o.y +
      self[row][2] * o.z +
      self[row][3] * o.w
  }
  m
}
