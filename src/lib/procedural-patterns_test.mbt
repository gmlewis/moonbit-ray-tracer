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

///|
test "voronoi f1/f2/f2-f1 outputs are consistent" {
  let seed = 23
  let scale = 3.0
  let jitter = 1.0
  let p_f1 = voronoi_f1_pattern(seed~, scale~, jitter~)
  let p_f2 = voronoi_f2_pattern(seed~, scale~, jitter~)
  let p_df = voronoi_f2_minus_f1_pattern(seed~, scale~, jitter~, edge_scale=1.0)
  let pt = point(0.12, 0.0, -0.34)
  let c1 = p_f1.pattern_at(pt)
  let c2 = p_f2.pattern_at(pt)
  let cd = p_df.pattern_at(pt)

  // By definition, f2 >= f1.
  assert_true(c2.red + @lib.EPSILON >= c1.red)

  // f2-f1 should be close to the difference when unclamped.
  // (Edge cases clamp to [0,1], so allow a small tolerance.)
  let diff = c2.red - c1.red
  assert_true((cd.red - diff).abs() < 1.e-6 || cd.red == 0.0 || cd.red == 1.0)

  // All are grayscale in [0,1].
  assert_true(c1.red >= 0.0 && c1.red <= 1.0)
  assert_true((c1.red - c1.green).abs() < @lib.EPSILON)
  assert_true(c2.red >= 0.0 && c2.red <= 1.0)
  assert_true((c2.red - c2.blue).abs() < @lib.EPSILON)
  assert_true(cd.red >= 0.0 && cd.red <= 1.0)
}

///|
struct ConstPattern {
  c : Color
}

///|
pub fn ConstPattern::to_string(self : ConstPattern) -> String {
  "const(\{self.c})"
}

///|
pub impl Show for ConstPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for ConstPattern with clone(self) {
  const_pattern(self.c)
}

///|
pub impl PatternTrait for ConstPattern with pattern_at(self, _p) {
  self.c
}

///|
pub impl PatternTrait for ConstPattern with uv_at(self, _u, _v) {
  self.c
}

///|
pub impl PatternTrait for ConstPattern with pattern_at_with_info(
  self,
  p,
  _normal,
  uv,
) {
  match uv {
    Some((u, v)) => self.uv_at(u, v)
    None => self.pattern_at(p)
  }
}

///|
fn const_pattern(c : Color) -> Pattern {
  Pattern::new(ConstPattern::{ c, })
}

///|
struct UVCoordPattern {}

///|
pub fn UVCoordPattern::to_string(_self : UVCoordPattern) -> String {
  "uv_coord()"
}

///|
pub impl Show for UVCoordPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for UVCoordPattern with clone(_self) {
  uv_coord_pattern()
}

///|
pub impl PatternTrait for UVCoordPattern with pattern_at(self, p) {
  // Treat object point as UV-like for convenience.
  self.uv_at(p.x, p.y)
}

///|
pub impl PatternTrait for UVCoordPattern with uv_at(_self, u, v) {
  // Clamp to [0,1] so colors stay sane.
  let u = if u < 0.0 { 0.0 } else if u > 1.0 { 1.0 } else { u }
  let v = if v < 0.0 { 0.0 } else if v > 1.0 { 1.0 } else { v }
  color(u, v, 0.0)
}

///|
pub impl PatternTrait for UVCoordPattern with pattern_at_with_info(
  self,
  p,
  _normal,
  uv,
) {
  match uv {
    Some((u, v)) => self.uv_at(u, v)
    None => self.pattern_at(p)
  }
}

///|
fn uv_coord_pattern() -> Pattern {
  Pattern::new(UVCoordPattern::{  })
}

///|
test "levels_pattern remaps and clamps" {
  let base = const_pattern(color(0.25, 0.5, 0.75))
  let p = levels_pattern(base, in_min=0.5, in_max=1.0, out_min=0.0, out_max=1.0)
  let c = p.pattern_at(point(0.0, 0.0, 0.0))
  // 0.25 < in_min => clamp to 0
  assert_true((c.red - 0.0).abs() < @lib.EPSILON)
  // 0.5 maps to 0
  assert_true((c.green - 0.0).abs() < @lib.EPSILON)
  // 0.75 maps to 0.5
  assert_true((c.blue - 0.5).abs() < 1.e-12)
}

///|
test "threshold_pattern switches on luminance" {
  let base = stripe_pattern([color(0.25, 0.25, 0.25), color(0.75, 0.75, 0.75)])
  let p = threshold_pattern(
    base,
    threshold=0.5,
    low=color(1, 0, 0),
    high=color(0, 0, 1),
  )
  assert_eq(p.pattern_at(point(0.1, 0.0, 0.0)), color(1, 0, 0))
  assert_eq(p.pattern_at(point(1.1, 0.0, 0.0)), color(0, 0, 1))
}

///|
test "posterize_pattern quantizes channels" {
  let base = const_pattern(color(0.2, 0.6, 0.9))
  let p = posterize_pattern(base, steps=4)
  let c = p.pattern_at(point(0.0, 0.0, 0.0))
  // With steps=4 => levels=3 and bins at {0, 1/3, 2/3, 1}
  assert_true((c.red - 0.0).abs() < 1.e-12)
  assert_true((c.green - 2.0 / 3.0).abs() < 1.e-12)
  assert_true((c.blue - 1.0).abs() < 1.e-12)
}

///|
test "gradient_map_pattern maps scalar to palette" {
  let base = stripe_pattern([
    color(0.0, 0.0, 0.0),
    color(0.5, 0.5, 0.5),
    color(1.0, 1.0, 1.0),
  ])
  let p = gradient_map_pattern(base, [color(1, 0, 0), color(0, 0, 1)])
  assert_eq(p.pattern_at(point(0.1, 0.0, 0.0)), color(1, 0, 0))
  assert_eq(p.pattern_at(point(2.1, 0.0, 0.0)), color(0, 0, 1))
  // 0.5 maps to mid of palette
  assert_eq(p.pattern_at(point(1.1, 0.0, 0.0)), color(0.5, 0.0, 0.5))
}

///|
test "triplanar_pattern picks correct projection when axis-aligned" {
  let base = uv_coord_pattern()
  let p = triplanar_pattern(base, scale=1.0, sharpness=8.0)
  let pt = point(0.2, 0.7, 0.4)

  // Normal X => use (z,y)
  let cx = p.pattern_at_shape(sphere(), pt, normal=vector(1, 0, 0))
  assert_eq(cx, color(0.4, 0.7, 0.0))

  // Normal Y => use (x,z)
  let cy = p.pattern_at_shape(sphere(), pt, normal=vector(0, 1, 0))
  assert_eq(cy, color(0.2, 0.4, 0.0))

  // Normal Z => use (x,y)
  let cz = p.pattern_at_shape(sphere(), pt, normal=vector(0, 0, 1))
  assert_eq(cz, color(0.2, 0.7, 0.0))
}

///|
test "triplanar_pattern blends projections" {
  let base = uv_coord_pattern()
  let p = triplanar_pattern(base, scale=1.0, sharpness=1.0)
  let pt = point(0.2, 0.7, 0.4)

  // Equal weights on X and Y.
  let c = p.pattern_at_shape(sphere(), pt, normal=vector(1, 1, 0))
  // 0.5 * (z,y) + 0.5 * (x,z) = (0.5*z + 0.5*x, 0.5*y + 0.5*z)
  assert_true((c.red - 0.3).abs() < 1.e-12)
  assert_true((c.green - 0.55).abs() < 1.e-12)
}

///|
test "warp_pattern uses RGB-as-vector (signed)" {
  let red = color(1, 0, 0)
  let blue = color(0, 0, 1)
  let base = stripe_pattern([red, blue])
  // RGB (1,0.5,0.5) decodes to vector(1,0,0) in Signed mode.
  let warp = const_pattern(color(1.0, 0.5, 0.5))
  let p = warp_pattern(base, warp, amplitude=0.25)

  // Without warp at x=0.9 => red. With warp => x=1.15 => blue.
  assert_eq(p.pattern_at(point(0.9, 0.0, 0.0)), blue)
}
