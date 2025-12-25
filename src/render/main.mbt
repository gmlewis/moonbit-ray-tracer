///|
async fn main {
  let args_spec : Map[String, @cli.Arg] = {
    "scene": @cli.opt_string(short='s', help="TOML scene file to render"),
    "output": @cli.opt_string(short='o', help="Output filename (PPM or PNG)"),
    "width": @cli.opt_int(0, short='w', help="Override output width"),
    "height": @cli.opt_int(0, short='H', help="Override output height"),
    "samples": @cli.opt_int(0, help="Override samples per pixel"),
    "divide": @cli.opt_int(0, help="Subdivide groups with at least this many children"),
  }

  let args = match @cli.parse(args_spec, prog="render", description="MoonBit Ray Tracer") {
    Some(a) => a
    None => return
  }

  let scene_path = match args.string_opt("scene") {
    Some(path) => path
    None => {
      @cli.eprintln("error: --scene/-s is required")
      abort("")
    }
  }

  // Load scene
  let parsed_scene = try {
    @lib.parse_scene_file(scene_path)
  } catch {
    e => {
      @cli.eprintln("error loading scene: \{e}")
      abort("")
    }
  }

  let world = parsed_scene.world
  let mut camera = parsed_scene.camera
  let settings = parsed_scene.render_settings
  world.background = settings.background

  // Apply overrides
  let w = args.int("width")
  if w > 0 {
    settings.width = w
    camera = @lib.camera(w, settings.height, camera.field_of_view)
    camera.transform = parsed_scene.camera.transform
  }

  let h = args.int("height")
  if h > 0 {
    settings.height = h
    camera = @lib.camera(settings.width, h, camera.field_of_view)
    camera.transform = parsed_scene.camera.transform
  }

  let s = args.int("samples")
  if s > 0 {
    settings.samples = s
  }

  let d = args.int("divide")
  if d > 0 {
    settings.divide = d
    let g = @lib.group()
    for shape in world.shapes {
      g.add_child(shape)
    }
    g.divide(d)
    world.shapes = [g]
  }

  // TODO: Implement multi-sampling if settings.samples > 1
  println("Rendering \{parsed_scene.metadata.name}...")
  println("Resolution: \{settings.width}x\{settings.height}")
  println("Samples: \{settings.samples}")

  let canvas = camera.render(
    world,
    samples=settings.samples,
    progress=async fn(y) {
      if y % 10 == 0 || y == settings.height {
        let pct = y.to_double() * 100.0 / settings.height.to_double()
        let msg = "\rProgress: \{pct.to_int()}% (\{y}/\{settings.height})"
        @stdio.stdout.write(msg)
        if y == settings.height {
          println("")
        }
      }
    },
  )

  // Determine output path
  let output_path = match args.string_opt("output") {
    Some(path) => path
    None => {
      // Default to scene name + .png
      let base = if scene_path.has_suffix(".toml") {
        scene_path[0:scene_path.length() - 5].to_string()
      } else {
        scene_path
      }
      base + ".png"
    }
  }

  // Save output
  println("Saving to \{output_path}...")
  try {
    if output_path.has_suffix(".ppm") {
      @fs.write_file(output_path, canvas.to_ppm(), create=0o644)
    } else {
      @fs.write_file(output_path, canvas.to_png(), create=0o644)
    }
  } catch {
    e => {
      @cli.eprintln("error saving output: \{e}")
      abort("")
    }
  }

  println("Done.")
}
