#!/bin/bash

export GO_COMPILER="`pwd`/go-compiler"
export GOROOT_BOOTSTRAP="`pwd`/bootstrap-compiler"

TEST_FINAL_COMPILER="y"

if [ ! -d "$GOROOT_BOOTSTRAP" ] 
then 
    curl https://storage.googleapis.com/golang/go1.4-bootstrap-20161024.tar.gz | tar xz 
    mv go "$GOROOT_BOOTSTRAP"
    cd "$GOROOT_BOOTSTRAP/src"
    ./make.bash
    cd -
fi

if [ ! -d "$GO_COMPILER" ]
then
    git clone https://github.com/golang/go "$GO_COMPILER"
    cd "$GO_COMPILER/src"
        ./make.bash
fi

if [ "$TEST_FINAL_COMPILER" == "y" ]; then
    export GOROOT="$GO_COMPILER"
    export PATH="$GO_COMPILER/bin:$PATH"

    go tool dist test
    go run ./my-test.go
fi
