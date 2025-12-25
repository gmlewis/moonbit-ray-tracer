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
    
      match self.lighting_mode {
        Phong => {
          if in_shadow {
            return color(0, 0, 0)
          }
          // combine the surface color with the light's color/intensity
          let effective_color = clr * light.intensity
          // find the direction to the light source
          let lightv = (light.position - position).normalize()
          // light_dot_normal represents the cosine of the angle between the
          // light vector and the normal vector. A negative number means the
          // light is on the other side of the surface.
          let light_dot_normal = lightv.dot(normalv)
          let mut diffuse = color(0, 0, 0)
          let mut specular = color(0, 0, 0)
          if light_dot_normal >= 0 {
            // compute the diffuse contribution
            diffuse = effective_color.mul_scalar(self.diffuse * light_dot_normal)
            // reflect_dot_eye represents the cosine of the angle between the
            // reflection vector and the eye vector. A negative number means the
            // light reflects away from the eye.
            let reflectv = (-lightv).reflect(normalv)
            let reflect_dot_eye = reflectv.dot(eyev)
            if reflect_dot_eye >= 0 {
              // compute the specular contribution
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
          // Find the direction to the light source
          let lightv = (light.position - position).normalize()
          let halfv = (eyev + lightv).normalize()
    
          // Dot products
          let n_dot_l = @cmp.maximum(normalv.dot(lightv), 0.0)
          if n_dot_l <= 0.0 {
            return color(0, 0, 0)
          }
          let n_dot_v = @cmp.maximum(normalv.dot(eyev), 0.0)
          let h_dot_v = @cmp.maximum(halfv.dot(eyev), 0.0)
    
          // Fresnel at zero incidence
          let mut f0 = color(0.04, 0.04, 0.04)
          f0 = f0 * (color(1.0, 1.0, 1.0).mul_scalar(1.0 - self.metallic)) +
            clr.mul_scalar(self.metallic)
    
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
          let diffuse_brdf = clr * kd // Omit 1/PI for "classic" brightness
          let brdf = diffuse_brdf + specular_brdf
          
          // Use double intensity for better visibility
          let effective_intensity = light.intensity.mul_scalar(2.0)
          
          brdf * effective_intensity.mul_scalar(n_dot_l)
        }
      }
    }
