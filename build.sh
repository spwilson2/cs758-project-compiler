#!/bin/bash

unset TEST_FINAL_COMPILER
# Comment out to avoid testing of the compiler.
TEST_FINAL_COMPILER="y"

BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export GO_COMPILER="$BUILD_DIR/go-compiler"
export GOROOT_BOOTSTRAP="$BUILD_DIR/bootstrap-compiler"
export STAGE2_PFX="-stage2"

export GO_VERSION="release-branch.go1.7"
export GO_SOURCE="https://github.com/golang/go"

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

if [ ! -d "${GO_COMPILER}${STAGE2_PFX}" ]
then
    git clone -b "$GO_VERSION" --single-branch "$GO_SOURCE" "${GO_COMPILER}${STAGE2_PFX}"
    cd "${GO_COMPILER}${STAGE2_PFX}/src"
	./make.bash
	cd -
fi

if [ ! -d "$GO_COMPILER" ]
then
    git clone -b "$GO_VERSION" --single-branch "$GO_SOURCE" "$GO_COMPILER"
    cd "$GO_COMPILER/src"
	GOROOT_BOOTSTRAP="${GO_COMPILER}${STAGE2_PFX}" GOROOT="${GO_COMPILER}${STAGE2_PFX}" PATH="${GO_COMPILER}${STAGE2_PFX}/bin:$PATH" ./make.bash
	cd -
fi

export GOROOT="$GO_COMPILER"
export PATH="$GO_COMPILER/bin:$PATH"

if [ "$TEST_FINAL_COMPILER" == "y" ]; then
    go tool dist test
    go run $BUILD_DIR/mytests/my-test.go
fi
