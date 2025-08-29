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
  }
}

///|
pub fn lighting(
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
  // combine the surface color with the light's color/intensity
  let effective_color = clr * light.intensity
  // find the direction to the light source
  let lightv = (light.position - position).normalize()
  // compute the ambient contribution
  let ambient = effective_color.mul_scalar(self.ambient)
  if in_shadow {
    return ambient
  }

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
      let factor = my_pow(reflect_dot_eye, self.shininess)
      specular = light.intensity.mul_scalar(self.specular * factor)
    }
  }
  ambient + diffuse + specular
}
