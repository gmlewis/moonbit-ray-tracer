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
