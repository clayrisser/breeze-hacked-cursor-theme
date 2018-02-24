CWD := $(shell pwd)

.PHONY: all
all: build

.PHONY: install
install: build
	@mkdir -p ~/.icons
	@cp -r Breeze_Hacked ~/.icons/Breeze_Hacked
	@echo ::: INSTALL :::

.PHONY: build
build: Breeze_Hacked
	@echo ::: BUILD :::

.PHONY: clean
	-@rm -rf build Breeze_Hacked &>/dev/null | true
	@echo ::: CLEAN :::

Breeze_Hacked:
	@sh build.sh
