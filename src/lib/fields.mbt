///|
// Lightweight field abstraction for procedural texture graphs.
//
// A Field is backed by a Pattern but provides standardized sampling as:
// - scalar (for masks/height)
// - color  (for albedo)
// - vector (for warps/flows)

///|
pub enum VectorDecoding {
  /// Interpret RGB as [0,1] components.
  Unit01
  /// Interpret RGB as [-1,1] components via (c*2-1).
  Signed
} derive(Show, Eq)

///|
pub struct Field {
  pattern : Pattern
  vector_decoding : VectorDecoding
} derive(Show)

///|
pub fn field(
  pattern : Pattern,
  vector_decoding? : VectorDecoding = VectorDecoding::Signed,
) -> Field {
  { pattern, vector_decoding }
}

///|
pub fn field_signed(pattern : Pattern) -> Field {
  field(pattern, vector_decoding=VectorDecoding::Signed)
}

///|
pub fn field_unit01(pattern : Pattern) -> Field {
  field(pattern, vector_decoding=VectorDecoding::Unit01)
}

///|
pub fn Field::color_at(self : Field, p : Tuple) -> Color {
  self.pattern.pattern_at(p)
}

///|
pub fn Field::color_uv_at(self : Field, u : Double, v : Double) -> Color {
  self.pattern.uv_at(u, v)
}

///|
pub fn Field::color_at_with_info(
  self : Field,
  p : Tuple,
  normal : Tuple,
  uv : (Double, Double)?,
) -> Color {
  self.pattern.pattern_at_with_info(p, normal, uv)
}

///|
pub fn Field::scalar_at(self : Field, p : Tuple) -> Double {
  self.color_at(p).luminance()
}

///|
pub fn Field::scalar_uv_at(self : Field, u : Double, v : Double) -> Double {
  self.color_uv_at(u, v).luminance()
}

///|
pub fn Field::scalar_at_with_info(
  self : Field,
  p : Tuple,
  normal : Tuple,
  uv : (Double, Double)?,
) -> Double {
  self.color_at_with_info(p, normal, uv).luminance()
}

///|
fn decode_vector(c : Color, mode : VectorDecoding) -> Tuple {
  match mode {
    VectorDecoding::Unit01 => vector(c.red, c.green, c.blue)
    VectorDecoding::Signed =>
      vector(c.red * 2.0 - 1.0, c.green * 2.0 - 1.0, c.blue * 2.0 - 1.0)
  }
}

///|
pub fn Field::vector_at(self : Field, p : Tuple) -> Tuple {
  decode_vector(self.color_at(p), self.vector_decoding)
}

///|
pub fn Field::vector_uv_at(self : Field, u : Double, v : Double) -> Tuple {
  decode_vector(self.color_uv_at(u, v), self.vector_decoding)
}

///|
pub fn Field::vector_at_with_info(
  self : Field,
  p : Tuple,
  normal : Tuple,
  uv : (Double, Double)?,
) -> Tuple {
  decode_vector(self.color_at_with_info(p, normal, uv), self.vector_decoding)
}
