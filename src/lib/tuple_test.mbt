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

test "Subtracting a vector from the zero vector (p.31)" {
  let zero = vector(0, 0, 0)
  let v = vector(1, -2, 3)
  assert_eq!(zero - v, vector(-1, 2, -3))
}

test "Negating a tuple (p.31)" {
  let a = tuple(1, -2, 3, -4)
  assert_eq!(-a, tuple(-1, 2, -3, 4))
}

test "Multiplying a tuple by a scalar (p.32)" {
  let a = tuple(1, -2, 3, -4)
  assert_eq!(a.mul_scalar(3.5), tuple(3.5, -7, 10.5, -14))
}

test "Multiplying a tuple by a fraction (p.32)" {
  let a = tuple(1, -2, 3, -4)
  assert_eq!(a.mul_scalar(0.5), tuple(0.5, -1, 1.5, -2))
}

test "Dividing a tuple by a scalar (p.32)" {
  let a = tuple(1, -2, 3, -4)
  assert_eq!(a.div_scalar(2), tuple(0.5, -1, 1.5, -2))
}

test "Computing the magnitude of vector(1,0,0) (p.32)" {
  let v = vector(1, 0, 0)
  assert_eq!(v.magnitude(), 1)
}

test "Computing the magnitude of vector(0,1,0) (p.32)" {
  let v = vector(0, 1, 0)
  assert_eq!(v.magnitude(), 1)
}

test "Computing the magnitude of vector(0,0,1) (p.33)" {
  let v = vector(0, 0, 1)
  assert_eq!(v.magnitude(), 1)
}

test "Computing the magnitude of vector(1,2,3) (p.33)" {
  let v = vector(1, 2, 3)
  assert_eq!(v.magnitude(), 14.0.sqrt())
}

test "Computing the magnitude of vector(-1,-2,-3) (p.33)" {
  let v = vector(-1, -2, -3)
  assert_eq!(v.magnitude(), 14.0.sqrt())
}

test "Normalizing vector(4,0,0) gives (1,0,0) (p.34)" {
  let v = vector(4, 0, 0)
  assert_eq!(v.normalize(), vector(1, 0, 0))
}

test "Normalizing vector(1,2,3) (p.34)" {
  let v = vector(1, 2, 3)
  assert_eq!(v.normalize(), vector(0.26726, 0.53452, 0.80178))
}

test "The magnitude of a normalized vector (p.34)" {
  let v = vector(1, 2, 3)
  let norm = v.normalize()
  assert_eq!(norm.magnitude(), 1)
}

test "The dot product of two vectors (p.34)" {
  let a = vector(1, 2, 3)
  let b = vector(2, 3, 4)
  assert_eq!(a.dot(b), 20)
}

test "The cross product of two vectors (p.36)" {
  let a = vector(1, 2, 3)
  let b = vector(2, 3, 4)
  assert_eq!(a.cross(b), vector(-1, 2, -1))
  assert_eq!(b.cross(a), vector(1, -2, 1))
}

test "Reflecting a vector approaching at 45° (p.122)" {
  let v = vector(1, -1, 0)
  let n = vector(0, 1, 0)
  let r = v.reflect(n)
  assert_eq!(r, vector(1, 1, 0))
}

test "Reflecting a vector off a slanted surface (p.122)" {
  let v = vector(0, -1, 0)
  let sq2 = 2.0.sqrt() / 2
  let n = vector(sq2, sq2, 0)
  let r = v.reflect(n)
  assert_eq!(r, vector(1, 0, 0))
}
