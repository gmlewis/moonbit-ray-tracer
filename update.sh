#!/bin/bash -ex
moon update && moon install && rm -rf target
moon add bob/toml
moon add gmlewis/image
moon add gmlewis/io
moon add moonbitlang/async
moon add TheWaWaR/clap
./test-all.sh
