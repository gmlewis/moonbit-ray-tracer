#!/bin/bash -ex
TARGET=js
moon run --target ${TARGET} src/ch1/main.mbt
moon run --target ${TARGET} src/ch2/main.mbt
moon run --target ${TARGET} src/ch4/main.mbt
moon run --target ${TARGET} src/ch5/main.mbt
moon run --target ${TARGET} src/ch6/main.mbt
moon run --target ${TARGET} src/ch7/main.mbt
moon run --target ${TARGET} src/ch9/main.mbt
moon run --target ${TARGET} src/ch10-stripes/main.mbt
moon run --target ${TARGET} src/ch10-gradients/main.mbt
