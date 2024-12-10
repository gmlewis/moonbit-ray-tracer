///|
let parse_obj_file = @lib.parse_obj_file

test "Ignoring unrecognized lines in an OBJ file (p.272)" {
  let gibberish =
    #|There was a young lady named Bright
    #|who traveled much faster than light.
    #|She set out one day
    #|in a relative way,
    #|and came back the previous night.
  let parser = parse_obj_file!(gibberish)
  assert_eq!(parser.ignored_lines, 5)
}

test "Parse vertex records in an OBJ file (p.273)" {
  let file =
    #|v    -1    1   0
    #|v -1.00000 0.50000 0.00000
    #|v 1 0 0
    #|v 1 1 0
  let parser = parse_obj_file!(file)
  assert_eq!(parser.vertices[1], point(-1, 1, 0))
  assert_eq!(parser.vertices[2], point(-1, 0.5, 0))
  assert_eq!(parser.vertices[3], point(1, 0, 0))
  assert_eq!(parser.vertices[4], point(1, 1, 0))
}

test "Parse triangle faces in an OBJ file (p.274)" {
  let file =
    #|v -1 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|v 1 1 0
    #|
    #|f 1 2 3
    #|f 1 3 4
  let parser = parse_obj_file!(file)
  let g = parser.default_group
  guard let Triangle(t1) = g.children()[0].object
  guard let Triangle(t2) = g.children()[1].object
  assert_eq!(t1.p1, parser.vertices[1])
  assert_eq!(t1.p2, parser.vertices[2])
  assert_eq!(t1.p3, parser.vertices[3])
  assert_eq!(t2.p1, parser.vertices[1])
  assert_eq!(t2.p2, parser.vertices[3])
  assert_eq!(t2.p3, parser.vertices[4])
}

test "Triangulating polygons in an OBJ file (p.274)" {
  let file =
    #|v -1 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|v 1 1 0
    #|v 0 2 0
    #|
    #|f 1 2 3 4 5
  let parser = parse_obj_file!(file)
  let g = parser.default_group
  guard let Triangle(t1) = g.children()[0].object
  guard let Triangle(t2) = g.children()[1].object
  guard let Triangle(t3) = g.children()[2].object
  assert_eq!(t1.p1, parser.vertices[1])
  assert_eq!(t1.p2, parser.vertices[2])
  assert_eq!(t1.p3, parser.vertices[3])
  assert_eq!(t2.p1, parser.vertices[1])
  assert_eq!(t2.p2, parser.vertices[3])
  assert_eq!(t2.p3, parser.vertices[4])
  assert_eq!(t3.p1, parser.vertices[1])
  assert_eq!(t3.p2, parser.vertices[4])
  assert_eq!(t3.p3, parser.vertices[5])
}
