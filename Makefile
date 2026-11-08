include common.mk

.PHONY: all release debug clean test build zip check-ndk
all: release debug

NDK_CLANG := $(TOOLCHAIN)/bin/clang
CFLAGS_COMMON := -std=c11 -D_POSIX_C_SOURCE=200809L -fPIC -fvisibility=hidden -Wall -Wextra -Werror -Wpedantic -fno-strict-aliasing
LDFLAGS_COMMON := -shared -Wl,-z,relro,-z,now -Wl,--gc-sections -llog

check-ndk:
	@test -x "$(NDK_CLANG)" || { echo "Android NDK missing: $(NDK_CLANG)"; exit 1; }

release: check-ndk
	@$(MAKE) --no-print-directory build BUILD_TYPE=release

debug: check-ndk
	@$(MAKE) --no-print-directory build BUILD_TYPE=debug

build:
	@mkdir -p "$(BUILD_DIR)/$(BUILD_TYPE)/zygisk" "$(BUILD_DIR)/out"
	@cp -R module/. "$(BUILD_DIR)/$(BUILD_TYPE)/"
	@for arch in $(ARCHS); do \
	  case "$$arch" in \
	    arm64-v8a) target="$(TARGET_arm64-v8a)" ;; \
	    armeabi-v7a) target="$(TARGET_armeabi-v7a)" ;; \
	    x86) target="$(TARGET_x86)" ;; \
	    x86_64) target="$(TARGET_x86_64)" ;; \
	    *) echo "Unknown arch $$arch"; exit 1 ;; \
	  esac; \
	  if [ "$(BUILD_TYPE)" = debug ]; then flags='-O0 -g -DDEBUG'; else flags='-O2 -fdata-sections -ffunction-sections'; fi; \
	  echo "Building $$arch ($(BUILD_TYPE))"; \
	  "$(NDK_CLANG)" --target="$$target" --sysroot="$(TOOLCHAIN)/sysroot" \
	     $(CFLAGS_COMMON) $$flags -Isrc src/main.c \
	     -o "$(BUILD_DIR)/$(BUILD_TYPE)/zygisk/$$arch.so" $(LDFLAGS_COMMON) || exit 1; \
	done
	@sed -e 's/$${versionName}/$(VER_NAME) ($(BUILD_TYPE))/g' -e 's/$${versionCode}/$(VER_CODE)/g' module/module.prop > "$(BUILD_DIR)/$(BUILD_TYPE)/module.prop"
	@cd "$(BUILD_DIR)/$(BUILD_TYPE)" && zip -qr9 "../out/ZygiskEnv-Alpha-Bridge-$(VER_NAME)-$(BUILD_TYPE).zip" .
	@echo "Archive ready: $(BUILD_DIR)/out/ZygiskEnv-Alpha-Bridge-$(VER_NAME)-$(BUILD_TYPE).zip"

test:
	@mkdir -p build/tests
	@cc -std=c11 -D_POSIX_C_SOURCE=200809L -DZYGISK_ENV_TEST -DDEBUG -g \
	     -Wall -Wextra -Werror -Isrc -Itests/include \
	     -I"$${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}/include" \
	     -I"$${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}/include/linux" \
	     src/main.c tests/test_main.c -o build/tests/zygisk_env_test
	@build/tests/zygisk_env_test
	@sh -n module/customize.sh
	@sh -n module/action.sh
	@sh tests/test_installer.sh

clean:
	@rm -rf build
