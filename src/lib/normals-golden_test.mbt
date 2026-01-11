///|
// Golden normals probe: exercises GLB mesh loading + intersection, and checks
// that procedural height→normal bump still affects shading on a real mesh.

///|
async test "Golden normals probe (GLB mesh)" {
  let shape = load_gltf_file("examples/assets/BoxTextured.glb") catch {
    e => abort("failed to load BoxTextured.glb: \{e}")
  }

  // Force a deterministic Phong material so changes in mesh glTF materials
  // don't affect this regression.
  let m = material()
  m.lighting_mode = Phong
  m.color = color(1.0, 1.0, 1.0)
  m.ambient = 0.0
  m.diffuse = 1.0
  m.specular = 0.0
  m.normal_pattern = Some(golden_rampx_pattern())

  // Apply material to the whole loaded hierarchy.
  fn apply_material(s : Shape, mat : Material) -> Unit {
    s.material = mat.clone()
    match s.object {
      Group(g) =>
        for child in g.children {
          apply_material(child, mat)
        }
      CSG(csg) => {
        apply_material(csg.left, mat)
        apply_material(csg.right, mat)
      }
      _ => ()
    }
  }

  fn set_normal_strength(s : Shape, strength : Double) -> Unit {
    s.material.normal_strength = strength
    match s.object {
      Group(g) =>
        for child in g.children {
          set_normal_strength(child, strength)
        }
      CSG(csg) => {
        set_normal_strength(csg.left, strength)
        set_normal_strength(csg.right, strength)
      }
      _ => ()
    }
  }

  apply_material(shape, m)
  let w = world()
  w.lights.push(point_light(point(0, 0, -10), color(1, 1, 1)))
  w.shapes.push(shape)

  // A simple ray aimed at the origin; this should hit the box and produce UVs.
  let r = ray(point(0, 0, -5), vector(0, 0, 1))
  let xs = w.intersect_world(r)
  let hit = match xs.hit() {
    Some(h) => h
    None => abort("expected ray to hit loaded GLB mesh")
  }
  let comps = hit.prepare_computations(r, xs~)

  // Ensure UVs are present on the hit (mesh+UV path).
  assert_true(comps.has_uv)
  assert_true(!comps.uv_u.is_nan() && !comps.uv_u.is_inf())
  assert_true(!comps.uv_v.is_nan() && !comps.uv_v.is_inf())

  // Baseline: bump disabled.
  set_normal_strength(w.shapes[0], 0.0)
  let c0 = w.color_at(r)

  // Bumped: strong enough to be unambiguous.
  set_normal_strength(w.shapes[0], 50.0)
  let c1 = w.color_at(r)

  // Bump should perturb the normal enough to change the computed color.
  assert_true(c0 != c1)
  let dr = (c0.red - c1.red).abs()
  let dg = (c0.green - c1.green).abs()
  let db = (c0.blue - c1.blue).abs()
  let dmax = @cmp.maximum(dr, @cmp.maximum(dg, db))
  assert_true(dmax > 1.0e-4)
}

///|
// A simple height field: grayscale ramps with +x.
struct GoldenRampX {}

///|
impl PatternTrait for GoldenRampX with clone(_self) {
  golden_rampx_pattern()
}

///|
impl Show for GoldenRampX with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn golden_rampx_pattern() -> Pattern {
  Pattern::new(GoldenRampX::{  })
}

///|
impl PatternTrait for GoldenRampX with pattern_at(_self, p) {
  let t = p.x * 0.5 + 0.5
  let t = if t < 0.0 { 0.0 } else if t > 1.0 { 1.0 } else { t }
  color(t, t, t)
}

///|
impl PatternTrait for GoldenRampX with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
impl PatternTrait for GoldenRampX with pattern_at_with_info(self, p, _n, uv) {
  // Intentionally ignore UV here: the current procedural bump code samples
  // nearby points in space but reuses the same UV, so a UV-driven height
  // field would have zero slope and appear flat.
  let _ = uv
  self.pattern_at(p)
}
