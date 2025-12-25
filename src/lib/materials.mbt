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
fn geometry_smith(n : Tuple, v : Tuple, l : Tuple, roughness : Double) -> Double {
  let n_dot_v = @cmp.maximum(n.dot(v), 0.0)
  let n_dot_l = @cmp.maximum(n.dot(l), 0.0)
  let ggx2 = geometry_schlick_ggx(n_dot_v, roughness)
  let ggx1 = geometry_schlick_ggx(n_dot_l, roughness)
  ggx1 * ggx2
}

///|
fn fresnel_schlick(cos_theta : Double, f0 : Color) -> Color {
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
) -> Color {
  let clr = match (self.pattern, shape) {
    (Some(pattern), Some(shape)) => pattern.pattern_at_shape(shape, position)
    _ => self.color
  }

  // Find the direction to the light source
  let lightv = (light.position - position).normalize()
  let halfv = (eyev + lightv).normalize()

  // Dot products
  let n_dot_v = @cmp.maximum(normalv.dot(eyev), 0.0)
  let n_dot_l = @cmp.maximum(normalv.dot(lightv), 0.0)
  let h_dot_v = @cmp.maximum(halfv.dot(eyev), 0.0)

  // Fresnel at zero incidence
  let mut f0 = color(0.04, 0.04, 0.04)
  f0 = f0 * (color(1.0, 1.0, 1.0).mul_scalar(1.0 - self.metallic)) + clr.mul_scalar(self.metallic)

  // Ambient component (Whitted compatibility)
  let ambient = clr.mul_scalar(self.ambient) * light.intensity
  if in_shadow {
    return ambient
  }

  if n_dot_l <= 0.0 {
    return ambient
  }

  // Cook-Torrance BRDF components
  let ndf = distribution_ggx(normalv, halfv, self.roughness)
  let g = geometry_smith(normalv, eyev, lightv, self.roughness)
  let f = fresnel_schlick(h_dot_v, f0)

  let numerator = f.mul_scalar(ndf * g)
  let denominator = 4.0 * n_dot_v * n_dot_l + 0.0001
  let specular_brdf = numerator.mul_scalar(1.0 / denominator)

  // Energy conservation
  let ks = f
  let mut kd = color(1.0, 1.0, 1.0) - ks
  kd = kd.mul_scalar(1.0 - self.metallic)

  // Final color
  let diffuse_part = clr.mul_scalar(1.0 / @math.PI) * kd
  let brdf = diffuse_part + specular_brdf
  
  ambient + brdf * light.intensity.mul_scalar(n_dot_l)
}
