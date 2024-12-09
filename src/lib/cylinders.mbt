///| Cylinder represents a unit cylinder at the origin.
pub(all) struct Cylinder {
  minimum : Double
  maximum : Double
} derive(Eq)

///|
let _Cylinder : Object = Cylinder::{ minimum: 0, maximum: 0 }

///|
pub fn cylinder(
  minimum~ : Double = @double.neg_infinity,
  maximum~ : Double = @double.infinity
) -> Shape {
  let cylinder = Cylinder::{ minimum, maximum }
  Shape::new(cylinder)
}

///|
pub fn op_equal(self : Cylinder, other : Cylinder) -> Bool {
  self == other
}

///|
pub fn Cylinder::to_string(_self : Cylinder) -> String {
  "cylinder()"
}

///|
pub fn output(self : Cylinder, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn local_intersect(self : Cylinder, ray : Ray) -> Array[Double] {
  let a = ray.direction.x * ray.direction.x + ray.direction.z * ray.direction.z
  // ray is parallel to the y axis
  if a < EPSILON {
    return []
  }
  let b = ray.origin.x * ray.direction.x * 2 +
    ray.origin.z * ray.direction.z * 2
  let c = ray.origin.x * ray.origin.x + ray.origin.z * ray.origin.z - 1
  let disc = b * b - a * c * 4
  // ray does not intersect the cylinder
  if disc < 0 {
    return []
  }

  //
  let sqr = disc.sqrt()
  let mut t0 = (-b - sqr) / (a * 2)
  let mut t1 = (-b + sqr) / (a * 2)
  if t0 > t1 {
    let tmp = t0
    t0 = t1
    t1 = tmp
  }

  //
  let xs = []
  let y0 = ray.origin.y + t0 * ray.direction.y
  if self.minimum < y0 && y0 < self.maximum {
    xs.push(t0)
  }
  let y1 = ray.origin.y + t1 * ray.direction.y
  if self.minimum < y1 && y1 < self.maximum {
    xs.push(t1)
  }
  xs
}

///|
pub fn Cylinder::local_normal_at(
  _self : Cylinder,
  local_point : Tuple
) -> Tuple {
  vector(local_point.x, 0, local_point.z)
}
