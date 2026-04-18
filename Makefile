SRC_DIR = src
BUILD_DIR = build
PREFIX ?= /usr/local


all: build

prepare:
	@mkdir -p "$(BUILD_DIR)"
	@echo "*" > "$(BUILD_DIR)/.gitignore"

build: prepare
	@argbash "$(SRC_DIR)/coloraddod.m4.sh" -o "$(BUILD_DIR)/coloraddod"
	@argbash "$(SRC_DIR)/coloraddoctl.m4.sh" -o "$(BUILD_DIR)/coloraddoctl"

clean:
	@rm -rf "$(BUILD_DIR)"

install: build
	install -D -m 755 "$(BUILD_DIR)/coloraddod" "$(DESTDIR)$(PREFIX)/bin/coloraddod"
	install -D -m 755 "$(BUILD_DIR)/coloraddoctl" "$(DESTDIR)$(PREFIX)/bin/coloraddoctl"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/coloraddod"
	rm -f "$(DESTDIR)$(PREFIX)/bin/coloraddoctl"
