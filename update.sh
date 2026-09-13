#!/bin/bash -ex
moon update && rm -rf ./{_build,.mooncakes}
moon add --upgrade bobzhang/toml
moon add --upgrade gmlewis/image
moon add --upgrade gmlewis/io
moon add --upgrade moonbitlang/async
moon info
./test-all.sh
