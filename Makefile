include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-easymesh
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only

LUCI_TITLE:=Easy Mesh
LUCI_DESCRIPTION:=Web UI for batman-adv based Mesh network configuration
LUCI_DEPENDS:=+kmod-batman-adv +batctl
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk
