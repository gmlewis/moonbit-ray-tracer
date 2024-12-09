///|
typealias Ray = @lib.Ray

///|
typealias Shape = @lib.Shape

///|
typealias Tuple = @lib.Tuple

///|
struct TestShape {
  mut saved_ray : Ray
} derive(Show, Eq)

///|
fn local_intersect(self : TestShape, ray : Ray) -> Array[Double] {
  self.saved_ray = ray
  []
}

///|
fn TestShape::local_normal_at(_self : TestShape, point : Tuple) -> Tuple {
  vector(point.x, point.y, point.z)
}

///|
fn to_string(self : TestShape) -> String {
  "test_shape(\{self.saved_ray})"
}

///|
fn output(self : TestShape, logger : Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
fn test_shape() -> Shape {
  let saved_ray = ray(point(0, 0, 0), vector(0, 1, 0)) // initial value unimportant
  Shape::new_object(TestShape::{ saved_ray, })
}

test "The default transformation (p.165)" {
  let s = test_shape()
  assert_eq!(s.transform, mat4ident())
}

test "Assigning a transformation (p.166)" {
  let s = test_shape()
  s.set_transform(translation(2, 3, 4))
  assert_eq!(s.transform, translation(2, 3, 4))
}

test "The default material (p.166)" {
  let s = test_shape()
  let m = s.material
  assert_eq!(m, material())
}

test "Assiging a material (p.166)" {
  let s = test_shape()
  let m = material()
  m.ambient = 1
  s.material = m
  assert_eq!(s.material, m)
}

test "Intersecting a scaled shape with a ray (p.167)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = test_shape()
  s.set_transform(scaling(2, 2, 2))
  let _ = s.intersect(r)
  inspect!(
    s.object,
    content="test_shape(ray(point(0, 0, -2.5), vector(0, 0, 0.5)))",
  )
}

test "Intersecting a translated shape with a ray (p.167)" {
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let s = test_shape()
  s.set_transform(translation(5, 0, 0))
  let _ = s.intersect(r)
  inspect!(
    s.object,
    content="test_shape(ray(point(-5, 0, -5), vector(0, 0, 1)))",
  )
}

test "Computing the normal on a translated shape (p.168)" {
  let s = test_shape()
  s.set_transform(translation(0, 1, 0))
  let n = s.normal_at(point(0, 1.70711, -0.70711))
  assert_eq!(n, vector(0, 0.70711, -0.70711))
}

test "Computing the normal on a transformed shape (p.168)" {
  let s = test_shape()
  let m = scaling(1, 0.5, 1) * rotation_z(@math.PI / 5)
  s.set_transform(m)
  let sq2 = 2.0.sqrt() / 2
  let n = s.normal_at(point(0, sq2, -sq2))
  assert_eq!(n, vector(0, 0.97014, -0.24254))
}

test "A shape has a parent attribute (p.253)" {
  let s = test_shape()
  assert_eq!(s.parent, None)
}

test "Converting a point from world to object space (p.256)" {
  let s = sphere()..set_transform(translation(5, 0, 0))
  let g2 = @lib.group()..set_transform(scaling(2, 2, 2))..add_child(s)
  @lib.group()..set_transform(rotation_y(@math.PI / 2)).add_child(g2)
  let p = s.world_to_object(point(-2, 0, -10))
  assert_eq!(p, point(0, 0, -1))
}
