include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-easymesh
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=EasyMesh Contributors

LUCI_TITLE:=Easy Mesh
LUCI_DESCRIPTION:=Web UI for batman-adv based Mesh network configuration
LUCI_DEPENDS:=+kmod-batman-adv +batctl +luci-base
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/preinst
#!/bin/sh
mkdir -p /etc/config
exit 0
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache /tmp/luci-modulecache
}
exit 0
endef

$(eval $(call BuildPackage,luci-app-easymesh))
