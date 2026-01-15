///|
async fn main {
  let args_spec : Map[String, @cli.Arg] = {
    "scene": @cli.opt_string(short='s', help="TOML scene file to render"),
    "output": @cli.opt_string(short='o', help="Output filename (PPM or PNG)"),
    "width": @cli.opt_int(0, short='w', help="Override output width"),
    "height": @cli.opt_int(0, short='H', help="Override output height"),
    "samples": @cli.opt_int(0, help="Override samples per pixel"),
    "draft": @cli.flag(
      help="Quick preview preset (lower resolution/samples/bounces unless overridden)",
    ),
    "stats": @cli.flag(
      help="Print render statistics (ray/shadow/intersection counts)",
    ),
    "debug": @cli.flag(help="Print parsed scene summary (materials/patterns)"),
    "divide": @cli.opt_int(
      0,
      help="Subdivide groups with at least this many children",
    ),
  }
  let args = match
    @cli.parse(args_spec, prog="render", description="MoonBit Ray Tracer") {
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
  let parsed_scene = @lib.parse_scene_file(scene_path) catch {
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
  let draft = args.flag("draft")
  let w_override = args.int("width")
  let h_override = args.int("height")
  let s_override = args.int("samples")
  let mut target_w = settings.width
  let mut target_h = settings.height
  if draft {
    // Prefer fast iteration defaults.
    // Only auto-adjust resolution when the user hasn't explicitly overridden it.
    if w_override <= 0 && h_override <= 0 {
      let max_w = 640
      let max_h = 360
      let sw = settings.width.to_double()
      let sh = settings.height.to_double()
      let mut scale = max_w.to_double() / sw
      let scale_h = max_h.to_double() / sh
      if scale_h < scale {
        scale = scale_h
      }
      if scale < 1.0 {
        let nw = (sw * scale).to_int()
        let nh = (sh * scale).to_int()
        target_w = if nw < 1 { 1 } else { nw }
        target_h = if nh < 1 { 1 } else { nh }
      }
    }

    // Only force low samples when the user hasn't explicitly overridden it.
    if s_override <= 0 {
      settings.samples = 1
    }

    // Cap bounces for speed (never increases the scene's requested bounces).
    if settings.max_bounces > 2 {
      settings.max_bounces = 2
    }
  }
  if w_override > 0 {
    target_w = w_override
  }
  if h_override > 0 {
    target_h = h_override
  }
  if target_w != settings.width || target_h != settings.height {
    settings.width = target_w
    settings.height = target_h
    camera = @lib.camera(settings.width, settings.height, camera.field_of_view)
    camera.transform = parsed_scene.camera.transform
  }
  if s_override > 0 {
    settings.samples = s_override
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
  if args.flag("debug") {
    println("--- debug: parsed scene summary ---")
    fn dump_shape(s : @lib.Shape, indent : String) -> Unit {
      println("\{indent}id=\{s.id} kind=\{s.object}")
      println(
        "\{indent}  material: mode=\{s.material.lighting_mode} color=\{s.material.color}",
      )
      println(
        "\{indent}  material: ambient=\{s.material.ambient} diffuse=\{s.material.diffuse} specular=\{s.material.specular} shininess=\{s.material.shininess}",
      )
      println(
        "\{indent}  material: metallic=\{s.material.metallic} metallic_pattern=\{s.material.metallic_pattern}",
      )
      println(
        "\{indent}  material: roughness=\{s.material.roughness} roughness_pattern=\{s.material.roughness_pattern}",
      )
      println("\{indent}  material: pattern=\{s.material.pattern}")
      println(
        "\{indent}  material: normal_pattern=\{s.material.normal_pattern} normal_strength=\{s.material.normal_strength}",
      )
      println(
        "\{indent}  material: displacement_pattern=\{s.material.displacement_pattern} displacement_strength=\{s.material.displacement_strength}",
      )
      println(
        "\{indent}  material: normal_texture=\{s.material.normal_texture} normal_texture_scale=\{s.material.normal_texture_scale} normal_texture_texcoord=\{s.material.normal_texture_texcoord}",
      )
      match s.object {
        Group(g) => {
          println("\{indent}  children: \{g.children.length()}")
          let next = indent + "    "
          for child in g.children {
            dump_shape(child, next)
          }
        }
        _ => ()
      }
    }

    println("name: \"\{parsed_scene.metadata.name}\"")
    println("scene: \"\{scene_path}\"")
    println("resolution: \{settings.width}x\{settings.height}")
    println("samples: \{settings.samples}")
    println("lights: \{world.lights.length()}")
    println("shapes: \{world.shapes.length()}")
    for i in 0..<world.shapes.length() {
      println("shape[\{i}]:")
      dump_shape(world.shapes[i], "  ")
    }
    println("--- debug: end ---")
  }

  // TODO: Implement multi-sampling if settings.samples > 1
  println("Rendering \{parsed_scene.metadata.name}...")
  println("Resolution: \{settings.width}x\{settings.height}")
  println("Samples: \{settings.samples}")
  let stats_enabled = args.flag("stats")
  if stats_enabled {
    world.stats_enabled = true
    world.stats = @lib.render_stats()
  }
  async fn write_progress(msg : String) -> Unit {
    // Best-effort terminal output; ignore failures.
    @stdio.stdout.write(msg) catch {
      _ => ()
    }
  }

  let canvas = camera.render(
    world,
    samples=settings.samples,
    max_bounces=settings.max_bounces,
    progress=async fn(y) {
      if y % 10 == 0 || y == settings.height {
        let pct = y.to_double() * 100.0 / settings.height.to_double()
        let msg = "\rProgress: \{pct.to_int()}% (\{y}/\{settings.height})"
        write_progress(msg)
        if y == settings.height {
          write_progress("\n")
        }
      }
    },
  )
  canvas.use_tone_mapping = true

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
  if stats_enabled {
    println(
      world.stats.summary(settings.width, settings.height, settings.samples),
    )
  }
  println("Done.")
}
