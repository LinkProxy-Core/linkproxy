# 03. 主流币种与矿池配置最佳实践矩阵

LinkProxy 针对主流工作量证明（PoW）币种的 Stratum 协议细节进行了深度逆向对齐与硬件底层优化。以下为 15 种主流币种的标准配置指南。

---

## 主流币种对接矩阵

| 币种 | 协议类型 | 推荐端口模式 | 目标矿池示例 (F2Pool / ViaBTC / AntPool) | 硬件兼容特性 |
| :--- | :--- | :--- | :--- | :--- |
| **BTC / BCH** | Stratum V1 | `SSLMIX` | `btc.f2pool.com:1315`<br>`btc.viabtc.top:3333` | 蚂蚁 S19/S21、神马 M30/M50 0芯片复位，平滑切池 |
| **LTC / DOGE** | Stratum V1 | `SSLMIX` | `ltc.f2pool.com:3335`<br>`ltc.viabtc.top:3333` | 蚂蚁 L7/L9、金贝多卡联合双挖低延迟 |
| **KAS (Kaspa)** | Stratum | `TCP` | `kas.f2pool.com:1400`<br>`kas.herominers.com:1206` | 冰壳 KS3/KS5 瞬时超高份额并发无阻塞 |
| **ETC / ETHW** | EthProxy | `TCP` | `etc.f2pool.com:8118`<br>`asia.etc.ethermine.org:4444` | 严格保留 8 字节 Nonce，防止 Target 重写算力损失 |
| **PRL (珍珠币)** | Stratum | `TCP` | `prl.pool.example.com:8008` | 原生双向协议动态重写，自适应周期调度 |
| **QTC (Quantus)** | Stratum | `TCP` | `qtc.pool.example.com:7007` | Poseidon2 专属协议分流与零漏报转发 |
| **ZEC (Zcash)** | Stratum | `TCP` | `zec.f2pool.com:3357` | Equihash 算法支持 |
| **DASH** | Stratum | `TCP` | `dash.f2pool.com:5588` | X11 蚂蚁 D7/D9 系列完美支持 |
| **CKB** | Stratum | `TCP` | `ckb.f2pool.com:4300` | Eaglesong 蚂蚁 K7 / 芯动系列支持 |
| **ALEO** | Stratum | `TCP` | `aleo.f2pool.com:4400` | ZKP 零知识证明并发分流 |
| **ALPH** | Stratum | `TCP` | `alph.f2pool.com:1200` | Blake3 极速分流 |

---

## 协议模式选择指南

在创建端口时，LinkProxy 提供了三种主流监听模式：

1. **`SSLMIX`（强烈推荐，默认首选）**：
   * 单一端口同时兼容下游普通的未加密 TCP 连接与 SSL/TLS 加密连接。
   * 代理服务在接收到新连接首包的几毫秒内，自动通过魔数探测协议类型并执行无感解密分流，省去开设两个不同端口的繁琐。
2. **`TCP`（纯未加密明文）**：
   * 适用于纯内网、矿场局域网直连或通过独立加密中转隧道上线的环境，开销极低。
3. **`SSL`（强制加密）**：
   * 仅允许带 SSL/TLS 证书握手的矿机或中转节点接入，适合直接暴露在公网的高安全场景。

---

## 主备矿池容灾规则

为保证大矿场 7x24 小时零停机：
* **主矿池 (Primary Pool)**：矿机日常提交份额的目标。
* **备用矿池 (Backup Pool)**：当主矿池发生机房断网、DNS 故障或连续重连失败时，代理引擎自动无感将底层会话降级切换至备用矿池。
* 当主矿池网络恢复稳定后，系统依据平滑策略自动回切，全程无需人工干预。
