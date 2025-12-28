#!/bin/sh

set -e

dest=myconf

# List all config options, and redirect to a file
#scripts/config/conf --listnewconfig Config.in -r /dev/null > $dest
scripts/config/conf Config.in -r /dev/null --alldefconfig -w $dest



# Replace CONFIG_XY=... with CONFIG_XY=$(error CONFIG_XY was not imported, but used.) using awk

awk '{
    if ($0 ~ /^CONFIG_[A-Za-z.\-0-9_]+=.*/) {
        split($0, a, "=");
        print a[1]"=$(error "a[1]" was not imported, but used.)"
    } else {
        print $0
    }
}' $dest > ${dest}_tmp

import() {
    grep -e "$1[= ]" .config.bak >> ${dest}_tmp || ( echo "$1 not found" && exit 1 )
}

# toolchain

# import CONFIG_ARCH
# import CONFIG_ARCH_64BIT
# import CONFIG_TARGET_ARCH_PACKAGES
# import CONFIG_TARGET_BOARD
# import CONFIG_TARGET_SUBTARGET
# import CONFIG_TARGET_OPTIMIZATION
# import CONFIG_BUILD_SUFFIX
# import CONFIG_CPU_TYPE
# import CONFIG_BINARY_FOLDER
# import CONFIG_GCC_VERSION
# import CONFIG_LIBC
# import CONFIG_USE_MUSL
# import CONFIG_TARGET_ROOTFS_DIR
# import CONFIG_BUILD_LOG_DIR
# import CONFIG_TARGET_INIT_PATH
# import CONFIG_EXTRA_OPTIMIZATION
# import CONFIG_TARGET_SUFFIX
# import CONFIG_USE_SSTRIP
# import CONFIG_SSTRIP_DISCARD_TRAILING_ZEROES
# import CONFIG_IPV6
# import CONFIG_DOWNLOAD_CHECK_CERTIFICATE
# import CONFIG_DOWNLOAD_TOOL_CUSTOM
# import CONFIG_DOWNLOAD_FOLDER

# import CONFIG_DEBUG
# import CONFIG_NO_STRIP
# import CONFIG_SSP_SUPPORT
# import CONFIG_BINUTILS_VERSION
# import CONFIG_EXTRA_BINUTILS_CONFIG_OPTIONS

# tools/7z
import CONFIG_ARCH # <- should be uncesseary?
import CONFIG_ARCH_64BIT
import CONFIG_TARGET_ARCH_PACKAGES
import CONFIG_TARGET_BOARD
import CONFIG_TARGET_SUBTARGET
import CONFIG_TARGET_OPTIMIZATION
import CONFIG_BUILD_SUFFIX
import CONFIG_CPU_TYPE
import CONFIG_BINARY_FOLDER
import CONFIG_GCC_VERSION
import CONFIG_LIBC
import CONFIG_USE_MUSL
import CONFIG_TARGET_ROOTFS_DIR
import CONFIG_BUILD_LOG_DIR
import CONFIG_TARGET_INIT_PATH
import CONFIG_EXTRA_OPTIMIZATION
import CONFIG_TARGET_SUFFIX
import CONFIG_USE_SSTRIP
import CONFIG_SSTRIP_DISCARD_TRAILING_ZEROES
import CONFIG_IPV6
import CONFIG_DOWNLOAD_CHECK_CERTIFICATE
import CONFIG_DOWNLOAD_TOOL_CUSTOM
import CONFIG_DOWNLOAD_FOLDER

import CONFIG_AUTOREBUILD