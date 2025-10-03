#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=automake
PKG_CPE_ID:=cpe:/a:gnu:automake
PKG_VERSION:=1.18.1
PKG_API_VERSION:=$(word 2,$(subst ., ,$(PKG_VERSION)))

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/automake
PKG_HASH:=63e585246d0fc8772dffdee0724f2f988146d1a3f1c756a3dc5cfbefa3c01915

include $(INCLUDE_DIR)/host-build.mk

HOST_CONFIGURE_ARGS += \
	--disable-silent-rules

HOST_CONFIGURE_VARS += \
	PERL="/usr/bin/env perl"

define Host/Configure
	(cd $(HOST_BUILD_DIR); $(AM_TOOL_PATHS) STAGING_DIR_HOST="" ./bootstrap)
	$(call Host/Configure/Default)
endef

define Host/Install
	# remove old automake resources to avoid version conflicts
	$(call Host/Uninstall)
	$(call Host/Compile/Default,install)
	mv $(HOST_BUILD_PREFIX)/bin/aclocal $(HOST_BUILD_PREFIX)/bin/aclocal.real
	$(INSTALL_BIN) ./files/aclocal $(HOST_BUILD_PREFIX)/bin
	( \
		api=$(PKG_API_VERSION); \
		while [ "$$$$api" -ge 11 ]; do \
			ln -sf aclocal "$(HOST_BUILD_PREFIX)/bin/aclocal-1.$$$$api"; \
			api=$$$$(($$$$api - 1)); \
		done; \
	)
endef

define Host/Uninstall
	-$(call Host/Compile/Default,uninstall)
	rm -rf $(HOST_BUILD_PREFIX)/share/aclocal-[0-9]*
	rm -rf $(HOST_BUILD_PREFIX)/share/automake-[0-9]*
	rm -f $(HOST_BUILD_PREFIX)/bin/aclocal.real
endef

$(eval $(call HostBuild))
