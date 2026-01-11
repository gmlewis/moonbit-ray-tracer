///|
const MAX_BOUNCES = 4

///|
pub(all) struct World {
  mut shapes : Array[Shape]
  mut lights : Array[Light]
  mut background : Color
  mut environment_map : Pattern?
}

///|
pub fn world() -> World {
  let shapes = []
  let lights = []
  let background = color(0, 0, 0)
  let environment_map = None
  { shapes, lights, background, environment_map }
}

///|
pub fn default_world() -> World {
  let s1 = sphere()
  s1.material.color = color(0.8, 1, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2
  let s2 = {
    let s = sphere()
    s.set_transform(scaling(0.5, 0.5, 0.5))
    s
  }
  let shapes = [s1, s2]
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  let lights = [light]
  let background = color(0, 0, 0)
  let environment_map = None
  { shapes, lights, background, environment_map }
}

///|
pub fn World::intersect_world(self : World, ray : Ray) -> Intersections {
  let xs = []
  for obj in self.shapes {
    let x = obj.intersect(ray)
    xs.append(x.xs)
  }
  intersections(xs)
}

///|
pub fn World::shade_hit(
  self : World,
  comps : Computations,
  remaining? : Int = MAX_BOUNCES,
) -> Color {

  // Get surface color including pattern
  let uv = if comps.has_uv { Some((comps.uv_u, comps.uv_v)) } else { None }
  let clr = match (comps.shape.material.pattern, Some(comps.shape)) {
    (Some(pattern), Some(shape)) =>
      pattern.pattern_at_shape(shape, comps.point, normal=comps.normalv, uv?)
    _ => comps.shape.material.color
  }

  // Add ambient light from environment map or background
  let (ambient_diffuse, ambient_specular) = match self.environment_map {
    Some(env) => {
      let (u_diff, v_diff) = spherical_map(comps.normalv)
      let (u_spec, v_spec) = spherical_map(comps.reflectv)
      (env.uv_at(u_diff, v_diff), env.uv_at(u_spec, v_spec))
    }
    None => (self.background, self.background)
  }
  let material = comps.shape.material
  let mut surface = if material.lighting_mode == PBR {
    let n_dot_v = @cmp.maximum(comps.normalv.dot(comps.eyev), 0.0)
    let mut f0 = color(0.04, 0.04, 0.04)
    f0 = f0 * color(1.0, 1.0, 1.0).mul_scalar(1.0 - material.metallic) +
      clr.mul_scalar(material.metallic)

    // Fresnel Schlick for IBL
    let f = f0 +
      (color(1.0, 1.0, 1.0) - f0).mul_scalar(@math.pow(1.0 - n_dot_v, 5.0))
    let ks = f
    let mut kd = color(1.0, 1.0, 1.0) - ks
    kd = kd.mul_scalar(1.0 - material.metallic)
    let diffuse_ibl = clr * ambient_diffuse * kd
    // For rough materials, we should ideally use a blurred environment map.
    // As a simple approximation, we blend between specular and diffuse IBL based on roughness.
    let specular_ibl = ambient_specular.mul_scalar(1.0 - material.roughness) +
      ambient_diffuse.mul_scalar(material.roughness)
    let specular_ibl = specular_ibl * ks

    // Ambient property scales the whole IBL. If it's 0, use a small default for PBR.
    let ambient_scale = if material.ambient == 0 {
      0.1
    } else {
      material.ambient
    }
    (diffuse_ibl + specular_ibl).mul_scalar(ambient_scale)
  } else {
    color(0, 0, 0)
  }
  for light in self.lights {
    let mut light_sum = color(0, 0, 0)
    let ambient = if material.lighting_mode == Phong {
      clr * light.intensity.mul_scalar(comps.shape.material.ambient)
    } else {
      color(0, 0, 0)
    }
    match light.kind {
      Point => {
        let in_shadow = self.is_shadowed(comps.over_point, light.position)
        light_sum = comps.shape.material.lighting(
          light,
          comps.point,
          comps.eyev,
          comps.normalv,
          in_shadow~,
          shape=Some(comps.shape),
          uv?,
        )
      }
      Area(_, u_steps, _, v_steps) => {
        for v in 0..<v_steps {
          for u in 0..<u_steps {
            let light_pos = light.point_at(u, v)
            let in_shadow = self.is_shadowed(comps.over_point, light_pos)

            // Temporarily use a fake light for the sample position
            let sample_light = {
              position: light_pos,
              intensity: light.intensity,
              kind: Point,
            }
            light_sum = light_sum +
              comps.shape.material.lighting(
                sample_light,
                comps.point,
                comps.eyev,
                comps.normalv,
                in_shadow~,
                shape=Some(comps.shape),
                uv?,
              )
          }
        }
        light_sum = light_sum.mul_scalar(1.0 / light.samples().to_double())
      }
    }
    surface = surface + ambient + light_sum
  }
  let reflected = self.reflected_color(comps, remaining)
  let refracted = self.refracted_color(comps, remaining)
  let material = comps.shape.material
  if material.reflective > 0 && material.transparency > 0 {
    let reflectance = comps.schlick()
    (surface +
    reflected.mul_scalar(reflectance) +
    refracted.mul_scalar(1.0 - reflectance)).clamp_valid()
  } else {
    (surface + reflected + refracted).clamp_valid()
  }
}

///|
pub fn World::color_at(
  self : World,
  ray : Ray,
  remaining? : Int = MAX_BOUNCES,
) -> Color {
  let xs = self.intersect_world(ray)
  let hit = match xs.hit() {
    None =>
      match self.environment_map {
        Some(env) => {
          // Map ray direction to UV
          let (u, v) = spherical_map(ray.direction)
          return env.uv_at(u, v)
        }
        None => return self.background
      }
    Some(hit) => hit
  }
  let comps = hit.prepare_computations(ray, xs~)
  self.shade_hit(comps, remaining~)
}

///|
pub fn World::is_shadowed(
  self : World,
  point : Tuple,
  light_pos : Tuple,
) -> Bool {
  let v = light_pos - point
  let distance = v.magnitude()
  let direction = v.normalize()
  let r = ray(point, direction)
  let xs = self.intersect_world(r)
  let h = xs.hit()
  match h {
    Some(hit) => hit.t < distance - 0.0001
    _ => false
  }
}

///|
fn pseudo_random_vector(p : Tuple) -> Tuple {
  let x = @math.sin(p.x * 12.9898 + p.y * 78.233 + p.z * 37.719) * 43758.5453
  let x = x - x.floor()
  let y = @math.sin(p.x * 39.346 + p.y * 11.135 + p.z * 83.221) * 43758.5453
  let y = y - y.floor()
  let z = @math.sin(p.x * 73.156 + p.y * 52.234 + p.z * 21.337) * 43758.5453
  let z = z - z.floor()
  vector(x * 2.0 - 1.0, y * 2.0 - 1.0, z * 2.0 - 1.0)
}

///|
pub fn World::reflected_color(
  self : World,
  comps : Computations,
  remaining : Int,
) -> Color {
  let material = comps.shape.material
  let mut reflective = material.reflective

  // For PBR materials, they are inherently reflective.
  // If reflective is not set, we use a default based on metallic property.
  if material.lighting_mode == PBR && reflective == 0 {
    reflective = 0.04 + 0.96 * material.metallic
  }
  if remaining <= 0 || reflective == 0 {
    return color(0, 0, 0)
  }
  let mut reflect_dir = comps.reflectv
  if material.lighting_mode == PBR && material.roughness > 0 {
    let jitter = pseudo_random_vector(comps.point).mul_scalar(
      material.roughness * material.roughness,
    )
    reflect_dir = (reflect_dir + jitter).normalize()
  }
  let reflect_ray = ray(comps.over_point, reflect_dir)
  let reflected = self.color_at(reflect_ray, remaining=remaining - 1)
  if material.lighting_mode == PBR {
    let n_dot_v = @cmp.maximum(comps.normalv.dot(comps.eyev), 0.0)
    let mut f0 = color(0.04, 0.04, 0.04)
    let uv = if comps.has_uv { Some((comps.uv_u, comps.uv_v)) } else { None }
    let clr = match (material.pattern, Some(comps.shape)) {
      (Some(pattern), Some(shape)) =>
        pattern.pattern_at_shape(shape, comps.point, uv?)
      _ => material.color
    }
    f0 = f0 * color(1.0, 1.0, 1.0).mul_scalar(1.0 - material.metallic) +
      clr.mul_scalar(material.metallic)
    let f = f0 +
      (color(1.0, 1.0, 1.0) - f0).mul_scalar(@math.pow(1.0 - n_dot_v, 5.0))

    // For PBR, reflective scales the overall reflection contribution
    return reflected * f.mul_scalar(reflective)
  }
  if material.metallic > 0 {
    // Tint reflection by material color for metals
    let tint = material.color.mul_scalar(material.metallic) +
      color(1, 1, 1).mul_scalar(1.0 - material.metallic)
    return (reflected * tint).mul_scalar(reflective)
  }
  reflected.mul_scalar(reflective)
}

///|
pub fn World::refracted_color(
  self : World,
  comps : Computations,
  remaining : Int,
) -> Color {
  if remaining <= 0 || comps.shape.material.transparency == 0 {
    return color(0, 0, 0)
  }
  // find the ratio of first index of refraction to the second
  let n_ratio = comps.n1 / comps.n2
  // cos(theta_i) is the same as the dot product  of the two vectors
  let cos_i = comps.eyev.dot(comps.normalv)
  // find sin(theta_t)^2 via trigonometric identity
  let sin2_t = n_ratio * n_ratio * (1.0 - cos_i * cos_i)
  if sin2_t > 1 {
    return color(0, 0, 0)
  }

  // Find cos(theta_t) via trigonometric identity
  let cos_t = (1.0 - sin2_t).sqrt()
  // Compute the direction of the refracted ray
  let direction = comps.normalv.mul_scalar(n_ratio * cos_i - cos_t) -
    comps.eyev.mul_scalar(n_ratio)
  // Created the refracted ray
  let refract_ray = ray(comps.under_point, direction)
  // Find the color of the refracted ray, making sure to multiply
  // by the transparency value to account for any opacity
  self
  .color_at(refract_ray, remaining=remaining - 1)
  .mul_scalar(comps.shape.material.transparency)
}
