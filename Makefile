VERSION ?= 0.1.0
ORG_IMG ?= tmdcio/knox:$(VERSION)
BINDIR      		:= $(CURDIR)/bin
BINNAME     		?= knox
GOPATH        = $(shell go env GOPATH)
GOIMPORTS     = $(GOPATH)/bin/goimports

# go option
PKG        := ./...
TAGS       :=
TESTS      := .
TESTFLAGS  :=
LDFLAGS    := -w -s
GOFLAGS    :=
SRC        := $(shell find . -type f -name '*.go' -print)

.PHONY: all
all: build

# ------------------------------------------------------------------------------
#  build

build: clean tidy fmt vet test-unit compile

.PHONY: clean
clean:
	@echo
	@echo "=== cleaning ==="
	rm -rf $(BINDIR)

tidy:
	@echo
	@echo "=== tidying ==="
	go mod tidy

.PHONY: compile
compile: $(BINDIR)/$(BINNAME)

$(BINDIR)/$(BINNAME): $(SRC)
	@echo
	@echo "=== running compile ==="
	GO111MODULE=on CGO_ENABLED=0 go build $(GOFLAGS) -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $(BINDIR)/$(BINNAME) ./cmd/dev_server

# Run go fmt against code
fmt:
	@echo
	@echo "=== fmt ==="
	go fmt ./...

# Run go vet against code
vet:
	@echo
	@echo "=== vet ==="
	go vet ./...

# ------------------------------------------------------------------------------
#  test

.PHONY: test-unit
test-unit:
	@echo
	@echo "=== running unit tests ==="
	@GO111MODULE=on go test $(GOFLAGS) -run $(TESTS) $(PKG) $(TESTFLAGS)

# ------------------------------------------------------------------------------
#  run

run: compile
	@echo
	@echo "=== running ==="
	$(BINDIR)/$(BINNAME)
