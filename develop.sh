#!/bin/bash

GO_COMPILER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

make -C "$GO_COMPILER_DIR" all

export PATH="$GO_COMPILER_DIR/vanilla-compiler/bin:$PATH"
