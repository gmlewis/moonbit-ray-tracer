# Ray Tracer Improvement Plans

This document outlines a comprehensive plan to take the MoonBit ray tracer to the next level, transforming it from a learning project into a genuinely useful and modern ray tracing tool.

## Priority 1: Foundation & Usability (Critical for making the tool usable)

### Scene Description System
- [x] Design TOML scene description format
- [x] Implement scene file parser
- [x] Create scene loader that builds World objects from descriptions
- [x] Add validation and error handling for scene files
- [x] Create example scene files for testing
- [x] Document scene format specification

### Command Line Interface
- [x] Design CLI argument structure and commands
- [x] Implement basic `render` command with scene file input
- [x] Add output format options (PNG, PPM)
- [x] Add basic rendering options (resolution, samples)
- [x] Implement progress reporting during rendering
- [x] Add `--help` and usage documentation

### Web Interface (Basic)
- [ ] Create basic HTML/JS frontend for scene editing
- [ ] Implement WebAssembly integration for ray tracer
- [ ] Add drag-and-drop scene file loading
- [ ] Create simple scene preview (wireframe/basic)
- [ ] Add material/lighting parameter controls
- [ ] Implement real-time parameter adjustment

## Priority 2: Performance (Critical for practical use)

### Spatial Acceleration Structures
- [x] Axis-Aligned Bounding Box (AABB) system
- [x] Bounding Volume Hierarchy (BVH) builder
- [x] BVH traversal for ray intersection
- [x] Spatial partitioning for scene objects
- [ ] Optimize BVH construction for different scene types
- [ ] Benchmark intersection performance improvements

### Parallel Rendering (Cooperative Multitasking)
- [x] Implement tile-based / line-based asynchronous rendering
- [x] Add yielding (`pause()`) for responsiveness
- [ ] Research future MoonBit threading capabilities
- [ ] Optimize memory usage for long-running renders
- [ ] Benchmark overhead of cooperative multitasking

### Progressive Rendering
- [ ] Implement progressive pixel sampling
- [ ] Create adaptive sampling based on image variance
- [ ] Implement render time estimation
- [ ] Add progressive quality indicators

## Priority 3: Modern Rendering Features

### Physically Based Rendering (PBR)
- [x] Research PBR material models (metallic/roughness)
- [x] Implement Cook-Torrance BRDF
- [x] Add Fresnel calculations
- [x] Implement importance sampling for materials (partially, for analytical lights)
- [x] Add material energy conservation
- [x] Create PBR material presets (metal, plastic, glass, etc.)

### Advanced Lighting
- [x] Implement area lights (rectangular, circular)
- [x] Add environment/IBL (Image-Based Lighting)
- [ ] Implement global illumination (path tracing)
- [ ] Add light importance sampling
- [ ] Implement volumetric lighting effects
- [ ] Add caustics rendering

### Anti-Aliasing & Sampling
- [x] Implement supersampling anti-aliasing (SSAA)
- [ ] Add temporal anti-aliasing for animations
- [x] Implement jittered sampling patterns
- [ ] Add adaptive sampling based on edge detection
- [ ] Optimize sample distribution algorithms
- [ ] Add configurable sampling quality levels

## Priority 4: Advanced Features

Next best thing to address: focus first on the Procedural Texture Library + compositing/masks, then wire that into `Graphic`-based masks; extrusion can follow once masks/textures are solid.

### Texture & Material System
- [x] Implement texture loading (PNG, JPG, HDR) (decode + sampling)
- [x] Add UV mapping support (spherical/planar/cylindrical/cubic + mesh UVs)
- [ ] Implement normal mapping
- [ ] Add displacement mapping
- [ ] Implement material layering/blending/masking

### Procedural Texture Library (High Priority for still images)
- [ ] Create extensive procedural texture system (noise, patterns)
- [ ] Add core noise primitives (value noise, Perlin/simplex-style gradients)
- [ ] Add fBm/turbulence and common looks (marble, wood, clouds)
- [ ] Add cellular/Voronoi noise variants
- [ ] Add domain warping for richer textures
- [ ] Add compositing nodes (blend/mix, mask, remap, clamp, invert)
- [ ] Add parameterized controls in scene format (seed, scale, octaves, lacunarity, gain)
- [ ] Create a procedural texture showcase scene + rendered gallery

### `Graphic` Integration (gmlewis/fonts/draw)
- [ ] Define scene representation for `Graphic` assets (likely JSON, referenced from TOML)
- [ ] Add loader that reads a `Graphic` asset and applies transforms/scaling
- [ ] Decide on scene authoring approach for complex `Graphic` generation (keep TOML for declarative scenes; optionally add a MoonBit “scene/asset generator” that outputs JSON/TOML)
- [ ] Implement `Graphic`-based mask pattern (inside/outside + optional antialiasing)
- [ ] Allow masking between two patterns (solid color or any procedural texture)
- [ ] Support nested masks (embed one procedural texture “inside” another via `Graphic`)
- [ ] Implement `Graphic` extrusion to solid geometry (profiles → triangulation + side walls)
- [ ] Add UV mapping strategies for extruded graphics (planar + configurable mapping)
- [ ] Add example scenes: extruded logo/text; masked decal on another surface
- [ ] Add unit tests for profile → mesh and mask evaluation

### Animation System (Deprioritized)
- [ ] Design keyframe animation framework
- [ ] Implement object transformation animations
- [ ] Add camera animation support
- [ ] Create timeline and interpolation system
- [ ] Add material property animations
- [ ] Implement motion blur rendering

### Advanced Geometry
- [ ] Expand OBJ file support (materials/MTL, textures)
- [x] Add GLTF format support
- [ ] Implement mesh subdivision
- [ ] Add procedural geometry generation
- [ ] Create geometry optimization tools
- [ ] Implement level-of-detail (LOD) system

## Priority 5: Ecosystem & Tools

### Plugin Architecture
- [ ] Design plugin interface specification (maybe via wasm?)
- [ ] Implement plugin loading system
- [ ] Create example plugins (materials, shapes, post-effects)
- [ ] Add plugin discovery and management
- [ ] Create plugin development documentation
- [ ] Implement plugin validation and sandboxing

### Debugging & Development Tools
- [ ] Implement ray visualization system
- [ ] Add performance profiling tools
- [ ] Create material debugging modes
- [ ] Add intersection visualization
- [ ] Implement render statistics and analytics
- [x] Create automated test runner + unit tests

### Documentation & Examples
- [ ] Create comprehensive API documentation
- [ ] Write getting-started tutorial series
- [ ] Create example scene gallery with source
- [ ] Document best practices and optimization tips
- [ ] Add video tutorials for complex features
- [ ] Create community contribution guidelines

## Priority 6: Advanced Graphics & Optimization

### GPU Acceleration
- [ ] Research WebGPU compute shader capabilities
- [ ] Implement GPU ray tracing pipeline
- [ ] Optimize memory bandwidth for GPU rendering
- [ ] Add GPU/CPU hybrid rendering modes
- [ ] Implement GPU-accelerated acceleration structures
- [ ] Benchmark GPU vs CPU performance

### Post-Processing Pipeline
- [ ] Implement tone mapping operators
- [ ] Add color grading and correction tools
- [ ] Implement bloom and lens flare effects
- [ ] Add depth of field simulation
- [ ] Create customizable post-processing chains
- [ ] Add real-time preview for post-effects

### Denoising
- [ ] Research AI-based denoising algorithms
- [ ] Implement temporal denoising for animations
- [ ] Add edge-preserving filters
- [ ] Create adaptive denoising based on sample count
- [ ] Implement multiple denoising algorithm options
- [ ] Add denoising quality/performance trade-offs

## Implementation Phases

### Phase 1: Foundation (Weeks 1-4)
Focus on Scene Description System and basic CLI to make the tool actually usable by others.

### Phase 2: Performance (Weeks 5-8)
Implement parallel rendering and basic spatial acceleration to handle realistic scene complexity.

### Phase 3: Modern Rendering (Weeks 9-16)
Add PBR materials and advanced lighting to produce professional-quality output.

### Phase 4: Polish & Ecosystem (Weeks 17-24)
Complete the tool with documentation, examples, and advanced features.

## Success Metrics

- [ ] Render complex scenes (1000+ objects) in reasonable time
- [x] Support standard 3D file formats (OBJ, GLTF) (baseline import; OBJ materials/MTL still TODO)
- [ ] Produce photorealistic images comparable to commercial tools
- [ ] Render `Graphic` assets as extruded solids and as texture masks
- [ ] Provide intuitive user interface for non-programmers
- [ ] Maintain code quality and comprehensive test coverage
- [ ] Build active community of users and contributors

## Notes

- Each checkbox represents a substantial development task (1-5 days of work)
- Some tasks may be parallelizable or can be worked on incrementally
- Priority levels can be adjusted based on user feedback and development progress
- Consider creating separate GitHub issues for major features
- Regular benchmarking and testing should accompany each implementation phase
