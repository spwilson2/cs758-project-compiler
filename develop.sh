#!/bin/bash

GO_COMPILER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$1" != "vanilla" ]
then
	echo "Using modded go compiler!"
	export PATH="$GO_COMPILER_DIR/modded-compiler/bin:$PATH"
	make -C "$GO_COMPILER_DIR" build-modded
else
	echo "Using vanilla go compiler."
	export PATH="$GO_COMPILER_DIR/vanilla-compiler/bin:$PATH"
	make -C "$GO_COMPILER_DIR" vanilla
fi

