.ONESHELL:
SHELL=/bin/bash

GO_SOURCE   ?=https://github.com/golang/go
GO_VERSION  ?=release-branch.go1.7

BOOTSTRAP_COMPILER_DOWNLOAD ?=bootstrap-compiler
STAGE2_COMPILER_DOWNLOAD    ?=stage2-compiler
VANILLA_COMPILER_DOWNLOAD   ?=vanilla-compiler

.PHONY:all
all: vanilla modded

BOOTSTRAP_COMPILER=$(join ${BOOTSTRAP_COMPILER_DOWNLOAD},/bin/go)
.PHONY:bootstrap
bootstrap: ${BOOTSTRAP_COMPILER_DOWNLOAD} ${BOOTSTRAP_COMPILER}

${BOOTSTRAP_COMPILER_DOWNLOAD}:
	curl https://storage.googleapis.com/golang/go1.4-bootstrap-20161024.tar.gz | tar xz 
	mv go $@

${BOOTSTRAP_COMPILER}: ${BOOTSTRAP_COMPILER_DOWNLOAD}
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
	@cd "$</src"
	GOROOT_BOOTSTRAP="$(abspath ${BOOTSTRAP_COMPILER_DOWNLOAD})" ./make.bash

VANILLA_COMPILER=$(join ${VANILLA_COMPILER_DOWNLOAD},/bin/go)
.PHONY:vanilla
vanilla: ${VANILLA_COMPILER_DOWNLOAD} ${VANILLA_COMPILER}

${VANILLA_COMPILER_DOWNLOAD}: ${STAGE2_COMPILER_DOWNLOAD}
	git clone "$<" "$@"

${VANILLA_COMPILER}: ${VANILLA_COMPILER_DOWNLOAD} ${STAGE2_COMPILER}
	@cd "$</src"
	export GOROOT_BOOTSTRAP="$(abspath ${STAGE2_COMPILER_DOWNLOAD})" 
	export GOROOT="$$GOROOT_BOOTSTRAP"
	./make.bash

.PHONY:modded
MODDED_COMPILER=modded-compiler
modded: ${MODDED_COMPILER}/bin/go

${MODDED_COMPILER}/bin/go: ${STAGE2_COMPILER}
	@cd "${MODDED_COMPILER}/src"
	export GOROOT_BOOTSTRAP="$(abspath ${STAGE2_COMPILER_DOWNLOAD})" 
	export GOROOT="$$GOROOT_BOOTSTRAP"
	./make.bash

.PHONY:test
test: ${VANILLA_COMPILER}
	export GOROOT="$(abspath ${VANILLA_COMPILER_DOWNLOAD})"
	export PATH="$(abspath $(dir $<)):$$PATH"
	printenv
	go tool dist test
	go run "${CURDIR}/mytests/my-test.go"

.PHONY:clean
clean:
	rm -rf "${MODDED_COMPILER}/bin/go" "${BOOTSTRAP_COMPILER_DOWNLOAD}" "${STAGE2_COMPILER_DOWNLOAD}" "${VANILLA_COMPILER_DOWNLOAD}"
