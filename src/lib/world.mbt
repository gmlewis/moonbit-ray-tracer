///|
pub(all) struct World {
  mut objects : Array[Shape]
  mut lights : Array[Light]
}

///|
pub fn world() -> World {
  let objects = []
  let lights = []
  { objects, lights }
}

///|
pub fn default_world() -> World {
  let s1 = sphere()
  s1.material.color = color(0.8, 1, 0.6)
  s1.material.diffuse = 0.7
  s1.material.specular = 0.2
  let s2 = sphere()..set_transform(scaling(0.5, 0.5, 0.5))
  let objects = [s1, s2]
  let light = point_light(point(-10, 10, -10), color(1, 1, 1))
  let lights = [light]
  { objects, lights }
}

///|
pub fn intersect_world(self : World, ray : Ray) -> Intersections {
  let xs = []
  for obj in self.objects {
    let x = obj.intersect(ray)
    xs.append(x.xs)
  }
  intersections(xs)
}

///|
pub fn shade_hit(self : World, comps : Computations) -> Color {
  let mut red = 0.0
  let mut green = 0.0
  let mut blue = 0.0
  for light in self.lights {
    let in_shadow = self.is_shadowed(comps.over_point, light~)
    let c = comps.object.material.lighting(
      light,
      comps.point,
      comps.eyev,
      comps.normalv,
      in_shadow~,
    )
    red += c.red
    green += c.green
    blue += c.blue
  }
  color(red, green, blue)
}

///|
pub fn color_at(self : World, ray : Ray) -> Color {
  let xs = self.intersect_world(ray)
  let hit = match xs.hit() {
    None => return color(0, 0, 0)
    Some(hit) => hit
  }
  let comps = hit.prepare_computations(ray)
  self.shade_hit(comps)
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
