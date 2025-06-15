///|
test "Ignoring unrecognized lines in an OBJ file (p.272)" {
  let gibberish =
    #|There was a young lady named Bright
    #|who traveled much faster than light.
    #|She set out one day
    #|in a relative way,
    #|and came back the previous night.
  let parser = parse_obj_file(gibberish)
  assert_eq(parser.ignored_lines, 5)
}

///|
test "Parse vertex records in an OBJ file (p.273)" {
  let file =
    #|v    -1    1   0
    #|v -1.00000 0.50000 0.00000
    #|v 1 0 0
    #|v 1 1 0
  let parser = parse_obj_file(file)
  assert_eq(parser.vertices[1], point(-1, 1, 0))
  assert_eq(parser.vertices[2], point(-1, 0.5, 0))
  assert_eq(parser.vertices[3], point(1, 0, 0))
  assert_eq(parser.vertices[4], point(1, 1, 0))
}

///|
test "Parse triangle faces in an OBJ file (p.274)" {
  let file =
    #|v -1 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|v 1 1 0
    #|
    #|f 1 2 3
    #|f 1 3 4
  let parser = parse_obj_file(file)
  let g = parser.default_group
  guard g.children()[0].object is Triangle(t1)
  guard g.children()[1].object is Triangle(t2)
  assert_eq(t1.p1, parser.vertices[1])
  assert_eq(t1.p2, parser.vertices[2])
  assert_eq(t1.p3, parser.vertices[3])
  assert_eq(t2.p1, parser.vertices[1])
  assert_eq(t2.p2, parser.vertices[3])
  assert_eq(t2.p3, parser.vertices[4])
}

///|
test "Triangulating polygons in an OBJ file (p.274)" {
  let file =
    #|v -1 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|v 1 1 0
    #|v 0 2 0
    #|
    #|f 1 2 3 4 5
  let parser = parse_obj_file(file)
  let g = parser.default_group
  guard g.children()[0].object is Triangle(t1)
  guard g.children()[1].object is Triangle(t2)
  guard g.children()[2].object is Triangle(t3)
  assert_eq(t1.p1, parser.vertices[1])
  assert_eq(t1.p2, parser.vertices[2])
  assert_eq(t1.p3, parser.vertices[3])
  assert_eq(t2.p1, parser.vertices[1])
  assert_eq(t2.p2, parser.vertices[3])
  assert_eq(t2.p3, parser.vertices[4])
  assert_eq(t3.p1, parser.vertices[1])
  assert_eq(t3.p2, parser.vertices[4])
  assert_eq(t3.p3, parser.vertices[5])
}

///|
test "Triangles in named groups in an OBJ file (p.275)" {
  let file =
    #|v -1 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|v 1 1 0
    #|
    #|g FirstGroup
    #|f 1 2 3
    #|g SecondGroup
    #|f 1 3 4
  let parser = parse_obj_file(file)
  let g1 = parser.named_groups.get("FirstGroup").unwrap()
  let g2 = parser.named_groups.get("SecondGroup").unwrap()
  guard g1.children()[0].object is Triangle(t1)
  guard g2.children()[0].object is Triangle(t2)
  assert_eq(t1.p1, parser.vertices[1])
  assert_eq(t1.p2, parser.vertices[2])
  assert_eq(t1.p3, parser.vertices[3])
  assert_eq(t2.p1, parser.vertices[1])
  assert_eq(t2.p2, parser.vertices[3])
  assert_eq(t2.p3, parser.vertices[4])
}

///|
test "Converting an OBJ file to a group (p.277)" {
  let file =
    #|v -1 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|v 1 1 0
    #|
    #|g FirstGroup
    #|f 1 2 3
    #|g SecondGroup
    #|f 1 3 4
  let parser = parse_obj_file(file)
  let g = parser.obj_to_group()
  assert_eq(g.children().length(), 2)
  let g1 = g.children()[0]
  assert_eq(g1.children().length(), 1)
  let g2 = g.children()[1]
  assert_eq(g2.children().length(), 1)
  guard g1.children()[0].object is Triangle(t1)
  guard g2.children()[0].object is Triangle(t2)
  assert_eq(t1.p1, parser.vertices[1])
  assert_eq(t1.p2, parser.vertices[2])
  assert_eq(t1.p3, parser.vertices[3])
  assert_eq(t2.p1, parser.vertices[1])
  assert_eq(t2.p2, parser.vertices[3])
  assert_eq(t2.p3, parser.vertices[4])
}

///|
test "Vertex normal records in an OBJ file (p.285)" {
  let file =
    #|vn 0 0 1
    #|vn 0.707 0 -0.707
    #|vn 1 2 3
  let parser = parse_obj_file(file)
  assert_eq(parser.normals[1], vector(0, 0, 1))
  assert_eq(parser.normals[2], vector(0.707, 0, -0.707))
  assert_eq(parser.normals[3], vector(1, 2, 3))
}

///|
test "Faces with normals in an OBJ file (p.285)" {
  let file =
    #|v 0 1 0
    #|v -1 0 0
    #|v 1 0 0
    #|
    #|vn -1 0 0
    #|vn 1 0 0
    #|vn 0 1 0
    #|
    #|f 1//3 2//1 3//2
    #|f 1/0/3 2/102/1 3/14/2
  let parser = parse_obj_file(file)
  let g = parser.default_group
  guard g.children()[0].object is SmoothTriangle(t1)
  guard g.children()[1].object is SmoothTriangle(t2)
  assert_eq(t1.p1, parser.vertices[1])
  assert_eq(t1.p2, parser.vertices[2])
  assert_eq(t1.p3, parser.vertices[3])
  assert_eq(t1.n1, parser.normals[3])
  assert_eq(t1.n2, parser.normals[1])
  assert_eq(t1.n3, parser.normals[2])
  assert_eq(t1, t2)
}
