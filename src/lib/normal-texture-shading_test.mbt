///|
// Regression: verifies that glTF/GLB `material.normalTexture` is not only parsed,
// but also wired into shading so it measurably perturbs the resulting color.

///|
fn find_normal_texture(s : Shape) -> (Pattern, Double)? {
  match s.material.normal_texture {
    Some(p) => Some((p.clone(), s.material.normal_texture_scale))
    None =>
      match s.object {
        Group(g) => {
          for child in g.children {
            match find_normal_texture(child) {
              Some(v) => return Some(v)
              None => ()
            }
          }
          None
        }
        CSG(csg) =>
          match find_normal_texture(csg.left) {
            Some(v) => Some(v)
            None => find_normal_texture(csg.right)
          }
        _ => None
      }
  }
}

///|
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

///|
async test "GLB normalTexture affects shading" {
  let shape = load_gltf_file("examples/assets/CompareNormal.glb") catch {
    e => abort("failed to load CompareNormal.glb: \{e}")
  }
  let (nt, nt_scale) = match find_normal_texture(shape) {
    Some(v) => v
    None => abort("expected CompareNormal.glb to contain a normalTexture")
  }
  let base = material()
  base.lighting_mode = Phong
  base.color = color(1.0, 1.0, 1.0)
  base.ambient = 0.0
  base.diffuse = 1.0
  base.specular = 0.0
  let with_nm = base.clone()
  with_nm.normal_texture = Some(nt)
  with_nm.normal_texture_scale = nt_scale
  let w = world()
  w.lights.push(point_light(point(0, 0, -10), color(1, 1, 1)))
  w.shapes.push(shape)
  // Aim a ray through the model's bounds center; glTF samples are not
  // guaranteed to be centered at the origin.
  let b = w.shapes[0].bounds()
  let cx = (b.min.x + b.max.x) * 0.5
  let cy = (b.min.y + b.max.y) * 0.5
  let cz = (b.min.z + b.max.z) * 0.5
  let padx = b.width() * 2.0 + 1.0
  let pady = b.height() * 2.0 + 1.0
  let padz = b.depth() * 2.0 + 1.0
  let candidates : Array[Ray] = []
  let fracs = [0.25, 0.5, 0.75]
  for fx in fracs {
    for fy in fracs {
      let x = b.min.x + b.width() * fx
      let y = b.min.y + b.height() * fy
      candidates.push(ray(point(x, y, b.min.z - padz), vector(0, 0, 1)))
      candidates.push(ray(point(x, y, b.max.z + padz), vector(0, 0, -1)))
    }
  }

  // Add a few axis rays as a fallback.
  candidates.push(ray(point(cx, cy, b.min.z - padz), vector(0, 0, 1)))
  candidates.push(ray(point(cx, cy, b.max.z + padz), vector(0, 0, -1)))
  candidates.push(ray(point(b.min.x - padx, cy, cz), vector(1, 0, 0)))
  candidates.push(ray(point(b.max.x + padx, cy, cz), vector(-1, 0, 0)))
  candidates.push(ray(point(cx, b.min.y - pady, cz), vector(0, 1, 0)))
  candidates.push(ray(point(cx, b.max.y + pady, cz), vector(0, -1, 0)))

  // Keep only rays that actually hit *and* carry UVs.
  let rays : Array[Ray] = []
  for r in candidates {
    let xs = w.intersect_world(r)
    match xs.hit() {
      Some(h) => {
        let comps = h.prepare_computations(r, xs~)
        if comps.has_uv {
          rays.push(r)
        }
      }
      None => ()
    }
  }
  assert_true(rays.length() > 0)

  // Baseline: no normal texture.
  apply_material(w.shapes[0], base)
  let c0s = rays.map(fn(r) { w.color_at(r) })

  // With normal texture: should perturb lighting via tangent-space normal.
  apply_material(w.shapes[0], with_nm)
  let c1s = rays.map(fn(r) { w.color_at(r) })
  let mut any_changed = false
  for i in 0..<c0s.length() {
    let c0 = c0s[i]
    let c1 = c1s[i]
    let dr = (c0.red - c1.red).abs()
    let dg = (c0.green - c1.green).abs()
    let db = (c0.blue - c1.blue).abs()
    let dmax = @cmp.maximum(dr, @cmp.maximum(dg, db))
    if dmax > 1.0e-4 {
      any_changed = true
      break
    }
  }
  assert_true(any_changed)
}
