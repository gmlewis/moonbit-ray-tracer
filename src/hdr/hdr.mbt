///|
pub(all) struct RGBE {
  r : Byte
  g : Byte
  b : Byte
  e : Byte
}

///|
pub fn RGBE::to_rgb(self : RGBE) -> (Double, Double, Double) {
  if self.e == (0).to_byte() {
    return (0.0, 0.0, 0.0)
  }
  let exponent = self.e.to_int() - 128
  let scale = @math.pow(2.0, exponent.to_double()) / 256.0
  (
    self.r.to_double() * scale,
    self.g.to_double() * scale,
    self.b.to_double() * scale,
  )
}

///|
pub(all) struct HdrImage {
  width : Int
  height : Int
  data : Array[Double] // R, G, B interleaved
}

///|
pub suberror HdrError {
  HdrError(String)
} derive(Show)

///|
pub fn decode(bytes : Bytes) -> HdrImage raise HdrError {
  let reader = @io.Buffer::from_bytes(bytes)

  // 1. Read header
  let mut line = read_line(reader)
  if line != "#?RADIANCE" && line != "#?RGBE" {
    raise HdrError("Invalid HDR header: " + line)
  }

  // Skip to resolution string
  while true {
    line = read_line(reader)
    if line == "" {
      break
    }
  }

  // 2. Read resolution
  line = read_line(reader)
  // Expecting e.g. "-Y 600 +X 1000"
  let parts = line.split(" ").collect()
  if parts.length() != 4 {
    raise HdrError("Invalid resolution line: " + line)
  }
  let height = @strconv.parse_int(parts[1].to_string()) catch {
    _ => raise HdrError("Invalid height: " + parts[1].to_string())
  }
  let width = @strconv.parse_int(parts[3].to_string()) catch {
    _ => raise HdrError("Invalid width: " + parts[3].to_string())
  }
  let data = Array::make(width * height * 3, 0.0)

  // 3. Read scanlines
  for y in 0..<height {
    read_scanline(reader, width, data, y * width * 3)
  }
  { width, height, data }
}

///|
fn read_line(reader : @io.Buffer) -> String {
  let sb = StringBuilder::new()
  while true {
    let (b, err) = reader.read_byte()
    if err is Some(_) {
      break
    }
    if b == (10).to_byte() { // \n
      break
    }
    if b != (13).to_byte() { // \r
      sb.write_char(b.to_int().unsafe_to_char())
    }
  }
  sb.to_string()
}

///|
fn next_byte(reader : @io.Buffer) -> Byte {
  let (b, _) = reader.read_byte()
  b
}

///|
fn read_scanline(
  reader : @io.Buffer,
  width : Int,
  data : Array[Double],
  offset : Int,
) -> Unit raise HdrError {
  if width < 8 || width > 0x7fff {
    // Non-RLE or very small
    read_old_scanline(reader, width, data, offset)
    return
  }
  let b1 = next_byte(reader)
  let b2 = next_byte(reader)
  let b3 = next_byte(reader)
  let b4 = next_byte(reader)
  if b1 != (2).to_byte() || b2 != (2).to_byte() || (b3.to_int() & 0x80) != 0 {
    // Not new RLE format
    raise HdrError("Old HDR RLE format not supported")
  }
  let found_width = (b3.to_int() << 8) | b4.to_int()
  if found_width != width {
    raise HdrError("Scanline width mismatch")
  }
  let rgbe_buf : FixedArray[Byte] = FixedArray::make(width * 4, (0).to_byte())

  // Read each component separately (R, G, B, E)
  for i in 0..<4 {
    let mut j = 0
    while j < width {
      let code = next_byte(reader).to_int()
      if code > 128 {
        // Run
        let count = code - 128
        let val = next_byte(reader)
        for _ in 0..<count {
          if j < width {
            rgbe_buf[j * 4 + i] = val
            j += 1
          }
        }
      } else {
        // Non-run
        let count = code
        for _ in 0..<count {
          let val = next_byte(reader)
          if j < width {
            rgbe_buf[j * 4 + i] = val
            j += 1
          }
        }
      }
    }
  }

  // Convert to double
  for i in 0..<width {
    let rgbe = RGBE::{
      r: rgbe_buf[i * 4 + 0],
      g: rgbe_buf[i * 4 + 1],
      b: rgbe_buf[i * 4 + 2],
      e: rgbe_buf[i * 4 + 3],
    }
    let (r, g, b) = rgbe.to_rgb()
    data[offset + i * 3 + 0] = r
    data[offset + i * 3 + 1] = g
    data[offset + i * 3 + 2] = b
  }
}

///|
fn read_old_scanline(
  _reader : @io.Buffer,
  _width : Int,
  _data : Array[Double],
  _offset : Int,
) -> Unit raise HdrError {
  raise HdrError("Old HDR format not supported")
}
