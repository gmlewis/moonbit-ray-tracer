///|
pub(all) struct Group {
  children : Array[Shape]
  mut bounds : Bounds?
}

///|
pub fn group() -> Shape {
  Shape::new_group(Group::{ children: [], bounds: None })
}

///|
pub fn Shape::new_group(group : Group) -> Shape {
  Shape::new(Group(group))
}

///|
pub fn Group::to_string(_self : Group) -> String {
  "group()"
}

///|
pub fn Group::output(self : Group, logger : &Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub fn Group::local_intersect(
  self : Group,
  group_shape : Shape,
  ray : Ray,
) -> Intersections {
  if self.children.length() == 0 {
    return Intersections::from_ts([], group_shape)
  }
  let xs = []
  for child in self.children {
    let ts = child.intersect(ray)
    xs.append(ts.xs)
  }
  intersections(xs)
}

///|
pub fn Group::local_normal_at(_self : Group, _point : Tuple) -> Tuple {
  vector(0, 0, 0) // should not happen.
}

///|
pub fn Group::clone(self : Group) -> Group {
  let children = self.children.map(fn(c) { c.clone() })
  { children, bounds: None }
}

///|
pub fn Group::bounds(self : Group) -> Bounds {
  match self.bounds {
    Some(bounds) => return bounds
    _ => ()
  }
  let bounds = Bounds::new()
  for child in self.children {
    let cb = child.parent_space_bounds()
    bounds.update(cb.min)
    bounds.update(cb.max)
  }
  self.bounds = Some(bounds)
  bounds
}

///|
pub fn Group::partition_children(self : Group) -> (Array[Shape], Array[Shape]) {
  let left = []
  let right = []
  let b = self.bounds()
  let w = b.width()
  let h = b.height()
  let d = b.depth()

  // Find longest axis and its midpoint
  let (axis, mid) = if w >= h && w >= d {
    ('x', b.min.x + w / 2.0)
  } else if h >= w && h >= d {
    ('y', b.min.y + h / 2.0)
  } else {
    ('z', b.min.z + d / 2.0)
  }

  // Filter children based on their center point relative to midpoint
  for child in self.children {
    let cb = child.parent_space_bounds()
    let center = match axis {
      'x' => (cb.min.x + cb.max.x) / 2.0
      'y' => (cb.min.y + cb.max.y) / 2.0
      _ => (cb.min.z + cb.max.z) / 2.0
    }

    if center < mid {
      left.push(child)
    } else {
      right.push(child)
    }
  }

  // If we couldn't split (all on one side), just split the array in half
  if left.length() == 0 || right.length() == 0 {
    let mid_idx = self.children.length() / 2
    let l = self.children.iter().take(mid_idx).collect()
    let r = self.children.iter().drop(mid_idx).collect()
    return (l, r)
  }

  (left, right)
}

///|
pub fn Group::divide(self : Group, limit : Int) -> Unit {
  if self.children.length() > limit {
    let (left, right) = self.partition_children()
    self.children.clear()

    if left.length() > 0 {
      let g = group()
      for child in left {
        g.add_child(child)
      }
      self.children.push(g)
    }

    if right.length() > 0 {
      let g = group()
      for child in right {
        g.add_child(child)
      }
      self.children.push(g)
    }
  }

  for child in self.children {
    child.divide(limit)
  }
}