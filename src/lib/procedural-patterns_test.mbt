///|
test "noise_pattern produces deterministic grayscale" {
  let p = noise_pattern(seed=42, scale=1.0)
  let c1 = p.pattern_at(point(1.234, 2.345, 3.456))
  let c2 = p.pattern_at(point(1.234, 2.345, 3.456))
  assert_eq(c1, c2)
  assert_true((c1.red - c1.green).abs() < @lib.EPSILON)
  assert_true((c1.green - c1.blue).abs() < @lib.EPSILON)
  assert_true(c1.red >= 0.0 && c1.red <= 1.0)
}

///|
test "fbm_pattern stays within [0,1]" {
  let p = fbm_pattern(seed=7, scale=1.3, octaves=6)
  let c = p.pattern_at(point(-10.2, 0.3, 4.9))
  assert_true(c.red >= 0.0 && c.red <= 1.0)
  assert_true((c.red - c.green).abs() < @lib.EPSILON)
}

///|
test "mix_pattern uses mask luminance" {
  let red = stripe_pattern([color(1, 0, 0), color(1, 0, 0)])
  let blue = stripe_pattern([color(0, 0, 1), color(0, 0, 1)])
  let mask = checkers_pattern([color(0, 0, 0), color(1, 1, 1)])
  let mix = mix_pattern(red, blue, mask)

  // Even cell -> mask black -> choose red
  let c0 = mix.pattern_at(point(0.1, 0.1, 0.1))
  assert_eq(c0, color(1, 0, 0))

  // Odd cell -> mask white -> choose blue
  let c1 = mix.pattern_at(point(1.1, 0.1, 0.1))
  assert_eq(c1, color(0, 0, 1))
}
