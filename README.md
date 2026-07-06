# **📶OpenWRT EasyMesh 简单mesh插件**
### **依托 OpenWRT + Batman-adv，几分钟快速搭建无线Mesh网格网络**
本插件旨在简化基于 WireGuard 的基础无线Mesh网格网络部署流程，底层基于 **Batman-adv（高级移动自组网协议）** 开发，可完美适配 TorGuard WireGuard OpenWRT 插件；同时也支持脱离VPN独立部署普通Mesh网络。

### **为什么要搭建Mesh网格WiFi网络？**
Mesh网格网络适合以下场景：
✔ 大面积拓展VPN WiFi覆盖范围
✔ 多节点通过无线/有线互联，提升全屋网络连通性
✔ 设备无缝漫游，优化上网体验
✔ 搭配WireGuard搭建家庭内网实验室，统一管理跨区域设备

## **🔥 核心功能**
- 一键部署主路由AP无线网络与Mesh回传网络
- 支持WPA3加密（也可开放无密码网络）
- 高级参数配置：K/V/R漫游参数、漫游域、RSSI信号阈值
- Mesh状态仪表盘：展示网卡、相邻节点、最后在线时长
- 支持客户端/节点模式，可配置DHCP自动获取IP或静态IP，兼容瘦AP模式
- 自动为主路由与子节点配置防火墙及网络接口
- 瘦AP网格节点可通过LAN口提供互联网访问
- 兼容TorGuard WireGuard OpenWRT插件，实现全网格VPN隧道组网

# **📦 使用 OpenWRT SDK 编译安装 luci-app-easymesh**
## **步骤1：部署 OpenWRT SDK 编译环境******
1. 下载并安装对应平台的 OpenWRT SDK：
```bash
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
```

### **步骤 2：将 EasyMesh 插件添加至 OpenWRT 软件包源**  
  ```bash
cd package
git clone https://github.com/torguardvpn/luci-app-easymesh.git
```

### **步骤 3：编译插件**  
1. 返回 OpenWRT 根目录:  
   ```bash
   cd ../
   ```
2. 执行配置菜单，选中插件:  
   ```bash
   make menuconfig
   ```
   - 路径：LuCI → 应用程序 → luci-app-easymesh 
   - 选择 <M> 将插件编译为模块
     
3. 执行编译命令:  
   ```bash
   make package/luci-app-easymesh/compile V=s
   ```
4.编译完成后，.ipk 安装包存放路径：bin/packages/.../base/ 

---

# **基于JD-Cloud RE-CP-02制作中文版luci-app-easymesh界面展示**
<img width="1637" height="869" alt="image" src="https://github.com/user-attachments/assets/727b81d6-6da0-4e68-8de9-f021b3348672" />
<img width="1683" height="876" alt="image" src="https://github.com/user-attachments/assets/e8a63390-c57e-4c4f-bc4b-b0a3f558f53e" />

# **📥 通过发布版 IPK 安装 luci-app-easymesh**  

### **方式一：Web 管理界面安装**  
1. 在发布页下载最新安装包：luci-app-easymesh_3.8.17-r1_all.ipk
下载地址：https://github.com/torguardvpn/luci-app-easymesh/releases/download/3.8.17/luci-app-easymesh_3.8.17-r1_all.ipk
2. 在发布页下载最新安装包：luci-app-easymesh_3.8.17-r1_all.ipk
3. 下载地址：https://github.com/torguardvpn/luci-app-easymesh/releases/download/3.8.17/luci-app-easymesh_3.8.17-r1_all.ipk

### **方式二：SSH 终端命令行安装**  
```bash
opkg update
opkg install /path/to/luci-app-easymesh_3.8.17-r1_all.ipk
```

---

# **🛠️ 基础 Mesh 组网部署教程（1 台主节点 + 2 台子节点**  

### **步骤 1：配置 Mesh 主节点**
1. 进入 **网络 → 无线**，删除 / 禁用所有已启用的无线网络
2. 打开 **网络 → EasyMesh**
3. Mesh 模式选择「服务器（Server）」
   ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359288453.png)
4. 填写 WiFi 名称 SSID（所有终端设备连接的统一 WiFi 名称）
5. 选择普通 AP 使用的无线射频（推荐：Mesh 回程与普通 AP 分开使用不同射频，性能更佳）
6. 选择 Mesh 专用射频，填写独立 Mesh 组网 SSID（插件会自动在名称末尾追加 -mesh）
   ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/raw/main/images/1740359253028.png)
7. 开启密码保护，设置 Mesh 组网密码，点击「保存并应用」
8. 点击「重新应用 EasyMesh 配置」，自动生成无线热点并启用 Mesh 组网
🔹 **配置校验:**  
- 进入 **网络 → 无线**，确认插件已自动生成对应 WiFi 网络
  ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359342226.png)
- 进入 **网络 → 接口**，确认已生成 Batman 虚拟网口 bat0 与 mesh_batman 接口
  ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359385796.png)

---

### 步骤 2：配置 Mesh 子节点**
1. 第二台路由器进入** 网络 → EasyMesh **
2. Mesh 模式选择「客户端（Client）」
   ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359451089.png)
3.填写与主节点完全一致的 WiFi 名称、Mesh 组网名称、组网密码
4. 普通 WiFi 与 Mesh 回程必须选用相同无线制式（AX/AC/b/g/n）
5. 保存应用配置，点击「重新应用 EasyMesh 配置」
6. 切换至「AP 模式」标签，设置节点主机名（如 node2、node3）
7. IP 配置推荐 DHCP 自动获取（瘦 AP 模式），也可手动设置与主节点同网段静态 IP
   ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/7.png)
8. 保存应用，点击「启用瘦 AP 模式」

---

### **步骤 3：新增更多 Mesh 子节点**
- 所有节点必须使用**完全相同的 WiFi 名称、Mesh 名称、组网密码**
-  全部节点**统一**无线制式（AX/AC/b/g/n）

---

### **步骤 4：校验相邻节点连通状态**
1. 在 Mesh 主节点后台打开 **网络 → EasyMesh**
   在 Mesh 状态页面查看是否识别到周边子节点
     ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359534195.png)
2. 进入** 网络 → 无线 **
   确认 Mesh 回程无线网络与主节点正常通信
     ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359602760.png)
3. 打开 **状态 → 总览 → DHCP客户端列表**，查看所有 Mesh 节点分配到的 IP 地址
   ![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359643565.png) 
5. 在浏览器输入节点 IP，即可单独登录对应子节点后台 

---

### **骤 5（可选）：主节点启用 TorGuard WireGuard VPN**
![EasyMesh Screenshot](https://github.com/torguardvpn/luci-app-easymesh/blob/main/images/1740359720850.png)
1. 进入 **网络 → TorGuard WireGuard**
2. 填写 WireGuard 账号与密码
3. 选择需要连接的 VPN 服务器地区
4. 开启 WireGuard，保存应用配置
5. 点击「启动 WireGuard」，全网 Mesh 流量全部走 VPN 隧道
---

# **❓ 常见问题 FAQ**  

### **是否必须搭配 WireGuard 才能使用本插件？**  
不需要。你可以完全脱离 VPN，仅用 OpenWRT 快速搭建标准 Mesh 无线网络。

### **普通 WiFi 热点和 Mesh 回程能否共用同一个射频？**
技术上可以，但不推荐，性能会大幅下降。
最佳方案：两组网络分别使用独立射频。
若只能共用单射频，存在以下限制：
  - 可用信道变少，网速、稳定性下降
  - 需关闭 Batman 高级功能：绑定、分片功能，降低硬件负载
    
### **能否接入有线设备或不支持 Mesh 的第三方路由器？**
可以。若使用无 Mesh 功能的有线 OpenWRT 设备（x86 软路由）：
进入 网络 → 接口，手动将 mesh_batman 接口绑定至 bat0 虚拟设备即可。
### **开启瘦 AP 模式后无法登录子节点怎么办？**
无法通过 WiFi 访问时，用网线将子节点 LAN 口直连主节点，在主节点 DHCP 列表查询子节点 IP，浏览器输入 IP 即可登录后台。
### **修改 Mesh 无线参数的正确流程**
1. 先修改所有子节点配置
2. 最后修改 Mesh 主节点参数
3. 全部设备重新应用配置，完成节点重连

---

🔥 **部署完成！你的 OpenWRT Mesh 无线组网已全部生效  🚀**  

## 原始作者

dz &lt;torguardvpn&gt;
