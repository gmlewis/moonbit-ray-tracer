///|
/// Cube represents a unit cube at the origin.
pub(all) struct Cube {} derive(Debug, Eq)

///|
pub extend Cube with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Cube with Eq::{not_equal}

///|
pub extend Cube with Debug::{to_repr}

///|
let _Cube : &Object = Cube::{ }

///|
pub fn cube() -> Shape {
  let cube = Cube::{ }
  Shape::new_object(cube)
}

///|

///|
pub extend Cube with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Cube with Show::{output}

///|
pub impl Show for Cube with fn output(_self, logger) {
  logger.write_string("cube()")
}

///|

///|
pub extend Cube with Object::{bounds, clone, local_intersect, local_normal_at}

///|
pub impl Object for Cube with fn local_intersect(_self, ray) {
  let (xtmin, xtmax) = check_axis(ray.origin.x, ray.direction.x, -1, 1)
  let (ytmin, ytmax) = check_axis(ray.origin.y, ray.direction.y, -1, 1)
  let (ztmin, ztmax) = check_axis(ray.origin.z, ray.direction.z, -1, 1)

  //
  let tmin = @cmp.maximum(@cmp.maximum(xtmin, ytmin), ztmin)
  let tmax = @cmp.minimum(@cmp.minimum(xtmax, ytmax), ztmax)
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
  max : Double,
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
pub impl Object for Cube with fn local_normal_at(_self, local_point) {
  let xabs = local_point.x.abs()
  let yabs = local_point.y.abs()
  let zabs = local_point.z.abs()
  let maxc = @cmp.maximum(@cmp.maximum(xabs, yabs), zabs)
  if maxc == xabs {
    vector(local_point.x, 0, 0)
  } else if maxc == yabs {
    vector(0, local_point.y, 0)
  } else {
    vector(0, 0, local_point.z)
  }
}

///|
pub impl Object for Cube with fn bounds(_self) {
  let min = point(-1, -1, -1)
  let max = point(1, 1, 1)
  { min, max, }
}

///|
pub impl Object for Cube with fn clone(_self) {
  Cube::{ }
}
