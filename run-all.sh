#!/bin/bash -ex
TARGET=js
moon run --target ${TARGET} src/ch1
moon run --target ${TARGET} src/ch2
moon run --target ${TARGET} src/ch4
moon run --target ${TARGET} src/ch5
moon run --target ${TARGET} src/ch6
moon run --target ${TARGET} src/ch7
moon run --target ${TARGET} src/ch9
moon run --target ${TARGET} src/ch10-stripes
moon run --target ${TARGET} src/ch10-gradients
moon run --target ${TARGET} src/ch10-rings
moon run --target ${TARGET} src/ch10-gradient-rings
moon run --target ${TARGET} src/ch10-checkers
moon run --target ${TARGET} src/ch10-gradient-checkers
