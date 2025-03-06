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
pub fn Shape::bounds(self : Shape) -> Bounds {
  match self.bounds {
    Some(bounds) => return bounds
    _ => ()
  }
  let bounds = match self.object {
    Object(object) => object.bounds().transform(self.transform)
    Group(group) => group.bounds().transform(self.transform)
    Triangle(triangle) => triangle.bounds().transform(self.transform)
    SmoothTriangle(triangle) => triangle.bounds().transform(self.transform)
    CSG(csg) => {
      let left_bounds = csg.left.bounds().transform(self.transform)
      let right_bounds = csg.right.bounds().transform(self.transform)
      left_bounds.enlarge(right_bounds)
      left_bounds
    }
  }
  self.bounds = Some(bounds)
  bounds
}

///|
pub impl Show for Shape with to_string(self) {
  self.object.to_string()
}

///|
pub impl Show for Shape with output(self, logger) {
  logger.write_string(self.object.to_string())
}

///|
pub impl Eq for Shape with op_equal(self, other) {
  // https://github.com/moonbitlang/core/issues/1304#issuecomment-2523373703
  // self.object == other.object &&
  self.material == other.material && self.transform == other.transform
}

///|
pub fn Shape::new_object(object : &Object) -> Shape {
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
pub fn Shape::local_intersect(self : Shape, local_ray : Ray) -> Intersections {
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
    CSG(csg) => {
      let xs = csg.left.intersect(local_ray)
      let right_xs = csg.right.intersect(local_ray)
      xs.xs.append(right_xs.xs)
      csg.filter_intersections(intersections(xs.xs))
    }
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
pub fn Shape::local_normal_at(
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
    CSG(_) => vector(0, 0, 0) // never called directly since intersections report left or right object.
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
