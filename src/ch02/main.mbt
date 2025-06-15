///|
typealias @lib.Tuple

///|
let canvas = @lib.canvas

///|
let color = @lib.color

///|
let point = @lib.point

///|
let vector = @lib.vector

///|
struct Projectile {
  position : Tuple
  velocity : Tuple
} derive(Show)

///|
fn projectile(position : Tuple, velocity : Tuple) -> Projectile {
  { position, velocity }
}

///|
struct Environment {
  gravity : Tuple
  wind : Tuple
}

///|
fn environment(gravity : Tuple, wind : Tuple) -> Environment {
  { gravity, wind }
}

///|
fn main {
  // projectile starts one unit above the origin.
  // velocity is normalized to 1 unit/tick.
  let mut p = projectile(
    point(0, 1, 0),
    vector(1, 1.8, 0).normalize().mul_scalar(11.25),
  )
  // gravity is 0.1 unit/tick, and wind is -0.01 unit/tick.
  let e = environment(vector(0, -0.1, 0), vector(-0.01, 0, 0))
  let mut t = 0

  //
  let max_height = 550
  let c = canvas(900, max_height + 1)
  let red = color(1, 0, 0)
  println("t=\{t}: pos=(\{p.position.x},\{p.position.y},\{p.position.z})")
  while p.position.y > 0 {
    let x = @math.round(p.position.x).to_int()
    let y = max_height - @math.round(p.position.y).to_int()
    c.write_pixel(x, y, red)
    c.write_pixel(x + 1, y, red)
    c.write_pixel(x + 1, y + 1, red)
    c.write_pixel(x, y + 1, red)
    p = tick(e, p)
    t += 1
    println("t=\{t}: pos=(\{p.position.x},\{p.position.y},\{p.position.z})")
  }

  //
  try {
    @fs.write_string_to_file("ch2.ppm", c.to_ppm())
    @fs.write_bytes_to_file("ch2.png", c.to_png())
  } catch {
    _ => println("error writing ch2.png")
  }
}

///|
fn tick(env : Environment, proj : Projectile) -> Projectile {
  let position = proj.position + proj.velocity
  let velocity = proj.velocity + env.gravity + env.wind
  projectile(position, velocity)
}
