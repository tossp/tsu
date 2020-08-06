.PHONY: run build fmt fmt-check test vet up clean

-include .env
EXE:=
ifeq ($(LANG),)
EXE=.exe
endif
DIST_DIR=./dist/
GITTAG:=$(shell git describe --tags || echo 'unknown')
GITVERSION:=$(shell git rev-parse HEAD)
PACKAGES:=$(shell go list ./... | grep -v /vendor/)
VETPACKAGES=`go list ./... | grep -v /vendor/ | grep -v /examples/`
GOFILES=`find . -name "*.go" -type f -not -path "./vendor/*"`
BUILD_TIME=`date +%FT%T%z`
LDFLAGS=-ldflags "-s -w -X github.com/tossp/tsgo/pkg/setting.GitTag=$(GITTAG) -X github.com/tossp/tsgo/pkg/setting.GitVersion=${GITVERSION} -X github.com/tossp/tsgo/pkg/setting.BuildTime=${BUILD_TIME} -X github.com/tossp/tsgo/pkg/setting.BuildVersion=${VERSION}"
GOBUILD=go build -trimpath

all: up

pdf: fmt
	@echo " > Building pdf..."
	@env CGO_ENABLED=0 ${GOBUILD} ${LDFLAGS} -o $(DIST_DIR)pdf$(EXE) ./cmd/pdf

deflate: fmt
	@echo " > Building deflate..."
	@env CGO_ENABLED=0 ${GOBUILD} ${LDFLAGS} -o $(DIST_DIR)deflate$(EXE) ./cmd/deflate

debug:
	@echo " > exec debug..."
	@${GOBUILD} -gcflags "all=-N -l" ./cmd/app
	@dlv --listen=:2345 --headless=true --api-version=2 exec ${BINARY}

list:
	@echo " > list..."
	@echo ${PACKAGES}
	@echo ${VETPACKAGES}
	@echo ${GOFILES}

fmt:
	@echo " > gofmt..."
	# @goimports -w ${GOFILES}
	@go fmt ./...

check: fmt
	@golint "-set_exit_status" ${GOFILES}
	@go vet ${GOFILES}

test:
	@go test -cpu=1,2,4 -v -tags integration ./...

up: fmt
	@echo " > go update..."
	@go get -u -v ./...
	@go mod tidy

vet:
	@echo " > go vet..."
	@go vet $(VETPACKAGES)

clean:
	@echo " > clean..."
	@if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi
