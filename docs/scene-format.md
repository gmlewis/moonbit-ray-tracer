# TOML Scene Description Format

This document specifies the TOML-based scene description format for the MoonBit Ray Tracer.

## Overview

The scene format uses TOML (Tom's Obvious, Minimal Language) to describe 3D scenes in a human-readable and machine-parseable way. Each scene file contains:

- **Metadata**: Scene information and render settings
- **Camera**: Viewpoint and projection settings
- **Lights**: Illumination sources
- **Materials**: Reusable material definitions
- **Patterns**: Reusable pattern definitions
- **Objects**: 3D shapes and their properties

## File Structure

```toml
[scene]
# Scene metadata and render settings

[camera]
# Camera configuration

[[lights]]
# Light source definitions (array of tables)

[materials]
# Named material definitions

[patterns]
# Named pattern definitions

[[objects]]
# Scene objects (array of tables)
```

## Scene Metadata

```toml
[scene]
name = "My Scene"
description = "A beautiful ray-traced scene"
version = "1.0"

[scene.render]
width = 800
height = 600
samples = 1          # Anti-aliasing samples per pixel
max_bounces = 4      # Maximum reflection/refraction bounces
background = [0.0, 0.0, 0.0]  # Background color [R, G, B]
```

## Camera Configuration

```toml
[camera]
# Camera position in world space
position = [0.0, 1.5, -5.0]
# Point the camera is looking at
look_at = [0.0, 1.0, 0.0]
# Up vector for camera orientation
up = [0.0, 1.0, 0.0]
# Field of view in radians
field_of_view = 1.047  # π/3 radians (60 degrees)
```

## Lights

```toml
[[lights]]
type = "point"
position = [-10.0, 10.0, -10.0]
intensity = [1.0, 1.0, 1.0]  # RGB intensity

[[lights]]
type = "area"
position = [0.0, 5.0, 0.0]
intensity = [0.8, 0.9, 1.0]
width = 2.0
height = 2.0
```

### Light Types
- `"point"`: Point light source
- `"area"`: Area light source (future)
- `"environment"`: Environment/IBL lighting (future)

## Materials

```toml
[materials.red_plastic]
color = [0.8, 0.2, 0.2]
ambient = 0.1
diffuse = 0.7
specular = 0.2
shininess = 200.0
reflective = 0.0
transparency = 0.0
refractive_index = 1.0

[materials.glass]
color = [1.0, 1.0, 1.0]
ambient = 0.0
diffuse = 0.1
specular = 0.9
shininess = 300.0
reflective = 0.9
transparency = 0.9
refractive_index = 1.5

[materials.mirror]
color = [0.1, 0.1, 0.1]
ambient = 0.0
diffuse = 0.1
specular = 0.9
shininess = 200.0
reflective = 0.9
transparency = 0.0
refractive_index = 1.0
```

### Material Properties
- `color`: Base color [R, G, B] (0.0-1.0)
- `ambient`: Ambient reflection coefficient (0.0-1.0)
- `diffuse`: Diffuse reflection coefficient (0.0-1.0)
- `specular`: Specular reflection coefficient (0.0-1.0)
- `shininess`: Specular highlight size (>= 1.0)
- `reflective`: Reflection coefficient (0.0-1.0)
- `transparency`: Transparency coefficient (0.0-1.0)
- `refractive_index`: Index of refraction (>= 1.0)

## Patterns

```toml
[patterns.checkers]
type = "checkers"
colors = [
  [1.0, 1.0, 1.0],  # White
  [0.0, 0.0, 0.0],  # Black
  [1.0, 0.0, 0.0],  # Red
  [0.0, 1.0, 0.0],  # Green
]

[patterns.stripes]
type = "stripes"
colors = [
  [1.0, 0.0, 0.0],  # Red
  [1.0, 1.0, 0.0],  # Yellow
]

[patterns.gradient]
type = "gradient"
colors = [
  [1.0, 0.0, 0.0],  # Red
  [0.0, 0.0, 1.0],  # Blue
]

[patterns.rings]
type = "rings"
colors = [
  [1.0, 1.0, 1.0],  # White
  [0.0, 0.0, 0.0],  # Black
]

[patterns.gradient_rings]
type = "gradient_rings"
colors = [
  [1.0, 0.0, 0.0],  # Red
  [0.0, 1.0, 0.0],  # Green
  [0.0, 0.0, 1.0],  # Blue
]

[patterns.gradient_checkers]
type = "gradient_checkers"
colors = [
  [1.0, 0.0, 0.0],  # Red
  [0.0, 1.0, 0.0],  # Green
]
```

### Pattern Types
- `"checkers"`: 3D checkerboard pattern
- `"stripes"`: Vertical stripes along X-axis
- `"gradient"`: Linear gradient along X-axis
- `"rings"`: Concentric rings around Y-axis
- `"gradient_rings"`: Concentric rings with gradient
- `"gradient_checkers"`: Checkerboard with gradient

### Procedural Pattern Types

These patterns are generated procedurally (no image file required):

- `"noise"`: 3D value noise (grayscale)
  - Params: `seed` (int, default `0`), `scale` (float, default `1.0`)
- `"fbm"`: Fractal Brownian motion built from value noise (grayscale)
  - Params: `seed` (0), `scale` (1.0), `octaves` (5), `lacunarity` (2.0), `gain` (0.5)
- `"marble"`: Marble-like sine bands modulated by fBm (uses a color palette)
  - Requires: `colors`
  - Params: `seed` (0), `scale` (1.0), `octaves` (5), `lacunarity` (2.0), `gain` (0.5),
    `frequency` (5.0), `strength` (2.0)
- `"wood"`: Wood-like radial rings with turbulence (uses a color palette)
  - Requires: `colors`
  - Params: `seed` (0), `scale` (1.0), `octaves` (5), `lacunarity` (2.0), `gain` (0.5),
    `ring_frequency` (6.0), `turbulence` (0.5)
- `"voronoi"`: 2D Voronoi (cellular) pattern evaluated on X/Z
  - Params: `seed` (0), `scale` (1.0), `jitter` (1.0), `mode` (`"distance"` or `"cells"`, default `"distance"`)

Example:

```toml
[patterns.my_voronoi]
type = "voronoi"
seed = 1
scale = 4.0
jitter = 1.0
mode = "cells"
```

### Compositing Pattern Types

These patterns combine other patterns. Sub-patterns are provided as inline TOML tables.

- `"invert"`: Invert a pattern’s RGB
  - Requires: `pattern` (inline pattern table)
- `"mix"`: Blend two patterns using a mask pattern’s luminance as $t$ in `lerp(a,b,t)`
  - Requires: `a`, `b`, `mask` (inline pattern tables)
- `"warp"`: Domain-warp `base` by offsetting the lookup point using `warp` RGB
  - Requires: `base`, `warp` (inline pattern tables)
  - Params: `amplitude` (float, default `0.25`)

Example:

```toml
[patterns.warped_marble]
type = "warp"
amplitude = 0.25

base = { type = "marble", colors = [[0.9,0.9,0.95], [0.2,0.2,0.25]], scale = 2.0, frequency = 6.0 }
warp = { type = "fbm", seed = 3, scale = 3.0, octaves = 5, lacunarity = 2.0, gain = 0.5 }
```

### Pattern Transforms
Patterns can be transformed using the same transform syntax as objects:

```toml
[patterns.scaled_checkers]
type = "checkers"
colors = [[1.0, 1.0, 1.0], [0.0, 0.0, 0.0]]

# Pattern-specific transformations
[patterns.scaled_checkers.transform]
scale = [0.1, 0.1, 0.1]
rotation = [0.0, 0.785, 0.0]  # π/4 radians around Y
```

## Objects

```toml
# Using a named material reference
[[objects]]
type = "sphere"
material = "red_plastic"  # Reference to named material

# Using an inline material definition (alternative to named reference)
[[objects]]
type = "plane"
[objects.material]
color = [0.5, 0.5, 0.5]
ambient = 0.1
diffuse = 0.9
specular = 0.0
transparency = 0.0
refractive_index = 1.0
pattern = "checkers"  # Reference to named pattern

# Note: You cannot use both 'material = "name"' and '[objects.material]'
# in the same object - they are mutually exclusive

[[objects]]
type = "cube"
[objects.transform]
translation = [1.0, 0.0, 0.0]
rotation = [0.0, 0.785, 0.0]  # π/4 radians around Y
scale = [1.0, 2.0, 1.0]

[[objects]]
type = "cylinder"
[objects.properties]
minimum = -2.0
maximum = 2.0
closed = true
[objects.transform]
translation = [-1.0, 0.0, 0.0]

[[objects]]
type = "cone"
[objects.properties]
minimum = -1.0
maximum = 0.0
closed = true

[[objects]]
type = "group"
[[objects.children]]
type = "sphere"
[objects.children.transform]
translation = [0.0, 0.0, 0.0]

[[objects.children]]
type = "sphere"
[objects.children.transform]
translation = [2.0, 0.0, 0.0]
```

### Object Types
- `"sphere"`: Unit sphere at origin
- `"plane"`: XZ plane at Y=0
- `"cube"`: Unit cube from -1 to +1 in each axis
- `"cylinder"`: Cylinder along Y-axis
- `"cone"`: Cone along Y-axis
- `"triangle"`: Triangle defined by three vertices
- `"group"`: Collection of child objects
- `"csg"`: Constructive Solid Geometry operations

### Object Properties

#### Cylinder/Cone Properties
```toml
[objects.properties]
minimum = -1.0    # Minimum Y value
maximum = 1.0     # Maximum Y value
closed = true     # Whether to cap the ends
```

#### Triangle Properties
```toml
[objects.properties]
vertices = [
  [0.0, 1.0, 0.0],   # Vertex 1
  [-1.0, 0.0, 0.0],  # Vertex 2
  [1.0, 0.0, 0.0]    # Vertex 3
]
# Optional: for smooth triangles
normals = [
  [0.0, 1.0, 0.0],   # Normal 1
  [0.0, 1.0, 0.0],   # Normal 2
  [0.0, 1.0, 0.0]    # Normal 3
]
```

#### CSG Properties
```toml
[[objects]]
type = "csg"
[objects.properties]
operation = "union"  # "union", "intersection", "difference"

[[objects.left]]
type = "sphere"

[[objects.right]]
type = "cube"
[objects.right.transform]
translation = [0.5, 0.0, 0.0]
```

### Transformations

Transformations are applied in order: scale, then rotation, then translation.

```toml
[objects.transform]
# Translation vector [X, Y, Z]
translation = [1.0, 0.0, 0.0]

# Rotation angles in radians [X, Y, Z] (Euler angles)
rotation = [0.0, 1.571, 0.0]  # π/2 radians around Y

# Scale factors [X, Y, Z]
scale = [2.0, 1.0, 1.0]

# Alternative: transformation matrix (4x4, row-major order)
matrix = [
  [1.0, 0.0, 0.0, 1.0],
  [0.0, 1.0, 0.0, 0.0],
  [0.0, 0.0, 1.0, 0.0],
  [0.0, 0.0, 0.0, 1.0]
]
```

**Note**: If `matrix` is specified, it takes precedence over `translation`, `rotation`, and `scale`.

### Groups and Hierarchies

Objects can be nested in groups for hierarchical transformations:

```toml
[[objects]]
type = "group"
name = "car_body"  # Optional name for debugging
[objects.transform]
translation = [0.0, 1.0, 0.0]

[[objects.children]]
type = "cube"
[objects.children.transform]
scale = [2.0, 0.5, 1.0]

[[objects.children]]
type = "sphere"
[objects.children.transform]
translation = [0.0, 0.5, 0.0]
scale = [0.3, 0.3, 0.3]
```

## External File References

The format supports loading geometry from external files:

```toml
[[objects]]
type = "mesh"
file = "models/teapot.obj"
[objects.transform]
scale = [0.1, 0.1, 0.1]
```

### Supported File Formats
- `.obj`: Wavefront OBJ files
- `.gltf/.glb`: GLTF files (future)

## Complete Example

See `examples/` directory for complete scene files demonstrating all features.

## Validation Rules

1. All color values must be in range [0.0, 1.0]
2. Material coefficients must be in range [0.0, 1.0] except `shininess` and `refractive_index`
3. `refractive_index` must be >= 1.0
4. `shininess` must be >= 1.0
5. Pattern and material references must exist
6. Group children must be valid objects
7. Transform values must be finite numbers
8. Required fields cannot be omitted

## Extensions

The format is designed to be extensible. Future versions may add:
- Volumetric rendering properties
- Advanced material models (PBR)
- Animation keyframes
- Post-processing effects
- Custom shader definitions
