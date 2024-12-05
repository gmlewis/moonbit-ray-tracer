///|
pub(all) struct World {
  objects : Array[Sphere]
  lights : Array[Light]
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
