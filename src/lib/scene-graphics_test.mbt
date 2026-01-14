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

///|
async test "parse_scene_file loads TOML-native text graphics (if fonts available)" {
  // Keep CI/clean checkouts green: skip if fonts aren't configured.
  match @sys.get_env_var("MOONBIT_FONTS_DIR") {
    None => return
    Some(_) => ()
  }

  // Also skip if the specific font isn't available in the configured dir.
  let _ = @lib.load_font("lato_lightitalic") catch { _ => return }
  let scene = @lib.parse_scene_file("src/lib/testdata/graphic-text-scene.toml") catch {
    e => abort("failed to parse scene file: \{e}")
  }
  match scene.graphics.get("label") {
    Some(g) =>
      match g.bounding_box() {
        Some(_) => ()
        None => abort("expected text graphic to have a bounding box")
      }
    None => abort("expected graphics.label to be loaded")
  }
}

///|
async test "parse_scene_file supports text_mask pattern shortcut (if fonts available)" {
  match @sys.get_env_var("MOONBIT_FONTS_DIR") {
    None => return
    Some(_) => ()
  }
  let _ = @lib.load_font("lato_lightitalic") catch { _ => return }
  let scene = @lib.parse_scene_file("src/lib/testdata/text-mask-scene.toml") catch {
    e => abort("failed to parse scene file: \{e}")
  }
  if scene.world.shapes.length() == 0 {
    abort("expected at least one object")
  }
  match scene.world.shapes[0].material.pattern {
    Some(_) => ()
    None => abort("expected material.pattern to be resolved")
  }
}
