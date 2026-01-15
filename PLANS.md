# Ray Tracer Roadmap (Clean)

This file is intentionally forward-looking.

- Completed work is summarized briefly (no checkboxes).
- Only remaining work is tracked as checkboxes.

Last refreshed: 2026-01-14

## Current Baseline (Already Implemented)

Core engine + scene system:
- TOML scene format + async scene loading
- Render CLI (PNG/PPM, progress output, resolution/samples overrides)
- Quick preview preset (`--draft`) for faster iteration
- Render statistics (`--stats`) for rays/shadows/intersections + BVH bounds culling
- Stats diagnostic scenes (`examples/stats-*.toml`) to isolate bottlenecks
- BVH acceleration + cooperative (async) rendering

Materials, textures, and patterns:
- Phong + PBR (metallic/roughness) shading
- Texture loading (PNG/JPG/HDR) + UV mapping (including mesh UVs)
- Normal mapping (procedural bump via height→normal, and glTF normalTexture w/ tangents)
- Material layering via `layer_material` + `layer_mask`
- Rich procedural pattern library (noise/fBm/marble/wood/voronoi, compositing, warps, triplanar, levels/threshold/posterize/gradient_map, etc.)

Vector masks + text:
- `Graphic` assets (gmlewis/fonts/draw) + `graphic_mask`
- TOML-native text (`graphics.*.type="text"` and `patterns.*.type="text_mask"`) driven by `MOONBIT_FONTS_DIR`

Lighting:
- Analytical point lights
- Area lights (rectangular) with multi-sample shadows
- Area light sampling cap (`--area-steps`) for faster soft-shadow previews

## Now (Highest Priority Next Steps)

### Stats-driven findings (what dominates runtime)

From the `examples/stats-*.toml` diagnostics and a small `glb-demo` run with `--stats`:

- **Area light scenes are dominated by shadow sampling**: with a 16×16 area light, `shadow/primary = 256` and bounds culling is effectively 0% (there’s little BVH work to save).
- **glTF/triangle-heavy scenes are dominated by BVH traversal + primitive tests**: in `glb-demo` at 240×135×1, `estimated primitive tests avg/intersect_world ≈ 1258`, `group bounds culled ≈ 39%`, and `group bounds tests avg/ray ≈ 269`.
- **Secondary rays are non-trivial in GLB scenes**: `secondary/primary ≈ 2.6` and `shadow/primary ≈ 5.7`, so “even at samples=1” you can still get a lot of work.

### Suggested “First Wins” (High Payoff / Low Risk)

If you only pick a couple of items to start with, these tend to deliver the most benefit per hour:

- **Fast preview defaults (`--draft` preset)**: Improves every iteration loop immediately (scene tweaking, debugging, demos). Mostly CLI plumbing + documented trade-offs.

- **Debug views (normals/albedo/roughness)**: Medium effort, huge debugging leverage when something is “black/noisy/wrong.”
- **Shadow/area-light performance controls**: High payoff now that `--stats` shows shadow sampling dominating work in area-light scenes.

Suggested order: debug views → shadow/area-light performance controls.

### Performance & UX
- [ ] Add more “preview render” controls
  - [ ] Optional: `--draft` should also cap area-light samples (or add `--area-steps` overrides)
  - [ ] Document trade-offs (noise vs speed)
- [ ] Area-light performance controls (highest payoff for soft-shadow scenes)
  - [ ] Optional: separate `u_steps`/`v_steps` caps (beyond the current `--area-steps`)
  - [ ] Fast shadow mode: stratified subset sampling for previews
  - [ ] Consider per-light overrides in TOML (scene-local defaults)
- [ ] BVH traversal + triangle intersection optimization (highest payoff for glTF scenes)
  - [ ] Reduce group bounds tests per ray (stack/iteration strategy, data layout)
  - [ ] Improve BVH build heuristics (partitioning strategy; consider SAH-like splits)
  - [ ] Reduce allocations/copies in intersection collection on hot paths
- [ ] Benchmark and optimize BVH construction for different scene types
- [ ] Reduce memory overhead for long-running renders

### Rendering Quality (Big Visual Wins)
- [ ] Better sampling controls
  - [ ] Adaptive sampling for edges/high-frequency regions
  - [ ] Clear, minimal sampling controls (favor explicit flags over many named presets)

## Next (Modern Lighting & Realism)

### Global Illumination
- [ ] Path tracing / indirect lighting (at least one-bounce GI)
- [ ] Light importance sampling (reduce noise, especially with multiple lights)

### Emissive Materials (Neon “for real”)
- [ ] Add emissive material parameters (color + strength)
- [ ] Mesh lights: treat emissive geometry as light sources
  - [ ] MIS between BSDF sampling and light sampling
- [ ] Add a scene helper for “neon tube” lights (capsule/cylinder + emissive material)
- [ ] Add a canonical neon example scene that relies on emission + bloom

### Volumetrics & Caustics
- [ ] Volumetric effects (fog/participating media)
- [ ] Caustics strategy (explicit sampling or photon-like approaches)

## Geometry & Asset Pipeline

- [ ] OBJ improvements (materials/MTL, textures)
- [ ] Mesh subdivision / smoothing options
- [ ] LOD strategies
- [ ] Optional: MikkTSpace compatibility for tangent parity with DCC/glTF tooling

## Text & Graphics: Next Capabilities

- [ ] Text decals with good ergonomics
  - [ ] Planar projection “decal” helper (pattern transform + mask)
  - [ ] Optional: UV-space stamping when UVs exist
- [ ] Text/Graphic extrusion to solid geometry
  - [ ] Profiles → triangulation + side walls
  - [ ] UV mapping strategies for extruded geometry
  - [ ] Example scenes: extruded logo/text; masked decal on a surface
  - [ ] Focused unit tests for profile→mesh and mask evaluation

## Post-Processing

- [ ] Tone mapping controls/operators (beyond current defaults)
- [ ] Bloom (needed for emissive neon look)
  - [ ] Threshold + soft-knee + multi-pass blur + composite
  - [ ] Establish HDR ordering (accumulate HDR → bloom → tone map → output)
- [ ] Depth of field
- [ ] Composable post-processing chain configuration

## Shader Authoring (OSL)

- [ ] Investigate Open Shading Language (OSL)-style support
  - [ ] Define a safe shader IR for patterns/materials (pure functions, no I/O)
  - [ ] Choose execution model: interpreter vs bytecode vs codegen
  - [ ] TOML integration: `type="osl"` with `file`/`code` + `params`
  - [ ] Start with a small subset (math/noise/conditionals)
  - [ ] One demo scene + small gallery comparing built-ins vs OSL

## Tooling & Ecosystem (Lower Priority)

- [ ] Web UI (WASM) for scene editing and rapid iteration
- [ ] Debug views (ray visualization, normals/albedo/roughness passes)
- [ ] Plugin architecture (likely wasm-based)
- [ ] Denoising (start with simple spatial filters; consider temporal later)
- [ ] GPU acceleration research (WebGPU compute)

## Lowest Priority (Nice-to-Have)

- [ ] Progressive rendering (deprioritized)
  - [ ] Progressive pixel sampling (early image + refinement)
  - [ ] Adaptive sampling based on variance
  - [ ] Time estimation + quality indicators

## Changelog

- 2026-01-14: Roadmap cleanup (removed completed checklist clutter, kept a short “Current Baseline” summary)
- 2026-01-14: Added stats diagnostic scenes; `--stats` analysis suggests area-light shadow sampling dominates work
- 2026-01-14: Added BVH bounds-test stats; `glb-demo` suggests BVH traversal/triangle tests dominate in glTF scenes
