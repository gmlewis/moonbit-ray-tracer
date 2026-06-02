name = "gmlewis/ray-tracer"

version = "0.10.41"

import {
  "bob/toml@0.1.6",
  "gmlewis/base64@0.16.10",
  "gmlewis/flate@0.36.8",
  "gmlewis/fonts@0.19.10",
  "gmlewis/gzip@0.34.8",
  "gmlewis/image@0.17.8",
  "gmlewis/io@0.23.11",
  "moonbitlang/async@0.19.0",
  "moonbitlang/x@0.4.38",
  "TheWaWaR/clap@0.2.6",
}

readme = "README.md"

repository = "https://github.com/gmlewis/moonbit-ray-tracer"

license = "Apache-2.0"

keywords = [ "3d", "graphics", "ray tracing" ]

description = ""

preferred_target = "native"

options(
  source: "src",
)