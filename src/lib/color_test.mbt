test "Colors are (red,green,blue) tuples (p.41)" {
  let c = color(-0.5, 0.4, 1.7)
  inspect!(c.red, content="-0.5")
  inspect!(c.green, content="0.4")
  inspect!(c.blue, content="1.7")
}

test "Adding colors (p.43)" {
  let c1 = color(0.9, 0.6, 0.75)
  let c2 = color(0.7, 0.1, 0.25)
  assert_eq!(c1 + c2, color(1.6, 0.7, 1))
}

test "Subtracting colors (p.43)" {
  let c1 = color(0.9, 0.6, 0.75)
  let c2 = color(0.7, 0.1, 0.25)
  assert_eq!(c1 - c2, color(0.2, 0.5, 0.5))
}

test "Multiplying a color by a scalar (p.43)" {
  let c = color(0.2, 0.3, 0.4)
  assert_eq!(c.mul_scalar(2), color(0.4, 0.6, 0.8))
}

test "Multiplying colors (p.43)" {
  let c1 = color(1, 0.2, 0.4)
  let c2 = color(0.9, 1, 0.1)
  assert_eq!(c1 * c2, color(0.9, 0.2, 0.04))
}
