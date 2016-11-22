#!/bin/bash

GO_COMPILER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

make -C "$GO_COMPILER_DIR" all

if [ "$1" == "devel" ]
then
	echo "Using modded go compiler!"
	export PATH="$GO_COMPILER_DIR/modded-compiler/bin:$PATH"
else
	echo "Using vanilla go compiler."
	export PATH="$GO_COMPILER_DIR/vanilla-compiler/bin:$PATH"
fi
