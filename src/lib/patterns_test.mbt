///|
let black = @lib.black

///|
let white = @lib.white

///|
let stripe_pattern = @lib.stripe_pattern

test "Creating a stripe pattern (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.colors[0], white)
  assert_eq!(pattern.colors[1], black)
}

test "A stripe pattern is constant in y (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.stripe_at(point(0, 0, 0)), white)
  assert_eq!(pattern.stripe_at(point(0, 1, 0)), white)
  assert_eq!(pattern.stripe_at(point(0, 2, 0)), white)
}

test "A stripe pattern is constant in z (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.stripe_at(point(0, 0, 0)), white)
  assert_eq!(pattern.stripe_at(point(0, 0, 1)), white)
  assert_eq!(pattern.stripe_at(point(0, 0, 2)), white)
}

test "A stripe pattern alternates in x (p.175)" {
  let pattern = stripe_pattern([white, black])
  assert_eq!(pattern.stripe_at(point(0, 0, 0)), white)
  assert_eq!(pattern.stripe_at(point(0.9, 0, 0)), white)
  assert_eq!(pattern.stripe_at(point(1, 0, 0)), black)
  assert_eq!(pattern.stripe_at(point(-0.1, 0, 0)), black)
  assert_eq!(pattern.stripe_at(point(-1, 0, 0)), black)
  assert_eq!(pattern.stripe_at(point(-1.1, 0, 0)), white)
}

test "A stripe pattern supports more than two colors" {
  let red = color(1, 0, 0)
  let green = color(0, 1, 0)
  let blue = color(0, 0, 1)
  let pattern = stripe_pattern([white, black, red, green, blue])
  assert_eq!(pattern.stripe_at(point(-5, 0, 0)), white)
  assert_eq!(pattern.stripe_at(point(-4, 0, 0)), black)
  assert_eq!(pattern.stripe_at(point(-3, 0, 0)), red)
  assert_eq!(pattern.stripe_at(point(-2, 0, 0)), green)
  assert_eq!(pattern.stripe_at(point(-1, 0, 0)), blue)
  assert_eq!(pattern.stripe_at(point(0, 0, 0)), white)
  assert_eq!(pattern.stripe_at(point(1, 0, 0)), black)
  assert_eq!(pattern.stripe_at(point(2, 0, 0)), red)
  assert_eq!(pattern.stripe_at(point(3, 0, 0)), green)
  assert_eq!(pattern.stripe_at(point(4, 0, 0)), blue)
  assert_eq!(pattern.stripe_at(point(5, 0, 0)), white)
}
