# Scene Examples

This directory contains example scene files demonstrating the TOML scene description format for the MoonBit Ray Tracer.

## Examples

### [`simple-sphere.toml`](simple-sphere.toml)
The simplest possible scene with a single red sphere and basic lighting. Good starting point for learning the format.

**Features demonstrated:**
- Basic scene metadata
- Camera setup
- Point light
- Material definition
- Simple sphere object

### [`checkers-scene.toml`](checkers-scene.toml)
Recreates the `ch10-checkers` example from the original codebase. Shows multiple spheres with colorful checkerboard patterns.

**Features demonstrated:**
- Multi-color patterns
- Pattern transformations
- Multiple objects with shared materials
- Transform chains (scale, rotate, translate)

### [`glass-spheres.toml`](glass-spheres.toml)
Demonstrates advanced materials including transparency, refraction, and reflection.

**Features demonstrated:**
- Glass materials with transparency and refraction
- Mirror materials with high reflectivity
- Multiple light sources
- Higher bounce counts for realistic glass rendering
- Pattern application to floors

### [`csg-demo.toml`](csg-demo.toml)
Shows Constructive Solid Geometry (CSG) operations for complex shape creation.

**Features demonstrated:**
- CSG union operations
- CSG intersection operations
- CSG difference operations
- Nested CSG operations
- Complex hierarchical shapes

### [`patterns-showcase.toml`](patterns-showcase.toml)
Comprehensive demonstration of all available pattern types and their applications.

**Features demonstrated:**
- Classic pattern types: stripes, checkers, gradient, rings, gradient_rings, gradient_checkers
- Pattern transformations (scale, rotation)
- Patterns on different shape types
- Pattern color definitions

### [`procedural-textures.toml`](procedural-textures.toml)
Demonstrates procedural patterns (noise/fBm/marble/wood/voronoi) and compositing (invert/mix/warp).

**Features demonstrated:**
- Procedural textures that don’t require images
- Nested inline pattern definitions for compositing
- Domain warping for more organic results

### [`glb-demo.toml`](glb-demo.toml)
Demonstrates loading a GLB model.

### [`triplanar-glb-demo.toml`](triplanar-glb-demo.toml)
Demonstrates overriding a GLB’s materials with a procedural `triplanar` pattern.

### [`normal-tangent-mirror-demo.toml`](normal-tangent-mirror-demo.toml)
Demonstrates using glTF-provided mesh tangents (ATTRIBUTE `TANGENT`) for correct tangent-space normal mapping, including mirrored handedness.

### [`levels-demo.toml`](levels-demo.toml)
Demonstrates `levels` (remap + gamma shaping) applied to procedural noise.

### [`bias-gain-demo.toml`](bias-gain-demo.toml)
Demonstrates `bias_gain` (bias shifts midtones; gain reshapes shadows/highlights).

### [`contrast-demo.toml`](contrast-demo.toml)
Demonstrates `contrast` around a pivot (default 0.5).

### [`threshold-demo.toml`](threshold-demo.toml)
Demonstrates `threshold` turning noise into bold graphic masks.

### [`posterize-demo.toml`](posterize-demo.toml)
Demonstrates `posterize` quantization (bolder banding as steps decrease).

### [`gradient-map-demo.toml`](gradient-map-demo.toml)
Demonstrates `gradient_map` (palette mapping from noise luminance).

### [`triplanar-demo.toml`](triplanar-demo.toml)
Demonstrates `triplanar` projection using surface normals.

### [`voronoi-edges-demo.toml`](voronoi-edges-demo.toml)
Demonstrates Voronoi `edges` and `crackle` modes.

### [`voronoi-f1f2-demo.toml`](voronoi-f1f2-demo.toml)
Demonstrates Voronoi `f1`, `f2`, and `f2_minus_f1` feature-distance outputs.

### [`bump-demo.toml`](bump-demo.toml)
Demonstrates procedural bump mapping using `normal_pattern` + `normal_strength`.

### [`displacement-demo.toml`](displacement-demo.toml)
Demonstrates `displacement_pattern` + `displacement_strength` (simple shading-time displacement; no silhouette changes).

### [`material-layer-demo.toml`](material-layer-demo.toml)
Demonstrates blending two full materials using `layer_material` + `layer_mask`.

### [`pbr-demo.toml`](pbr-demo.toml)
Demonstrates a basic PBR setup with varying constant `metallic` and `roughness`.

### [`pbr-channels-demo.toml`](pbr-channels-demo.toml)
Demonstrates driving PBR channels from procedural patterns via `metallic_pattern` and `roughness_pattern`.

What to look for:
- Metallic sphere shows alternating bands that shift between metal-like vs dielectric-like response.
- Roughness spheres show varying highlight sharpness (smooth fBm) and chunky regions (posterized).

### [`mask-demo.toml`](mask-demo.toml)
Demonstrates using any pattern graph as a **mask** (scalar field) to drive `mix`.

### [`graphic-mask-demo.toml`](graphic-mask-demo.toml)
Demonstrates loading a `gmlewis/fonts/draw` `Graphic` from JSON and using it as a crisp vector mask.

Regenerate the demo asset (from the gmlewis/fonts repo):

```bash
echo "MoonBit Render Test" | ./scripts/render-to-json.py -o examples/assets/moonbit-bloom.json
```

### [`warp-field-demo.toml`](warp-field-demo.toml)
Demonstrates using any pattern graph as a **warp field** (vector-ish RGB) to drive domain warping.

## Using the Examples

1. Copy any example file as a starting point for your own scenes
2. Modify the camera position, lighting, or materials to experiment
3. Add or remove objects to create your own compositions
4. Adjust render settings like resolution and sample count

## Common Patterns

### Creating Materials
```toml
[materials.my_material]
color = [0.8, 0.2, 0.2]
ambient = 0.1
diffuse = 0.9
specular = 0.9
shininess = 200.0
reflective = 0.0
transparency = 0.0
refractive_index = 1.0
```

### Adding Objects
```toml
# Using named material
[[objects]]
type = "sphere"
material = "my_material"
[objects.transform]
translation = [1.0, 0.0, 0.0]
scale = [2.0, 1.0, 1.0]
rotation = [0.0, 1.571, 0.0]  # π/2 radians

# Using inline material (cannot combine with material = "name")
[[objects]]
type = "cube"
[objects.material]
color = [0.8, 0.2, 0.2]
ambient = 0.1
diffuse = 0.9
specular = 0.9
shininess = 200.0
reflective = 0.0
transparency = 0.0
refractive_index = 1.0
[objects.transform]
translation = [2.0, 0.0, 0.0]
```

### Defining Patterns
```toml
[patterns.my_pattern]
type = "checkers"
colors = [
  [1.0, 0.0, 0.0],  # Red
  [1.0, 1.0, 1.0]   # White
]
```

## Tips

- Use `field_of_view = 1.047` (π/3 radians) for a natural 60-degree view
- Place lights at `[-10, 10, -10]` for good default lighting
- Use `max_bounces = 4` for most scenes, increase to 8+ for heavy glass/mirror scenes
- Background colors like `[0.1, 0.1, 0.15]` provide nice contrast
- Material `reflective` and `transparency` values should generally sum to ≤ 1.0 for physically plausible results

## Common TOML Validation Issues

**❌ Don't mix material reference and inline material:**
```toml
[[objects]]
type = "sphere"
material = "my_material"    # ← This conflicts with the next line
[objects.material]          # ← This conflicts with the previous line
color = [1.0, 0.0, 0.0]
```

**✅ Use either a reference OR inline material:**
```toml
# Option 1: Use material reference only
[[objects]]
type = "sphere"
material = "my_material"

# Option 2: Use inline material only
[[objects]]
type = "cube"
[objects.material]
color = [1.0, 0.0, 0.0]
ambient = 0.1
diffuse = 0.9
```
