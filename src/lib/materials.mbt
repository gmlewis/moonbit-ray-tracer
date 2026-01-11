///|
pub(all) enum LightingMode {
  Phong
  PBR
} derive(Show, Eq)

///|
pub(all) struct Material {
  mut color : Color
  mut ambient : Double
  mut diffuse : Double
  mut specular : Double
  mut shininess : Double
  mut reflective : Double
  mut transparency : Double
  mut refractive_index : Double
  mut pattern : Pattern?
  mut normal_pattern : Pattern?
  mut normal_strength : Double
  mut displacement_pattern : Pattern?
  mut displacement_strength : Double
  mut normal_texture : Pattern?
  mut normal_texture_scale : Double
  mut normal_texture_texcoord : Int
  // Scene-only: optional material layering (resolved onto Shape).
  mut layer_material : String?
  mut layer_mask : String?
  mut layer_opacity : Double
  mut metallic : Double
  mut roughness : Double
  mut lighting_mode : LightingMode
} derive(Show, Eq)

///|
pub fn material() -> Material {
  let color = color(1, 1, 1)
  let ambient = 0.1
  let diffuse = 0.9
  let specular = 0.9
  let shininess = 200.0
  let reflective = 0.0
  let transparency = 0.0
  let refractive_index = 1.0
  let pattern = None
  let normal_pattern = None
  let normal_strength = 0.0
  let displacement_pattern = None
  let displacement_strength = 0.0
  let normal_texture = None
  let normal_texture_scale = 1.0
  let normal_texture_texcoord = 0
  let layer_material = None
  let layer_mask = None
  let layer_opacity = 1.0
  let metallic = 0.0
  let roughness = 0.5
  let lighting_mode = Phong
  {
    color,
    ambient,
    diffuse,
    specular,
    shininess,
    reflective,
    transparency,
    refractive_index,
    pattern,
    normal_pattern,
    normal_strength,
    displacement_pattern,
    displacement_strength,
    normal_texture,
    normal_texture_scale,
    normal_texture_texcoord,
    layer_material,
    layer_mask,
    layer_opacity,
    metallic,
    roughness,
    lighting_mode,
  }
}

///|
pub fn Material::clone(self : Material) -> Material {
  let pattern = match self.pattern {
    Some(p) => Some(p.clone())
    None => None
  }
  let normal_pattern = match self.normal_pattern {
    Some(p) => Some(p.clone())
    None => None
  }
  let displacement_pattern = match self.displacement_pattern {
    Some(p) => Some(p.clone())
    None => None
  }
  let normal_texture = match self.normal_texture {
    Some(p) => Some(p.clone())
    None => None
  }
  {
    color: self.color.clone(),
    ambient: self.ambient,
    diffuse: self.diffuse,
    specular: self.specular,
    shininess: self.shininess,
    reflective: self.reflective,
    transparency: self.transparency,
    refractive_index: self.refractive_index,
    pattern,
    normal_pattern,
    normal_strength: self.normal_strength,
    displacement_pattern,
    displacement_strength: self.displacement_strength,
    normal_texture,
    normal_texture_scale: self.normal_texture_scale,
    normal_texture_texcoord: self.normal_texture_texcoord,
    layer_material: self.layer_material,
    layer_mask: self.layer_mask,
    layer_opacity: self.layer_opacity,
    metallic: self.metallic,
    roughness: self.roughness,
    lighting_mode: self.lighting_mode,
  }
}

///|
pub(all) struct MaterialLayer {
  top : Material
  mask : Pattern
  opacity : Double
} derive(Show, Eq)

///|
fn get_shape_tangent_basis_world(shape : Shape) -> (Tuple, Tuple)? {
  match shape.object {
    TriangleUV(t) =>
      Some(
        (
          shape.object_to_world(t.tangent_u).normalize(),
          shape.object_to_world(t.tangent_v).normalize(),
        ),
      )
    SmoothTriangleUV(t) =>
      Some(
        (
          shape.object_to_world(t.tangent_u).normalize(),
          shape.object_to_world(t.tangent_v).normalize(),
        ),
      )
    _ => None
  }
}

///|
fn normal_from_texture(
  normal_texture : Pattern,
  scale : Double,
  shape : Shape,
  position : Tuple,
  base_normalv : Tuple,
  uv? : (Double, Double),
) -> Tuple {
  match uv {
    None => return base_normalv
    Some(_) => ()
  }
  let c = normal_texture.pattern_at_shape(
    shape,
    position,
    normal=base_normalv,
    uv?,
  )

  // glTF normalTexture encodes tangent-space normals as RGB in [0,1], where:
  // n = normalize(vec3(2*r-1, 2*g-1, 2*b-1)), and `scale` scales x/y.
  let mut tx = 2.0 * c.red - 1.0
  let mut ty = 2.0 * c.green - 1.0
  let tz = 2.0 * c.blue - 1.0
  tx *= scale
  ty *= scale
  let tn = vector(tx, ty, tz).normalize()

  // Tangent basis in world space (best effort). If missing, fall back to an
  // arbitrary orthonormal basis around the base normal.
  let (t0, b0) = match get_shape_tangent_basis_world(shape) {
    Some((tu, tv)) => (tu, tv)
    None => {
      let up = if base_normalv.y.abs() < 0.9 {
        vector(0, 1, 0)
      } else {
        vector(1, 0, 0)
      }
      let tu = base_normalv.cross(up).normalize()
      let tv = base_normalv.cross(tu).normalize()
      (tu, tv)
    }
  }

  // Orthonormalize T,B against the (possibly interpolated) base normal.
  let n = base_normalv.normalize()
  let t = (t0 - n.mul_scalar(n.dot(t0))).normalize()
  let b = (b0 - n.mul_scalar(n.dot(b0)) - t.mul_scalar(t.dot(b0))).normalize()

  // Tangent-to-world transform: worldN = normalize(T*tx + B*ty + N*tz)
  (t.mul_scalar(tn.x) + b.mul_scalar(tn.y) + n.mul_scalar(tn.z)).normalize()
}

///|
pub fn bump_normal_from_pattern(
  normal_pattern : Pattern,
  strength : Double,
  shape : Shape,
  position : Tuple,
  geometric_normalv : Tuple,
  uv? : (Double, Double),
) -> Tuple {
  if strength <= 0.0 {
    return geometric_normalv
  }
  // Tangent-space finite differences (in object space) give a much more
  // stable/visible bump effect on curved geometry than sampling along fixed
  // object axes.
  // Larger step makes the numerical gradient much more visible and less
  // likely to vanish due to extremely smooth / quantized height functions.
  let eps = 1.e-2
  let op = shape.world_to_object(position)
  let obj_normal = shape.world_normal_to_object(geometric_normalv)

  // Build an orthonormal tangent basis around the geometric normal.
  let up = if obj_normal.y.abs() < 0.9 {
    vector(0, 1, 0)
  } else {
    vector(1, 0, 0)
  }
  let tangent_u = obj_normal.cross(up).normalize()
  let tangent_v = obj_normal.cross(tangent_u).normalize()
  let p0 = position
  let pu = shape.object_to_world(
    point(
      op.x + tangent_u.x * eps,
      op.y + tangent_u.y * eps,
      op.z + tangent_u.z * eps,
    ),
  )
  let pv = shape.object_to_world(
    point(
      op.x + tangent_v.x * eps,
      op.y + tangent_v.y * eps,
      op.z + tangent_v.z * eps,
    ),
  )
  fn h(
    pat : Pattern,
    s : Shape,
    wp : Tuple,
    gn : Tuple,
    uv : (Double, Double)?,
  ) -> Double {
    let c = pat.pattern_at_shape(s, wp, normal=gn, uv?)
    // Simple luminance height.
    c.luminance()
  }

  let h0 = h(normal_pattern, shape, p0, geometric_normalv, uv)
  let hu = h(normal_pattern, shape, pu, geometric_normalv, uv)
  let hv = h(normal_pattern, shape, pv, geometric_normalv, uv)

  // Slope along tangents.
  let du = (hu - h0) / eps
  let dv = (hv - h0) / eps

  // Standard bump approximation: tilt the normal against the height slopes.
  let bumped_obj = (obj_normal -
  tangent_u.mul_scalar(du * strength) -
  tangent_v.mul_scalar(dv * strength)).normalize()
  shape.normal_to_world(bumped_obj)
}

///|
fn distribution_ggx(n : Tuple, h : Tuple, roughness : Double) -> Double {
  let a = roughness * roughness
  let a2 = a * a
  let n_dot_h = @cmp.maximum(n.dot(h), 0.0)
  let n_dot_h2 = n_dot_h * n_dot_h
  let nom = a2
  let denom = n_dot_h2 * (a2 - 1.0) + 1.0
  let denom = @math.PI * denom * denom
  nom / denom
}

///|
fn geometry_schlick_ggx(n_dot_v : Double, roughness : Double) -> Double {
  let r = roughness + 1.0
  let k = r * r / 8.0
  let nom = n_dot_v
  let denom = n_dot_v * (1.0 - k) + k
  nom / denom
}

///|
fn geometry_smith(
  n : Tuple,
  v : Tuple,
  l : Tuple,
  roughness : Double,
) -> Double {
  let n_dot_v = @cmp.maximum(n.dot(v), 0.0)
  let n_dot_l = @cmp.maximum(n.dot(l), 0.0)
  let ggx2 = geometry_schlick_ggx(n_dot_v, roughness)
  let ggx1 = geometry_schlick_ggx(n_dot_l, roughness)
  ggx1 * ggx2
}

///|
fn fresnel_schlick(cos_theta : Double, f0 : Color) -> Color {
  let cos_theta = if cos_theta < 0 {
    0.0
  } else if cos_theta > 1.0 {
    1.0
  } else {
    cos_theta
  }
  f0 + (color(1.0, 1.0, 1.0) - f0).mul_scalar(@math.pow(1.0 - cos_theta, 5.0))
}

///|
pub fn Material::lighting(
  self : Material,
  light : Light,
  position : Tuple,
  eyev : Tuple,
  normalv : Tuple,
  in_shadow? : Bool = false,
  shape? : Shape? = None,
  uv0? : (Double, Double),
  uv1? : (Double, Double),
) -> Color {
  fn lighting_core(
    mat : Material,
    light : Light,
    position : Tuple,
    eyev : Tuple,
    normalv : Tuple,
    in_shadow : Bool,
    shape : Shape?,
    uv0 : (Double, Double)?,
    uv1 : (Double, Double)?,
  ) -> Color {
    // Use geometric normal by default for pattern evaluation, and a potentially
    // bumped normal for shading. When a normal map is present, we also feed the
    // bumped normal into pattern evaluation so normal-aware patterns (e.g.
    // triplanar) can reflect the perturbation.
    let normal_uv = if mat.normal_texture_texcoord == 1 {
      match uv1 {
        Some(_) => uv1
        None => uv0
      }
    } else {
      uv0
    }
    let normalv = match (mat.normal_texture, shape) {
      (Some(nt), Some(shape)) => {
        let uv = normal_uv
        normal_from_texture(
          nt,
          mat.normal_texture_scale,
          shape,
          position,
          normalv,
          uv?,
        )
      }
      _ => normalv
    }
    let shading_normalv = match (mat.normal_pattern, shape) {
      (Some(np), Some(shape)) => {
        let uv = uv0
        bump_normal_from_pattern(
          np,
          mat.normal_strength,
          shape,
          position,
          normalv,
          uv?,
        )
      }
      _ => normalv
    }
    let pattern_normalv = match (mat.normal_pattern, mat.normal_texture) {
      (Some(_), _) => shading_normalv
      (_, Some(_)) => shading_normalv
      _ => normalv
    }
    let clr = match (mat.pattern, shape) {
      (Some(pattern), Some(shape)) => {
        let uv = uv0
        pattern.pattern_at_shape(shape, position, normal=pattern_normalv, uv?)
      }
      _ => mat.color
    }
    match mat.lighting_mode {
      Phong => {
        if in_shadow {
          return color(0, 0, 0)
        }
        let effective_color = clr * light.intensity
        let lightv = (light.position - position).normalize()
        let light_dot_normal = lightv.dot(shading_normalv)
        let mut diffuse = color(0, 0, 0)
        let mut specular = color(0, 0, 0)
        if light_dot_normal >= 0 {
          diffuse = effective_color.mul_scalar(mat.diffuse * light_dot_normal)
          let reflectv = (-lightv).reflect(shading_normalv)
          let reflect_dot_eye = reflectv.dot(eyev)
          if reflect_dot_eye >= 0 {
            let factor = @math.pow(reflect_dot_eye, mat.shininess)
            specular = light.intensity.mul_scalar(mat.specular * factor)
          }
        }
        diffuse + specular
      }
      PBR => {
        if in_shadow {
          return color(0, 0, 0)
        }
        let lightv = (light.position - position).normalize()
        let halfv = (eyev + lightv).normalize()
        let n_dot_l = @cmp.maximum(shading_normalv.dot(lightv), 0.0)
        if n_dot_l <= 0.0 {
          return color(0, 0, 0)
        }
        let n_dot_v = @cmp.maximum(shading_normalv.dot(eyev), 0.0)
        let h_dot_v = @cmp.maximum(halfv.dot(eyev), 0.0)
        let mut f0 = color(0.04, 0.04, 0.04)
        f0 = f0 * color(1.0, 1.0, 1.0).mul_scalar(1.0 - mat.metallic) +
          clr.mul_scalar(mat.metallic)
        let ndf = distribution_ggx(shading_normalv, halfv, mat.roughness)
        let g = geometry_smith(shading_normalv, eyev, lightv, mat.roughness)
        let f = fresnel_schlick(h_dot_v, f0)
        let numerator = f.mul_scalar(ndf * g)
        let denominator = 4.0 * n_dot_v * n_dot_l + 0.001
        let specular_brdf = numerator
          .mul_scalar(1.0 / denominator)
          .clamp_valid()
        let ks = f
        let mut kd = color(1.0, 1.0, 1.0) - ks
        kd = kd.mul_scalar(1.0 - mat.metallic)
        let diffuse_brdf = clr.mul_scalar(1.0 / @math.PI) * kd
        let brdf = diffuse_brdf + specular_brdf
        brdf * light.intensity.mul_scalar(n_dot_l)
      }
    }
  }

  // If the shape has a resolved material layer, blend base vs top lighting.
  match shape {
    Some(s) =>
      match s.material_layer {
        Some(layer) => {
          let uv = uv0
          let t0 = layer.mask
            .pattern_at_shape(s, position, normal=normalv, uv?)
            .luminance()
          let t = @cmp.minimum(@cmp.maximum(t0 * layer.opacity, 0.0), 1.0)
          let base_c = lighting_core(
            self, light, position, eyev, normalv, in_shadow, shape, uv0, uv1,
          )
          let top_c = lighting_core(
            layer.top,
            light,
            position,
            eyev,
            normalv,
            in_shadow,
            shape,
            uv0,
            uv1,
          )
          base_c + (top_c - base_c).mul_scalar(t)
        }
        None =>
          lighting_core(
            self, light, position, eyev, normalv, in_shadow, shape, uv0, uv1,
          )
      }
    None =>
      lighting_core(
        self, light, position, eyev, normalv, in_shadow, shape, uv0, uv1,
      )
  }
}
