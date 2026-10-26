# LinkProxy

高性能多币种 Stratum / EthProxy 网络中转与分流服务。

![Version](https://img.shields.io/badge/Version-v2.2.136-blue.svg)
![Protocol](https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg)

针对 BTC、LTC、Kaspa、ETC 等主流 ASIC 与 GPU 计算节点开发的高并发网关服务，支持多矿池分流、动态难度自适应、平滑切池与 Web 可视化管理。

## 主要特性

- **协议深度兼容**：全面支持 BTC/BCH (SHA-256)、LTC/DOGE (Scrypt)、KAS (kHeavyHash)、ETC/ETHW 等主流币种的 Stratum 及 EthProxy 协议。
- **平滑切池与防断连**：底层深度对齐协议状态，切池过程只同步 Extranonce 与工作难度，不触发芯片流水线清空，避免 S19/S21 等 ASIC 节点掉线或保护重启。
- **动态难度（Vardiff）对齐**：支持自动校准不同矿池间的下发难度，消除跨池切换造成的算力抖动与虚假算力。
- **故障转移与容灾**：主矿池网络异常时自动执行平滑重连与故障降级，确保高网络抖动环境下的持续连接。
- **Web 可视化面板**：内置轻量 Web 监控后台，提供节点实时算力折线图、有效/拒绝份额统计、在线状态及独立拒绝日志追溯。

## 支持币种

| 币种 | 协议类型 | 算法 |
| :--- | :--- | :--- |
| BTC / BCH | Stratum | SHA-256 |
| LTC / DOGE | Stratum | Scrypt |
| KAS (Kaspa) | Stratum | kHeavyHash |
| ETC / ETHW | EthProxy | Etchash / Ethash |
| DASH | Stratum | X11 |
| CKB | Stratum | Eaglesong |
| 自定义代币 | 自适应 | 兼容主流 Stratum 变体 |

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
