///|
// Small deterministic noise helpers for procedural textures.
//
// These are intentionally simple and portable (no bitwise RNG needed):
// a lattice hash based on sin() + fract(), then smooth interpolation.

///|
fn fract(x : Double) -> Double {
  x - @math.floor(x)
}

///|
fn lerp(a : Double, b : Double, t : Double) -> Double {
  a + (b - a) * t
}

///|
fn fade(t : Double) -> Double {
  // Smoothstep: 3t^2 - 2t^3
  t * t * (3.0 - 2.0 * t)
}

///|
fn hash3(ix : Int, iy : Int, iz : Int, seed : Int) -> Double {
  // Deterministic pseudo-random in [0, 1)
  let x = ix.to_double()
  let y = iy.to_double()
  let z = iz.to_double()
  let s = seed.to_double()
  let v = @math.sin(x * 127.1 + y * 311.7 + z * 74.7 + s * 19.19) *
    43758.5453123
  fract(v)
}

///|
pub fn value_noise3(p : Tuple, seed : Int) -> Double {
  let x0 = @math.floor(p.x).to_int()
  let y0 = @math.floor(p.y).to_int()
  let z0 = @math.floor(p.z).to_int()
  let x1 = x0 + 1
  let y1 = y0 + 1
  let z1 = z0 + 1
  let tx = fade(p.x - x0.to_double())
  let ty = fade(p.y - y0.to_double())
  let tz = fade(p.z - z0.to_double())
  let c000 = hash3(x0, y0, z0, seed)
  let c100 = hash3(x1, y0, z0, seed)
  let c010 = hash3(x0, y1, z0, seed)
  let c110 = hash3(x1, y1, z0, seed)
  let c001 = hash3(x0, y0, z1, seed)
  let c101 = hash3(x1, y0, z1, seed)
  let c011 = hash3(x0, y1, z1, seed)
  let c111 = hash3(x1, y1, z1, seed)
  let x00 = lerp(c000, c100, tx)
  let x10 = lerp(c010, c110, tx)
  let x01 = lerp(c001, c101, tx)
  let x11 = lerp(c011, c111, tx)
  let y0v = lerp(x00, x10, ty)
  let y1v = lerp(x01, x11, ty)
  lerp(y0v, y1v, tz)
}

///|
pub fn fbm3(
  p : Tuple,
  seed : Int,
  octaves : Int,
  lacunarity : Double,
  gain : Double,
) -> Double {
  let octaves = if octaves < 1 { 1 } else { octaves }
  let mut freq = 1.0
  let mut amp = 1.0
  let mut sum = 0.0
  let mut amp_sum = 0.0
  for _ in 0..<octaves {
    sum = sum + value_noise3(p.mul_scalar(freq), seed) * amp
    amp_sum = amp_sum + amp
    freq = freq * lacunarity
    amp = amp * gain
  }
  if amp_sum <= 0.0 {
    0.0
  } else {
    sum / amp_sum
  }
}

///|
fn hash2(ix : Int, iy : Int, seed : Int) -> (Double, Double) {
  // Two independent hashes in [0,1)
  let a = hash3(ix, iy, 0, seed)
  let b = hash3(ix, iy, 1, seed + 101)
  (a, b)
}

///|
pub fn voronoi2(p : Tuple, seed : Int, jitter : Double) -> (Double, Int, Int) {
  // 2D Voronoi on (x,z)
  let x = p.x
  let y = p.z
  let ix = @math.floor(x).to_int()
  let iy = @math.floor(y).to_int()
  let mut best : Double = @double.max_value
  let mut best_ix = ix
  let mut best_iy = iy

  // Check neighbor cells
  for dx in -1..<2 {
    for dy in -1..<2 {
      let cx = ix + dx
      let cy = iy + dy
      let (rx, ry) = hash2(cx, cy, seed)
      let fx = cx.to_double() + rx * jitter
      let fy = cy.to_double() + ry * jitter
      let dxv = x - fx
      let dyv = y - fy
      let d2 = dxv * dxv + dyv * dyv
      if d2 < best {
        best = d2
        best_ix = cx
        best_iy = cy
      }
    }
  }
  (best.sqrt(), best_ix, best_iy)
}

///|
pub fn voronoi2_f1_f2(
  p : Tuple,
  seed : Int,
  jitter : Double,
) -> (Double, Double, Int, Int) {
  // Returns F1, F2 (Euclidean), and the winning cell coords.
  // 2D Voronoi on (x,z)
  let x = p.x
  let y = p.z
  let ix = @math.floor(x).to_int()
  let iy = @math.floor(y).to_int()
  let mut best1 : Double = @double.max_value
  let mut best2 : Double = @double.max_value
  let mut best_ix = ix
  let mut best_iy = iy

  // Check neighbor cells
  for dx in -1..<2 {
    for dy in -1..<2 {
      let cx = ix + dx
      let cy = iy + dy
      let (rx, ry) = hash2(cx, cy, seed)
      let fx = cx.to_double() + rx * jitter
      let fy = cy.to_double() + ry * jitter
      let dxv = x - fx
      let dyv = y - fy
      let d2 = dxv * dxv + dyv * dyv
      if d2 < best1 {
        best2 = best1
        best1 = d2
        best_ix = cx
        best_iy = cy
      } else if d2 < best2 {
        best2 = d2
      }
    }
  }
  (best1.sqrt(), best2.sqrt(), best_ix, best_iy)
}
