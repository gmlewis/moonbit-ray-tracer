///|
let canvas = @lib.canvas

test "Creating a canvas (p.46)" {
  let c = canvas(10, 20)
  assert_eq!(c.width, 10)
  assert_eq!(c.height, 20)
  for y in 0..<c.height {
    for x in 0..<c.width {
      assert_eq!(c.pixel_at(x, y), color(0, 0, 0))
    }
  }
}

test "Writing pixels to a canvas (p.46)" {
  let c = canvas(10, 20)
  let red = color(1, 0, 0)
  c.write_pixel(2, 3, red)
  assert_eq!(c.pixel_at(2, 3), red)
  assert_eq!(c.pixel_at(0, 0), color(0, 0, 0))
}

test "Constructing the PPM header (p.48)" {
  let c = canvas(5, 3)
  let ppm = c.to_ppm()
  // let lines1to3 = (ppm.split("\n")[0:3]).join("\n")
  // YUCK! https://github.com/moonbitlang/core/pull/993
  let lines1to3 = String::concat(ppm.split("\n")[0:3].collect(), separator="\n")
  inspect!(
    lines1to3,
    content=
      #|P3
      #|5 3
      #|255
    ,
  )
}

test "Constructing the PPM pixel data (p.48)" {
  let c = canvas(5, 3)
  let c1 = color(1.5, 0, 0)
  let c2 = color(0, 0.5, 0)
  let c3 = color(-0.5, 0, 1)
  let ppm = c
    ..write_pixel(0, 0, c1)
    ..write_pixel(2, 1, c2)
    ..write_pixel(4, 2, c3)
    .to_ppm()
  // let lines4to6 = (ppm.split("\n")[3:6]).join("\n")
  // YUCK! https://github.com/moonbitlang/core/pull/993
  let lines4to6 = String::concat(ppm.split("\n")[3:6].collect(), separator="\n")
  inspect!(
    lines4to6,
    content=
      #|255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      #|0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
      #|0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
    ,
  )
}

test "Constructing the PNG pixel data" {
  let c = canvas(5, 3)
  let c1 = color(1.5, 0, 0)
  let c2 = color(0, 0.5, 0)
  let c3 = color(-0.5, 0, 1)
  let png = c
    ..write_pixel(0, 0, c1)
    ..write_pixel(2, 1, c2)
    ..write_pixel(4, 2, c3)
    .to_png!()
  inspect!(
    png,
    content=
      #|b"\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52\x00\x00\x00\x05\x00\x00\x00\x03\x08\x02\x00\x00\x00\xd4\x54\x52\xaf\x00\x00\x00\x20\x49\x44\x41\x54\x78\x01\x04\xc0\x01\x11\x00\x00\x08\x03\x21\xce\xe4\x36\xff\x71\x01\x00\x00\x0f\x00\x00\xb4\x00\x00\x00\xff\xff\x3c\x60\x02\x81\xd1\xde\x8a\xab\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82"
    ,
  )
}
