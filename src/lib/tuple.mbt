const EPSILON = 0.00001

/// Tuple represents either a point or a vector.
pub(all) struct Tuple {
  mut x : Double
  mut y : Double
  mut z : Double
  mut w : Double
} derive(Show)

pub fn tuple(x : Double, y : Double, z : Double, w : Double) -> Tuple {
  { x, y, z, w }
}

pub fn op_equal(self : Tuple, other : Tuple) -> Bool {
  let { x, y, z, w } = (self - other).abs()
  x < EPSILON && y < EPSILON && z < EPSILON && w < EPSILON
}

pub fn op_add(self : Tuple, other : Tuple) -> Tuple {
  let x = self.x + other.x
  let y = self.y + other.y
  let z = self.z + other.z
  let w = self.w + other.w
  { x, y, z, w }
}

pub fn op_sub(self : Tuple, other : Tuple) -> Tuple {
  let x = self.x - other.x
  let y = self.y - other.y
  let z = self.z - other.z
  let w = self.w - other.w
  { x, y, z, w }
}

pub fn abs(self : Tuple) -> Tuple {
  let x = self.x.abs()
  let y = self.y.abs()
  let z = self.z.abs()
  let w = self.w.abs()
  { x, y, z, w }
}

pub fn point(x : Double, y : Double, z : Double) -> Tuple {
  { x, y, z, w: 1 }
}

pub fn is_point(self : Tuple) -> Bool {
  self.w == 1
}

pub fn vector(x : Double, y : Double, z : Double) -> Tuple {
  { x, y, z, w: 0 }
}

pub fn is_vector(self : Tuple) -> Bool {
  self.w == 0
}
