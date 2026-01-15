///|
pub(all) struct Pattern {
  pattern : &PatternTrait
  // Do not modify transform directly. Use `set_transform` instead.
  mut transform : Matrix
  mut inv_transform : Matrix
} derive(Show)

///|
pub(open) trait PatternTrait: Show {
  pattern_at(Self, Tuple) -> Color
  uv_at(Self, Double, Double) -> Color
  pattern_at_with_info(Self, Tuple, Tuple, (Double, Double)?) -> Color
  clone(Self) -> Pattern
}

///|
pub fn Pattern::new(pattern : &PatternTrait) -> Pattern {
  let transform = mat4ident()
  let inv_transform = mat4ident()
  { pattern, transform, inv_transform }
}

///|
pub impl PatternTrait for Pattern with pattern_at(self, point) {
  self.pattern.pattern_at(point)
}

///|
pub impl PatternTrait for Pattern with uv_at(self, u, v) {
  self.pattern.uv_at(u, v)
}

///|
pub impl PatternTrait for Pattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  self.pattern.pattern_at_with_info(point, normal, uv)
}

///|
pub impl Eq for Pattern with equal(self, other) {
  self.transform == other.transform
}

///|
pub impl PatternTrait for Pattern with clone(self) {
  let pattern = self.pattern.clone().pattern
  let transform = self.transform.clone()
  let inv_transform = self.inv_transform.clone()
  { pattern, transform, inv_transform }
}

///|
pub fn Pattern::set_pattern_transform(
  self : Pattern,
  transform : Matrix,
) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn Pattern::pattern_at_shape(
  self : Pattern,
  shape : Shape,
  world_point : Tuple,
  normal? : Tuple,
  uv? : (Double, Double),
) -> Color {
  let object_point = shape.world_to_object(world_point)
  let pattern_point = self.inv_transform.mul_tuple(object_point)
  let n = match normal {
    Some(n) => {
      let object_normal = shape.world_normal_to_object(n)
      let pattern_normal = self.transform.transpose().mul_tuple(object_normal)
      pattern_normal.w = 0
      pattern_normal.normalize()
    }
    None => vector(0, 0, 0)
  }
  self.pattern.pattern_at_with_info(pattern_point, n, uv)
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Mappings
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(open) trait Mapping: Show {
  map(Self, Tuple) -> (Double, Double)
}

///|
pub(all) struct SphericalMapping {} derive(Show, Eq)

///|
pub impl Mapping for SphericalMapping with map(_self, p) {
  let theta = @math.atan2(p.x, p.z)
  let radius = (p.x * p.x + p.y * p.y + p.z * p.z).sqrt()
  let phi = @math.acos(p.y / radius)
  let raw_u = theta / (2.0 * @math.PI)
  let u = raw_u + 0.5
  let v = 1.0 - phi / @math.PI
  (u, v)
}

///|
pub(all) struct PlanarMapping {} derive(Show, Eq)

///|
pub impl Mapping for PlanarMapping with map(_self, p) {
  let u = p.x - @math.floor(p.x)
  let v = p.z - @math.floor(p.z)
  (u, v)
}

///|
pub(all) struct CylindricalMapping {} derive(Show, Eq)

///|
pub impl Mapping for CylindricalMapping with map(_self, p) {
  let theta = @math.atan2(p.x, p.z)
  let raw_u = theta / (2.0 * @math.PI)
  let u = raw_u + 0.5
  let v = p.y - @math.floor(p.y)
  (u, v)
}

///|
pub(all) struct CubicMapping {} derive(Show, Eq)

///|
pub impl Mapping for CubicMapping with map(_self, p) {
  let xabs = p.x.abs()
  let yabs = p.y.abs()
  let zabs = p.z.abs()
  let maxc = @cmp.maximum(@cmp.maximum(xabs, yabs), zabs)
  if maxc == xabs {
    if p.x > 0 {
      return (1.0 - (p.z + 1.0) / 2.0, (p.y + 1.0) / 2.0)
    } else {
      return ((p.z + 1.0) / 2.0, (p.y + 1.0) / 2.0)
    }
  }
  if maxc == yabs {
    if p.y > 0 {
      return ((p.x + 1.0) / 2.0, 1.0 - (p.z + 1.0) / 2.0)
    } else {
      return ((p.x + 1.0) / 2.0, (p.z + 1.0) / 2.0)
    }
  }
  if p.z > 0 {
    return ((p.x + 1.0) / 2.0, (p.y + 1.0) / 2.0)
  }
  return (1.0 - (p.x + 1.0) / 2.0, (p.y + 1.0) / 2.0)
}
