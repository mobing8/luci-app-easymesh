include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-easymesh
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=mobing8
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

# 导入LuCI标准编译规则
include $(TOPDIR)/feeds/luci/luci.mk

# 自动生成多语言包，po/zh-cn/easymesh.po 会自动打包为 luci-i18n-easymesh-zh-cn
LUCI_I18N:=1
LUCI_PKGNAME:=easymesh
LUCI_TITLE:=Easy Mesh WiFi Setup
LUCI_DESCRIPTION:=基于 Batman-adv 的简易无线 Mesh 组网配置插件
LUCI_DEPENDS:=+luci-base +kmod-batman-adv +batctl

define Package/$(PKG_NAME)/conffiles
/etc/config/easymesh
endef

$(eval $(call LuCIPackage,$(PKG_NAME)))
