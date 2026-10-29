# LinkProxy

高性能多币种 Stratum / EthProxy 网络中转与分流服务。

![Version](https://img.shields.io/badge/Version-v2.2.142-blue.svg)
![Protocol](https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg)
[![Docs](https://img.shields.io/badge/Docs-在线使用手册-brightgreen.svg)](https://linkproxy-core.github.io/linkproxy/)

> 📖 **官方在线使用手册**：[https://linkproxy-core.github.io/linkproxy/](https://linkproxy-core.github.io/linkproxy/)
>
> 涵盖服务器选型、一键极速安装、端口创建、多钱包分流 (PayList)、免配置加密中转隧道部署与常见问题排查。

针对 BTC、LTC、Kaspa、ETC、PRL、QTC 等主流 ASIC 与 GPU/CPU 计算节点开发的高并发网关服务，支持多矿池分流、动态难度自适应、平滑切池与 Web 可视化管理。

## 📖 在线使用手册导航

详尽的操作指南与最佳实践已发布至官方文档中心，欢迎查阅：
👉 **[点击查阅 LinkProxy 官方在线使用手册](https://linkproxy-core.github.io/linkproxy/)**

- [01. 安装部署与快速上手](https://linkproxy-core.github.io/linkproxy/#/01_quickstart) —— 推荐服务器硬件选型、Linux 一键安装与终端快捷指令
- [02. 常见组网与连接模式](https://linkproxy-core.github.io/linkproxy/#/02_architecture) —— 局域网直连代理与跨国加密中转架构方案
- [03. 端口管理与矿池配置](https://linkproxy-core.github.io/linkproxy/#/03_ports_and_pools) —— 端口创建、协议模式推荐（SSLMIX）、主备容灾与一键克隆
- [04. 抽水设置与多钱包分流](https://linkproxy-core.github.io/linkproxy/#/04_fee_mining) —— 基础抽水、多钱包按比例分流 (PayList) 与大客户免抽白名单
- [05. 加密中转隧道使用教程](https://linkproxy-core.github.io/linkproxy/#/05_encrypted_tunnel) —— 单文件免配置中转客户端下载、部署与远程热重启
- [06. 高级设置与难度微调说明](https://linkproxy-core.github.io/linkproxy/#/06_advanced_vardiff) —— 芯片兼容增强、防封保护 (AntiBan) 与难度微调控制
- [07. 安全防护与运行日志](https://linkproxy-core.github.io/linkproxy/#/07_security_defense) —— 控制台防爆破、2分钟防抖告警与单机专有日志追踪
- [08. 支持币种与矿机配置示例](https://linkproxy-core.github.io/linkproxy/#/08_coins_matrix) —— 15 种主流支持币种及主流矿机（蚂蚁/神马/GPU）后台填法
- [09. 常见问题排错与运维 FAQ](https://linkproxy-core.github.io/linkproxy/#/09_faq_troubleshooting) —— 连不上排查、拒绝率偏高解决与密码快速重置方法

## 主要特性

- **协议深度兼容**：全面支持 BTC/BCH (SHA-256)、LTC (Scrypt)、KAS (kHeavyHash)、ETC/ETHW 等主流币种的 Stratum 及 EthProxy 协议，原生深度适配 **PRL (Pearlhash 珍珠币)** 与 **QTC (Quantus)** 专属协议重写与动态周期调度。
- **加密隧道全景监控**：引入独立双向控制信道与长连接管理引擎，面板实时呈现所有加密客户端机器名、挂载活跃矿机数与传输状态，支持服务端一键远程安全热重启与管道管理。
- **平滑切池与防断连**：底层深度对齐协议状态，避免 S19/S21 等 ASIC 节点掉线或保护重启。
- **离线防抖与智能过滤**：消除矿池闪断与网络抖动造成的日志刷屏，保持面板清爽。
- **端口参数一键克隆**：管理面板支持现有代理端口参数一键深拷贝，无需重复填写目标矿池、备用矿池与复杂高级参数，秒级微调并派生新端口。
- **动态难度（Vardiff）对齐**：支持自动校准不同矿池间的下发难度，消除算力抖动与虚假算力。
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
