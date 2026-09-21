///|
test "Creating a stripe pattern (p.175)" {
  let pattern = @lib.stripe_pattern([@lib.white, @lib.black])
  inspect(
    pattern,
    content=(
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
    ),
  )
}

///|
test "A stripe pattern is constant in y (p.175)" {
  let pattern = @lib.stripe_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 1, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 2, 0)), @lib.white)
}

///|
test "A stripe pattern is constant in z (p.175)" {
  let pattern = @lib.stripe_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 1)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 2)), @lib.white)
}

///|
test "A stripe pattern alternates in x (p.175)" {
  let pattern = @lib.stripe_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0.9, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(1, 0, 0)), @lib.black)
  assert_eq(pattern.pattern_at(@lib.point(-0.1, 0, 0)), @lib.black)
  assert_eq(pattern.pattern_at(@lib.point(-1, 0, 0)), @lib.black)
  assert_eq(pattern.pattern_at(@lib.point(-1.1, 0, 0)), @lib.white)
}

///|
test "A stripe pattern supports more than two colors" {
  let red = @lib.color(1, 0, 0)
  let green = @lib.color(0, 1, 0)
  let blue = @lib.color(0, 0, 1)
  let pattern = @lib.stripe_pattern([@lib.white, @lib.black, red, green, blue])
  assert_eq(pattern.pattern_at(@lib.point(-5, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(-4, 0, 0)), @lib.black)
  assert_eq(pattern.pattern_at(@lib.point(-3, 0, 0)), red)
  assert_eq(pattern.pattern_at(@lib.point(-2, 0, 0)), green)
  assert_eq(pattern.pattern_at(@lib.point(-1, 0, 0)), blue)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(1, 0, 0)), @lib.black)
  assert_eq(pattern.pattern_at(@lib.point(2, 0, 0)), red)
  assert_eq(pattern.pattern_at(@lib.point(3, 0, 0)), green)
  assert_eq(pattern.pattern_at(@lib.point(4, 0, 0)), blue)
  assert_eq(pattern.pattern_at(@lib.point(5, 0, 0)), @lib.white)
}

///|
struct TestPattern {} derive(Debug)

///|
pub fn TestPattern::to_string(_self : TestPattern) -> String {
  "test_pattern()"
}

///|
impl PatternTrait for TestPattern with fn clone(_self) {
  test_pattern()
}

///|
// impl Show for TestPattern with to_string(_self) {
//   "test_pattern()"
// }

///|
impl Show for TestPattern with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn test_pattern() -> @lib.Pattern {
  @lib.Pattern::new(TestPattern::{ })
}

///|
impl PatternTrait for TestPattern with fn pattern_at(_self, point) {
  @lib.color(point.x, point.y, point.z)
}

///|
impl PatternTrait for TestPattern with fn uv_at(_self, _u, _v) {
  @lib.color(0, 0, 0)
}

///|
impl PatternTrait for TestPattern with fn pattern_at_with_info(
  self,
  point,
  _normal,
  uv,
) {
  match uv {
    Some((u, v)) => self.uv_at(u, v)
    None => self.pattern_at(point)
  }
}

///|
extend TestPattern with @gmlewis/ray-tracer/lib.PatternTrait::{
  pattern_at,
  uv_at,
}

///|
test "The default pattern transformation (p.182)" {
  let pattern = test_pattern()
  assert_eq(pattern.transform, @lib.mat4ident())
}

///|
test "Assigning a transformation (p.182)" {
  let pattern = test_pattern()
  pattern.set_pattern_transform(@lib.translation(1, 2, 3))
  assert_eq(pattern.transform, @lib.translation(1, 2, 3))
}

///|
test "A pattern with an object transformation (p.182)" {
  let shape = @lib.sphere()
  shape.set_transform(@lib.scaling(2, 2, 2))
  let pattern = test_pattern()
  let c = pattern.pattern_at_shape(
    shape,
    @lib.point(2, 3, 4),
    normal=@lib.vector(0, 0, 0),
  )
  assert_eq(c, @lib.color(1, 1.5, 2))
}

///|
test "A pattern with a pattern transformation (p.182)" {
  let shape = @lib.sphere()
  let pattern = test_pattern()
  pattern.set_pattern_transform(@lib.scaling(2, 2, 2))
  let c = pattern.pattern_at_shape(
    shape,
    @lib.point(2, 3, 4),
    normal=@lib.vector(0, 0, 0),
  )
  assert_eq(c, @lib.color(1, 1.5, 2))
}

///|
test "A pattern with both an object and a pattern transformation (p.182)" {
  let shape = @lib.sphere()
  shape.set_transform(@lib.scaling(2, 2, 2))
  let pattern = test_pattern()
  pattern.set_pattern_transform(@lib.translation(0.5, 1, 1.5))
  let c = pattern.pattern_at_shape(
    shape,
    @lib.point(2.5, 3, 3.5),
    normal=@lib.vector(0, 0, 0),
  )
  assert_eq(c, @lib.color(0.75, 0.5, 0.25))
}

///|
test "A gradient linearly interpolates between colors (p.184)" {
  let pattern = @lib.gradient_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(
    pattern.pattern_at(@lib.point(0.25, 0, 0)),
    @lib.color(0.75, 0.75, 0.75),
  )
  assert_eq(
    pattern.pattern_at(@lib.point(0.5, 0, 0)),
    @lib.color(0.5, 0.5, 0.5),
  )
  assert_eq(
    pattern.pattern_at(@lib.point(0.75, 0, 0)),
    @lib.color(0.25, 0.25, 0.25),
  )
  assert_eq(pattern.pattern_at(@lib.point(1, 0, 0)), @lib.black)
}

///|
test "A ring should extend in both x and z (p.186)" {
  let pattern = @lib.ring_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(1, 0, 0)), @lib.black)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 1)), @lib.black)
  // 0.708 = just slightly more than √2/2
  assert_eq(pattern.pattern_at(@lib.point(0.708, 0, 0.708)), @lib.black)
}

///|
test "Checkers should repeat in x (p.189)" {
  let pattern = @lib.checkers_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0.99, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(1, 0, 0)), @lib.black)
}

///|
test "Checkers should repeat in y (p.189)" {
  let pattern = @lib.checkers_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 0.99, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 1, 0)), @lib.black)
}

///|
test "Checkers should repeat in z (p.189)" {
  let pattern = @lib.checkers_pattern([@lib.white, @lib.black])
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0.99)), @lib.white)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 1)), @lib.black)
}

///|
test "GradientCheckersPattern should interpolate smoothly in 3D" {
  let pattern = @lib.gradient_checkers_pattern([@lib.white, @lib.black])
  // Cell (0,0,0) index 0 (white), next_index 1 (black)
  assert_eq(pattern.pattern_at(@lib.point(0, 0, 0)), @lib.white)
  // t = (0.5+0+0)/3 = 1/6
  assert_eq(
    pattern.pattern_at(@lib.point(0.5, 0, 0)),
    @lib.color(1.0 - 1.0 / 6.0, 1.0 - 1.0 / 6.0, 1.0 - 1.0 / 6.0),
  )
  // t = (0.5+0.5+0.5)/3 = 0.5
  assert_eq(
    pattern.pattern_at(@lib.point(0.5, 0.5, 0.5)),
    @lib.color(0.5, 0.5, 0.5),
  )
}
