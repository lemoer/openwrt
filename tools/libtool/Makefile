# 
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=libtool
PKG_CPE_ID:=cpe:/a:gnu:libtool
PKG_VERSION:=2.5.4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=da8ebb2ce4dcf46b90098daf962cffa68f4b4f62ea60f798d0ef12929ede6adf

include $(INCLUDE_DIR)/host-build.mk

export GNULIB_SRCDIR:=$(HOST_GNULIB_SRCDIR)

HOST_CONFIGURE_VARS += \
	lt_cv_sys_dlsearch_path=""

HOST_MAKE_FLAGS += \
	am__CONFIG_DISTCLEAN_FILES= \
	CONFIG_STATUS_DEPENDENCIES=

define Host/Bootstrap
	( \
		cd $(HOST_BUILD_DIR); \
		$(AM_TOOL_PATHS) \
		./bootstrap \
			--copy \
			--force \
			--skip-git \
			--skip-po \
			--gnulib-srcdir=$(GNULIB_SRCDIR) \
	)
endef

define Host/Prepare
	$(call Host/Prepare/Default)
	$(call Host/Uninstall)
	$(if $(QUILT),,$(call Host/Bootstrap))
endef

define Host/Configure
	$(if $(QUILT),$(call Host/Bootstrap))
	$(call Host/Configure/Default)
	$(call Host/Uninstall)
endef

define Host/Install
	$(call Host/Compile/Default,install)
	$(SED) 's,\(hardcode_into_libs\)=yes,\1=no,g' $(HOST_BUILD_PREFIX)/bin/libtool
endef

define Host/Uninstall
	-$(call Host/Compile/Default,uninstall)
	-$(call Host/Compile/Default,maintainer-clean) # Clean bootstrap files from the release
	(if test -d $(HOST_BUILD_PREFIX)/share/aclocal/; then rm -f $(HOST_BUILD_PREFIX)/share/aclocal/libtool.m4 $(HOST_BUILD_PREFIX)/share/aclocal/ltdl.m4 $(HOST_BUILD_PREFIX)/share/aclocal/lt~obsolete.m4 $(HOST_BUILD_PREFIX)/share/aclocal/ltoptions.m4 $(HOST_BUILD_PREFIX)/share/aclocal/ltsugar.m4 $(HOST_BUILD_PREFIX)/share/aclocal/ltversion.m4; fi)
endef

$(eval $(call HostBuild))
