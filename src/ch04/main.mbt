///|
let canvas = @lib.canvas

///|
let color = @lib.color

///|
let point = @lib.point

///|
fn main {
  let width = 900
  let height = 550
  let r = height.to_double() * 3 / 8
  let c = canvas(width, height)
  let white = color(1, 1, 1)
  for i in 0..<12 {
    let rad = i.to_double() * @math.PI / 6
    let t = @lib.mat4ident()
      .translate(r, 0, 0)
      .rotate_z(rad)
      .translate(width.to_double() / 2, height.to_double() / 2, 0)
    let p = t.mul_tuple(point(0, 0, 0))
    let x = @math.round(p.x).to_int()
    let y = @math.round(p.y).to_int()
    println("i=\{i}, rad=\{@lib.round_to_fixed(rad,2)}, p=\{p}, x=\{x}, y=\{y}")
    c.write_pixel(x, y, white)
    c.write_pixel(x + 1, y, white)
    c.write_pixel(x + 1, y + 1, white)
    c.write_pixel(x, y + 1, white)
  }

  //
  try {
    @fs.write_string_to_file!("ch4.ppm", c.to_ppm())
    @fs.write_bytes_to_file!("ch4.png", c.to_png!())
  } catch {
    _ => println("error writing ch4.png")
  }
}
