# LinkProxy

高性能多币种 Stratum / EthProxy 网络中转与分流服务。

![Version](https://img.shields.io/badge/Version-v2.2.141-blue.svg)
![Protocol](https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg)

针对 BTC、LTC、Kaspa、ETC、PRL、QTC 等主流 ASIC 与 GPU/CPU 计算节点开发的高并发网关服务，支持多矿池分流、动态难度自适应、平滑切池与 Web 可视化管理。

## 主要特性

- **协议深度兼容**：全面支持 BTC/BCH (SHA-256)、LTC (Scrypt)、KAS (kHeavyHash)、ETC/ETHW 等主流币种的 Stratum 及 EthProxy 协议，原生深度适配 **PRL (Pearlhash 珍珠币)** 与 **QTC (Quantus)** 专属协议重写与动态周期调度。
- **平滑切池与防断连**：底层深度对齐协议状态，切池过程只同步 Extranonce 与工作难度，不触发芯片流水线清空，避免 S19/S21 等 ASIC 节点掉线或保护重启。
- **离线防抖与智能过滤**：对标业界顶级网关架构，实现 2 分钟离线防抖观察期与待机连接静默机制，自动消除矿池闪断与网络抖动造成的日志刷屏，保持面板清爽。
- **端口参数一键克隆**：管理面板支持现有代理端口参数一键深拷贝，无需重复填写目标矿池、备用矿池与复杂高级参数，秒级微调并派生新端口。
- **动态发布智能感知**：部署管理脚本内置 302 毫秒级重定向探测，全自动识别官方最新版本并自动部署，无需手动维护脚本。
- **动态难度（Vardiff）对齐**：支持自动校准不同矿池间的下发难度，消除跨池切换造成的算力抖动与虚假算力。
- **故障转移与容灾**：主矿池网络异常时自动执行平滑重连与故障降级，确保高网络抖动环境下的持续连接。
- **Web 可视化面板**：内置轻量 Web 监控后台，提供节点实时算力折线图、有效/拒绝份额统计、在线状态及独立拒绝日志追溯。

## 支持币种

| 币种 | 协议类型 | 算法与特性 |
| :--- | :--- | :--- |
| **BTC / BCH** | Stratum | SHA-256 (ASIC 深度优化，0 芯片重启) |
| **LTC** | Stratum | Scrypt (主池/备用池平滑切换) |
| **PRL (珍珠币)** | Stratum | Pearlhash (原生支持，自适应双向改写) |
| **QTC (Quantus)** | Stratum | Poseidon2-Goldilocks (Quantus 专属中转分流) |
| **KAS (Kaspa)** | Stratum | kHeavyHash (超低延迟并行通道) |
| **ETC / ETHW** | EthProxy / Stratum | Etchash / Ethash (Target 难度无感重写) |
| **ZEC** | Stratum | Equihash |
| **SC** | Stratum | Blake2b |
| **DASH** | Stratum | X11 |
| **CKB** | Stratum | Eaglesong |
| **CFX** | Stratum | Octopus |
| **ALEO** | Stratum | Aleo (ZKP 证明分流) |
| **ALPH** | Stratum | Blake3 |
| **自定义代币** | 自适应 | 兼容主流 Stratum 变体 |

## 安装与部署

### 方式一：Linux 一键安装（推荐）

支持 Ubuntu / Debian / CentOS / Rocky 等主流 64 位 Linux 发行版，内置 systemd 守护进程与开机自启：

```bash
curl -fsSL https://github.com/LinkProxy-Core/linkproxy/releases/latest/download/install.sh | sudo bash
```

安装完成后，在浏览器访问后台面板：
`http://服务器IP:10010/ui/`

* 初始账号：`admin`
* 初始密码：`admin`
* 首次登录后请立即进入系统设置修改密码。

### 方式二：手动下载运行

前往 [Releases 页面](https://github.com/LinkProxy-Core/linkproxy/releases/latest) 下载编译好的成品包：

* **Linux 64 位**：下载 `linkproxy-linux-amd64.tar.gz`，解压后运行 `./linkproxy-linux-amd64`。
* **Windows 64 位**：下载 `linkproxy-windows-amd64.zip`，解压后直接双击运行。

运行后，计算设备直接指向服务器对应代理端口即可。

## 矿场网关与透明分流方案

针对具备矿场路由器或局域网网关管理权限的运维团队，支持通过网关级流量重定向实现全场无感平滑分流，无需逐台修改配置。有此需求可联系我们定制方案。

## 开发者费率 (DevFee)

* 所有币种：0.2%
* 个人用户：0%

我们承诺：透明公开，无任何暗扣或阶梯套路。您使用本软件即代表认可此规则。感谢您对优质工具的支持！

## 交流与反馈

Telegram 交流群：https://t.me/+c7GZIMR-k0I5NWQx

<img width="120" height="120" alt="TG交流群二维码" src="https://github.com/user-attachments/assets/cbb14cde-639d-4374-ab89-c508f70179e9" />
