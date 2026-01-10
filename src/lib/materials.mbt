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
    metallic: self.metallic,
    roughness: self.roughness,
    lighting_mode: self.lighting_mode,
  }
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
  let clr = match (self.pattern, shape) {
    (Some(pattern), Some(shape)) =>
      pattern.pattern_at_shape(shape, position, normal=normalv, uv?)
    _ => self.color
  }
  match self.lighting_mode {
    Phong => {
      if in_shadow {
        return color(0, 0, 0)
      }
      let effective_color = clr * light.intensity
      let lightv = (light.position - position).normalize()
      let light_dot_normal = lightv.dot(normalv)
      let mut diffuse = color(0, 0, 0)
      let mut specular = color(0, 0, 0)
      if light_dot_normal >= 0 {
        diffuse = effective_color.mul_scalar(self.diffuse * light_dot_normal)
        let reflectv = (-lightv).reflect(normalv)
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
      let n_dot_l = @cmp.maximum(normalv.dot(lightv), 0.0)
      if n_dot_l <= 0.0 {
        return color(0, 0, 0)
      }
      let n_dot_v = @cmp.maximum(normalv.dot(eyev), 0.0)
      let h_dot_v = @cmp.maximum(halfv.dot(eyev), 0.0)
      let mut f0 = color(0.04, 0.04, 0.04)
      f0 = f0 * color(1.0, 1.0, 1.0).mul_scalar(1.0 - self.metallic) +
        clr.mul_scalar(self.metallic)
      let ndf = distribution_ggx(normalv, halfv, self.roughness)
      let g = geometry_smith(normalv, eyev, lightv, self.roughness)
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
