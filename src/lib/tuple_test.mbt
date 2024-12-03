let point = @lib.point

let tuple = @lib.tuple

let vector = @lib.vector

test "A tuple with w=1.0 is a point (p.26)" {
  let a = tuple(4.3, -4.2, 3.1, 1.0)
  inspect!(a.x, content="4.3")
  inspect!(a.y, content="-4.2")
  inspect!(a.z, content="3.1")
  inspect!(a.w, content="1")
  inspect!(a.is_point(), content="true")
  inspect!(a.is_vector(), content="false")
}

test "A tuple with w=0 is a vector (p.27)" {
  let a = tuple(4.3, -4.2, 3.1, 0)
  inspect!(a.x, content="4.3")
  inspect!(a.y, content="-4.2")
  inspect!(a.z, content="3.1")
  inspect!(a.w, content="0")
  inspect!(a.is_point(), content="false")
  inspect!(a.is_vector(), content="true")
}

test "point() creates tuples with w=1 (p.27)" {
  let p = point(4, -4, 3)
  assert_eq!(p, tuple(4, -4, 3, 1))
}

test "vector() creates tuples with w=0 (p.27)" {
  let p = vector(4, -4, 3)
  assert_eq!(p, tuple(4, -4, 3, 0))
}

test "Adding two tuples (p.29)" {
  let a1 = tuple(3, -2, 5, 1)
  let a2 = tuple(-2, 3, 1, 0)
  assert_eq!(a1 + a2, tuple(1, 1, 6, 1))
}

test "Subtracting two points (p.30)" {
  let p1 = point(3, 2, 1)
  let p2 = point(5, 6, 7)
  assert_eq!(p1 - p2, vector(-2, -4, -6))
}

test "Subtracting a vector from a point (p.30)" {
  let p = point(3, 2, 1)
  let v = vector(5, 6, 7)
  assert_eq!(p - v, point(-2, -4, -6))
}

test "Subtracting two vectors (p.30)" {
  let v1 = vector(3, 2, 1)
  let v2 = vector(5, 6, 7)
  assert_eq!(v1 - v2, vector(-2, -4, -6))
}
