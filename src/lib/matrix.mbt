///|
pub(all) struct MatrixRow(Array[Double]) derive(Show)

///|
pub fn MatrixRow::op_get(self : MatrixRow, col : Int) -> Double {
  self.inner()[col]
}

///|
pub fn op_set(self : MatrixRow, col : Int, v : Double) -> Unit {
  self.inner()[col] = v
}

///|
pub(all) struct Matrix(Array[MatrixRow])

///|
pub fn Matrix::to_string(self : Matrix) -> String {
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  guard nrows == ncols
  let rows = StringBuilder::new()
  for row in 0..<nrows {
    for col in 0..<ncols {
      let s = round_to_fixed(self[row][col], 5).to_string()
      rows.write_string(s)
      rows.write_string(", ")
    }
    rows.write_string("// row \{row}\n")
  }
  "mat\{nrows}(\n\{rows})"
}

///|
pub impl Show for Matrix with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn Matrix::op_get(self : Matrix, row : Int) -> MatrixRow {
  self.inner()[row]
}

///|
pub fn num_rows(self : Matrix) -> Int {
  self.inner().length()
}

///|
pub fn num_cols(self : Matrix) -> Int {
  if self.num_rows() == 0 {
    return 0
  }
  self.inner()[0].inner().length()
}

///|
pub impl Eq for Matrix with op_equal(self, other) {
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
      let delta = (self.inner()[row].inner()[col] -
      other.inner()[row].inner()[col]).abs()
      if delta >= EPSILON {
        return false
      }
    }
  }
  true
}

///|
/// Matrix multiplication - currently, only 4x4 is handled.
pub impl Mul for Matrix with op_mul(self, o) {
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
pub fn Matrix::clone(self : Matrix) -> Matrix {
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
pub fn copy(self : Matrix, other : Matrix) -> Unit {
  let nrows = self.num_rows()
  let ncols = self.num_cols()
  guard other.num_rows() == nrows && other.num_cols() == ncols
  for row in 0..<nrows {
    for col in 0..<ncols {
      self[row][col] = other[row][col]
    }
  }
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

///|
/// Multiple matrix by single-column tuple.
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

///|
fn my_pow(base : Double, exponent : Double) -> Double {
  @math.exp(exponent * @math.ln(base))
}

///|
/// round_to_fixed rounds the double to the provided
/// number of digits.
pub fn round_to_fixed(v : Double, digits : Int) -> Double {
  let num = digits.to_double().abs()
  let exp = @math.round(my_pow(10, num))
  if digits < 0 {
    return @math.round(v / exp) * exp
  }
  @math.round(v * exp) / exp
}

///|
pub fn dump(self : Matrix) -> String {
  let nrows = self.num_rows()
  let f = fn(v) { round_to_fixed(v, 5) }
  match nrows {
    2 =>
      (
        #|mat2(
        $|\{f(self[0][0])}, \{f(self[0][1])}, // row 0
        $|\{f(self[1][0])}, \{f(self[1][1])}, // row 1
        #|)
      )
    3 =>
      (
        #|mat3(
        $|\{f(self[0][0])}, \{f(self[0][1])}, \{f(self[0][2])}, // row 0
        $|\{f(self[1][0])}, \{f(self[1][1])}, \{f(self[1][2])}, // row 1
        $|\{f(self[2][0])}, \{f(self[2][1])}, \{f(self[2][2])}, // row 2
        #|)
      )
    4 =>
      (
        #|mat4(
        $|\{f(self[0][0])}, \{f(self[0][1])}, \{f(self[0][2])}, \{f(self[0][3])}, // row 0
        $|\{f(self[1][0])}, \{f(self[1][1])}, \{f(self[1][2])}, \{f(self[1][3])}, // row 1
        $|\{f(self[2][0])}, \{f(self[2][1])}, \{f(self[2][2])}, \{f(self[2][3])}, // row 2
        $|\{f(self[3][0])}, \{f(self[3][1])}, \{f(self[3][2])}, \{f(self[3][3])}, // row 3
        #|)
      )
    _ => "unsupported nrows=\{nrows}"
  }
}

///|
pub fn rotate_x(self : Matrix, rad : Double) -> Matrix {
  rotation_x(rad) * self
}

///|
pub fn rotate_y(self : Matrix, rad : Double) -> Matrix {
  rotation_y(rad) * self
}

///|
pub fn rotate_z(self : Matrix, rad : Double) -> Matrix {
  rotation_z(rad) * self
}

///|
pub fn scale(self : Matrix, x : Double, y : Double, z : Double) -> Matrix {
  scaling(x, y, z) * self
}

///|
pub fn translate(self : Matrix, x : Double, y : Double, z : Double) -> Matrix {
  translation(x, y, z) * self
}

///|
pub fn shear(
  self : Matrix,
  xy : Double,
  xz : Double,
  yx : Double,
  yz : Double,
  zx : Double,
  zy : Double,
) -> Matrix {
  shearing(xy, xz, yx, yz, zx, zy) * self
}
