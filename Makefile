.ONESHELL:
SHELL=/bin/bash

GO_SOURCE   ?=https://github.com/golang/go
GO_VERSION  ?=release-branch.go1.7

BOOTSTRAP_COMPILER_DOWNLOAD ?=bootstrap-compiler
STAGE2_COMPILER_DOWNLOAD    ?=stage2-compiler
VANILLA_COMPILER_DOWNLOAD   ?=vanilla-compiler

.PHONY:all
all: vanilla build-modded

BOOTSTRAP_COMPILER=$(join ${BOOTSTRAP_COMPILER_DOWNLOAD},/bin/go)
.PHONY:bootstrap
bootstrap: ${BOOTSTRAP_COMPILER_DOWNLOAD} ${BOOTSTRAP_COMPILER}

${BOOTSTRAP_COMPILER_DOWNLOAD}:
	curl https://storage.googleapis.com/golang/go1.4-bootstrap-20161024.tar.gz | tar xz 
	mv go $@

${BOOTSTRAP_COMPILER}: ${BOOTSTRAP_COMPILER_DOWNLOAD}
	@printf "##################################\n"
	@printf "                                  \n"
	@printf "Building the c-bootstrap compiler.\n"
	@printf "                                  \n"
	@printf "##################################\n"
	@cd "$</src"
	@# We build without CGO_ENABLED since it's not needed for a bootstrapper
	@# and has a tendency to break compilation on some hosts
	CGO_ENABLED=0 ./make.bash

STAGE2_COMPILER=$(join ${STAGE2_COMPILER_DOWNLOAD},/bin/go)
.PHONY:stage2
stage2: ${STAGE2_COMPILER_DOWNLOAD} ${STAGE2_COMPILER}

${STAGE2_COMPILER_DOWNLOAD}:
	git clone -b "${GO_VERSION}" --single-branch "${GO_SOURCE}" "$@"

${STAGE2_COMPILER}: ${STAGE2_COMPILER_DOWNLOAD} ${BOOTSTRAP_COMPILER}
	@printf "##################################\n"
	@printf "                                  \n"
	@printf "Building the stage-2 compiler.    \n"
	@printf "                                  \n"
	@printf "##################################\n"
	@cd "$</src"
	CGO_ENABLED=1 GOROOT_BOOTSTRAP="$(abspath ${BOOTSTRAP_COMPILER_DOWNLOAD})" ./make.bash

VANILLA_COMPILER=$(join ${VANILLA_COMPILER_DOWNLOAD},/bin/go)
.PHONY:vanilla
vanilla: ${VANILLA_COMPILER_DOWNLOAD} ${VANILLA_COMPILER}

${VANILLA_COMPILER_DOWNLOAD}: ${STAGE2_COMPILER_DOWNLOAD}
	git clone "$<" "$@"

${VANILLA_COMPILER}: ${VANILLA_COMPILER_DOWNLOAD} ${STAGE2_COMPILER}
	@printf "##################################\n"
	@printf "                                  \n"
	@printf "Building the vanilla compiler.    \n"
	@printf "                                  \n"
	@printf "##################################\n"
	@cd "$</src"
	@export GOROOT_BOOTSTRAP="$(abspath ${STAGE2_COMPILER_DOWNLOAD})" 
	@export GOROOT="$$GOROOT_BOOTSTRAP"
	CGO_ENABLED=1 ./make.bash

.PHONY:modded
MODDED_COMPILER=modded-compiler
modded: |clean-modded update-modded-defs ${MODDED_COMPILER}/bin/go
build-modded: ${MODDED_COMPILER}/bin/go

${MODDED_COMPILER}/bin/go: ${STAGE2_COMPILER}
	@printf "##################################\n"
	@printf "                                  \n"
	@printf "Building the modded compiler.     \n"
	@printf "                                  \n"
	@printf "##################################\n"
	@cd "${MODDED_COMPILER}/src"
	@export GOROOT_BOOTSTRAP="$(abspath ${STAGE2_COMPILER_DOWNLOAD})" 
	@export GOROOT="$$GOROOT_BOOTSTRAP"
	CGO_ENABLED=1 ./make.bash

.PHONY:update-modded-defs
update-modded-defs: ${STAGE2_COMPILER} 
	@printf "############################################\n"
	@printf "                                  			 \n"
	@printf "Updating modded systemcall definitions.     \n"
	@printf "                                  			 \n"
	@printf "############################################\n"
	export PATH="$(abspath ${STAGE2_COMPILER_DOWNLOAD}/bin):$$PATH"
	cd ${MODDED_COMPILER}/src/syscall
	GOOS=linux GOARCH=amd64 ./mkall.sh

.PHONY:test test-modded test-vanilla

test: test-modded-all test-vanilla-all

test-vanilla-all: test-vaniall ${VANILLA_COMPILER}
	@export GOROOT="$(abspath ${VANILLA_COMPILER_DOWNLOAD})"
	@export PATH="$(abspath $(dir $<)):$$PATH"
	go run "${CURDIR}/mytests/my-test.go"

test-vanilla: ${VANILLA_COMPILER}
	@export GOROOT="$(abspath ${VANILLA_COMPILER_DOWNLOAD})"
	@export PATH="$(abspath $(dir $<)):$$PATH"
	go tool dist test

test-modded-all: ${MODDED_COMPILER}/bin/go
	@export GOROOT="$(abspath ${VANILLA_COMPILER_DOWNLOAD})"
	@export PATH="$(abspath $(dir $<)):$$PATH"
	go tool dist test

test-modded: ${MODDED_COMPILER}/bin/go
	@export GOROOT="$(abspath ${MODDED_COMPILER})"
	@export PATH="$(abspath $(dir $<)):$$PATH"
	set -e
	cd "${CURDIR}/mytests/"
	go run modded-smoketest-io.go
	go run modded-smoketest.go
	go run modded-aio-simple.go
	echo Passed modded-compiler smoke tests!

.PHONY:clean-modded
clean-modded:
	rm -f "${MODDED_COMPILER}/bin/go" 

.PHONY:clean
clean:
	rm -rf "${MODDED_COMPILER}/bin/go" "${BOOTSTRAP_COMPILER_DOWNLOAD}" "${STAGE2_COMPILER_DOWNLOAD}" "${VANILLA_COMPILER_DOWNLOAD}"
