///|
pub(all) struct BinaryReader {
  bytes : Bytes
  mut offset : Int
}

///|
pub fn BinaryReader::new(bytes : Bytes, offset? : Int) -> BinaryReader {
  let offset = match offset {
    Some(v) => v
    None => 0
  }
  { bytes, offset }
}

///|
pub fn BinaryReader::read_uint8(self : BinaryReader) -> UInt {
  let b = self.bytes[self.offset].to_int()
  self.offset += 1
  b.reinterpret_as_uint()
}

///|
pub fn BinaryReader::read_uint16(self : BinaryReader) -> UInt {
  let b1 = self.bytes[self.offset].to_int()
  let b2 = self.bytes[self.offset + 1].to_int()
  self.offset += 2
  (b1 | (b2 << 8)).reinterpret_as_uint()
}

///|
pub fn BinaryReader::read_uint32(self : BinaryReader) -> UInt {
  let b1 = self.bytes[self.offset].to_int()
  let b2 = self.bytes[self.offset + 1].to_int()
  let b3 = self.bytes[self.offset + 2].to_int()
  let b4 = self.bytes[self.offset + 3].to_int()
  self.offset += 4
  (b1 | (b2 << 8) | (b3 << 16) | (b4 << 24)).reinterpret_as_uint()
}

///|
pub fn BinaryReader::read_float32(self : BinaryReader) -> Float {
  let bits = self.read_uint32()
  Float::reinterpret_from_uint(bits)
}

///|
pub fn decode_base64_uri(uri : String) -> Bytes? {
  if not(uri.has_prefix("data:")) {
    return None
  }
  let mut comma_idx = -1
  for i in 0..<uri.length() {
    if uri[i] == ',' {
      comma_idx = i
      break
    }
  }
  if comma_idx == -1 {
    return None
  }
  let base64_str = uri.unsafe_substring(start=comma_idx + 1, end=uri.length())
  Some(@base64.std_decode2bytes(base64_str)) catch {
    _ => None
  }
}

///|
pub fn get_directory(path : String) -> String {
  let mut last_slash = -1
  for i in 0..<path.length() {
    if path[i] == '/' {
      last_slash = i
    }
  }
  if last_slash == -1 {
    return "."
  }
  path.unsafe_substring(start=0, end=last_slash)
}
