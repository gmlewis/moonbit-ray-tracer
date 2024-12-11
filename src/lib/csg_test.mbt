///|
let csg = @lib.csg

test "CSG is created with an operation and two shapes (p.293)" {
  let s1 = sphere()
  let s2 = cube()
  let parent = csg(Union, s1, s2)
  guard let CSG(c) = parent.object
  assert_eq!(c.operation, Union)
  assert_eq!(c.left, s1)
  assert_eq!(c.right, s2)
  assert_eq!(s1.parent, Some(parent))
}
