///| Cone represents a unit cone at the origin.
pub(all) struct Cone {
  minimum : Double
  maximum : Double
  closed : Bool
} derive(Eq)

///|
let _Cone : Object = Cone::{ minimum: 0, maximum: 0, closed: false }

///|
pub fn cone(
  minimum~ : Double = @double.neg_infinity,
  maximum~ : Double = @double.infinity,
  closed~ : Bool = false
) -> Shape {
  let cone = Cone::{ minimum, maximum, closed }
  Shape::new(cone)
}

///|
pub fn op_equal(self : Cone, other : Cone) -> Bool {
  self == other
}

///|
pub fn Cone::to_string(_self : Cone) -> String {
  "cone()"
}

///|
pub fn output(self : Cone, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

// a helper function to reduce duplication.
// checks to see if the intersection at `t` is within a radius
// of 1 (the radius of the cylinders) from the y axis.
///|
fn check_cone_cap(ray : Ray, t : Double, y : Double) -> Bool {
  let x = ray.origin.x + t * ray.direction.x
  let z = ray.origin.z + t * ray.direction.z
  let r = y.abs()
  x * x + z * z <= r
}

///|
fn intersect_caps(self : Cone, ray : Ray, xs : Array[Double]) -> Unit {
  // caps only matter if the cone is closed, and might possibly be
  // intersected by the ray.
  if not(self.closed) || ray.direction.y.abs() < EPSILON {
    return
  }
  // check for an intersection with the lower end cap by intersecting
  // the ray with the plane at y=cyl.minimum
  let t = (self.minimum - ray.origin.y) / ray.direction.y
  if check_cone_cap(ray, t, self.minimum) {
    xs.push(t)
  }
  // check for an intersection with the upper end cap by intersecting
  // the ray with the plane at y=cyl.maximum
  let t = (self.maximum - ray.origin.y) / ray.direction.y
  if check_cone_cap(ray, t, self.maximum) {
    xs.push(t)
  }
}

///|
pub fn local_intersect(self : Cone, ray : Ray) -> Array[Double] {
  let xs = []
  let o = ray.origin
  let d = ray.direction
  let a = d.x * d.x - d.y * d.y + d.z * d.z
  let b = o.x * d.x * 2 - o.y * d.y * 2 + o.z * d.z * 2
  if a.abs() < EPSILON && b.abs() < EPSILON {
    self.intersect_caps(ray, xs)
    return xs
  }
  let c = o.x * o.x - o.y * o.y + o.z * o.z
  if a.abs() < EPSILON {
    let t = -c / (b * 2)
    xs.push(t)
    self.intersect_caps(ray, xs)
    return xs
  }

  //
  let disc = b * b - a * c * 4
  // ray does not intersect the cone
  if disc < 0 {
    self.intersect_caps(ray, xs)
    return xs
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
  let y0 = o.y + t0 * d.y
  if self.minimum < y0 && y0 < self.maximum {
    xs.push(t0)
  }
  let y1 = o.y + t1 * d.y
  if self.minimum < y1 && y1 < self.maximum {
    xs.push(t1)
  }
  self.intersect_caps(ray, xs)
  xs
}

///|
pub fn local_normal_at(self : Cone, local_point : Tuple) -> Tuple {
  let dist = local_point.x * local_point.x + local_point.z * local_point.z
  if dist < 1 && local_point.y >= self.maximum - EPSILON {
    return vector(0, 1, 0)
  }
  if dist < 1 && local_point.y <= self.minimum + EPSILON {
    return vector(0, -1, 0)
  }

  //
  let mut y = dist.sqrt()
  if local_point.y > 0 {
    y = -y
  }
  vector(local_point.x, y, local_point.z)
}
