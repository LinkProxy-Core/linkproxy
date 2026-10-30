<div align="center">
  <a href="https://github.com/LinkProxy-Core/linkproxy">
    <img src="../../images/logo.png" alt="LinkProxy Logo" width="128" height="128" />
  </a>

  <h1>LinkProxy</h1>

  <p>
    <strong>Enterprise High-Performance Multi-Coin Stratum / EthProxy Gateway &amp; Tunnel Service</strong>
  </p>

  <p align="center">
    <a href="https://github.com/LinkProxy-Core/linkproxy">简体中文</a>
    ·
    <strong>English</strong>
    ·
    <a href="https://linkproxy-core.github.io/linkproxy/">在线手册 (中文)</a>
    ·
    <a href="https://linkproxy-core.github.io/linkproxy/#/en/">Online Manual (EN)</a>
  </p>

  <p align="center">
    <a href="https://github.com/LinkProxy-Core/linkproxy/releases/latest"><img src="https://img.shields.io/badge/Release-v2.2.144-blue.svg?style=flat-square" alt="Version"></a>
    <a href="https://linkproxy-core.github.io/linkproxy/#/en/"><img src="https://img.shields.io/badge/Docs-Online%20Manual-brightgreen.svg?style=flat-square" alt="Docs"></a>
    <img src="https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg?style=flat-square" alt="Protocol">
    <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg?style=flat-square" alt="Platform">
    <img src="https://img.shields.io/badge/License-MIT-orange.svg?style=flat-square" alt="License">
    <a href="https://t.me/+fKG-u6OEDexlMDIx"><img src="https://img.shields.io/badge/Telegram-Community-2CA5E0?logo=telegram&logoColor=white&style=flat-square" alt="Telegram"></a>
  </p>
</div>

---

## What is LinkProxy

LinkProxy is an enterprise-grade PoW mining gateway engineered for large-scale mining operations, hashrate hosting providers, and cross-border routing. It provides strict 1:1 Stratum protocol state-machine alignment, zero-latency stealth fee switching, dynamic difficulty alignment (VarDiff), encrypted tunnel transport, and a modern Web management console.

<div align="center">
  <img src="../../images/architecture.svg" alt="LinkProxy Architecture" width="100%"/>
</div>

---

## Core Capabilities

| Capability | Description |
| :--- | :--- |
| **Strict 1:1 Stratum Mapping** | Maintains dedicated physical Stratum session per miner. Avoids session multiplexing, eliminating Extranonce collisions and VarDiff storms. |
| **Zero-Latency Stealth Fee Switching** | Reverse-engineered 10ms pacing synchronization aligned with ASIC hardware state machines. **0 hashrate dips, 0 chip resets, 0 deadlocks**. |
| **O(1) Duplicate Pre-Filtering** | Sliding window deduplication tracker (`RecentShareTracker`) intercepts duplicate/stale shares locally, protecting miners from pool bans. |
| **3-Minute Offline Grace Cache** | Seamlessly preserves cumulative shares and hashrate curves across transient network drops and pool reconnections. |
| **One-Click Port Cloning** | Deep-copies existing port configurations (primary/backup pools, fee rates, whitelists) to launch new ports in seconds. |
| **VIP Zero-Fee Whitelist** | Exclude VIP client sub-accounts or test rigs with O(1) hash lookup (`FilterWallet`). |
| **Zero-Config Encrypted Tunnel** | Bidirectional TLS/AES-GCM encrypted tunnel with stream compression reduces public bandwidth usage by 60%~75%. |

---

## 💡 Why LinkProxy? (Comparison with Legacy Proxies)

| Dimension | Legacy Proxies (minerProxy / Early Clones) | LinkProxy Enterprise Gateway |
| :--- | :--- | :--- |
| **Session Discipline** | Dirty multiplexing over a single Stratum socket; causes Extranonce collisions | **Strict 1:1 Stratum session mapping** per physical miner |
| **Fee Switching & Stability** | Crude `clean_jobs: true` injection; causes Antminer S19/S21 hashboard resets | **10ms pacing synchronization**; **0 chip resets, 0 hashrate drops** |
| **Duplicate Share Pre-filtering** | No local interception; forwards blindly to pool, triggering bans | **O(1) sliding window tracker (`RecentShareTracker`)** local filtering |
| **Network Flapping Grace** | Instant offline marking and graph reset; noisy false alarms | **3-minute grace cache**; smooth reconnect preserves lifetime stats |
| **Encrypted Tunneling** | Requires third-party software; complex configuration | **Native zero-config TLS/AES-GCM tunnel** with live monitoring |
| **Fee Transparency** | Hidden dark fees / progressive cuts up to 1%~3% | **Flat 0.2% fee**, free for personal miners, 100% transparent |
| **New Coin Support** | Limited to legacy PoW; fails on modern dynamic algorithms | Native support for **PRL (Pearlhash)**, **QTC (Quantus)**, **Kaspa**, etc. |

---

## Quick Start

### 1. Linux One-Click (Ubuntu / Debian / CentOS / Rocky)

Run the following command to download, install, and register systemd auto-start service:

```bash
curl -fsSL https://raw.githubusercontent.com/LinkProxy-Core/linkproxy/main/install_en.sh | sudo bash
```

After installation:
- **Web Console**: `http://YOUR_SERVER_IP:10010/ui/`
- **Default Username**: `admin`
- **Default Password**: `admin`
- **CLI Manager**: Type `linkproxy` in any terminal to open the management menu.

### 2. Windows 64-bit

1. Download `linkproxy-windows-amd64.zip` from [Releases](https://github.com/LinkProxy-Core/linkproxy/releases/latest).
2. Extract the archive (e.g. to `D:\LinkProxy`).
3. Run `start.bat` for interactive console mode.
4. For production background auto-start, right-click `install-service.bat` and select **Run as Administrator**.
5. Open `http://127.0.0.1:10010/ui/` in your browser.

---

## Documentation Navigation

Comprehensive guides are available at the **[LinkProxy Online Documentation Manual](https://linkproxy-core.github.io/linkproxy/#/en/)**:

| Topic | Guide Link | Key Content |
| :--- | :--- | :--- |
| **01. Quick Start** | [Installation Guide](https://linkproxy-core.github.io/linkproxy/#/en/01_quickstart) | Hardware specs, Linux & Windows deployment, default credentials |
| **02. Topologies** | [Networking Schemes](https://linkproxy-core.github.io/linkproxy/#/en/02_architecture) | Local farm gateway vs cross-border encrypted tunnel |
| **03. Ports & Protocols** | [Port Management](https://linkproxy-core.github.io/linkproxy/#/en/03_ports_and_pools) | Protocol modes (SSLMIX, ECCP256MIX), primary/backup pool failover |
| **04. Fee Routing** | [Fee & PayList](https://linkproxy-core.github.io/linkproxy/#/en/04_fee_mining) | Multi-wallet percentage distribution, VIP zero-fee whitelist |
| **05. Encrypted Tunnel** | [Tunnel Guide](https://linkproxy-core.github.io/linkproxy/#/en/05_encrypted_tunnel) | Single-binary client deployment, traffic compression, remote restart |
| **06. Advanced VarDiff** | [Advanced Tuning](https://linkproxy-core.github.io/linkproxy/#/en/06_advanced_vardiff) | Starting difficulty, ViaBTC optimization, chip defense flags |
| **07. Security & Logs** | [Security Defense](https://linkproxy-core.github.io/linkproxy/#/en/07_security_defense) | Fail2Ban brute-force lock, 2-minute damping, per-miner diagnostics |
| **08. Supported Coins** | [Coin Matrix](https://linkproxy-core.github.io/linkproxy/#/en/08_coins_matrix) | 15+ coins setup, Antminer / Whatsminer / GPU rig config examples |
| **09. Troubleshooting** | [FAQ & Troubleshooting](https://linkproxy-core.github.io/linkproxy/#/en/09_faq_troubleshooting) | Connectivity checks, reject rate diagnostics, password reset |

---

## Supported Coins & Algorithms

<details>
<summary><strong>Click to expand full algorithm &amp; coin matrix</strong></summary>

| Algorithm | Supported Coins | Typical Hardware |
| :--- | :--- | :--- |
| **SHA256d** | BTC, BCH | Antminer S19 / S21, Whatsminer M30 / M50, Avalon |
| **Scrypt** | LTC, DOGE, BEL | Antminer L7 / L9, Goldshell series |
| **kHeavyHash** | KAS (Kaspa) | Antminer KS3 / KS5, IceRiver series |
| **Etchash / Ethash** | ETC, ETHW | GPU Rigs, Jasminer, Poloniex ASIC |
| **Pearlhash** | PRL | SRBMiner, custom compute nodes |
| **Quantus PoW** | QTC | Official client, specialized terminals |
| **Equihash** | ZEC, ZEN | Antminer Z15 series |
| **Blake2b-Sia** | SC | Goldshell, Antminer SC series |
| **X11** | DASH | Antminer D9 series |
| **Eaglesong** | CKB | Antminer K7 series |
| **Octopus** | CFX | GPU Rigs |
| **SnarkVM** | ALEO | GPU / CPU ZKP compute nodes |
| **Blake3** | ALPH | Specialized Blake3 ASICs |

</details>

---

## Community & Support

- **Telegram Group**: [https://t.me/+fKG-u6OEDexlMDIx](https://t.me/+fKG-u6OEDexlMDIx)
- **Online Documentation**: [https://linkproxy-core.github.io/linkproxy/#/en/](https://linkproxy-core.github.io/linkproxy/#/en/)
- **Bug Reports & Feedback**: Please submit via GitHub Issues.

---

## License

This project is licensed under the [MIT License](https://github.com/LinkProxy-Core/linkproxy/blob/main/LICENSE).
