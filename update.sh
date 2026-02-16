#!/bin/bash -ex
moon update && rm -rf ./{_build,.mooncakes}
moon add bob/toml
moon add gmlewis/image
moon add gmlewis/io
moon add moonbitlang/async
moon add TheWaWaR/clap
./test-all.sh
