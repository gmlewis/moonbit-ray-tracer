///|
const MAX_BOUNCES = 4

///|
pub(all) struct World {
  mut shapes : Array[Shape]
  mut lights : Array[Light]
}

///|
pub fn world() -> World {
  let shapes = []
  let lights = []
  { shapes, lights }
}

///|
pub fn default_world() -> World {
  let s1 = sphere()
  s1.material.color = color(0.8, 1, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2
  let s2 = sphere()..set_transform(scaling(0.5, 0.5, 0.5))
  let shapes = [s1, s2]
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  let lights = [light]
  { shapes, lights }
}

///|
pub fn intersect_world(self : World, ray : Ray) -> Intersections {
  let xs = []
  for obj in self.shapes {
    let x = obj.intersect(ray)
    xs.append(x.xs)
  }
  intersections(xs)
}

///|
pub fn shade_hit(
  self : World,
  comps : Computations,
  remaining~ : Int = MAX_BOUNCES
) -> Color {
  let mut c = color(0, 0, 0)
  for light in self.lights {
    let in_shadow = self.is_shadowed(comps.over_point, light~)
    let surface = comps.shape.material.lighting(
      light,
      comps.point,
      comps.eyev,
      comps.normalv,
      in_shadow~,
      shape=Some(comps.shape),
    )
    let reflected = self.reflected_color(comps, remaining)
    let refracted = self.refracted_color(comps, remaining)
    let material = comps.shape.material
    if material.reflective > 0 && material.transparency > 0 {
      let reflectance = comps.schlick()
      c = c +
        surface +
        reflected.mul_scalar(reflectance) +
        refracted.mul_scalar(1.0 - reflectance)
    } else {
      c = c + surface + reflected + refracted
    }
  }
  c
}

///|
pub fn color_at(
  self : World,
  ray : Ray,
  remaining~ : Int = MAX_BOUNCES
) -> Color {
  let xs = self.intersect_world(ray)
  let hit = match xs.hit() {
    None => return color(0, 0, 0)
    Some(hit) => hit
  }
  let comps = hit.prepare_computations(ray, xs~)
  self.shade_hit(comps, remaining~)
}

///|
pub fn is_shadowed(
  self : World,
  point : Tuple,
  light~ : Light = self.lights[0]
) -> Bool {
  let v = light.position - point
  let distance = v.magnitude()
  let direction = v.normalize()
  let r = ray(point, direction)
  let xs = self.intersect_world(r)
  let h = xs.hit()
  match h {
    Some(hit) => hit.t < distance
    _ => false
  }
}

///|
pub fn reflected_color(
  self : World,
  comps : Computations,
  remaining : Int
) -> Color {
  let reflective = comps.shape.material.reflective
  if remaining <= 0 || reflective == 0 {
    return color(0, 0, 0)
  }

  //
  let reflect_ray = ray(comps.over_point, comps.reflectv)
  self.color_at(reflect_ray, remaining=remaining - 1).mul_scalar(reflective)
}

///|
pub fn refracted_color(
  self : World,
  comps : Computations,
  remaining : Int
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
