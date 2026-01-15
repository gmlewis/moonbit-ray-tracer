///|
pub(all) struct RenderStats {
  mut rays_total : Int
  mut rays_hit : Int
  mut rays_miss : Int
  mut shadow_rays : Int
  mut reflected_rays : Int
  mut refracted_rays : Int
  mut intersect_world_calls : Int
  mut shape_intersect_calls : Int
  mut intersections_total : Int
}

///|
pub fn render_stats() -> RenderStats {
  {
    rays_total: 0,
    rays_hit: 0,
    rays_miss: 0,
    shadow_rays: 0,
    reflected_rays: 0,
    refracted_rays: 0,
    intersect_world_calls: 0,
    shape_intersect_calls: 0,
    intersections_total: 0,
  }
}

///|
fn ratio(n : Int, d : Int) -> Double {
  if d == 0 {
    0.0
  } else {
    n.to_double() / d.to_double()
  }
}

///|
fn pct(n : Int, d : Int) -> Int {
  // Percentage as an integer in [0,100].
  @math.round(ratio(n, d) * 100.0).to_int()
}

///|
pub fn RenderStats::summary(
  self : RenderStats,
  width : Int,
  height : Int,
  samples : Int,
) -> String {
  let primary_rays = width * height * samples
  let secondary_rays = self.rays_total - primary_rays
  let total = self.rays_total
  let hit_pct = pct(self.rays_hit, total)
  let miss_pct = pct(self.rays_miss, total)
  let primary_pct = pct(primary_rays, total)
  let secondary_pct = pct(secondary_rays, total)
  let shadow_pct = pct(self.shadow_rays, total)
  let reflected_pct = pct(self.reflected_rays, total)
  let refracted_pct = pct(self.refracted_rays, total)
  let shadow_per_primary = ratio(self.shadow_rays, primary_rays)
  let secondary_per_primary = ratio(secondary_rays, primary_rays)
  let avg_shapes_per_intersect = ratio(
    self.shape_intersect_calls,
    self.intersect_world_calls,
  )
  let avg_inters_per_intersect = ratio(
    self.intersections_total,
    self.intersect_world_calls,
  )
  let avg_inters_per_ray = ratio(self.intersections_total, self.rays_total)
  let lines : Array[String] = []
  lines.push("--- render stats ---")
  lines.push(
    "primary rays: \{primary_rays} (\{primary_pct}%) (\{width}x\{height}x\{samples})",
  )
  lines.push("secondary rays (approx): \{secondary_rays} (\{secondary_pct}%)")
  lines.push("total rays:   \{total}")
  lines.push("  hit:        \{self.rays_hit} (\{hit_pct}%)")
  lines.push("  miss:       \{self.rays_miss} (\{miss_pct}%)")
  lines.push("shadow rays:    \{self.shadow_rays} (\{shadow_pct}%)")
  lines.push("reflected rays: \{self.reflected_rays} (\{reflected_pct}%)")
  lines.push("refracted rays: \{self.refracted_rays} (\{refracted_pct}%)")
  lines.push(
    "derived: shadow/primary \{shadow_per_primary}, secondary/primary \{secondary_per_primary}",
  )
  lines.push("intersect_world calls: \{self.intersect_world_calls}")
  lines.push(
    "shape intersect calls: \{self.shape_intersect_calls} (avg \{avg_shapes_per_intersect})",
  )
  lines.push(
    "intersections returned: \{self.intersections_total} (avg/intersect \{avg_inters_per_intersect}, avg/ray \{avg_inters_per_ray})",
  )
  lines.push("--- end stats ---")
  lines.join("\n")
}
