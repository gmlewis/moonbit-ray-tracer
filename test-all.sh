#!/bin/bash -ex
moon fmt && moon info
moon test --target native
