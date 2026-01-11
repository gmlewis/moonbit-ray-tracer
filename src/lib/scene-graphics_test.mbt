///|
async test "parse_scene_file loads graphics assets" {
  let scene = @lib.parse_scene_file("src/lib/testdata/graphic-scene.toml") catch {
    e => abort("failed to parse scene file: \{e}")
  }
  match scene.graphics.get("square") {
    Some(g) =>
      inspect(
        g.bounding_box(),
        content="Some({min: {x: 2, y: 3}, max: {x: 6, y: 8}})",
      )
    None => abort("expected graphics.square to be loaded")
  }
}
