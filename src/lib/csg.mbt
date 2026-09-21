///|
pub(all) enum Operation {
  Union
  Intersection
  Difference
} derive(Debug, Eq)

///|
pub extend Operation with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Operation with Eq::{not_equal}

///|
pub extend Operation with Debug::{to_repr}

///|
pub fn Operation::to_string(self : Operation) -> String {
  match self {
    Union => "union"
    Intersection => "intersection"
    Difference => "difference"
  }
}

///|

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Operation with Show::{output}

///|
pub impl Show for Operation with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) struct CSG {
  operation : Operation
  left : Shape
  right : Shape
} derive(Debug, Eq)

///|
pub extend CSG with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend CSG with Eq::{not_equal}

///|
pub extend CSG with Debug::{to_repr}

///|
pub fn csg(operation : Operation, left : Shape, right : Shape) -> Shape {
  Shape::new_csg({ operation, left, right, })
}

///|
pub fn Shape::new_csg(csg : CSG) -> Shape {
  let shape = Shape::new(CSG(csg))
  csg.left.parent = Some(shape)
  csg.right.parent = Some(shape)
  shape
}

///|
pub fn intersection_allowed(
  op : Operation,
  left_hit : Bool,
  inside_left : Bool,
  inside_right : Bool,
) -> Bool {
  match op {
    Union => (left_hit && !inside_right) || (!left_hit && !inside_left)
    Intersection => (left_hit && inside_right) || (!left_hit && inside_left)
    Difference => (left_hit && !inside_right) || (!left_hit && inside_left)
  }
}

///|
pub fn CSG::clone(self : CSG) -> CSG {
  {
    operation: self.operation,
    left: self.left.clone(),
    right: self.right.clone(),
  }
}

///|
// Shallow like Group::to_string: a CSG tree can be deep, and --debug
// already dumps the parsed shape hierarchy separately.
pub fn CSG::to_string(self : CSG) -> String {
  "csg(\{self.operation})"
}

///|

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend CSG with Show::{output}

///|
pub impl Show for CSG with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn CSG::filter_intersections(
  self : CSG,
  xs : Intersections,
) -> Intersections {
  // begin outside of both children
  let mut inside_left = false
  let mut inside_right = false

  // prepare an array to receive the filtered intersections
  let result = []
  for i in xs.xs {
    // if i.shape is part of the "left" child, then left_hit is true
    let left_hit = self.left.includes_shape(i.shape)
    if intersection_allowed(self.operation, left_hit, inside_left, inside_right) {
      result.push(i)
    }
    if left_hit {
      inside_left = !inside_left
    } else {
      inside_right = !inside_right
    }
  }
  intersections(result)
}
