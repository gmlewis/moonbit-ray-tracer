///|
/// Cube represents a unit cube at the origin.
pub(all) struct Cube {} derive(Show, Eq)

///|
let _Cube : &Object = Cube::{  }

///|
pub fn cube() -> Shape {
  let cube = Cube::{  }
  Shape::new_object(cube)
}

///|
pub impl Show for Cube with to_string(_self) {
  "cube()"
}

///|
pub impl Object for Cube with local_intersect(_self, ray) {
  let (xtmin, xtmax) = check_axis(ray.origin.x, ray.direction.x, -1, 1)
  let (ytmin, ytmax) = check_axis(ray.origin.y, ray.direction.y, -1, 1)
  let (ztmin, ztmax) = check_axis(ray.origin.z, ray.direction.z, -1, 1)

  //
  let tmin = @math.maximum(@math.maximum(xtmin, ytmin), ztmin)
  let tmax = @math.minimum(@math.minimum(xtmax, ytmax), ztmax)
  if tmin > tmax {
    return []
  }

  //
  [tmin, tmax]
}

///|
fn check_axis(
  origin : Double,
  direction : Double,
  min : Double,
  max : Double
) -> (Double, Double) {
  let tmin_numerator = min - origin
  let tmax_numerator = max - origin
  let tmin = tmin_numerator / direction // div-by-zero = +/- infinity
  let tmax = tmax_numerator / direction
  if tmin > tmax {
    (tmax, tmin)
  } else {
    (tmin, tmax)
  }
}

///|
pub impl Object for Cube with local_normal_at(_self, local_point) {
  let xabs = local_point.x.abs()
  let yabs = local_point.y.abs()
  let zabs = local_point.z.abs()
  let maxc = @math.maximum(@math.maximum(xabs, yabs), zabs)
  if maxc == xabs {
    vector(local_point.x, 0, 0)
  } else if maxc == yabs {
    vector(0, local_point.y, 0)
  } else {
    vector(0, 0, local_point.z)
  }
}

///|
pub impl Object for Cube with bounds(_self) {
  let min = point(-1, -1, -1)
  let max = point(1, 1, 1)
  { min, max }
}
