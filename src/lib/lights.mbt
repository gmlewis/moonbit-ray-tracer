///|
pub(all) struct Light {
  position : Tuple
  intensity : Color
} derive(Show, Eq)

///|
pub fn point_light(position : Tuple, intensity : Color) -> Light {
  { position, intensity }
}
