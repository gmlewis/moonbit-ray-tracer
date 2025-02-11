///|
test "Creating a stripe pattern (p.175)" {
  let pattern = stripe_pattern([white, black])
  inspect!(
    pattern,
    content=
      #|{pattern: stripe(color(1, 1, 1),color(0, 0, 0)), transform: mat4(
      #|1, 0, 0, 0, // row 0
      #|0, 1, 0, 0, // row 1
      #|0, 0, 1, 0, // row 2
      #|0, 0, 0, 1, // row 3
      #|), inv_transform: mat4(
      #|1, 0, 0, 0, // row 0
      #|0, 1, 0, 0, // row 1
      #|0, 0, 1, 0, // row 2
      #|0, 0, 0, 1, // row 3
      #|)}
    ,
  )
}

///|
test "A stripe pattern is constant in y (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0, 1, 0)), white)
  assert_eq!(pattern.pattern_at(point(0, 2, 0)), white)
}

///|
test "A stripe pattern is constant in z (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0, 0, 1)), white)
  assert_eq!(pattern.pattern_at(point(0, 0, 2)), white)
}

///|
test "A stripe pattern alternates in x (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0.9, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(1, 0, 0)), black)
  assert_eq!(pattern.pattern_at(point(-0.1, 0, 0)), black)
  assert_eq!(pattern.pattern_at(point(-1, 0, 0)), black)
  assert_eq!(pattern.pattern_at(point(-1.1, 0, 0)), white)
}

///|
test "A stripe pattern supports more than two colors" {
  let red = color(1, 0, 0)
  let green = color(0, 1, 0)
  let blue = color(0, 0, 1)
  let pattern = stripe_pattern([white, black, red, green, blue])
  assert_eq!(pattern.pattern_at(point(-5, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(-4, 0, 0)), black)
  assert_eq!(pattern.pattern_at(point(-3, 0, 0)), red)
  assert_eq!(pattern.pattern_at(point(-2, 0, 0)), green)
  assert_eq!(pattern.pattern_at(point(-1, 0, 0)), blue)
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(1, 0, 0)), black)
  assert_eq!(pattern.pattern_at(point(2, 0, 0)), red)
  assert_eq!(pattern.pattern_at(point(3, 0, 0)), green)
  assert_eq!(pattern.pattern_at(point(4, 0, 0)), blue)
  assert_eq!(pattern.pattern_at(point(5, 0, 0)), white)
}

///|
struct TestPattern {}

///|
fn TestPattern::clone(_self : TestPattern) -> Pattern {
  test_pattern()
}

///|
fn TestPattern::to_string(_self : TestPattern) -> String {
  "test_pattern()"
}

///|
fn output(self : TestPattern, logger : &Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
fn test_pattern() -> Pattern {
  Pattern::new(TestPattern::{  })
}

///|
fn TestPattern::pattern_at(_self : TestPattern, point : Tuple) -> Color {
  color(point.x, point.y, point.z)
}

///|
test "The default pattern transformation (p.182)" {
  let pattern = test_pattern()
  assert_eq!(pattern.transform, mat4ident())
}

///|
test "Assigning a transformation (p.182)" {
  let pattern = test_pattern()
  pattern.set_pattern_transform(translation(1, 2, 3))
  assert_eq!(pattern.transform, translation(1, 2, 3))
}

///|
test "A pattern with an object transformation (p.182)" {
  let shape = sphere()
  shape.set_transform(scaling(2, 2, 2))
  let pattern = test_pattern()
  let c = pattern.pattern_at_shape(shape, point(2, 3, 4))
  assert_eq!(c, color(1, 1.5, 2))
}

///|
test "A pattern with a pattern transformation (p.182)" {
  let shape = sphere()
  let pattern = test_pattern()
  pattern.set_pattern_transform(scaling(2, 2, 2))
  let c = pattern.pattern_at_shape(shape, point(2, 3, 4))
  assert_eq!(c, color(1, 1.5, 2))
}

///|
test "A pattern with both an object and a pattern transformation (p.182)" {
  let shape = sphere()
  shape.set_transform(scaling(2, 2, 2))
  let pattern = test_pattern()
  pattern.set_pattern_transform(translation(0.5, 1, 1.5))
  let c = pattern.pattern_at_shape(shape, point(2.5, 3, 3.5))
  assert_eq!(c, color(0.75, 0.5, 0.25))
}

///|
test "A gradient linearly interpolates between colors (p.184)" {
  let pattern = gradient_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0.25, 0, 0)), color(0.75, 0.75, 0.75))
  assert_eq!(pattern.pattern_at(point(0.5, 0, 0)), color(0.5, 0.5, 0.5))
  assert_eq!(pattern.pattern_at(point(0.75, 0, 0)), color(0.25, 0.25, 0.25))
  assert_eq!(pattern.pattern_at(point(1, 0, 0)), black)
}

///|
test "A ring should extend in both x and z (p.186)" {
  let pattern = ring_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(1, 0, 0)), black)
  assert_eq!(pattern.pattern_at(point(0, 0, 1)), black)
  // 0.708 = just slightly more than √2/2
  assert_eq!(pattern.pattern_at(point(0.708, 0, 0.708)), black)
}

///|
test "Checkers should repeat in x (p.189)" {
  let pattern = checkers_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0.99, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(1, 0, 0)), black)
}

///|
test "Checkers should repeat in y (p.189)" {
  let pattern = checkers_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0, 0.99, 0)), white)
  assert_eq!(pattern.pattern_at(point(0, 1, 0)), black)
}

///|
test "Checkers should repeat in z (p.189)" {
  let pattern = checkers_pattern([white, black])
  assert_eq!(pattern.pattern_at(point(0, 0, 0)), white)
  assert_eq!(pattern.pattern_at(point(0, 0, 0.99)), white)
  assert_eq!(pattern.pattern_at(point(0, 0, 1)), black)
}
