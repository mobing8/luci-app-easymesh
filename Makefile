include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-easymesh
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=xxx
PKG_LICENSE:=MIT

# 导入LuCI编译规则
include $(TOPDIR)/feeds/luci/luci.mk

# 开启翻译包生成
LUCI_I18N:=1
LUCI_PKGNAME:=easymesh
LUCI_TITLE:=Easy Mesh WiFi Setup
LUCI_DEPENDS:=+luci-base +batman-adv

$(eval $(call LuCIPackage,luci-app-easymesh))
