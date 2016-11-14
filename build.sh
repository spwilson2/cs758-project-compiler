#!/bin/bash


export GO_COMPILER="`pwd`/go-compiler"
export GOROOT_BOOTSTRAP="`pwd`/bootstrap-compiler"

unset TEST_FINAL_COMPILER
TEST_FINAL_COMPILER="y"


BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -d "$GOROOT_BOOTSTRAP" ] 
then 
    curl https://storage.googleapis.com/golang/go1.4-bootstrap-20161024.tar.gz | tar xz 
    mv go "$GOROOT_BOOTSTRAP"
    cd "$GOROOT_BOOTSTRAP/src"
	# We build without CGO_ENABLED since it's not needed for a bootstrapper
	# and has a tendency to break compilation on some hosts
    CGO_ENABLED=0 ./make.bash
    cd -
fi

if [ ! -d "$GO_COMPILER" ]
then
    git clone https://github.com/golang/go "$GO_COMPILER"
    cd "$GO_COMPILER/src"
	./make.bash
	cd -
fi

export GOROOT="$GO_COMPILER"
export PATH="$GO_COMPILER/bin:$PATH"

if [ "$TEST_FINAL_COMPILER" == "y" ]; then
    go tool dist test
    go run $BUILD_DIR/mytests/my-test.go
fi
