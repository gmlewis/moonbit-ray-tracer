///|
pub fn translation(x : Double, y : Double, z : Double) -> Matrix {
  mat4(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1)
}

///|
pub fn scaling(x : Double, y : Double, z : Double) -> Matrix {
  mat4(x, 0, 0, 0, 0, y, 0, 0, 0, 0, z, 0, 0, 0, 0, 1)
}

///|
pub fn rotation_x(rad : Double) -> Matrix {
  let c = @math.cos(rad)
  let s = @math.sin(rad)
  mat4(1, 0, 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1)
}

///|
pub fn rotation_y(rad : Double) -> Matrix {
  let c = @math.cos(rad)
  let s = @math.sin(rad)
  mat4(c, 0, s, 0, 0, 1, 0, 0, -s, 0, c, 0, 0, 0, 0, 1)
}

///|
pub fn rotation_z(rad : Double) -> Matrix {
  let c = @math.cos(rad)
  let s = @math.sin(rad)
  mat4(c, -s, 0, 0, s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
}

///|
pub fn shearing(
  xy : Double,
  xz : Double,
  yx : Double,
  yz : Double,
  zx : Double,
  zy : Double
) -> Matrix {
  mat4(1, xy, xz, 0, yx, 1, yz, 0, zx, zy, 1, 0, 0, 0, 0, 1)
}

///|
pub fn view_transform(from : Tuple, to : Tuple, up : Tuple) -> Matrix {
  // left-hand coordinate system
  let forward = (to - from).normalize()
  let left = forward.cross(up.normalize())
  let true_up = left.cross(forward)
  let orientation = mat4(
    left.x,
    left.y,
    left.z,
    0, // row 0
    true_up.x,
    true_up.y,
    true_up.z,
    0, // row 1
    -forward.x,
    -forward.y,
    -forward.z,
    0, // row 2
    0,
    0,
    0,
    1, // row 3
  )
  orientation * translation(-from.x, -from.y, -from.z)
}
