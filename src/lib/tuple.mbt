///|
pub const EPSILON = 0.00001

///|
/// Tuple represents either a point or a vector.
pub(all) struct Tuple {
  mut x : Double
  mut y : Double
  mut z : Double
  mut w : Double
}

///|
pub fn tuple(x : Double, y : Double, z : Double, w : Double) -> Tuple {
  { x, y, z, w }
}

///|
pub fn Tuple::to_string(self : Tuple) -> String {
  let x = round_to_fixed(self.x, 5)
  let y = round_to_fixed(self.y, 5)
  let z = round_to_fixed(self.z, 5)
  let w = round_to_fixed(self.w, 5)
  if w == 0 {
    "vector(\{x}, \{y}, \{z})"
  } else if w == 1 {
    "point(\{x}, \{y}, \{z})"
  } else {
    "tuple(\{x}, \{y}, \{z}, \{w})"
  }
}

///|
pub impl Show for Tuple with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn Tuple::op_get(self : Tuple, i : Int) -> Double {
  match i {
    0 => self.x
    1 => self.y
    2 => self.z
    3 => self.w
    _ => 0
  }
}

///|
pub fn Tuple::op_set(self : Tuple, i : Int, v : Double) -> Unit {
  match i {
    0 => self.x = v
    1 => self.y = v
    2 => self.z = v
    3 => self.w = v
    _ => ()
  }
}

///|
pub fn point(x : Double, y : Double, z : Double) -> Tuple {
  { x, y, z, w: 1 }
}

///|
pub fn is_point(self : Tuple) -> Bool {
  self.w == 1
}

///|
pub fn vector(x : Double, y : Double, z : Double) -> Tuple {
  { x, y, z, w: 0 }
}

///|
pub fn is_vector(self : Tuple) -> Bool {
  self.w == 0
}

///|
pub impl Eq for Tuple with op_equal(self, other) {
  let { x, y, z, w } = (self - other).abs()
  x < EPSILON && y < EPSILON && z < EPSILON && w < EPSILON
}

///|
pub impl Add for Tuple with op_add(self, other) {
  let x = self.x + other.x
  let y = self.y + other.y
  let z = self.z + other.z
  let w = self.w + other.w
  { x, y, z, w }
}

///|
pub impl Sub for Tuple with op_sub(self, other) {
  let x = self.x - other.x
  let y = self.y - other.y
  let z = self.z - other.z
  let w = self.w - other.w
  { x, y, z, w }
}

///|
pub impl Neg for Tuple with op_neg(self) {
  let x = -self.x
  let y = -self.y
  let z = -self.z
  let w = -self.w
  { x, y, z, w }
}

///|
pub impl Mul for Tuple with op_mul(self, other) {
  let x = self.x * other.x
  let y = self.y * other.y
  let z = self.z * other.z
  let w = self.w * other.w
  { x, y, z, w }
}

///|
pub fn Tuple::mul_scalar(self : Tuple, other : Double) -> Tuple {
  let x = self.x * other
  let y = self.y * other
  let z = self.z * other
  let w = self.w * other
  { x, y, z, w }
}

///|
pub fn op_div(self : Tuple, other : Tuple) -> Tuple {
  let x = self.x / other.x
  let y = self.y / other.y
  let z = self.z / other.z
  let w = self.w / other.w
  { x, y, z, w }
}

///|
pub fn div_scalar(self : Tuple, other : Double) -> Tuple {
  let x = self.x / other
  let y = self.y / other
  let z = self.z / other
  let w = self.w / other
  { x, y, z, w }
}

///|
pub fn abs(self : Tuple) -> Tuple {
  let x = self.x.abs()
  let y = self.y.abs()
  let z = self.z.abs()
  let w = self.w.abs()
  { x, y, z, w }
}

///|
pub fn magnitude(self : Tuple) -> Double {
  let { x, y, z, w } = self
  (x * x + y * y + z * z + w * w).sqrt()
}

///|
pub fn normalize(self : Tuple) -> Tuple {
  let len = self.magnitude()
  self.div_scalar(len)
}

///|
pub fn dot(self : Tuple, other : Tuple) -> Double {
  let x = self.x * other.x
  let y = self.y * other.y
  let z = self.z * other.z
  let w = self.w * other.w
  x + y + z + w
}

///|
pub fn cross(self : Tuple, other : Tuple) -> Tuple {
  let x = self.y * other.z - self.z * other.y
  let y = self.z * other.x - self.x * other.z
  let z = self.x * other.y - self.y * other.x
  { x, y, z, w: 0 }
}

///|
pub fn reflect(self : Tuple, normal : Tuple) -> Tuple {
  self - normal.mul_scalar(self.dot(normal) * 2)
}
