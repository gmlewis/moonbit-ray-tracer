///|
pub(open) trait Object {
  local_intersect(Self, Ray) -> Array[Double] // Intersections
  local_normal_at(Self, Tuple) -> Tuple
  bounds(Self) -> Bounds
  // https://github.com/moonbitlang/core/issues/1304
  output(Self, Logger) -> Unit
  to_string(Self) -> String
}
// pub impl Eq for Object with op_equal(self, other) { self == other }

///|
pub(all) struct Shape {
  object : Renderable
  mut material : Material
  // Do not modify transform or inv_transform directly.
  // Instead, use `set_transform`.
  mut transform : Matrix
  mut inv_transform : Matrix
  mut parent : Shape?
  mut bounds : Bounds?
  // Since MoonBit does not have reflection or pointer comparisons, the `id`
  // field has been added to uniquely identify an individual shape.
  // Unfortunately, the bumping of the `id` field should be an atomic
  // operation to be safe in future parallel threaded runtimes, but for now
  // this is all single-threaded and unprotected.
  id : UInt
}

///|
let id_counter : Ref[UInt] = { val: 0 }

///|
pub fn bounds(self : Shape) -> Bounds {
  match self.bounds {
    Some(bounds) => return bounds
    _ => ()
  }
  let bounds = match self.object {
    Object(object) => object.bounds().transform(self.transform)
    Group(group) => group.bounds().transform(self.transform)
    Triangle(triangle) => triangle.bounds().transform(self.transform)
    SmoothTriangle(triangle) => triangle.bounds().transform(self.transform)
  }
  self.bounds = Some(bounds)
  bounds
}

///|
pub fn Shape::to_string(self : Shape) -> String {
  self.object.to_string()
}

///|
pub fn output(self : Shape, logger : Logger) -> Unit {
  logger.write_string(self.object.to_string())
}

///|
pub fn op_equal(self : Shape, other : Shape) -> Bool {
  // https://github.com/moonbitlang/core/issues/1304#issuecomment-2523373703
  // self.object == other.object &&
  self.material == other.material && self.transform == other.transform
}

///|
pub fn Shape::new_object(object : Object) -> Shape {
  Shape::new(Object(object))
}

///|
pub fn Shape::new(object : Renderable) -> Shape {
  let material = material()
  let transform = mat4ident()
  let inv_transform = mat4ident()
  let parent = None
  let bounds = None
  let id = id_counter.val
  id_counter.val += 1
  { object, material, transform, inv_transform, parent, bounds, id }
}

///|
pub fn set_transform(self : Shape, transform : Matrix) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn intersect(self : Shape, ray : Ray) -> Intersections {
  let local_ray = ray.transform(self.inv_transform)
  self.local_intersect(local_ray)
}

///|
pub fn local_intersect(self : Shape, local_ray : Ray) -> Intersections {
  match self.object {
    Object(object) => {
      let ts = object.local_intersect(local_ray)
      intersections(ts.map(fn(t) { intersection(t, self) }))
    }
    Group(group) => {
      let bounds = group.bounds()
      let xs = bounds.local_intersect(local_ray, self)
      if xs.count == 0 {
        return xs
      }
      group.local_intersect(self, local_ray)
    }
    Triangle(triangle) => {
      let ts = triangle.local_intersect(local_ray)
      intersections(ts.map(fn(t) { intersection(t.0, self, u=t.1, v=t.2) }))
    }
    SmoothTriangle(triangle) => {
      let ts = triangle.local_intersect(local_ray)
      intersections(ts.map(fn(t) { intersection(t.0, self, u=t.1, v=t.2) }))
    }
    //  CSG(csg) => {
    //    let ts = csg.local_intersect(local_ray)
    //    intersections(ts.map(fn(t) { intersection(t, self) }))
    //  }
  }
}

///|
pub fn normal_at(
  self : Shape,
  world_point : Tuple,
  hit~ : Intersection? = None
) -> Tuple {
  let local_point = self.world_to_object(world_point)
  let local_normal = self.local_normal_at(local_point, hit~)
  self.normal_to_world(local_normal)
}

///|
pub fn local_normal_at(
  self : Shape,
  local_point : Tuple,
  hit~ : Intersection? = None
) -> Tuple {
  match self.object {
    Object(object) => object.local_normal_at(local_point)
    Group(group) => group.local_normal_at(local_point)
    Triangle(triangle) => triangle.local_normal_at(local_point)
    SmoothTriangle(triangle) =>
      match hit {
        Some(hit) => triangle.local_normal_at(local_point, hit)
        _ => {
          println(
            "smooth_triangle \{triangle} called local_normal_at without hit point",
          )
          vector(0, 0, 0)
        }
      }
  }
}

///|
pub fn children(self : Shape) -> Array[Shape] {
  match self.object {
    Object(_) => []
    Group(group) => group.children
    Triangle(_) => []
    SmoothTriangle(_) => []
    CSG(_) => []
  }
}

///|
pub fn add_child(self : Shape, child : Shape) -> Unit {
  match self.object {
    Group(group) => {
      group.children.push(child)
      child.parent = Some(self)
    }
    Object(_) => ()
    Triangle(_) => ()
    SmoothTriangle(_) => ()
    CSG(_) => ()
  }
}

///|
pub fn world_to_object(self : Shape, point : Tuple) -> Tuple {
  match self.parent {
    Some(parent) => {
      let point = parent.world_to_object(point)
      self.inv_transform.mul_tuple(point)
    }
    _ => self.inv_transform.mul_tuple(point)
  }
}

///|
pub fn normal_to_world(self : Shape, normal : Tuple) -> Tuple {
  let normal = self.inv_transform.transpose().mul_tuple(normal)
  normal.w = 0
  let normal = normal.normalize()
  match self.parent {
    Some(parent) => parent.normal_to_world(normal)
    _ => normal
  }
}

///|
pub fn includes_shape(self : Shape, shape : Shape) -> Bool {
  if self.id == shape.id {
    return true
  }
  match self.object {
    Group(group) =>
      for child in group.children {
        if child.includes_shape(shape) {
          return true
        }
      }
    Object(_) => ()
    Triangle(_) => ()
    SmoothTriangle(_) => ()
    CSG(csg) =>
      return csg.left.includes_shape(shape) || csg.right.includes_shape(shape)
  }
  false
}
