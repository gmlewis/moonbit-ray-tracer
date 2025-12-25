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
RENDER="moon run src/render --"
$RENDER -s examples/checkers-scene.toml -o checkers-scene.png --samples 4 --divide 1
$RENDER -s examples/csg-demo.toml -o csg-demo.png --samples 4 --divide 1
$RENDER -s examples/environment-demo.toml -o environment-demo.png --samples 4 --divide 1
$RENDER -s examples/glass-spheres.toml -o glass-spheres.png --samples 4 --divide 1
$RENDER -s examples/patterns-showcase.toml -o patterns-showcase.png --samples 4 --divide 1
$RENDER -s examples/pbr-demo.toml -o pbr-demo.png --samples 4 --divide 1
$RENDER -s examples/simple-sphere.toml -o simple-sphere.png --samples 4 --divide 1
$RENDER -s examples/texture-demo.toml -o texture-demo.png --samples 4 --divide 1
$RENDER -s examples/art-gallery.toml -o art-gallery.png --samples 4 --divide 1
