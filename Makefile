.POSIX:
export ROOTDIR ?= $(eval ROOTDIR := $(shell git rev-parse --show-toplevel))$(ROOTDIR)
include $(ROOTDIR)/make.mk

.DEFAULT_GOAL := build

THEME := Breeze_Hacked

.PHONY: prepare
prepare:
	@awk '!/^#/ && NF {print $$1}' .tool-versions | \
		while read t; do asdf plugin add "$$t" 2>/dev/null || true; done
	@rcfile=$$(mktemp); \
		{ asdf install 2>&1; echo $$? >$$rcfile; } | grep --line-buffered -v 'is already installed' || true; \
		rc=$$(cat $$rcfile); rm -f $$rcfile; exit $$rc

.PHONY: configure
configure:
	@for cmd in $(SHFMT) $(BATS); do \
		command -v $$cmd >/dev/null 2>&1 || { echo "$$cmd is missing, run \`make prepare\`"; exit 1; }; \
	done

# build.sh checks for its own tools (inkscape, xcursorgen) and points at
# `make build/docker` when they are missing. The ~build artifact marker lets
# install/test reuse a fresh theme (e.g. one staged by build/docker) without
# requiring the render tools on the host.
.PHONY: build ~build
~build: $(THEME)/index.theme
$(THEME)/index.theme: build.sh $(shell $(GIT) ls-files src)
	@$(MAKE) build
build: FORCE
	@./build.sh

DOCKER_IMAGE ?= breeze-hacked-cursor-theme-build

.PHONY: build/docker
build/docker:
	@$(DOCKER) build -t $(DOCKER_IMAGE) docker
	@$(DOCKER) run --rm -v $(ROOTDIR):/work -w /work -e HOME=/tmp \
		-u $$(id -u):$$(id -g) $(DOCKER_IMAGE) ./build.sh

PREFIX ?= /usr/local
DESTDIR ?=
datadir := $(DESTDIR)$(PREFIX)/share
icondir := $(datadir)/icons

# cp -R instead of install(1) because the theme is a tree whose alias
# cursors are symlinks, which install(1) would flatten into file copies.
.PHONY: install
install: ~build
	@install -d $(icondir)
	@rm -rf $(icondir)/$(THEME)
	@cp -R $(THEME) $(icondir)/$(THEME)

.PHONY: uninstall
uninstall:
	@rm -rf $(icondir)/$(THEME)

.PHONY: test
test: configure ~build
	@$(BATS) tests

.PHONY: format
format: configure
	@$(SHFMT) -w .

.PHONY: lint
lint: configure
	@$(SHFMT) -d .

.PHONY: count
count:
	@$(CLOC) $$($(GIT) ls-files)

.PHONY: clean
clean:
	@rm -rf build $(THEME)

.PHONY: purge
purge: clean
	@$(GIT) clean -fxd
