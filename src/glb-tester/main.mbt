///|

///|
fn count_all_children(shape : @lib.Shape) -> Int {
  let mut count = shape.children().length()
  for child in shape.children() {
    count += count_all_children(child)
  }
  count
}

///|
async fn main {
  let args = @env.args()
  if args.length() < 2 {
    println("Usage: glb-tester <file.glb>")
    return
  }
  let path = args[1]
  println("Loading \{path}...")
  try {
    let shape = @lib.load_gltf_file(path)
    println("Successfully loaded \{path}")
    println("Total recursive children: \{count_all_children(shape)}")
    // Accessing internal data might be hard, I'll just check if @lib has it.
    // Actually I'll modify gltf_loader.mbt to print image info if requested or just always.
  } catch {
    e => {
      println("Failed to load \{path}: \{e}")
      abort("Test failed")
    }
  }
}
