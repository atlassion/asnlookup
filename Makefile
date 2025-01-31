VERSION = 0.1.0
BUILDDIR ?= build
BINDIR ?= /usr/local/bin
DOCKER_IMAGE ?= banviktor/asnlookup
GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
DATE = $(shell date -u +%Y%m%d)

.PHONY: build
build: $(BUILDDIR)/asnlookup $(BUILDDIR)/asnlookup-utils

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*

.PHONY: deps
deps:
	go mod download

$(BUILDDIR)/asnlookup: deps
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BUILDDIR)/asnlookup ./cmd/asnlookup

$(BUILDDIR)/asnlookup-utils: deps
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BUILDDIR)/asnlookup-utils ./cmd/asnlookup-utils

.PHONY: release
release:
	$(MAKE) clean
	$(MAKE)
	tar -zcf asnlookup-$(GOOS)-$(GOARCH)-v$(VERSION).tar.gz -C $(BUILDDIR) .

release-all:
	$(MAKE) release GOOS=linux GOARCH=amd64
	$(MAKE) release GOOS=linux GOARCH=arm64
	$(MAKE) release GOOS=linux GOARCH=386
	$(MAKE) release GOOS=darwin GOARCH=amd64
	$(MAKE) release GOOS=darwin GOARCH=arm64

.PHONY: test
test:
	go test -race ./...

.PHONY: install
install:
	cp -f $(BUILDDIR)/asnlookup $(BINDIR)/
	cp -f $(BUILDDIR)/asnlookup-utils $(BINDIR)/

.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/asnlookup $(BINDIR)/asnlookup-utils
