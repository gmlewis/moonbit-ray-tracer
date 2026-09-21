///|
async test "graphic_mask pattern samples inside/outside" {
  let scene = @lib.parse_scene_file("src/lib/testdata/graphic-mask-scene.toml") catch {
    e => abort("failed to parse scene file: \{e}")
  }
  let shape = scene.world.shapes[0]
  let pattern = match shape.material.pattern {
    Some(p) => p
    None => abort("expected object material.pattern to be set")
  }
  let inside = pattern.pattern_at_shape(
    shape,
    @lib.point(0.5, 0.0, 0.5),
    normal=@lib.vector(0, 0, 0),
  )
  let outside = pattern.pattern_at_shape(
    shape,
    @lib.point(1.5, 0.0, 0.5),
    normal=@lib.vector(0, 0, 0),
  )
  assert_eq(inside, @lib.color(1, 1, 1))
  assert_eq(outside, @lib.color(0, 0, 0))
}
