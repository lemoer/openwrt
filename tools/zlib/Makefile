#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zlib
PKG_VERSION:=1.3.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/madler/zlib
PKG_SOURCE_VERSION:=51b7f2abdade71cd9bb0e7a373ef2610ec6f9daf
PKG_MIRROR_HASH:=6558577038f4839057fad93afb295bf32e84dc9bd2c33512d40a5eab6d4889ef

PKG_LICENSE:=Zlib
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:zlib:zlib

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk

HOSTCC := $(HOSTCC_NOCACHE)
HOST_CFLAGS += $(HOST_FPIC)

HOST_CONFIGURE_ARGS = \
	--prefix=$(HOST_BUILD_PREFIX) \
	--sysconfdir=$(HOST_BUILD_PREFIX)/etc \
	--localstatedir=$(HOST_BUILD_PREFIX)/var \
	--libdir=$(HOST_BUILD_PREFIX)/lib \
	--includedir=$(HOST_BUILD_PREFIX)/include \
	--static

define Host/Uninstall
	-$(call Host/Compile/Default,uninstall)
endef

$(eval $(call HostBuild))
