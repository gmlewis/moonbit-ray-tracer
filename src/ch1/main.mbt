typealias Tuple = @lib.Tuple

let point = @lib.point

let vector = @lib.vector

struct Projectile {
  position : Tuple
  velocity : Tuple
} derive(Show)

fn projectile(position : Tuple, velocity : Tuple) -> Projectile {
  { position, velocity }
}

struct Environment {
  gravity : Tuple
  wind : Tuple
}

fn environment(gravity : Tuple, wind : Tuple) -> Environment {
  { gravity, wind }
}

///
fn main {
  // projectile starts one unit above the origin.
  // velocity is normalized to 1 unit/tick.
  let mut p = projectile(point(0, 1, 0), vector(1, 1, 0).normalize())
  // gravity is 0.1 unit/tick, and wind is -0.01 unit/tick.
  let e = environment(vector(0, -0.1, 0), vector(-0.01, 0, 0))
  let mut t = 0
  println("t=\{t}: pos=(\{p.position.x},\{p.position.y},\{p.position.z})")
  while p.position.y > 0 {
    p = tick(e, p)
    t += 1
    println("t=\{t}: pos=(\{p.position.x},\{p.position.y},\{p.position.z})")
  }
}

fn tick(env : Environment, proj : Projectile) -> Projectile {
  let position = proj.position + proj.velocity
  let velocity = proj.velocity + env.gravity + env.wind
  projectile(position, velocity)
}
