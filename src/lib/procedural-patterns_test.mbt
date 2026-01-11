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

///|
test "bias_gain_pattern identity at 0.5" {
  let base = stripe_pattern([color(0.25, 0.25, 0.25), color(0.25, 0.25, 0.25)])
  let p = bias_gain_pattern(base, bias=0.5, gain=0.5)
  let c = p.pattern_at(point(0.1, 0.2, 0.3))
  assert_true((c.red - 0.25).abs() < @lib.EPSILON)
}

///|
test "bias_gain_pattern bias shifts midtones" {
  let base = stripe_pattern([color(0.25, 0.25, 0.25), color(0.25, 0.25, 0.25)])
  let p_low = bias_gain_pattern(base, bias=0.25, gain=0.5)
  let p_high = bias_gain_pattern(base, bias=0.75, gain=0.5)
  let c_low = p_low.pattern_at(point(0.1, 0.2, 0.3))
  let c_high = p_high.pattern_at(point(0.1, 0.2, 0.3))
  assert_true(c_low.red < 0.25)
  assert_true(c_high.red > 0.25)
}

///|
test "bias_gain_pattern gain affects shadows" {
  let base = stripe_pattern([color(0.25, 0.25, 0.25), color(0.25, 0.25, 0.25)])
  let p_bright = bias_gain_pattern(base, bias=0.5, gain=0.25)
  let p_dark = bias_gain_pattern(base, bias=0.5, gain=0.75)
  let c_bright = p_bright.pattern_at(point(0.1, 0.2, 0.3))
  let c_dark = p_dark.pattern_at(point(0.1, 0.2, 0.3))
  assert_true(c_bright.red > 0.25)
  assert_true(c_dark.red < 0.25)
}

///|
test "contrast_pattern clamps" {
  let base = stripe_pattern([color(0.25, 0.25, 0.25), color(0.25, 0.25, 0.25)])
  let p = contrast_pattern(base, contrast=2.0, pivot=0.5)
  let c = p.pattern_at(point(0.1, 0.2, 0.3))
  assert_true((c.red - 0.0).abs() < @lib.EPSILON)
  let base2 = stripe_pattern([color(0.75, 0.75, 0.75), color(0.75, 0.75, 0.75)])
  let p2 = contrast_pattern(base2, contrast=2.0, pivot=0.5)
  let c2 = p2.pattern_at(point(0.1, 0.2, 0.3))
  assert_true((c2.red - 1.0).abs() < @lib.EPSILON)
}
