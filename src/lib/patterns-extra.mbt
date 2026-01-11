///|
pub(all) struct StripePattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn StripePattern::to_string(self : StripePattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "stripe(\{colors})"
}

///|
pub impl Show for StripePattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for StripePattern with clone(self) {
  stripe_pattern(self.colors)
}

///|
pub impl PatternTrait for StripePattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub impl PatternTrait for StripePattern with uv_at(self, u, _v) {
  let ncols = self.colors.length()
  let index = @math.floor(u * ncols.to_double()).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub impl PatternTrait for StripePattern with pattern_at_with_info(
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
pub fn stripe_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(StripePattern::{ colors, })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// GradientPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct GradientPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn GradientPattern::to_string(self : GradientPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "gradient(\{colors})"
}

///|
pub impl Show for GradientPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for GradientPattern with clone(self) {
  gradient_pattern(self.colors)
}

///|
pub impl PatternTrait for GradientPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let t = point.x - @math.floor(point.x)
  let index = @math.floor(point.x).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  let next_index = (index + 1) % ncols
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(t)
}

///|
pub impl PatternTrait for GradientPattern with uv_at(self, u, _v) {
  let ncols = self.colors.length()
  let t = u * ncols.to_double()
  let index = @math.floor(t).to_int() % ncols
  let next_index = (index + 1) % ncols
  let fraction = t - @math.floor(t)
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(fraction)
}

///|
pub impl PatternTrait for GradientPattern with pattern_at_with_info(
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
pub fn gradient_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(GradientPattern::{ colors, })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// RingPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct RingPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn RingPattern::to_string(self : RingPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "ring(\{colors})"
}

///|
pub impl Show for RingPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for RingPattern with clone(self) {
  ring_pattern(self.colors)
}

///|
pub impl PatternTrait for RingPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let r = (point.x * point.x + point.z * point.z).sqrt()
  let index = @math.floor(r).to_int() % ncols
  self.colors[index]
}

///|
pub impl PatternTrait for RingPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let dist = ((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)).sqrt()
  let index = @math.floor(dist * 2.0 * ncols.to_double()).to_int() % ncols
  self.colors[index]
}

///|
pub impl PatternTrait for RingPattern with pattern_at_with_info(
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
pub fn ring_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(RingPattern::{ colors, })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// GradientRingPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct GradientRingPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn GradientRingPattern::to_string(self : GradientRingPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "ring(\{colors})"
}

///|
pub impl Show for GradientRingPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for GradientRingPattern with clone(self) {
  gradient_ring_pattern(self.colors)
}

///|
pub impl PatternTrait for GradientRingPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let r = (point.x * point.x + point.z * point.z).sqrt()
  let t = r - @math.floor(r)
  let index = @math.floor(r).to_int() % ncols
  let next_index = (index + 1) % ncols
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(t)
}

///|
pub impl PatternTrait for GradientRingPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let dist = ((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)).sqrt()
  let t = dist * 2.0 * ncols.to_double()
  let index = @math.floor(t).to_int() % ncols
  let next_index = (index + 1) % ncols
  let fraction = t - @math.floor(t)
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(fraction)
}

///|
pub impl PatternTrait for GradientRingPattern with pattern_at_with_info(
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
pub fn gradient_ring_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(GradientRingPattern::{ colors, })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// CheckersPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct CheckersPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn CheckersPattern::to_string(self : CheckersPattern) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "checkers(\{colors})"
}

///|
pub impl Show for CheckersPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for CheckersPattern with clone(self) {
  checkers_pattern(self.colors)
}

///|
pub impl PatternTrait for CheckersPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let index = @math.floor(point.x + 0.00001).to_int() +
    @math.floor(point.y + 0.00001).to_int() +
    @math.floor(point.z + 0.00001).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub impl PatternTrait for CheckersPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let index = @math.floor(u * 2.0 + 0.00001).to_int() +
    @math.floor(v * 2.0 + 0.00001).to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  self.colors[index]
}

///|
pub impl PatternTrait for CheckersPattern with pattern_at_with_info(
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
pub fn checkers_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(CheckersPattern::{ colors, })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Texture
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct Texture {
  canvas : Canvas
  mapping : &Mapping
}

///|
pub impl Show for Texture with output(_self, logger) {
  logger.write_string("texture()")
}

///|
pub impl PatternTrait for Texture with pattern_at(self, point) {
  let (u, v) = self.mapping.map(point)
  self.uv_at(u, v)
}

///|
pub impl PatternTrait for Texture with uv_at(self, u, v) {
  let u = u - @math.floor(u)
  let v = v - @math.floor(v)
  self.canvas.pixel_at_bilinear(u, v)
}

///|
pub impl PatternTrait for Texture with pattern_at_with_info(
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
pub impl PatternTrait for Texture with clone(self) {
  texture(self.canvas, mapping=self.mapping)
}

///|
pub impl Eq for Texture with equal(self, other) {
  self.canvas == other.canvas
}

///|
pub fn texture(canvas : Canvas, mapping? : &Mapping) -> Pattern {
  let m : &Mapping = match mapping {
    Some(m) => m
    None => PlanarMapping::{  } as &Mapping
  }
  Pattern::new(Texture::{ canvas, mapping: m })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// GradientCheckersPattern
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
pub(all) struct GradientCheckersPattern {
  colors : Array[Color]
} derive(Eq)

///|
pub fn GradientCheckersPattern::to_string(
  self : GradientCheckersPattern,
) -> String {
  let colors = self.colors.map(fn(c) { "\{c}" })
  let colors = colors.join(",")
  "gradient_checkers(\{colors})"
}

///|
pub impl Show for GradientCheckersPattern with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl PatternTrait for GradientCheckersPattern with clone(self) {
  gradient_checkers_pattern(self.colors)
}

///|
pub impl PatternTrait for GradientCheckersPattern with pattern_at(self, point) {
  let ncols = self.colors.length()
  let x_floor = @math.floor(point.x)
  let y_floor = @math.floor(point.y)
  let z_floor = @math.floor(point.z)
  let index = x_floor.to_int() + y_floor.to_int() + z_floor.to_int()
  let index = if index >= 0 {
    index % ncols
  } else {
    (index % ncols + ncols) % ncols
  }
  let next_index = (index + 1) % ncols
  let t = (point.x - x_floor + point.y - y_floor + point.z - z_floor) / 3.0
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(t)
}

///|
pub impl PatternTrait for GradientCheckersPattern with uv_at(self, u, v) {
  let ncols = self.colors.length()
  let t = (u + v) * 2.0
  let index = @math.floor(t).to_int() % ncols
  let next_index = (index + 1) % ncols
  let fraction = t - @math.floor(t)
  self.colors[index] +
  (self.colors[next_index] - self.colors[index]).mul_scalar(fraction)
}

///|
pub impl PatternTrait for GradientCheckersPattern with pattern_at_with_info(
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
pub fn gradient_checkers_pattern(colors : Array[Color]) -> Pattern {
  Pattern::new(GradientCheckersPattern::{ colors, })
}

///|
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Procedural noise + compositing
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

///|
fn clamp01(t : Double) -> Double {
  if t < 0.0 {
    0.0
  } else if t > 1.0 {
    1.0
  } else {
    t
  }
}

///|
fn lerp_color(a : Color, b : Color, t : Double) -> Color {
  a + (b - a).mul_scalar(clamp01(t))
}

///|
fn palette(colors : Array[Color], t : Double) -> Color {
  let n = colors.length()
  if n == 0 {
    return color(0, 0, 0)
  }
  if n == 1 {
    return colors[0]
  }
  let t = clamp01(t) * (n - 1).to_double()
  let i = @math.floor(t).to_int()
  let frac = t - @math.floor(t)
  let i0 = if i < 0 { 0 } else if i >= n { n - 1 } else { i }
  let i1 = if i0 + 1 >= n { n - 1 } else { i0 + 1 }
  lerp_color(colors[i0], colors[i1], frac)
}

///|
pub(all) struct NoisePattern {
  seed : Int
  scale : Double
} derive(Eq)

///|
pub impl Show for NoisePattern with output(self, logger) {
  logger.write_string("noise(seed=\{self.seed}, scale=\{self.scale})")
}

///|
pub impl PatternTrait for NoisePattern with clone(self) {
  noise_pattern(seed=self.seed, scale=self.scale)
}

///|
pub impl PatternTrait for NoisePattern with pattern_at(self, point) {
  let v = value_noise3(point.mul_scalar(self.scale), self.seed)
  color(v, v, v)
}

///|
pub impl PatternTrait for NoisePattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for NoisePattern with pattern_at_with_info(
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
pub fn noise_pattern(seed? : Int = 0, scale? : Double = 1.0) -> Pattern {
  Pattern::new(NoisePattern::{ seed, scale })
}

///|
pub(all) struct FbmPattern {
  seed : Int
  scale : Double
  octaves : Int
  lacunarity : Double
  gain : Double
} derive(Eq)

///|
pub impl Show for FbmPattern with output(self, logger) {
  logger.write_string(
    "fbm(seed=\{self.seed}, scale=\{self.scale}, octaves=\{self.octaves})",
  )
}

///|
pub impl PatternTrait for FbmPattern with clone(self) {
  fbm_pattern(
    seed=self.seed,
    scale=self.scale,
    octaves=self.octaves,
    lacunarity=self.lacunarity,
    gain=self.gain,
  )
}

///|
pub impl PatternTrait for FbmPattern with pattern_at(self, point) {
  let v = fbm3(
    point.mul_scalar(self.scale),
    self.seed,
    self.octaves,
    self.lacunarity,
    self.gain,
  )
  color(v, v, v)
}

///|
pub impl PatternTrait for FbmPattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for FbmPattern with pattern_at_with_info(
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
pub fn fbm_pattern(
  seed? : Int = 0,
  scale? : Double = 1.0,
  octaves? : Int = 5,
  lacunarity? : Double = 2.0,
  gain? : Double = 0.5,
) -> Pattern {
  Pattern::new(FbmPattern::{ seed, scale, octaves, lacunarity, gain })
}

///|
pub(all) struct MarblePattern {
  colors : Array[Color]
  seed : Int
  scale : Double
  octaves : Int
  lacunarity : Double
  gain : Double
  frequency : Double
  strength : Double
}

///|
pub impl Show for MarblePattern with output(_self, logger) {
  logger.write_string("marble(...) ")
}

///|
pub impl PatternTrait for MarblePattern with clone(self) {
  marble_pattern(
    self.colors,
    seed=self.seed,
    scale=self.scale,
    octaves=self.octaves,
    lacunarity=self.lacunarity,
    gain=self.gain,
    frequency=self.frequency,
    strength=self.strength,
  )
}

///|
pub impl PatternTrait for MarblePattern with pattern_at(self, point) {
  let p = point.mul_scalar(self.scale)
  let n = fbm3(p, self.seed, self.octaves, self.lacunarity, self.gain)
  let t = @math.sin((p.x * self.frequency + n * self.strength) * 2.0 * @math.PI)
  let t = clamp01(t * 0.5 + 0.5)
  palette(self.colors, t)
}

///|
pub impl PatternTrait for MarblePattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for MarblePattern with pattern_at_with_info(
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
pub fn marble_pattern(
  colors : Array[Color],
  seed? : Int = 0,
  scale? : Double = 1.0,
  octaves? : Int = 5,
  lacunarity? : Double = 2.0,
  gain? : Double = 0.5,
  frequency? : Double = 5.0,
  strength? : Double = 2.0,
) -> Pattern {
  Pattern::new(MarblePattern::{
    colors,
    seed,
    scale,
    octaves,
    lacunarity,
    gain,
    frequency,
    strength,
  })
}

///|
pub(all) struct WoodPattern {
  colors : Array[Color]
  seed : Int
  scale : Double
  octaves : Int
  lacunarity : Double
  gain : Double
  ring_frequency : Double
  turbulence : Double
}

///|
pub impl Show for WoodPattern with output(_self, logger) {
  logger.write_string("wood(...) ")
}

///|
pub impl PatternTrait for WoodPattern with clone(self) {
  wood_pattern(
    self.colors,
    seed=self.seed,
    scale=self.scale,
    octaves=self.octaves,
    lacunarity=self.lacunarity,
    gain=self.gain,
    ring_frequency=self.ring_frequency,
    turbulence=self.turbulence,
  )
}

///|
pub impl PatternTrait for WoodPattern with pattern_at(self, point) {
  let p = point.mul_scalar(self.scale)
  let n = fbm3(p, self.seed, self.octaves, self.lacunarity, self.gain)
  let r = (p.x * p.x + p.z * p.z).sqrt()
  let t = r * self.ring_frequency + n * self.turbulence
  let t = t - @math.floor(t)
  palette(self.colors, t)
}

///|
pub impl PatternTrait for WoodPattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for WoodPattern with pattern_at_with_info(
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
pub fn wood_pattern(
  colors : Array[Color],
  seed? : Int = 0,
  scale? : Double = 1.0,
  octaves? : Int = 5,
  lacunarity? : Double = 2.0,
  gain? : Double = 0.5,
  ring_frequency? : Double = 6.0,
  turbulence? : Double = 0.5,
) -> Pattern {
  Pattern::new(WoodPattern::{
    colors,
    seed,
    scale,
    octaves,
    lacunarity,
    gain,
    ring_frequency,
    turbulence,
  })
}

///|
pub(all) enum VoronoiMode {
  Distance
  Cells
  Edges
  Crackle
  F1
  F2
  F2MinusF1
} derive(Show, Eq)

///|
pub(all) struct VoronoiPattern {
  seed : Int
  scale : Double
  jitter : Double
  mode : VoronoiMode
  edge_scale : Double
}

///|
pub impl Show for VoronoiPattern with output(self, logger) {
  logger.write_string(
    "voronoi(seed=\{self.seed}, scale=\{self.scale}, mode=\{self.mode})",
  )
}

///|
pub impl PatternTrait for VoronoiPattern with clone(self) {
  voronoi_pattern(
    seed=self.seed,
    scale=self.scale,
    jitter=self.jitter,
    mode=self.mode,
    edge_scale=self.edge_scale,
  )
}

///|
pub impl PatternTrait for VoronoiPattern with pattern_at(self, p) {
  let p = p.mul_scalar(self.scale)
  let (f1, f2, cx, cy) = voronoi2_f1_f2(p, self.seed, self.jitter)
  match self.mode {
    VoronoiMode::Distance => {
      let v = clamp01(1.0 - f1)
      color(v, v, v)
    }
    VoronoiMode::F1 => {
      let v = clamp01(f1)
      color(v, v, v)
    }
    VoronoiMode::F2 => {
      let v = clamp01(f2)
      color(v, v, v)
    }
    VoronoiMode::F2MinusF1 => {
      // Feature distance: larger values away from borders.
      // `edge_scale` acts as a generic multiplier for this signal.
      let v = clamp01((f2 - f1) * self.edge_scale)
      color(v, v, v)
    }
    VoronoiMode::Cells => {
      let r = value_noise3(
        point(cx.to_double(), 0.0, cy.to_double()),
        self.seed,
      )
      let g = value_noise3(
        point(cx.to_double(), 1.0, cy.to_double()),
        self.seed,
      )
      let b = value_noise3(
        point(cx.to_double(), 2.0, cy.to_double()),
        self.seed,
      )
      color(r, g, b)
    }
    VoronoiMode::Edges => {
      // F2 - F1 is small near cell borders.
      let e = clamp01(1.0 - (f2 - f1) * self.edge_scale)
      color(e, e, e)
    }
    VoronoiMode::Crackle => {
      let e = clamp01(1.0 - (f2 - f1) * self.edge_scale)
      let c = @math.pow(e, 4.0)
      color(c, c, c)
    }
  }
}

///|
pub impl PatternTrait for VoronoiPattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for VoronoiPattern with pattern_at_with_info(
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
pub fn voronoi_pattern(
  seed? : Int = 0,
  scale? : Double = 1.0,
  jitter? : Double = 1.0,
  mode? : VoronoiMode = VoronoiMode::Distance,
  edge_scale? : Double = 12.0,
) -> Pattern {
  Pattern::new(VoronoiPattern::{ seed, scale, jitter, mode, edge_scale })
}

///|
pub fn voronoi_f1_pattern(
  seed? : Int = 0,
  scale? : Double = 1.0,
  jitter? : Double = 1.0,
) -> Pattern {
  voronoi_pattern(seed~, scale~, jitter~, mode=VoronoiMode::F1)
}

///|
pub fn voronoi_f2_pattern(
  seed? : Int = 0,
  scale? : Double = 1.0,
  jitter? : Double = 1.0,
) -> Pattern {
  voronoi_pattern(seed~, scale~, jitter~, mode=VoronoiMode::F2)
}

///|
pub fn voronoi_f2_minus_f1_pattern(
  seed? : Int = 0,
  scale? : Double = 1.0,
  jitter? : Double = 1.0,
  edge_scale? : Double = 12.0,
) -> Pattern {
  voronoi_pattern(
    seed~,
    scale~,
    jitter~,
    mode=VoronoiMode::F2MinusF1,
    edge_scale~,
  )
}

///|############################################################################

///| More looks

///|############################################################################

///|
fn remap_channel(
  x : Double,
  in_min : Double,
  in_max : Double,
  out_min : Double,
  out_max : Double,
  gamma : Double,
) -> Double {
  let denom = in_max - in_min
  let t = if denom.abs() <= 1.0e-12 { 0.0 } else { (x - in_min) / denom }
  let t = clamp01(t)
  let g = if gamma <= 1.0e-12 { 1.0 } else { gamma }
  let t = @math.pow(t, 1.0 / g)
  clamp01(out_min + t * (out_max - out_min))
}

///|
pub(all) struct LevelsPattern {
  pattern : Pattern
  in_min : Double
  in_max : Double
  out_min : Double
  out_max : Double
  gamma : Double
}

///|
pub impl Show for LevelsPattern with output(_self, logger) {
  logger.write_string("levels(...)")
}

///|
pub impl PatternTrait for LevelsPattern with clone(self) {
  levels_pattern(
    self.pattern.clone(),
    in_min=self.in_min,
    in_max=self.in_max,
    out_min=self.out_min,
    out_max=self.out_max,
    gamma=self.gamma,
  )
}

///|
pub impl PatternTrait for LevelsPattern with pattern_at(self, point) {
  let c = self.pattern.pattern_at(point)
  color(
    remap_channel(
      c.red,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
    remap_channel(
      c.green,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
    remap_channel(
      c.blue,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
  )
}

///|
pub impl PatternTrait for LevelsPattern with uv_at(self, u, v) {
  let c = self.pattern.uv_at(u, v)
  color(
    remap_channel(
      c.red,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
    remap_channel(
      c.green,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
    remap_channel(
      c.blue,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
  )
}

///|
pub impl PatternTrait for LevelsPattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  let c = self.pattern.pattern_at_with_info(point, normal, uv)
  color(
    remap_channel(
      c.red,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
    remap_channel(
      c.green,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
    remap_channel(
      c.blue,
      self.in_min,
      self.in_max,
      self.out_min,
      self.out_max,
      self.gamma,
    ),
  )
}

///|
pub fn levels_pattern(
  pattern : Pattern,
  in_min? : Double = 0.0,
  in_max? : Double = 1.0,
  out_min? : Double = 0.0,
  out_max? : Double = 1.0,
  gamma? : Double = 1.0,
) -> Pattern {
  Pattern::new(LevelsPattern::{
    pattern,
    in_min,
    in_max,
    out_min,
    out_max,
    gamma,
  })
}

///|
fn bias_value(x : Double, bias : Double) -> Double {
  let x = clamp01(x)
  // Schlick bias: x^(log(b)/log(0.5))
  let b0 = clamp01(bias)
  let eps = 1.0e-6
  let b = if b0 < eps { eps } else if b0 > 1.0 - eps { 1.0 - eps } else { b0 }
  let exp = @math.ln(b) / @math.ln(0.5)
  clamp01(@math.pow(x, exp))
}

///|
fn gain_value(x : Double, gain : Double) -> Double {
  let x = clamp01(x)
  let g = clamp01(gain)
  if x < 0.5 {
    0.5 * bias_value(2.0 * x, 1.0 - g)
  } else {
    1.0 - 0.5 * bias_value(2.0 - 2.0 * x, 1.0 - g)
  }
}

///|
pub(all) struct BiasGainPattern {
  pattern : Pattern
  bias : Double
  gain : Double
}

///|
pub impl Show for BiasGainPattern with output(_self, logger) {
  logger.write_string("bias_gain(...)")
}

///|
pub impl PatternTrait for BiasGainPattern with clone(self) {
  bias_gain_pattern(self.pattern.clone(), bias=self.bias, gain=self.gain)
}

///|
pub impl PatternTrait for BiasGainPattern with pattern_at(self, point) {
  let c = self.pattern.pattern_at(point)
  color(
    gain_value(bias_value(c.red, self.bias), self.gain),
    gain_value(bias_value(c.green, self.bias), self.gain),
    gain_value(bias_value(c.blue, self.bias), self.gain),
  )
}

///|
pub impl PatternTrait for BiasGainPattern with uv_at(self, u, v) {
  let c = self.pattern.uv_at(u, v)
  color(
    gain_value(bias_value(c.red, self.bias), self.gain),
    gain_value(bias_value(c.green, self.bias), self.gain),
    gain_value(bias_value(c.blue, self.bias), self.gain),
  )
}

///|
pub impl PatternTrait for BiasGainPattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  let c = self.pattern.pattern_at_with_info(point, normal, uv)
  color(
    gain_value(bias_value(c.red, self.bias), self.gain),
    gain_value(bias_value(c.green, self.bias), self.gain),
    gain_value(bias_value(c.blue, self.bias), self.gain),
  )
}

///|
pub fn bias_gain_pattern(
  pattern : Pattern,
  bias? : Double = 0.5,
  gain? : Double = 0.5,
) -> Pattern {
  Pattern::new(BiasGainPattern::{ pattern, bias, gain })
}

///|
fn contrast_value(x : Double, contrast : Double, pivot : Double) -> Double {
  clamp01((clamp01(x) - pivot) * contrast + pivot)
}

///|
pub(all) struct ContrastPattern {
  pattern : Pattern
  contrast : Double
  pivot : Double
}

///|
pub impl Show for ContrastPattern with output(_self, logger) {
  logger.write_string("contrast(...)")
}

///|
pub impl PatternTrait for ContrastPattern with clone(self) {
  contrast_pattern(
    self.pattern.clone(),
    contrast=self.contrast,
    pivot=self.pivot,
  )
}

///|
pub impl PatternTrait for ContrastPattern with pattern_at(self, point) {
  let c = self.pattern.pattern_at(point)
  color(
    contrast_value(c.red, self.contrast, self.pivot),
    contrast_value(c.green, self.contrast, self.pivot),
    contrast_value(c.blue, self.contrast, self.pivot),
  )
}

///|
pub impl PatternTrait for ContrastPattern with uv_at(self, u, v) {
  let c = self.pattern.uv_at(u, v)
  color(
    contrast_value(c.red, self.contrast, self.pivot),
    contrast_value(c.green, self.contrast, self.pivot),
    contrast_value(c.blue, self.contrast, self.pivot),
  )
}

///|
pub impl PatternTrait for ContrastPattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  let c = self.pattern.pattern_at_with_info(point, normal, uv)
  color(
    contrast_value(c.red, self.contrast, self.pivot),
    contrast_value(c.green, self.contrast, self.pivot),
    contrast_value(c.blue, self.contrast, self.pivot),
  )
}

///|
pub fn contrast_pattern(
  pattern : Pattern,
  contrast? : Double = 1.0,
  pivot? : Double = 0.5,
) -> Pattern {
  Pattern::new(ContrastPattern::{ pattern, contrast, pivot })
}

///|
pub(all) struct ThresholdPattern {
  pattern : Field
  threshold : Double
  low : Color
  high : Color
}

///|
pub impl Show for ThresholdPattern with output(_self, logger) {
  logger.write_string("threshold(...)")
}

///|
pub impl PatternTrait for ThresholdPattern with clone(self) {
  threshold_pattern(
    self.pattern.pattern.clone(),
    threshold=self.threshold,
    low=self.low,
    high=self.high,
  )
}

///|
fn threshold_eval(
  t : Double,
  threshold : Double,
  low : Color,
  high : Color,
) -> Color {
  if t >= threshold {
    high
  } else {
    low
  }
}

///|
pub impl PatternTrait for ThresholdPattern with pattern_at(self, point) {
  threshold_eval(
    self.pattern.scalar_at(point),
    self.threshold,
    self.low,
    self.high,
  )
}

///|
pub impl PatternTrait for ThresholdPattern with uv_at(self, u, v) {
  threshold_eval(
    self.pattern.scalar_uv_at(u, v),
    self.threshold,
    self.low,
    self.high,
  )
}

///|
pub impl PatternTrait for ThresholdPattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  threshold_eval(
    self.pattern.scalar_at_with_info(point, normal, uv),
    self.threshold,
    self.low,
    self.high,
  )
}

///|
pub fn threshold_pattern(
  pattern : Pattern,
  threshold? : Double = 0.5,
  low? : Color = color(0.0, 0.0, 0.0),
  high? : Color = color(1.0, 1.0, 1.0),
) -> Pattern {
  Pattern::new(ThresholdPattern::{
    pattern: field(pattern),
    threshold,
    low,
    high,
  })
}

///|
pub(all) struct PosterizePattern {
  pattern : Pattern
  steps : Int
}

///|
pub impl Show for PosterizePattern with output(_self, logger) {
  logger.write_string("posterize(...)")
}

///|
pub impl PatternTrait for PosterizePattern with clone(self) {
  posterize_pattern(self.pattern.clone(), steps=self.steps)
}

///|
fn posterize_channel(x : Double, steps : Int) -> Double {
  let steps = if steps < 2 { 2 } else { steps }
  let levels = (steps - 1).to_double()
  let idx = @math.floor(clamp01(x) * steps.to_double()).to_int()
  let idx = if idx >= steps { steps - 1 } else { idx }
  idx.to_double() / levels
}

///|
pub impl PatternTrait for PosterizePattern with pattern_at(self, point) {
  let c = self.pattern.pattern_at(point)
  color(
    posterize_channel(c.red, self.steps),
    posterize_channel(c.green, self.steps),
    posterize_channel(c.blue, self.steps),
  )
}

///|
pub impl PatternTrait for PosterizePattern with uv_at(self, u, v) {
  let c = self.pattern.uv_at(u, v)
  color(
    posterize_channel(c.red, self.steps),
    posterize_channel(c.green, self.steps),
    posterize_channel(c.blue, self.steps),
  )
}

///|
pub impl PatternTrait for PosterizePattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  let c = self.pattern.pattern_at_with_info(point, normal, uv)
  color(
    posterize_channel(c.red, self.steps),
    posterize_channel(c.green, self.steps),
    posterize_channel(c.blue, self.steps),
  )
}

///|
pub fn posterize_pattern(pattern : Pattern, steps? : Int = 4) -> Pattern {
  Pattern::new(PosterizePattern::{ pattern, steps })
}

///|
pub(all) struct GradientMapPattern {
  pattern : Pattern
  colors : Array[Color]
}

///|
pub impl Show for GradientMapPattern with output(_self, logger) {
  logger.write_string("gradient_map(...)")
}

///|
pub impl PatternTrait for GradientMapPattern with clone(self) {
  gradient_map_pattern(self.pattern.clone(), self.colors)
}

///|
fn gradient_map_eval(colors : Array[Color], c : Color) -> Color {
  palette(colors, c.luminance())
}

///|
pub impl PatternTrait for GradientMapPattern with pattern_at(self, point) {
  gradient_map_eval(self.colors, self.pattern.pattern_at(point))
}

///|
pub impl PatternTrait for GradientMapPattern with uv_at(self, u, v) {
  gradient_map_eval(self.colors, self.pattern.uv_at(u, v))
}

///|
pub impl PatternTrait for GradientMapPattern with pattern_at_with_info(
  self,
  point,
  normal,
  uv,
) {
  gradient_map_eval(
    self.colors,
    self.pattern.pattern_at_with_info(point, normal, uv),
  )
}

///|
pub fn gradient_map_pattern(
  pattern : Pattern,
  colors : Array[Color],
) -> Pattern {
  Pattern::new(GradientMapPattern::{ pattern, colors })
}

///|
pub(all) struct TriplanarPattern {
  pattern : Pattern
  scale : Double
  sharpness : Double
}

///|
pub impl Show for TriplanarPattern with output(_self, logger) {
  logger.write_string("triplanar(...)")
}

///|
pub impl PatternTrait for TriplanarPattern with clone(self) {
  triplanar_pattern(
    self.pattern.clone(),
    scale=self.scale,
    sharpness=self.sharpness,
  )
}

///|
pub impl PatternTrait for TriplanarPattern with pattern_at(self, point) {
  // Fallback to Z projection when normal isn't available.
  self.pattern.uv_at(point.x * self.scale, point.y * self.scale)
}

///|
pub impl PatternTrait for TriplanarPattern with uv_at(self, u, v) {
  // UV isn't meaningful for triplanar; treat UV as a 2D plane.
  self.pattern.uv_at(u * self.scale, v * self.scale)
}

///|
pub impl PatternTrait for TriplanarPattern with pattern_at_with_info(
  self,
  point,
  normal,
  _uv,
) {
  let ax0 = normal.x.abs()
  let ay0 = normal.y.abs()
  let az0 = normal.z.abs()
  let sharp = if self.sharpness <= 1.0e-12 { 1.0 } else { self.sharpness }
  let ax = @math.pow(ax0, sharp)
  let ay = @math.pow(ay0, sharp)
  let az = @math.pow(az0, sharp)
  let sum = ax + ay + az
  if sum <= 1.0e-12 {
    return self.pattern.uv_at(point.x * self.scale, point.y * self.scale)
  }
  let wx = ax / sum
  let wy = ay / sum
  let wz = az / sum

  // Project point onto three planes and blend.
  let cx = self.pattern.uv_at(point.z * self.scale, point.y * self.scale)
  let cy = self.pattern.uv_at(point.x * self.scale, point.z * self.scale)
  let cz = self.pattern.uv_at(point.x * self.scale, point.y * self.scale)
  cx.mul_scalar(wx) + cy.mul_scalar(wy) + cz.mul_scalar(wz)
}

///|
pub fn triplanar_pattern(
  pattern : Pattern,
  scale? : Double = 1.0,
  sharpness? : Double = 1.0,
) -> Pattern {
  Pattern::new(TriplanarPattern::{ pattern, scale, sharpness })
}

///|
pub(all) struct InvertPattern {
  pattern : Pattern
}

///|
pub impl Show for InvertPattern with output(_self, logger) {
  logger.write_string("invert(...) ")
}

///|
pub impl PatternTrait for InvertPattern with clone(self) {
  invert_pattern(self.pattern.clone())
}

///|
pub impl PatternTrait for InvertPattern with pattern_at(self, point) {
  let c = self.pattern.pattern_at(point)
  color(1.0 - c.red, 1.0 - c.green, 1.0 - c.blue)
}

///|
pub impl PatternTrait for InvertPattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for InvertPattern with pattern_at_with_info(
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
pub fn invert_pattern(pattern : Pattern) -> Pattern {
  Pattern::new(InvertPattern::{ pattern, })
}

///|
pub(all) struct MixPattern {
  a : Pattern
  b : Pattern
  mask : Field
}

///|
pub impl Show for MixPattern with output(_self, logger) {
  logger.write_string("mix(...) ")
}

///|
pub impl PatternTrait for MixPattern with clone(self) {
  mix_pattern(self.a.clone(), self.b.clone(), self.mask.pattern.clone())
}

///|
pub impl PatternTrait for MixPattern with pattern_at(self, point) {
  let ca = self.a.pattern_at(point)
  let cb = self.b.pattern_at(point)
  let t = self.mask.scalar_at(point)
  lerp_color(ca, cb, t)
}

///|
pub impl PatternTrait for MixPattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for MixPattern with pattern_at_with_info(
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
pub fn mix_pattern(a : Pattern, b : Pattern, mask : Pattern) -> Pattern {
  Pattern::new(MixPattern::{ a, b, mask: field(mask) })
}

///|
pub(all) struct WarpPattern {
  base : Pattern
  warp : Field
  amplitude : Double
}

///|
pub impl Show for WarpPattern with output(_self, logger) {
  logger.write_string("warp(...) ")
}

///|
pub impl PatternTrait for WarpPattern with clone(self) {
  warp_pattern(
    self.base.clone(),
    self.warp.pattern.clone(),
    amplitude=self.amplitude,
  )
}

///|
pub impl PatternTrait for WarpPattern with pattern_at(self, p) {
  let dv = self.warp.vector_at(p)
  self.base.pattern_at(
    point(
      p.x + dv.x * self.amplitude,
      p.y + dv.y * self.amplitude,
      p.z + dv.z * self.amplitude,
    ),
  )
}

///|
pub impl PatternTrait for WarpPattern with uv_at(self, u, v) {
  self.pattern_at(point(u, 0.0, v))
}

///|
pub impl PatternTrait for WarpPattern with pattern_at_with_info(
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
pub fn warp_pattern(
  base : Pattern,
  warp : Pattern,
  amplitude? : Double = 0.25,
) -> Pattern {
  Pattern::new(WarpPattern::{ base, warp: field(warp), amplitude })
}
