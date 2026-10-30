# 02. 万台矿机高并发 Linux 内核与网络栈调优参数手册

当单个代理节点挂载超过 500 台矿机，或者面对高频算力（如 Kaspa / Aleo / 蚂蚁 S21 集群瞬时数百份额并发）时，默认的 Linux 内核参数会导致：
* **`Too many open files`**（句柄耗尽导致新矿机连不上）
* **`Connection reset by peer`**（SYN 队列溢出导致 ASIC 掉线）
* **网络延迟抖动引发的陈旧份额（Stale Share）拒绝**

本指南详细记录经千万级并发验证的标准生产调优方案。

---

## 一键自动调优（推荐）

LinkProxy 仓库自带了一键调优脚本，自动备份原配置并写入最优参数：

```bash
curl -fsSL https://raw.githubusercontent.com/LinkProxy-Core/linkproxy/main/scripts/sysctl-tune.sh | sudo bash
```

---

## 手动调优参数详解

### 1. 解除最大文件句柄限制 (`/etc/security/limits.conf`)

编辑 `/etc/security/limits.conf`，在末尾追加：

```ini
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 524288
* hard nproc 524288
root soft nofile 1048576
root hard nofile 1048576
root soft nproc 524288
root hard nproc 524288
```

同时修改 `/etc/pam.d/common-session`，确保追加以下行使配置对所有登录会话生效：
```ini
session required pam_limits.so
```

### 2. TCP 网络栈核心调优 (`/etc/sysctl.conf`)

编辑 `/etc/sysctl.conf`，追加以下优化块：

```ini
# 系统全局最大文件句柄数
fs.file-max = 2097152

# 最大 Socket 监听队列与 SYN 半连接队列
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# 优化 TIME_WAIT 套接字快速回收与复用 (矿机频繁短连接断线保护)
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# 保活心跳探测优化 (更敏锐感知物理断线，避免挂起僵尸连接)
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5

# 增大 Socket 接收与发送缓冲区 (防瞬时高突发丢包)
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# 开启 BBR 拥塞控制算法 (大幅改善跨境网络高延迟与丢包率)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
```

执行以下命令立即生效：
```bash
sudo sysctl -p
```

### 3. Systemd 进程级句柄覆盖

确保 LinkProxy 服务单元文件具备最高特权限制。检查 `/etc/systemd/system/linkproxy.service`：

```ini
[Service]
LimitNOFILE=1048576
LimitNPROC=524288
```

更新后执行：
```bash
sudo systemctl daemon-reload
sudo systemctl restart linkproxy
```

---

## 验证调优结果

在服务器执行以下检查指令：

```bash
# 1. 验证用户文件描述符
ulimit -n
# 预期输出: 1048576

# 2. 验证进程实际生效限制 (替换 <PID> 为 linkproxy 实际进程号)
cat /proc/$(pgrep linkproxy | head -n 1)/limits | grep 'Max open files'
# 预期输出: Max open files  1048576  1048576  files

# 3. 验证 BBR 拥塞控制
sysctl net.ipv4.tcp_congestion_control
# 预期输出: net.ipv4.tcp_congestion_control = bbr
```
