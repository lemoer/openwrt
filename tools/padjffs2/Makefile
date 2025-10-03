#
# Copyright (C) 2011-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=padjffs2
PKG_RELEASE:=1

include $(INCLUDE_DIR)/host-build.mk

define Host/Prepare
	$(call Host/Prepare/Default)
	find $(HOST_BUILD_DIR) -name .svn | $(XARGS) rm -rf
endef

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)
endef

define Host/Configure
endef

define Host/Install
	$(CP) $(HOST_BUILD_DIR)/padjffs2 $(HOST_BUILD_PREFIX)/bin/
endef

define Host/Clean
	rm -f $(HOST_BUILD_PREFIX)/bin/padjffs2
endef

$(eval $(call HostBuild))
