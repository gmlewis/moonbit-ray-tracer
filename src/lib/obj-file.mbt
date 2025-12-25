///|
pub(all) struct ObjFile {
  default_group : Shape
  ignored_lines : Int

  //
  vertices : Array[Tuple]
  normals : Array[Tuple]
  named_groups : Map[String, Shape]
}

///|
suberror ParserError String derive(Show, Eq)

///|
pub fn parse_obj_file(buf : String) -> ObjFile raise ParserError {
  let default_group = group()
  let mut last_group = default_group
  let mut ignored_lines = 0
  let vertices = [point(0, 0, 0)] // vertices[0] is unused
  let normals = [vector(0, 0, 0)] // normals[0] is unused
  let named_groups = {}

  // helper functions
  let add_vertex = fn(args : Array[Double]) -> Unit raise ParserError {
    guard 3 == args.length() else {
      raise ParserError("add_vertex expected 3 doubles, got \{args.length()}")
    }
    vertices.push(point(args[0], args[1], args[2]))
  }
  let add_normal = fn(args : Array[Double]) -> Unit raise ParserError {
    guard 3 == args.length() else {
      raise ParserError("add_normal expected 3 doubles, got \{args.length()}")
    }
    normals.push(vector(args[0], args[1], args[2]))
  }
  let add_triangles = fn(args : Array[Double]) -> Unit raise ParserError {
    guard args.length() >= 3 else {
      raise ParserError(
        "add_triangles expected at least 3 doubles, got \{args.length()}",
      )
    }
    let p1 = args[0].to_int()
    for i in 2..<args.length() {
      let p2 = args[i - 1].to_int()
      let p3 = args[i].to_int()
      last_group.add_child(triangle(vertices[p1], vertices[p2], vertices[p3]))
    }
  }
  let add_triangle_faces = fn(args : Array[String]) -> Unit raise ParserError {
    guard args.length() >= 3 else {
      raise ParserError(
        "add_triangle_faces expected at least 3 strings, got \{args.length()}",
      )
    }
    let (p1, n1) = parse_indices(args[0])
    for i in 2..<args.length() {
      let (p2, n2) = parse_indices(args[i - 1])
      let (p3, n3) = parse_indices(args[i])
      last_group.add_child(
        smooth_triangle(
          vertices[p1],
          vertices[p2],
          vertices[p3],
          normals[n1],
          normals[n2],
          normals[n3],
        ),
      )
    }
  }

  //
  let lines = buf.split("\n")
  for line in lines {
    let line = line.trim().to_string()
    if line.length() == 0 {
      // silently ignored
    } else if line.has_prefix("v ") {
      parse_args(
        line.unsafe_substring(start=2, end=line.length()),
        " ",
        add_vertex,
      )
    } else if line.has_prefix("vn ") {
      parse_args(
        line.unsafe_substring(start=3, end=line.length()),
        " ",
        add_normal,
      )
    } else if line.has_prefix("f ") {
      parse_args(
        line.unsafe_substring(start=2, end=line.length()),
        " ",
        add_triangles,
        string_fn=add_triangle_faces,
      )
    } else if line.has_prefix("g ") {
      let group_name = line
        .unsafe_substring(start=2, end=line.length())
        .trim()
        .to_string()
      last_group = group()
      named_groups[group_name] = last_group
    } else {
      ignored_lines += 1
    }
  }

  //
  { default_group, ignored_lines, vertices, normals, named_groups }
}

///|
fn parse_indices(s : String) -> (Int, Int) raise ParserError {
  let mut p = 0
  let mut n = 0
  let get_vert_and_normal_indices = fn(
    args : Array[Double],
  ) -> Unit raise ParserError {
    guard args.length() == 3 else {
      raise ParserError("parse_indices expected 3 ints, got \{s}")
    }
    p = args[0].to_int()
    n = args[2].to_int()
  }
  parse_args(s, "/", get_vert_and_normal_indices)
  (p, n)
}

///|
fn parse_args(
  s : String,
  sep : String,
  double_fn : (Array[Double]) -> Unit raise ParserError,
  string_fn? : (Array[String]) -> Unit raise ParserError = fn(_args) {  },
) -> Unit raise ParserError {
  let parts = s.split(sep).map(fn(s) { s.trim().to_string() }).collect()
  let doubles = Array::new(capacity=parts.length())
  for arg in parts {
    if arg == "" {
      if sep == "/" {
        doubles.push(0.0) // missing arg defaults to 0 when parsing face information
      }
      continue
    }
    try {
      let v = @strconv.parse_double(arg)
      doubles.push(v)
    } catch {
      _ => return string_fn(parts)
    }
  }
  double_fn(doubles)
}

///|
pub fn ObjFile::obj_to_group(self : ObjFile) -> Shape {
  let g = group()
  for child in self.default_group.children() {
    g.add_child(child)
  }
  for child in self.named_groups {
    g.add_child(child.1)
  }
  g
}
