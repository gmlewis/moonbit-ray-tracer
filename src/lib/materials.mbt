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
    metallic: self.metallic,
    roughness: self.roughness,
    lighting_mode: self.lighting_mode,
  }
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
  let eps = 1.0e-2
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
    let v = 0.2126 * c.red + 0.7152 * c.green + 0.0722 * c.blue
    if v < 0.0 {
      0.0
    } else if v > 1.0 {
      1.0
    } else {
      v
    }
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
  uv? : (Double, Double),
) -> Color {
  // Use geometric normal by default for pattern evaluation, and a potentially
  // bumped normal for shading. When a normal map is present, we also feed the
  // bumped normal into pattern evaluation so normal-aware patterns (e.g.
  // triplanar) can reflect the perturbation.
  let shading_normalv = match (self.normal_pattern, shape) {
    (Some(np), Some(shape)) =>
      bump_normal_from_pattern(
        np,
        self.normal_strength,
        shape,
        position,
        normalv,
        uv?,
      )
    _ => normalv
  }
  let pattern_normalv = match self.normal_pattern {
    Some(_) => shading_normalv
    None => normalv
  }
  let clr = match (self.pattern, shape) {
    (Some(pattern), Some(shape)) =>
      pattern.pattern_at_shape(shape, position, normal=pattern_normalv, uv?)
    _ => self.color
  }
  match self.lighting_mode {
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
        diffuse = effective_color.mul_scalar(self.diffuse * light_dot_normal)
        let reflectv = (-lightv).reflect(shading_normalv)
        let reflect_dot_eye = reflectv.dot(eyev)
        if reflect_dot_eye >= 0 {
          let factor = @math.pow(reflect_dot_eye, self.shininess)
          specular = light.intensity.mul_scalar(self.specular * factor)
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
      f0 = f0 * color(1.0, 1.0, 1.0).mul_scalar(1.0 - self.metallic) +
        clr.mul_scalar(self.metallic)
      let ndf = distribution_ggx(shading_normalv, halfv, self.roughness)
      let g = geometry_smith(shading_normalv, eyev, lightv, self.roughness)
      let f = fresnel_schlick(h_dot_v, f0)
      let numerator = f.mul_scalar(ndf * g)
      let denominator = 4.0 * n_dot_v * n_dot_l + 0.001
      let specular_brdf = numerator.mul_scalar(1.0 / denominator).clamp_valid()
      let ks = f
      let mut kd = color(1.0, 1.0, 1.0) - ks
      kd = kd.mul_scalar(1.0 - self.metallic)
      let diffuse_brdf = clr.mul_scalar(1.0 / @math.PI) * kd
      let brdf = diffuse_brdf + specular_brdf
      brdf * light.intensity.mul_scalar(n_dot_l)
    }
  }
}
