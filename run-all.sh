#!/bin/bash -ex
# moon run src/ch01
# moon run src/ch02
# moon run src/ch04
# moon run src/ch05
# moon run src/ch06
# moon run src/ch07
# moon run src/ch09
# moon run src/ch10-stripes
# moon run src/ch10-gradients
# moon run src/ch10-rings
# moon run src/ch10-gradient-rings
# moon run src/ch10-checkers
# moon run src/ch10-gradient-checkers
# moon run src/ch14
# moon run src/ch15

# Scene examples using the render CLI
moon run src/render -- -s examples/area-light-demo.toml -o area-light-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/art-gallery.toml -o art-gallery.png --samples 4 --divide 1
moon run src/render -- -s examples/box-demo.toml -o box-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/checkers-scene.toml -o checkers-scene.png --samples 8 --divide 1
moon run src/render -- -s examples/csg-demo.toml -o csg-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/environment-demo.toml -o environment-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/glass-spheres.toml -o glass-spheres.png --samples 4 --divide 1
moon run src/render -- -s examples/glb-demo.toml -o glb-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/triplanar-glb-demo.toml -o triplanar-glb-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/patterns-showcase.toml -o patterns-showcase.png --samples 4 --divide 1
moon run src/render -- -s examples/pbr-demo.toml -o pbr-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/procedural-textures.toml -o procedural-textures.png --samples 4 --divide 1
moon run src/render -- -s examples/levels-demo.toml -o levels-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/bias-gain-demo.toml -o bias-gain-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/contrast-demo.toml -o contrast-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/threshold-demo.toml -o threshold-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/posterize-demo.toml -o posterize-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/gradient-map-demo.toml -o gradient-map-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/triplanar-demo.toml -o triplanar-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/mask-demo.toml -o mask-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/warp-field-demo.toml -o warp-field-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/voronoi-edges-demo.toml -o voronoi-edges-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/voronoi-f1f2-demo.toml -o voronoi-f1f2-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/bump-demo.toml -o bump-demo.png --samples 4 --divide 1
moon run src/render -- -s examples/simple-sphere.toml -o simple-sphere.png --samples 4 --divide 1
moon run src/render -- -s examples/texture-demo.toml -o texture-demo.png --samples 4 --divide 1
