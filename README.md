<div align="center">

# 🚀 MinerLink-Proxy 极速矿池直连专家

新一代矿机网络中转与防封杀优化器 | 零拒绝率 | 算力无损直连

![Version](https://img.shields.io/badge/Version-v2.0.49--beta-blue.svg)
![Protocol](https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg)

</div>

---

## 🌟 项目简介 (Introduction)

MinerLink-Proxy 是一款专为大规模矿场和矿工打造的企业级矿池本地中转加速器。
面对日益严峻的网络封锁、高延迟、以及频繁的算力拒绝（Stale/Reject Share）问题，MinerLink 提供了一套“软硬兼施”的终极解决方案。通过独家的深度报文检测（DPI）防伪装防火墙与毫秒级底层 TCP 优化，让您的矿机如同直连矿池核心机房，算力曲线平滑如丝！

## 🎯 核心黑科技 (Core Features)

- ⚡ 极致低延迟 (Ultra-Low Latency)：采用 Go 语言高并发底层重写，TCP 连接零开销转发，大幅降低由于网络抖动造成的份额延迟与拒绝率。
- 🛡️ DPI 协议级防封杀 (Anti-Ban Engine)：内置智能通信混淆与深度报文特征检测，防止运营商层面的协议阻断，保护您的算力资产安全出海。
- 极简面板 (Cyberpunk UI)：告别繁琐的命令行，提供极简且极其易用的 Web 可视化面板，一键配置，毫秒级生效。
  - **动态多模组状态矩阵**：精准展示 保算力、ViaBTC优化、防封锁、动态难度等。
  - **内存高维透视**：悬浮展示物理内存、系统占用、程序耗损三维数据。
- 🤖 智能防呆保护：前端采取严苛的标准化下拉框准入机制，彻底杜绝因拼写错误、端口配置错位导致的矿机无效运转。
- 🌐 全场景兼容：完美支持 ASIC 矿机、显卡服务器，即插即用。

## 🪙 完美支持的十大币种

MinerLink 引擎深度适配了市面主流币种的 Stratum / EthProxy 协议底层：

| 币种 | 算法兼容 |
| :--- | :--- |
| BTC (比特币) | SHA-256 |
| BCH (比特现金) | SHA-256 |
| KAS (Kaspa) | kHeavyHash |
| LTC (莱特币) | Scrypt |
| DOGE (狗狗币) | Scrypt |
| ETC (以太经典) | Etchash |
| ETHW | Ethash |
| DASH (达世币) | X11 |
| CKB (神经元) | Eaglesong |
| pearl (珍珠币PEARL/PRL) | 自适应 |
......
可按需增加币种

## 🚀 极速部署指南 (Quick Start)

### ⬇️ 选项一：一键安装 (交互式推荐)

复制下面一行命令并在您的 Linux 终端执行，按提示操作即可自动下载、配置、并启动 (自动安装 systemd 守护进程与开机自启)。

```bash
curl -fsSL https://github.com/niuniu06/MinerLink-Proxy/releases/latest/download/install.sh | sudo bash
```

面板初始管理员账号为：admin，密码：admin   强烈建议您设置复杂密码。修改保存后系统将重启，需要重新登录

### 📦 选项二：直接下载 (开箱即用)

以下是编译好的成品程序包，包含极简的 Web 管理面板。

| 系统平台 | 下载指南 | 说明 |
| :--- | :--- | :--- |
| 🐧 Linux 64 位 | 到 [Releases 页面](https://github.com/niuniu06/MinerLink-Proxy/releases/latest) 下载 `MinerLink-Proxy-Linux.zip`。解压后执行 `./MinerLink-Proxy-linux-amd64` | 绿色无依赖 |
| 🪟 Windows 64 位 | 到 [Releases 页面](https://github.com/niuniu06/MinerLink-Proxy/releases/latest) 下载 `MinerLink-Proxy-Windows.zip`。解压后双击 `.exe` 文件运行 | 适合测试/新手 |

运行后，在浏览器访问 `http://您的服务器IP:10010/ui/` 即可进入控制台配置矿池。矿机指向您服务器的对应端口即可！

DNS劫持方案
如果你是运维或者有矿厂路由器权限，可以联系我们，我们为你搭建无感知DNS劫持抽水方案。

## 🤝 开发者承诺与捐赠 (DevFee)

开发费用

所有币种 0.2%

个人 0%

开发和维护一套高并发、低延迟的企业级网络引擎需要消耗极大的精力与服务器成本。
我们承诺：透明公开，无任何暗扣或阶梯套路。您使用本软件即代表认可此规则。感谢您对优质工具的支持！

---
<div align="center">
<i>让每一份算力都发挥到极致 —— MinerLink 团队</i>
</div>


<img width="100" height="100" alt="qrcode_1781400572216" src="https://github.com/user-attachments/assets/cbb14cde-639d-4374-ab89-c508f70179e9" />


https://t.me/+c7GZIMR-k0I5NWQx
