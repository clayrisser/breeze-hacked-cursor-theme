MAKEFLAGS += --no-print-directory

# Recipes spawn fresh non-interactive shells that don't source ~/.zshrc, so
# the asdf shim dir isn't on PATH unless we add it here. asdf's default data
# dir is ~/.asdf on both Linux and macOS; honour ASDF_DATA_DIR if the user
# overrides it (XDG-style). Duplicates are harmless — shell PATH lookup just
# stops at the first match.
export PATH := $(or $(ASDF_DATA_DIR),$(HOME)/.asdf)/shims:$(PATH)

GIT ?= git
CLOC ?= cloc
SHFMT ?= shfmt
BATS ?= bats
DOCKER ?= docker

.PHONY: FORCE
FORCE:
