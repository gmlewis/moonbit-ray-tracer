///|
/// Cylinder represents a unit cylinder at the origin.
pub(all) struct Cylinder {
  minimum : Double
  maximum : Double
  closed : Bool
} derive(Show, Eq)

///|
let _Cylinder : &Object = Cylinder::{ minimum: 0, maximum: 0, closed: false }

///|
pub fn cylinder(
  minimum~ : Double = @double.neg_infinity,
  maximum~ : Double = @double.infinity,
  closed~ : Bool = false
) -> Shape {
  let cylinder = Cylinder::{ minimum, maximum, closed }
  Shape::new_object(cylinder)
}

///|
pub impl Show for Cylinder with to_string(_self) {
  "cylinder()"
}

// a helper function to reduce duplication.
// checks to see if the intersection at `t` is within a radius
// of 1 (the radius of the cylinders) from the y axis.

///|
fn check_cylinder_cap(ray : Ray, t : Double) -> Bool {
  let x = ray.origin.x + t * ray.direction.x
  let z = ray.origin.z + t * ray.direction.z
  x * x + z * z <= 1
}

///|
fn Cylinder::intersect_caps(
  self : Cylinder,
  ray : Ray,
  xs : Array[Double]
) -> Unit {
  // caps only matter if the cylinder is closed, and might possibly be
  // intersected by the ray.
  if not(self.closed) || ray.direction.y.abs() < EPSILON {
    return
  }
  // check for an intersection with the lower end cap by intersecting
  // the ray with the plane at y=cyl.minimum
  let t = (self.minimum - ray.origin.y) / ray.direction.y
  if check_cylinder_cap(ray, t) {
    xs.push(t)
  }
  // check for an intersection with the upper end cap by intersecting
  // the ray with the plane at y=cyl.maximum
  let t = (self.maximum - ray.origin.y) / ray.direction.y
  if check_cylinder_cap(ray, t) {
    xs.push(t)
  }
}

///|
pub impl Object for Cylinder with local_intersect(self, ray) {
  let xs = []
  let a = ray.direction.x * ray.direction.x + ray.direction.z * ray.direction.z
  // ray is parallel to the y axis
  if a >= EPSILON {
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
    let y0 = ray.origin.y + t0 * ray.direction.y
    if self.minimum < y0 && y0 < self.maximum {
      xs.push(t0)
    }
    let y1 = ray.origin.y + t1 * ray.direction.y
    if self.minimum < y1 && y1 < self.maximum {
      xs.push(t1)
    }
  }
  self.intersect_caps(ray, xs)
  xs
}

///|
pub impl Object for Cylinder with local_normal_at(self, local_point) {
  let dist = local_point.x * local_point.x + local_point.z * local_point.z
  if dist < 1 && local_point.y >= self.maximum - EPSILON {
    return vector(0, 1, 0)
  }
  if dist < 1 && local_point.y <= self.minimum + EPSILON {
    return vector(0, -1, 0)
  }
  vector(local_point.x, 0, local_point.z)
}

///|
pub impl Object for Cylinder with bounds(self) {
  let min = point(-1, self.minimum, -1)
  let max = point(1, self.maximum, 1)
  { min, max }
}
