///|
pub(all) enum LightKind {
  Point
  Area(Tuple, Int, Tuple, Int) // u_vec, u_steps, v_vec, v_steps
} derive(Show, Eq)

///|
pub(all) struct Light {
  position : Tuple // Corner for area light, position for point light
  intensity : Color
  kind : LightKind
} derive(Show, Eq)

///|
pub fn point_light(position : Tuple, intensity : Color) -> Light {
  { position, intensity, kind: Point }
}

///|
pub fn area_light(
  corner : Tuple,
  full_uvec : Tuple,
  u_steps : Int,
  full_vvec : Tuple,
  v_steps : Int,
  intensity : Color,
) -> Light {
  let uvec = full_uvec.div_scalar(u_steps.to_double())
  let vvec = full_vvec.div_scalar(v_steps.to_double())
  { position: corner, intensity, kind: Area(uvec, u_steps, vvec, v_steps) }
}

///|
pub fn Light::point_at_uv(self : Light, u : Double, v : Double) -> Tuple {
  match self.kind {
    Point => self.position
    Area(uvec, _, vvec, _) =>
      self.position + uvec.mul_scalar(u) + vvec.mul_scalar(v)
  }
}

///|
pub fn Light::point_at(self : Light, u : Int, v : Int) -> Tuple {
  match self.kind {
    Point => self.position
    Area(_, _, _, _) =>
      self.point_at_uv(u.to_double() + 0.5, v.to_double() + 0.5)
  }
}

///|
pub fn Light::samples(self : Light) -> Int {
  match self.kind {
    Point => 1
    Area(_, u_steps, _, v_steps) => u_steps * v_steps
  }
}

///|
pub fn Light::cap_area_steps(self : Light, max_steps : Int) -> Light {
  if max_steps <= 0 {
    return self
  }
  match self.kind {
    Point => self
    Area(uvec, u_steps, vvec, v_steps) => {
      let nu = if u_steps > max_steps { max_steps } else { u_steps }
      let nv = if v_steps > max_steps { max_steps } else { v_steps }
      if nu == u_steps && nv == v_steps {
        return self
      }
      // Preserve full light extent while changing sample grid resolution.
      let full_u = uvec.mul_scalar(u_steps.to_double())
      let full_v = vvec.mul_scalar(v_steps.to_double())
      let new_uvec = full_u.div_scalar(nu.to_double())
      let new_vvec = full_v.div_scalar(nv.to_double())
      {
        position: self.position,
        intensity: self.intensity,
        kind: Area(new_uvec, nu, new_vvec, nv),
      }
    }
  }
}
