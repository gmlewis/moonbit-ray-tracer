///|
/// Cone represents a unit cone at the origin.
pub(all) struct Cone {
  minimum : Double
  maximum : Double
  closed : Bool
} derive(Show, Eq)

///|
let _Cone : &Object = Cone::{ minimum: 0, maximum: 0, closed: false }

///|
pub fn cone(
  minimum? : Double = @double.neg_infinity,
  maximum? : Double = @double.infinity,
  closed? : Bool = false,
) -> Shape {
  let cone = Cone::{ minimum, maximum, closed }
  Shape::new_object(cone)
}

///|
pub impl Object for Cone with bounds(self) {
  let r_max = @cmp.maximum(self.minimum.abs(), self.maximum.abs())
  let min = point(-r_max, self.minimum, -r_max)
  let max = point(r_max, self.maximum, r_max)
  { min, max }
}

///|
pub impl Show for Cone with to_string(_self) {
  "cone()"
}

// a helper function to reduce duplication.
// checks to see if the intersection at `t` is within a radius
// of |y| from the y axis.

///|
fn check_cone_cap(ray : Ray, t : Double, y : Double) -> Bool {
  let x = ray.origin.x + t * ray.direction.x
  let z = ray.origin.z + t * ray.direction.z
  x * x + z * z <= y * y + EPSILON
}

///|
fn Cone::intersect_caps(self : Cone, ray : Ray, xs : Array[Double]) -> Unit {
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
pub impl Object for Cone with local_intersect(self, ray) {
  let xs = []
  let o = ray.origin
  let d = ray.direction
  let a = d.x * d.x - d.y * d.y + d.z * d.z
  let b = o.x * d.x * 2 - o.y * d.y * 2 + o.z * d.z * 2
  let c = o.x * o.x - o.y * o.y + o.z * o.z

  if a.abs() < EPSILON {
    if b.abs() >= EPSILON {
      let t = -c / b
      let y = o.y + t * d.y
      if self.minimum < y && y < self.maximum {
        xs.push(t)
      }
    }
  } else {
    //
    let disc = b * b - a * c * 4
    // ray does not intersect the cone
    if disc >= 0 {
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
    }
  }
  self.intersect_caps(ray, xs)
  xs
}

///|
pub impl Object for Cone with local_normal_at(self, local_point) {
  let dist_sq = local_point.x * local_point.x + local_point.z * local_point.z
  
  if dist_sq < self.maximum * self.maximum && local_point.y >= self.maximum - EPSILON {
    return vector(0, 1, 0)
  }
  if dist_sq < self.minimum * self.minimum && local_point.y <= self.minimum + EPSILON {
    return vector(0, -1, 0)
  }

  //
  let mut y = dist_sq.sqrt()
  if local_point.y > 0 {
    y = -y
  }
  vector(local_point.x, y, local_point.z)
}