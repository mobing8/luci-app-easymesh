local m, s, o
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local iwinfo = require "iwinfo"
m = Map("easymesh",
    "无线Mesh WiFi设置",
    "本程序基于Batman-adv二层Mesh协议开发。部署流程：先配置主网关路由，再添加子节点。配置Mesh节点时，先启用Mesh无线接口建立组网链路，再切换DHCP子节点模式。默认参数适用于绝大多数家庭Mesh场景。"
    .. "<br/>" .. "官方文档：" .. ' <a href="https://www.open-mesh.org/projects/batman-adv/wiki" target="_blank">https://www.open-mesh.org/projects/batman-adv/wiki</a>'
)
-- ? Ensure get_verbose_hw_info() is declared first
local function get_verbose_hw_info(iface)
    local type = iwinfo.type(iface)
    if not type then return "通用无线网卡" end
    local driver = iwinfo[type]
    if not driver then return "不支持的驱动" end
    local hw_name = driver.hardware_name and driver.hardware_name(iface) or "未知硬件"
    local hw_modes = driver.hwmodelist and driver.hwmodelist(iface) or {}
    local supported_modes = {}
    for mode, supported in pairs(hw_modes) do
        if supported then
            table.insert(supported_modes, mode)
        end
    end
    return hw_name .. " (" .. (#supported_modes > 0 and table.concat(supported_modes, "/") or "无模式信息") .. ")"
end
-- ? Fixed Neighbor Detection Function
function detect_Node()
    local data = {}
    -- Run batctl to list neighbor nodes
    local lps = luci.util.execi("batctl n 2>/dev/null | tail -n +3")  -- Skip headers
    for line in lps do
        -- Print each raw line for debugging
        print("DEBUG: Raw line -> [" .. line .. "]")
        -- Skip invalid lines (headers)
        if string.match(line, "Neighbor%s+last%-seen%s+speed%s+IF") then
            print("DEBUG: Skipping header line -> [" .. line .. "]")
        else
            -- Normalize spacing
            line = string.gsub(line, "%s+", " ")
            -- Extract fields
            local neighbor, lastseen, interface = line:match("(%S+)%s+(%S+)%s+%(.+%)%s+%[(%S+)%]")
            -- Debugging: Show extracted values
            if neighbor and lastseen and interface then
                print(string.format("DEBUG: Parsed -> Interface: %s, Neighbor: %s, Last Seen: %s", interface, neighbor, lastseen))
                
                table.insert(data, {
                    ["IF"] = interface,
                    ["Neighbor"] = neighbor,
                    ["lastseen"] = lastseen
                })
            else
                print("DEBUG: Skipped line due to incorrect format -> [" .. line .. "]")
            end
        end
    end
    return data
end
-- ? Get Active Node Count Correctly
local Nodes = luci.sys.exec("batctl n 2>/dev/null | grep -E '^[0-9a-fA-F]{2}:' | wc -l")
-- ? Display Mesh Status Table
local Node = detect_Node()
v = m:section(Table, Node, "Mesh组网状态", "<b>在线节点数量：" .. Nodes .. "</b>")
v:option(DummyValue, "IF", "无线接口")
v:option(DummyValue, "Neighbor", "相邻节点")
v:option(DummyValue, "lastseen", "最后通信时间")
s = m:section(TypedSection, "easymesh", "Mesh组网设置")
s.anonymous = true
s:tab("setup", "基础设置")
s:tab("apmode", "扩展AP模式")
s:tab("advanced", "高级设置")
-- Enable EasyMesh
o = s:taboption("setup", Flag, "enabled", "启用Mesh组网",
    "开启/关闭本机Mesh无线组网功能，所有参数修改后需重新应用配置。")
o.default = 0
-- Mesh Mode Selection
o = s:taboption("setup", ListValue, "role", "Mesh节点角色",
    "选择本机在Mesh网络中的身份：主路由、独立扩展节点、子AP节点。")
o:value("server", "主网关路由")
o:value("off", "独立扩展节点")
o:value("client", "子AP节点")
o.default = "server"
-- Regular WiFi Network SSID
o = s:taboption("setup", Value, "wifi_id", "普通WiFi名称",
    "终端设备正常连接的无线网络名称。")
o.default = "easymesh_AC"
-- Select the WiFi radio for the regular AP
wifiRadio = s:taboption("setup", ListValue, "wifi_radio", "普通AP射频",
    "选择用于发射普通家用WiFi的无线射频。")
uci:foreach("wireless", "wifi-device",
    function(s)
        local iface = s['.name']
        local hw_modes = get_verbose_hw_info(iface)
        local desc = string.format("%s (%s)", iface, hw_modes)
        wifiRadio:value(iface, desc)
    end)
wifiRadio.default = "radio1"
wifiRadio.widget = "select"
-- Select the WiFi radio for mesh backhaul
apRadio = s:taboption("setup", MultiValue, "apRadio", "Mesh回传射频",
    "专门用于节点之间无线互联的射频接口。")
uci:foreach("wireless", "wifi-device",
    function(s)
        local iface = s['.name']
        local hw_modes = get_verbose_hw_info(iface)
        local desc = string.format("%s (%s)", iface, hw_modes)
        apRadio:value(iface, desc)
    end)
apRadio.default = "radio0"
apRadio.widget = "select"
o = s:taboption("setup", Value, "mesh_id", "Mesh组网名称",
    '<p style="text-align: justify; padding: 0;"><strong>所有Mesh节点必须填写完全相同的组网名称才能互相发现。</strong></p>')
o.default = "easymesh_AC"
encryption = s:taboption("setup", Flag, "encryption", "启用组网密码",
    '<p style="text-align: justify; padding: 0;"><strong>开启后其他设备需要输入密码才能加入Mesh组网。</strong></p>')
encryption.default = 0
o = s:taboption("setup", Value, "key", "Mesh组网密码")
o.default = "easymesh"
o:depends("encryption", 1)
o.password = true
o.datatype = "minlength(8)"
btnReapply = s:taboption("setup", Button, "_btn_reapply", "重新应用Mesh配置",
    '<p style="text-align: justify; padding: 0;"><strong>保存配置后点击此按钮重载所有Mesh无线参数。</strong></p>')
function btnReapply.write()
    io.popen("/easymesh/easymesh.sh &")
end
enable_kvr = s:taboption("advanced", Flag, "kvr", "开启802.11k/v/r漫游",
    '<p style="text-align: justify; padding: 0;"><strong>无特殊需求请保持默认开启，修改会影响终端无缝漫游体验</p></strong>')
enable_kvr.default = 1
mobility_domain = s:taboption("advanced", Value, "mobility_domain", "漫游域ID")
mobility_domain.default = "4f57"
mobility_domain.datatype = "and(hexstring,rangelength(4,4))"
rssi_val = s:taboption("advanced", Value, "good_rssi_val", "良好信号阈值")
rssi_val.default = "-60"
rssi_val.datatype = "range(-120,-1)"
low_rssi_val = s:taboption("advanced", Value, "bad_rssi_val", "弱信号下线阈值")
low_rssi_val.default = "-88"
low_rssi_val.datatype = "range(-120,-1)"
---- ap_mode
o = s:taboption("apmode", Value, "hostname", "节点主机名")
o.default = "node2"
o:value("node2", "node2")
o:value("node3", "node3")
o:value("node4", "node4")
o:value("node5", "node5")
o:value("node6", "node6")
o:value("node7", "node7")
o:value("node8", "node8")
o:value("node9", "node9")
o.datatype = "string"
o:depends({role="off",role="client"})
-- IP Mode (DHCP or Static)
ipmode = s:taboption("apmode", ListValue, "ipmode", "IP获取方式",
    "选择子节点IP地址获取模式：自动DHCP或手动静态IP")
ipmode:value("dhcp", "自动DHCP")
ipmode:value("static", "静态IP")
ipmode.default = "dhcp"
ipmode:depends({role="off",role="client"})
-- Static IP address
o = s:taboption("apmode", Value, "ipaddr", "静态IP地址")
o.default = "192.168.8.3"
o.datatype = "ip4addr"
o:depends({ipmode="static",role="off",role="client"})
-- DNS (Mesh Gateway IP Address)
o = s:taboption("apmode", Value, "gateway", "Mesh网关地址")
o.default = "192.168.8.1"
o.datatype = "ip4addr"
o:depends({ipmode="static",role="off",role="client"})
-- IPv4 netmask
o = s:taboption("apmode", Value, "netmask", "子网掩码")
o.default = "255.255.255.0"
o.datatype = "ip4addr"
o:depends({ipmode="static",role="off",role="client"})
-- IPv4 netmask
o = s:taboption("apmode", Value, "dns", "DNS服务器")
o.default = "192.168.8.1"
o.datatype = "ip4addr"
o:depends({ipmode="static",role="off",role="client"})
btnAPMode = s:taboption("apmode", Button, "_btn_apmode", "启用纯AP扩展模式",
    "警告：切换后本机IP地址会变更，当前网页连接会断开，请使用新IP访问后台")
function btnAPMode.write()
    io.popen("/easymesh/easymesh.sh dumbap &")
end
btnAPMode:depends({role="off",role="client"})
return m
