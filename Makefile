SRC_DIR = src
BUILD_DIR = build


all: build

prepare:
	@mkdir -p $(BUILD_DIR)
	@echo "*" > $(BUILD_DIR)/.gitignore

build: prepare
	@argbash $(SRC_DIR)/coloraddod.m4.sh -o $(BUILD_DIR)/coloraddod
	@argbash $(SRC_DIR)/coloraddoctl.m4.sh -o $(BUILD_DIR)/coloraddoctl

clean:
	@rm -rf $(BUILD_DIR)
