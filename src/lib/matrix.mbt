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
pub fn clone(self : Matrix) -> Matrix {
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  let result = Array::new(capacity=nrows)
  for row in 0..<nrows {
    let arr = Array::new(capacity=ncols)
    for col in 0..<ncols {
      arr.push(self[row][col])
    }
    result.push(MatrixRow(arr))
  }
  Matrix(result)
}

///|
pub fn transpose(self : Matrix) -> Matrix {
  let result = self.clone()
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  for row in 0..<nrows {
    for col in 0..<ncols {
      result[row][col] = self[col][row]
    }
  }
  result
}

///| Multiple matrix by single-column tuple.
/// Currently only 4x4 * 1x4 is handled.
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

///|
pub fn determinant(self : Matrix) -> Double {
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  guard nrows == ncols
  if nrows == 2 {
    return self[0][0] * self[1][1] - self[0][1] * self[1][0]
  }
  let mut det = 0.0
  for col in 0..<ncols {
    det += self[0][col] * self.cofactor(0, col)
  }
  det
}

///|
pub fn submatrix(self : Matrix, row : Int, col : Int) -> Matrix {
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  guard nrows == ncols
  let result = Array::new(capacity=nrows - 1)
  for r in 0..<nrows {
    if r == row {
      continue
    }
    let arr = Array::new(capacity=ncols - 1)
    for c in 0..<ncols {
      if c == col {
        continue
      }
      arr.push(self[r][c])
    }
    result.push(MatrixRow(arr))
  }
  Matrix(result)
}

///|
pub fn minor(self : Matrix, row : Int, col : Int) -> Double {
  let m = self.submatrix(row, col)
  m.determinant()
}

///|
pub fn cofactor(self : Matrix, row : Int, col : Int) -> Double {
  let m = self.minor(row, col)
  if (row + col) % 2 == 0 {
    m
  } else {
    -m
  }
}

///|
pub fn is_invertible(self : Matrix) -> Bool {
  let det = self.determinant()
  det != 0
}

///|
pub fn inverse(self : Matrix) -> Matrix {
  let det = self.determinant()
  if det == 0 {
    return self
  }
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  guard nrows == ncols
  let inv = self.clone()
  for row in 0..<nrows {
    for col in 0..<ncols {
      let c = self.cofactor(row, col)
      // note that "[col][row]" here accomplishes the transpose!
      inv[col][row] = c / det
    }
  }
  inv
}
