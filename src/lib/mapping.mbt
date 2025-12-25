///|
pub fn spherical_map(p : Tuple) -> (Double, Double) {
  // compute the azimuthal angle
  // -π < theta <= π
  let theta = @math.atan2(p.x, p.z)

  // radius of the sphere
  let radius = (p.x * p.x + p.y * p.y + p.z * p.z).sqrt()

  // compute the polar angle
  // 0 <= phi <= π
  let phi = @math.acos(p.y / radius)

  // -0.5 < raw_u <= 0.5
  let raw_u = theta / (2.0 * @math.PI)

  // 0 <= u < 1
  let u = raw_u + 0.5

  // we want v to be 0 at the south pole and 1 at the north pole
  // 0 <= v <= 1
  let v = 1.0 - phi / @math.PI
  (u, v)
}

///|
pub fn planar_map(p : Tuple) -> (Double, Double) {
  let u = p.x - @math.floor(p.x)
  let v = p.z - @math.floor(p.z)
  (u, v)
}

///|
pub fn cylindrical_map(p : Tuple) -> (Double, Double) {
  // compute the azimuthal angle, same as with spherical_map
  let theta = @math.atan2(p.x, p.z)
  let raw_u = theta / (2.0 * @math.PI)
  let u = 1.0 - (raw_u + 0.5)

  // let v go from 0 to 1 between whole units of y
  let v = p.y - @math.floor(p.y)
  (u, v)
}

///|
pub fn cubic_map(p : Tuple) -> (Double, Double) {
  let xabs = p.x.abs()
  let yabs = p.y.abs()
  let zabs = p.z.abs()
  let maxc = @cmp.maximum(@cmp.maximum(xabs, yabs), zabs)
  if maxc == xabs {
    if p.x > 0 {
      // right face
      return (1.0 - (p.z + 1.0) / 2.0, (p.y + 1.0) / 2.0)
    } else {
      // left face
      return ((p.z + 1.0) / 2.0, (p.y + 1.0) / 2.0)
    }
  }
  if maxc == yabs {
    if p.y > 0 {
      // top face
      return ((p.x + 1.0) / 2.0, 1.0 - (p.z + 1.0) / 2.0)
    } else {
      // bottom face
      return ((p.x + 1.0) / 2.0, (p.z + 1.0) / 2.0)
    }
  }
  if p.z > 0 {
    // front face
    return ((p.x + 1.0) / 2.0, (p.y + 1.0) / 2.0)
  }
  // back face
  return (1.0 - (p.x + 1.0) / 2.0, (p.y + 1.0) / 2.0)
}
