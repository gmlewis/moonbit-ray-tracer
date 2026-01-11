///|
/// `GraphicMaskPattern` turns a 2D `@draw.Graphic` into a black/white mask pattern.
///
/// Coordinates:
/// - `pattern_at(point)`: uses `(x, z)` as `(u, v)`.
/// - `uv_at(u, v)`: uses `(u, v)` directly.
///
/// This is intended to be used as a mask for `mix_pattern` or material layering.
pub(all) struct GraphicMaskPattern {
  graphic : @draw.Graphic
  profiles : Array[(Array[@draw.Vec2], Array[Array[@draw.Vec2]])]
  curve_segments : Int
  inside : Color
  outside : Color
  style : Bool
}

///|
pub impl Show for GraphicMaskPattern with output(_self, logger) {
  logger.write_string("graphic_mask(...) ")
}

///|
pub impl PatternTrait for GraphicMaskPattern with clone(self) {
  graphic_mask_pattern(
    self.graphic.clone(),
    curve_segments=self.curve_segments,
    inside=self.inside,
    outside=self.outside,
    style=self.style,
  )
}

///|
pub impl PatternTrait for GraphicMaskPattern with pattern_at(self, p) {
  let pt = @draw.vec2(p.x, p.z)
  if self.graphic_profiles_contain_point(pt) {
    self.inside
  } else {
    self.outside
  }
}

///|
pub impl PatternTrait for GraphicMaskPattern with uv_at(self, u, v) {
  let pt = @draw.vec2(u, v)
  if self.graphic_profiles_contain_point(pt) {
    self.inside
  } else {
    self.outside
  }
}

///|
pub impl PatternTrait for GraphicMaskPattern with pattern_at_with_info(
  self,
  point,
  _normal,
  uv,
) {
  match uv {
    Some((u, v)) => self.uv_at(u, v)
    None => self.pattern_at(point)
  }
}

///|
pub fn graphic_mask_pattern(
  graphic : @draw.Graphic,
  curve_segments? : Int = 16,
  inside? : Color = color(1, 1, 1),
  outside? : Color = color(0, 0, 0),
  style? : Bool = false,
) -> Pattern {
  // Note: `gmlewis/fonts/draw` currently has `contains_point` unimplemented on
  // Path/CompoundPath, so we build polygon profiles and use point-in-polygon.
  let profiles = graphic.to_profiles(curve_segments)
  Pattern::new(GraphicMaskPattern::{
    graphic,
    profiles,
    curve_segments,
    inside,
    outside,
    style,
  })
}

///|
fn GraphicMaskPattern::graphic_profiles_contain_point(
  self : GraphicMaskPattern,
  pt : @draw.Vec2,
) -> Bool {
  // `style` is reserved for future (stroke/fill-aware masks).
  let _style = self.style
  for profile in self.profiles {
    let outer = profile.0
    let holes = profile.1
    if @draw.is_point_in_poly(pt, outer) {
      let mut in_hole = false
      for hole in holes {
        if @draw.is_point_in_poly(pt, hole) {
          in_hole = true
          break
        }
      }
      if not(in_hole) {
        return true
      }
    }
  }
  false
}
