# 08. 支持币种与矿机配置示例

LinkProxy 专注于高收益与主流算力市场，深度原生支持 15 种核心数字货币算法。

---

## 15 种主流支持币种列表

| 币种代号 | 币种全称 | 核心算法 (PoW) | 常用算力单位 | 推荐代理协议 | 典型支持矿机/软件 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BTC** | Bitcoin 比特币 | SHA256d | TH/s, EH/s | SSLMIX / ECCP256MIX | 蚂蚁 S19/S21, 神马 M30/M50 |
| **BCH** | Bitcoin Cash | SHA256d | TH/s, PH/s | SSLMIX | 蚂蚁, 神马系列 |
| **LTC** | Litecoin 莱特币 | Scrypt | GH/s, TH/s | SSLMIX | 蚂蚁 L7, 金贝系列 |
| **ETC** | Ethereum Classic | Etchash | MH/s, GH/s | SSLMIX | 菠萝, 茉莉, GPU 矿机 |
| **ETHW** | EthereumPoW | Ethash | MH/s, GH/s | SSLMIX | GPU 显卡矿机, ASIC 矿机 |
| **ZEC** | Zcash 大零币 | Equihash | KSol/s | SSLMIX | 蚂蚁 Z15 系列 |
| **SC** | Siacoin 云储币 | Blake2b-Sia | GH/s, TH/s | SSLMIX | 金贝, 蚂蚁 SC 系列 |
| **DASH** | Dash 达世币 | X11 | GH/s, TH/s | SSLMIX | 蚂蚁 D9 系列 |
| **CKB** | Nervos Network | Eaglesong | TH/s | SSLMIX | 蚂蚁 K7 系列 |
| **CFX** | Conflux 树图 | Octopus | MH/s, GH/s | SSLMIX | GPU 显卡矿机 |
| **ALEO** | Aleo 零知识证明 | SnarkVM | K/s, M/s | TCP / SSLMIX | 专用计算服务器 |
| **KAS** | Kaspa 快速区块 | kHeavyHash | GH/s, TH/s | SSLMIX | 蚂蚁 KS3/KS5, 冰河系列 |
| **ALPH** | Alephium | Blake3 | GH/s, TH/s | SSLMIX | 专用 ASIC 矿机 |
| **PRL** | Pearlhash 珍珠 | Pearlhash | MH/s, GH/s | SSLMIX / TCP | SRBMiner, 专用矿机 |
| **QTC** | Quantus 量子 | Quantus PoW | GH/s, TH/s | SSLMIX / TCP | 官方客户端, 专用算力终端 |

---

## 新币种原生支持 (PRL / QTC)

LinkProxy 内置了针对 **Pearlhash (PRL)** 和 **Quantus (QTC)** 的原生解析与算力折算模块：
- **PRL**：支持双算法协议帧自动解包，控制台算力与矿池真实收益实时校准；
- **QTC**：全新量子计算协议状态机原生支持，超低延迟转发，保障极高出块效率。

---

## 常见矿机后台配置示例

在矿机管理后台（如 Antminer、Whatsminer 或 GPU 挖矿软件）中，将矿池地址指向 LinkProxy 服务器 IP 与创建的端口即可：

### 1. ASIC 矿机配置示例 (以 BTC 蚂蚁 S19/S21 为例)
- **URL (矿池地址)**：`stratum+tcp://YOUR_PROXY_IP:10690`
- **Worker (矿工账号)**：`YourWallet.worker01`
- **Password (密码)**：`123` 或 `x`

### 2. LTC 莱特币 / Doge 联合挖矿 (以蚂蚁 L7 为例)
- **URL**：`stratum+tcp://YOUR_PROXY_IP:10550`
- **Worker**：`YourLTCAccount.worker01`
- **Password**：`x`

### 3. GPU 挖矿软件示例 (以 SRBMiner / BzMiner 挖 ETC 或 PRL 为例)
在命令行或 `.bat` 启动脚本中指定代理地址：
```bash
# ETC 示例
SRBMiner-MULTI.exe --algorithm etchash --pool YOUR_PROXY_IP:10880 --wallet YourETCWallet.gpu01

# PRL 示例
SRBMiner-MULTI.exe --algorithm pearlhash --pool YOUR_PROXY_IP:10990 --wallet YourPRLWallet.worker01
```
