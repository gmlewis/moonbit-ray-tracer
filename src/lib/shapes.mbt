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
  let local_bounds = match self.object {
    Object(object) => object.bounds()
    Group(group) => group.bounds()
    Triangle(triangle) => triangle.bounds()
    SmoothTriangle(triangle) => triangle.bounds()
    TriangleUV(triangle) => triangle.bounds()
    SmoothTriangleUV(triangle) => triangle.bounds()
    CSG(csg) => {
      let left_bounds = csg.left.parent_space_bounds()
      let right_bounds = csg.right.parent_space_bounds()
      left_bounds.enlarge(right_bounds)
      left_bounds
    }
  }
  let bounds = local_bounds.transform(self.transform)
  self.bounds = Some(bounds)
  bounds
}

///|
pub fn Shape::parent_space_bounds(self : Shape) -> Bounds {
  self.object_space_bounds().transform(self.transform)
}

///|
pub fn Shape::object_space_bounds(self : Shape) -> Bounds {
  match self.object {
    Object(object) => object.bounds()
    Group(group) => group.bounds()
    Triangle(triangle) => triangle.bounds()
    SmoothTriangle(triangle) => triangle.bounds()
    TriangleUV(triangle) => triangle.bounds()
    SmoothTriangleUV(triangle) => triangle.bounds()
    CSG(csg) => {
      let left_bounds = csg.left.parent_space_bounds()
      let right_bounds = csg.right.parent_space_bounds()
      left_bounds.enlarge(right_bounds)
      left_bounds
    }
  }
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
pub impl Eq for Shape with equal(self, other) {
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
pub fn Shape::clone(self : Shape) -> Shape {
  let object = match self.object {
    Object(o) => Renderable::Object(o.clone())
    Group(g) => Renderable::Group(g.clone())
    Triangle(t) => Renderable::Triangle(t.clone())
    SmoothTriangle(t) => Renderable::SmoothTriangle(t.clone())
    TriangleUV(t) => Renderable::TriangleUV(t.clone())
    SmoothTriangleUV(t) => Renderable::SmoothTriangleUV(t.clone())
    CSG(c) => Renderable::CSG(c.clone())
  }
  let s = Shape::new(object)
  s.material = self.material.clone()
  s.transform = self.transform.clone()
  s.inv_transform = self.inv_transform.clone()
  // Parent is intentionally not cloned to avoid cycles or incorrect linking
  s
}

///|
pub fn Shape::set_transform(self : Shape, transform : Matrix) -> Unit {
  self.transform = transform
  self.inv_transform = transform.inverse()
}

///|
pub fn Shape::intersect(self : Shape, ray : Ray) -> Intersections {
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
      if not(bounds.local_intersect(local_ray)) {
        return intersections([])
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
    TriangleUV(triangle) => {
      let ts = triangle.local_intersect(local_ray)
      intersections(
        ts.map(fn(t) {
          let hit = intersection(t.0, self, u=t.1, v=t.2)
          let uv_u = triangle.uv1.0 * (1.0 - t.1 - t.2) +
            triangle.uv2.0 * t.1 +
            triangle.uv3.0 * t.2
          let uv_v = triangle.uv1.1 * (1.0 - t.1 - t.2) +
            triangle.uv2.1 * t.1 +
            triangle.uv3.1 * t.2
          hit.uv_u = uv_u
          hit.uv_v = uv_v
          hit.has_uv = true
          hit
        }),
      )
    }
    SmoothTriangleUV(triangle) => {
      let ts = triangle.local_intersect(local_ray)
      intersections(
        ts.map(fn(t) {
          let hit = intersection(t.0, self, u=t.1, v=t.2)
          let uv_u = triangle.uv1.0 * (1.0 - t.1 - t.2) +
            triangle.uv2.0 * t.1 +
            triangle.uv3.0 * t.2
          let uv_v = triangle.uv1.1 * (1.0 - t.1 - t.2) +
            triangle.uv2.1 * t.1 +
            triangle.uv3.1 * t.2
          hit.uv_u = uv_u
          hit.uv_v = uv_v
          hit.has_uv = true
          hit
        }),
      )
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
pub fn Shape::normal_at(
  self : Shape,
  world_point : Tuple,
  hit? : Intersection? = None,
) -> Tuple {
  let local_point = self.world_to_object(world_point)
  let local_normal = self.local_normal_at(local_point, hit~)
  self.normal_to_world(local_normal)
}

///|
pub fn Shape::local_normal_at(
  self : Shape,
  local_point : Tuple,
  hit? : Intersection? = None,
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
    TriangleUV(triangle) => triangle.local_normal_at(local_point)
    SmoothTriangleUV(triangle) =>
      match hit {
        Some(hit) => triangle.local_normal_at(local_point, hit)
        _ => {
          println(
            "smooth_triangle_uv \{triangle} called local_normal_at without hit point",
          )
          vector(0, 0, 0)
        }
      }
    CSG(_) => vector(0, 0, 0) // never called directly since intersections report left or right object.
  }
}

///|
pub fn Shape::children(self : Shape) -> Array[Shape] {
  match self.object {
    Object(_) => []
    Group(group) => group.children
    Triangle(_) => []
    SmoothTriangle(_) => []
    TriangleUV(_) => []
    SmoothTriangleUV(_) => []
    CSG(_) => []
  }
}

///|
pub fn Shape::add_child(self : Shape, child : Shape) -> Unit {
  match self.object {
    Group(group) => {
      group.children.push(child)
      child.parent = Some(self)
    }
    Object(_) => ()
    Triangle(_) => ()
    SmoothTriangle(_) => ()
    TriangleUV(_) => ()
    SmoothTriangleUV(_) => ()
    CSG(_) => ()
  }
}

///|
pub fn Shape::divide(self : Shape, limit : Int) -> Unit {
  match self.object {
    Group(group) => group.divide(limit)
    CSG(csg) => {
      csg.left.divide(limit)
      csg.right.divide(limit)
    }
    TriangleUV(_) => ()
    SmoothTriangleUV(_) => ()
    _ => ()
  }
}

///|
pub fn Shape::world_to_object(self : Shape, point : Tuple) -> Tuple {
  match self.parent {
    Some(parent) => {
      let point = parent.world_to_object(point)
      self.inv_transform.mul_tuple(point)
    }
    _ => self.inv_transform.mul_tuple(point)
  }
}

///|
pub fn Shape::object_to_world(self : Shape, point : Tuple) -> Tuple {
  let point = self.transform.mul_tuple(point)
  match self.parent {
    Some(parent) => parent.object_to_world(point)
    _ => point
  }
}

///|
pub fn Shape::normal_to_world(self : Shape, normal : Tuple) -> Tuple {
  let normal = self.inv_transform.transpose().mul_tuple(normal)
  normal.w = 0
  let normal = normal.normalize()
  match self.parent {
    Some(parent) => parent.normal_to_world(normal)
    _ => normal
  }
}

///|
pub fn Shape::world_normal_to_object(self : Shape, normal : Tuple) -> Tuple {
  let normal = match self.parent {
    Some(parent) => parent.world_normal_to_object(normal)
    _ => normal
  }
  let normal = self.transform.transpose().mul_tuple(normal)
  normal.w = 0
  normal.normalize()
}

///|
pub fn Shape::includes_shape(self : Shape, shape : Shape) -> Bool {
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
    TriangleUV(_) => ()
    SmoothTriangleUV(_) => ()
    CSG(csg) =>
      return csg.left.includes_shape(shape) || csg.right.includes_shape(shape)
  }
  false
}
