///|
test "field vector decoding variants" {
  let p = stripe_pattern([color(0.25, 0.5, 0.75), color(0.25, 0.5, 0.75)])
  let fs = field_signed(p)
  let vs = fs.vector_at(point(0.1, 0.2, 0.3))
  assert_true((vs.x - -0.5).abs() < @lib.EPSILON)
  assert_true((vs.y - 0.0).abs() < @lib.EPSILON)
  assert_true((vs.z - 0.5).abs() < @lib.EPSILON)
  let fu = field_unit01(p)
  let vu = fu.vector_at(point(0.1, 0.2, 0.3))
  assert_true((vu.x - 0.25).abs() < @lib.EPSILON)
  assert_true((vu.y - 0.5).abs() < @lib.EPSILON)
  assert_true((vu.z - 0.75).abs() < @lib.EPSILON)
}
