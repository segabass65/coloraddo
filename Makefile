BUILD_DIR = build
DIST_DIR = dist
MAINTAINER ?= segabass65 <segabass65@proton.me>
PREFIX ?= /usr/local
SRC_DIR = src


all: build

clean:
	@rm -rf "$(BUILD_DIR)"
	@rm -rf "$(DIST_DIR)"

prepare: clean
	@mkdir -p "$(BUILD_DIR)" "$(DIST_DIR)"
	@echo "*" | tee \
		"$(BUILD_DIR)/.gitignore" \
		"$(DIST_DIR)/.gitignore" \
	> /dev/null

build: prepare
	@argbash "$(SRC_DIR)/coloraddod.m4.sh" -o "$(BUILD_DIR)/coloraddod"
	@argbash "$(SRC_DIR)/coloraddoctl.m4.sh" -o "$(BUILD_DIR)/coloraddoctl"

install: build
	install -D -m 755 \
		"$(BUILD_DIR)/coloraddod" \
		"$(DESTDIR)/$(PREFIX)/bin/coloraddod"

	install -D -m 755 \
		"$(BUILD_DIR)/coloraddoctl" \
		"$(DESTDIR)/$(PREFIX)/bin/coloraddoctl"

uninstall:
	rm -f "$(DESTDIR)/$(PREFIX)/bin/coloraddod"
	rm -f "$(DESTDIR)/$(PREFIX)/bin/coloraddoctl"

package:
	@$(MAKE) install DESTDIR="dist" PREFIX="usr"
	@fpm \
		--description "Changing border colors depending on bspwm node flags" \
		--license MIT \
		--url https://github.com/segabass65/coloraddo \
		--vendor "SegaBASS (segabass65)" \
		-C "$(DIST_DIR)" \
		-a all \
		-f \
		-m "$(MAINTAINER)" \
		-n coloraddo \
		-p packages/ \
		-s dir \
		-t deb \
		-v 1.0 \
		-x .gitignore \
		.
