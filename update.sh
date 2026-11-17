#!/bin/bash -ex
moon update && rm -rf ./{_build,.mooncakes}
moon add --upgrade gmlewis/image
moon add --upgrade gmlewis/io
moon add --upgrade moonbit-community/toml
moon add --upgrade moonbitlang/async
moon info
./test-all.sh
