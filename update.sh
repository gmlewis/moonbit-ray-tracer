#!/bin/bash -ex
moon update && rm -rf ./{_build,.mooncakes}
moon add --upgrade bobzhang/toml
moon add --upgrade gmlewis/image
moon add --upgrade gmlewis/io
moon add --upgrade moonbitlang/async
moon add --upgrade TheWaWaR/clap
moon info
./test-all.sh
