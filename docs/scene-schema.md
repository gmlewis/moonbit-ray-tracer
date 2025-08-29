# TOML Scene Schema Reference

This document provides the exact schema definition for TOML scene files.

## Type Definitions

### Color
`[R, G, B]` where each component is a float in range [0.0, 1.0]

### Vector3
`[X, Y, Z]` where each component is a float

### Matrix4x4
4x4 transformation matrix in row-major order:
```toml
[
  [m00, m01, m02, m03],
  [m10, m11, m12, m13], 
  [m20, m21, m22, m23],
  [m30, m31, m32, m33]
]
```

## Schema Definition

```toml
# Root level - all sections optional except [scene] and [camera]
[scene]                          # REQUIRED
name = "string"                  # OPTIONAL
description = "string"           # OPTIONAL  
version = "string"               # OPTIONAL

[scene.render]                   # OPTIONAL
width = 800                      # OPTIONAL, default: 800, range: > 0
height = 600                     # OPTIONAL, default: 600, range: > 0
samples = 1                      # OPTIONAL, default: 1, range: > 0
max_bounces = 4                  # OPTIONAL, default: 4, range: >= 0
background = [0.0, 0.0, 0.0]     # OPTIONAL, default: black, type: Color

[camera]                         # REQUIRED
position = [0.0, 0.0, 0.0]       # REQUIRED, type: Vector3
look_at = [0.0, 0.0, 1.0]        # REQUIRED, type: Vector3
up = [0.0, 1.0, 0.0]             # REQUIRED, type: Vector3
field_of_view = 1.047            # REQUIRED, range: > 0, < π

[[lights]]                       # OPTIONAL, array of tables
type = "point"                   # REQUIRED, enum: ["point"]
position = [0.0, 0.0, 0.0]       # REQUIRED, type: Vector3
intensity = [1.0, 1.0, 1.0]      # REQUIRED, type: Color

[materials]                      # OPTIONAL, table of materials
[materials.NAME]                 # Material definition
color = [1.0, 1.0, 1.0]          # OPTIONAL, default: white, type: Color
ambient = 0.1                    # OPTIONAL, default: 0.1, range: [0.0, 1.0]
diffuse = 0.9                    # OPTIONAL, default: 0.9, range: [0.0, 1.0]
specular = 0.9                   # OPTIONAL, default: 0.9, range: [0.0, 1.0]
shininess = 200.0                # OPTIONAL, default: 200.0, range: >= 1.0
reflective = 0.0                 # OPTIONAL, default: 0.0, range: [0.0, 1.0]
transparency = 0.0               # OPTIONAL, default: 0.0, range: [0.0, 1.0]
refractive_index = 1.0           # OPTIONAL, default: 1.0, range: >= 1.0
pattern = "pattern_name"         # OPTIONAL, reference to [patterns.NAME]

[patterns]                       # OPTIONAL, table of patterns
[patterns.NAME]                  # Pattern definition
type = "checkers"                # REQUIRED, enum: ["checkers", "stripes", "gradient", "rings", "gradient_rings", "gradient_checkers"]
colors = [[1.0,0.0,0.0], [...]]  # REQUIRED, array of Color, min length: 1

[patterns.NAME.transform]        # OPTIONAL, pattern transform
translation = [0.0, 0.0, 0.0]    # OPTIONAL, type: Vector3
rotation = [0.0, 0.0, 0.0]       # OPTIONAL, type: Vector3 (radians)
scale = [1.0, 1.0, 1.0]          # OPTIONAL, type: Vector3
matrix = [[...], [...], [...]]   # OPTIONAL, type: Matrix4x4 (overrides t/r/s)

[[objects]]                      # OPTIONAL, array of objects
type = "sphere"                  # REQUIRED, enum: ["sphere", "plane", "cube", "cylinder", "cone", "triangle", "group", "csg", "mesh"]
name = "object_name"             # OPTIONAL, for debugging
material = "material_name"       # OPTIONAL, reference to [materials.NAME]

[objects.material]               # OPTIONAL, inline material (mutually exclusive with material reference)
# Same structure as [materials.NAME]

[objects.transform]              # OPTIONAL, object transform  
translation = [0.0, 0.0, 0.0]    # OPTIONAL, type: Vector3
rotation = [0.0, 0.0, 0.0]       # OPTIONAL, type: Vector3 (radians)
scale = [1.0, 1.0, 1.0]          # OPTIONAL, type: Vector3
matrix = [[...], [...], [...]]   # OPTIONAL, type: Matrix4x4 (overrides t/r/s)

[objects.pattern_transform]      # OPTIONAL, pattern-specific transform
# Same structure as [objects.transform]

[objects.properties]             # OPTIONAL, type-specific properties

# For cylinder/cone
minimum = -1.0                   # OPTIONAL, default: -∞
maximum = 1.0                    # OPTIONAL, default: +∞
closed = true                    # OPTIONAL, default: false

# For triangle
vertices = [[0,1,0], [-1,0,0], [1,0,0]]  # REQUIRED for triangle, array of 3 Vector3
normals = [[0,1,0], [0,1,0], [0,1,0]]    # OPTIONAL for smooth triangle, array of 3 Vector3

# For CSG
operation = "union"              # REQUIRED for CSG, enum: ["union", "intersection", "difference"]

# For mesh
file = "path/to/model.obj"       # REQUIRED for mesh, string path

# CSG-specific child objects
[[objects.left]]                 # REQUIRED for CSG, single object
# Same structure as [[objects]]

[[objects.right]]                # REQUIRED for CSG, single object  
# Same structure as [[objects]]

# Group children
[[objects.children]]             # OPTIONAL for group, array of objects
# Same structure as [[objects]]
```

## Validation Rules

### Required Fields
- `[scene]` section must exist
- `[camera]` section must exist with all required fields
- Each object must have a valid `type`
- Each light must have `type`, `position`, and `intensity`
- Each pattern must have `type` and `colors`
- CSG objects must have `operation`, `left`, and `right`
- Triangle objects must have `vertices`
- Mesh objects must have `file`

### Value Constraints
- All color components: [0.0, 1.0]
- Material coefficients (ambient, diffuse, specular, reflective, transparency): [0.0, 1.0]
- `shininess`: >= 1.0
- `refractive_index`: >= 1.0
- `field_of_view`: (0.0, π)
- Render dimensions: > 0
- `samples`, `max_bounces`: >= 0

### Reference Integrity
- Material references must point to existing `[materials.NAME]`
- Pattern references must point to existing `[patterns.NAME]`
- File references must point to existing files (validated at parse time)
- Objects cannot have both `material = "name"` and `[objects.material]` (mutually exclusive)

### Transformation Rules
- If `matrix` is specified, `translation`, `rotation`, and `scale` are ignored
- Rotation values are in radians
- Transformations apply in order: scale → rotation → translation
- Pattern transforms are independent of object transforms

### CSG Rules
- CSG objects cannot be leaves (must have `left` and `right`)
- CSG children can be any object type including other CSG objects
- Infinite recursion is prevented by implementation

### Group Rules
- Groups can contain any object types including other groups
- Empty groups are valid
- Group transforms apply to all children

## Error Handling

### Parse Errors
- Invalid TOML syntax
- Missing required sections/fields
- Invalid data types

### Validation Errors  
- Values outside allowed ranges
- Invalid enum values
- Broken references
- Missing required properties for object types
- Conflicting material definitions (both reference and inline material)

### Runtime Errors
- File not found for mesh objects
- Malformed geometry files
- Circular group references

## Extensions

Future schema versions may add:
- Additional light types
- New primitive shapes
- Advanced material properties
- Animation keyframes
- Post-processing effects