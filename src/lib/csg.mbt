///|
pub(all) enum Operation {
  Union
  Intersection
  Difference
} derive(Show, Eq)

///|
pub(all) struct CSG {
  operation : Operation
  left : Shape
  right : Shape
} derive(Show, Eq)

///|
pub fn csg(operation : Operation, left : Shape, right : Shape) -> Shape {
  Shape::new_csg({ operation, left, right })
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
    Union =>
      (left_hit && not(inside_right)) || (not(left_hit) && not(inside_left))
    Intersection => (left_hit && inside_right) || (not(left_hit) && inside_left)
    Difference =>
      (left_hit && not(inside_right)) || (not(left_hit) && inside_left)
  }
}

///|
pub fn filter_intersections(self : CSG, xs : Intersections) -> Intersections {
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
      inside_left = not(inside_left)
    } else {
      inside_right = not(inside_right)
    }
  }
  intersections(result)
}
