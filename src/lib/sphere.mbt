///|
/// Sphere represents a sphere with radius 1.
pub(all) struct Sphere {} derive(Show, Eq)

///|
let _Sphere : &Object = Sphere::{  }

///|
pub fn sphere() -> Shape {
  let sphere = Sphere::{  }
  Shape::new_object(sphere)
}

///|
pub fn glass_sphere() -> Shape {
  let s = sphere()
  s.material.transparency = 1
  s.material.refractive_index = 1.5
  s
}

///|
pub impl Show for Sphere with to_string(_self) {
  "sphere()"
}

///|
pub impl Object for Sphere with local_intersect(_self, ray) {
  // the vector from the sphere's center to the ray origin
  // (the sphere is centered at the world origin)
  let sphere_to_ray = ray.origin - point(0, 0, 0)
  let a = ray.direction.dot(ray.direction)
  let b = ray.direction.dot(sphere_to_ray) * 2
  let c = sphere_to_ray.dot(sphere_to_ray) - 1
  let discriminant = b * b - a * c * 4
  if discriminant < 0 {
    return []
  }
  let d = discriminant.sqrt()
  let t1 = (-b - d) / (a * 2)
  let t2 = (-b + d) / (a * 2)
  [t1, t2]
}

///|
pub impl Object for Sphere with local_normal_at(_self, local_point) {
  local_point - point(0, 0, 0)
}

///|
pub impl Object for Sphere with bounds(_self) {
  let min = point(-1, -1, -1)
  let max = point(1, 1, 1)
  { min, max }
}
