# 05. 常见运维问题与故障自检速查手册 (FAQ)

---

### Q1: 矿机后台显示死机/连接不上代理服务？

**排查步骤**：
1. **检查服务端端口监听**：
   在服务器执行 `netstat -tlpn | grep 8888`，确认对应端口处于 `LISTEN` 状态。
2. **检查服务器安全组与系统防火墙**：
   * 云厂商（阿里云/腾讯云/华为云/AWS）必须在控制台“安全组入方向规则”放行对应端口（TCP 协议）。
   * 服务器本地防火墙：`sudo ufw allow 8888/tcp` 或 `sudo firewall-cmd --add-port=8888/tcp --permanent && sudo firewall-cmd --reload`。
3. **协议模式匹配**：
   确认矿机后台协议。如果矿机使用的是常规未加密 Stratum，确保端口模式为 `SSLMIX` 或 `TCP`，切勿误配为纯 `SSL`。

---

### Q2: 矿池后台拒绝率偏高，显示 `Duplicate share` 或 `Stale share`？

**原因与解决**：
1. **物理网络延迟过高 (Stale)**：
   * 矿机 -> 代理 -> 矿池的单向网络往返延迟超过 150ms 时，易出现陈旧块份额。建议将代理部署在靠近矿池机房的节点，或开启 BBR 拥塞控制。
2. **矿机芯片重复提交 (Duplicate)**：
   * LinkProxy 内置了基于 `RecentShareTracker` 的滑动窗口去重过滤引擎，会自动在本地拦截无效重复份额，避免被矿池风控惩罚。
3. **难度跳变导致的计算误差**：
   * 若主备矿池难度差异过大，可在高级设置中开启动态难度平滑（Vardiff 对齐）。

---

### Q3: 忘记了 Web 控制台的管理员密码如何重置？

LinkProxy 的账户信息保存在本地 SQLite 数据库中，可通过以下两种方式重置：

**方式一：使用终端快捷管理菜单（推荐）**
```bash
# 执行终端快捷指令
linkproxy
# 选择菜单选项 [9] 重置面板端口与登录状态
```

**方式二：通过 SQLite 直接重置为默认 admin/admin**
```bash
# 停止代理服务
sudo systemctl stop linkproxy

# 重置管理员账密为 admin / admin
sqlite3 /root/linkproxy/data/proxy.db "UPDATE global_configs SET admin_account='admin', admin_password='admin';"

# 重新启动服务
sudo systemctl start linkproxy
```
重新登录后台后，请立即进入系统设置更新密码。

---

### Q4: 矿机提交份额时，为什么算力折线图偶尔有一两分钟的波谷？

PoW 挖矿本质上是泊松分布的随机事件：
* 在极高难度或单台算力较小的情况下，矿机在连续 1~2 分钟内未找到符合难度的 Nonce 属于完全正常的统计学波动。
* 查看矿机的 15 分钟、1 小时和 24 小时平均算力才是衡量实际性能的标准。
* LinkProxy 采用了 3 分钟优雅离线防抖机制（Grace Cache），网络闪断重连不会丢失历史统计与累积份额。
