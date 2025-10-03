#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=missing-macros
PKG_RELEASE:=12

include $(INCLUDE_DIR)/host-build.mk

define Host/Configure
endef

define Host/Compile
endef

define Host/Install
	$(INSTALL_DIR) $(HOST_BUILD_PREFIX)/share/aclocal
	$(INSTALL_DATA) $(HOST_BUILD_DIR)/m4/*.m4 $(HOST_BUILD_PREFIX)/share/aclocal/
	$(INSTALL_DIR) $(HOST_BUILD_PREFIX)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/bin/* $(HOST_BUILD_PREFIX)/bin/
	$(LN) makeinfo $(HOST_BUILD_PREFIX)/bin/texi2any
	$(LN) makeinfo $(HOST_BUILD_PREFIX)/bin/texi2pdf
	$(LN) makeinfo $(HOST_BUILD_PREFIX)/bin/texi2dvi
	$(LN) makeinfo $(HOST_BUILD_PREFIX)/bin/pdftexi2dvi
	$(LN) makeinfo $(HOST_BUILD_PREFIX)/bin/texi2html
endef

$(eval $(call HostBuild))
