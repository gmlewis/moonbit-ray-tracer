///| Sphere represents a sphere with radius 1.
pub(all) struct Sphere {
  transform : Matrix
  inv_transform : Matrix
} derive(Eq)

///|
pub fn sphere() -> Sphere {
  let transform = mat4ident()
  let inv_transform = mat4ident()
  { transform, inv_transform }
}

///|
pub fn set_transform(self : Sphere, t : Matrix) -> Unit {
  self.transform.copy(t)
  self.inv_transform.copy(t.inverse())
}

///|
pub fn to_string(self : Sphere) -> String {
  "sphere()"
}

///|
pub impl Show for Sphere with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub fn intersect(self : Sphere, ray : Ray) -> Intersections {
  let ray = ray.transform(self.inv_transform)
  // the vector from the sphere's center to the ray origin
  // (the sphere is centered at the world origin)
  let sphere_to_ray = ray.origin - point(0, 0, 0)
  let a = ray.direction.dot(ray.direction)
  let b = ray.direction.dot(sphere_to_ray) * 2
  let c = sphere_to_ray.dot(sphere_to_ray) - 1
  let discriminant = b * b - a * c * 4
  if discriminant < 0 {
    return intersections([])
  }
  let d = discriminant.sqrt()
  let t1 = (-b - d) / (a * 2)
  let t2 = (-b + d) / (a * 2)
  intersections([intersection(t1, self), intersection(t2, self)])
}
