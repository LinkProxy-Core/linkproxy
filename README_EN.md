<div align="center">
  <a href="https://github.com/LinkProxy-Core/linkproxy">
    <img src="images/logo.png" alt="LinkProxy Logo" width="128" height="128" />
  </a>

  <h1>LinkProxy</h1>

  <p>
    <strong>Enterprise High-Performance Multi-Coin Stratum / EthProxy Gateway &amp; Tunnel Service</strong>
  </p>

  <p>
    High Concurrency · Zero-Latency Feemining · O(1) Duplicate Suppression · Encrypted Tunnel · Hardware-Aligned (BTC / LTC / KAS / ETC / PRL / QTC)
  </p>

  <p>
    <a href="https://github.com/LinkProxy-Core/linkproxy/releases/latest"><img src="https://img.shields.io/badge/Release-v2.2.144-blue.svg?style=flat-square" alt="Version"></a>
    <a href="https://linkproxy-core.github.io/linkproxy/"><img src="https://img.shields.io/badge/Docs-Online%20Manual-brightgreen.svg?style=flat-square" alt="Docs"></a>
    <img src="https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg?style=flat-square" alt="Protocol">
    <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg?style=flat-square" alt="Platform">
    <img src="https://img.shields.io/badge/License-MIT-orange.svg?style=flat-square" alt="License">
    <a href="README.md"><img src="https://img.shields.io/badge/Language-%E4%B8%AD%E6%96%87-blue?style=flat-square" alt="Chinese"></a>
  </p>
</div>

---

## 🚀 Architecture & Key Features

LinkProxy is engineered for high-concurrency PoW mining infrastructures (BTC, LTC, Kaspa, ETC, PRL, QTC) across ASIC and GPU clusters. It maintains strict 1:1 Stratum protocol state machines, provides dynamic difficulty alignment (Vardiff), stealth low-latency fee routing, and an intuitive Web UI.

<div align="center">
  <img src="images/architecture.svg" alt="LinkProxy Architecture" width="100%"/>
</div>

### Highlights

- **Strict 1:1 Stratum Session Discipline**: Avoids dirty Stratum multiplexing, preventing Extranonce collisions, ASIC chip register faults, and VarDiff storms.
- **Zero-Latency Stealth Fee Switching**: Reverse-engineered 10ms pacing synchronization prevents ASIC hashboard resets (Antminer S19/S21, Whatsminer M30/M50).
- **O(1) Predictive Duplicate Share Suppression**: Intercepts duplicate or stale ASIC shares locally before they reach upstream pools.
- **Zero-Config Encrypted Tunnel**: Bidirectional encrypted control and data channels for cross-border traffic obfuscation.
- **3-Minute Offline Grace Cache**: Seamlessly caches cumulative shares and hashrate curves during transient network hiccups.
- **One-Click Port Cloning**: Duplicate existing ports and their configurations in one click without re-entering parameters.
- **Enterprise Whitelist Filter (`FilterWallet`)**: Exclude VIP mining accounts with O(1) hash table lookup.

### 💡 Why Choose LinkProxy? (Comparison with Legacy Proxies)

| Dimension | Legacy Proxy (e.g. FXMinerProxy / Early Clones) | LinkProxy Enterprise Gateway |
| :--- | :--- | :--- |
| **Session Discipline** | Dirty multiplexing over single Stratum connection; causes Extranonce collisions | **Strict 1:1 Stratum session mapping** per physical miner |
| **Fee Switching & Stability** | Crude `clean_jobs` forced injection; resets Antminer S19/S21 hashboards | **10ms pacing synchronization**; **0 chip resets, 0 hashrate dips** |
| **Duplicate Share Pre-filtering** | No local interception; triggers pool rejections and bans | **O(1) sliding window tracker (`RecentShareTracker`)** local filtering |
| **Network Flapping Grace** | Instant offline marking and graph reset; noisy false alarms | **3-minute grace cache**; smooth reconnect preserves lifetime stats |
| **Encrypted Tunneling** | Requires third-party software; complex configuration | **Native zero-config TLS/AES-GCM tunnel** with live monitoring |
| **Fee Transparency** | Hidden dark fees / progressive cuts up to 1%~3% | **Flat 0.2% fee**, free for personal miners, 100% transparent |
| **New Coin Support** | Limited to legacy PoW; fails on modern dynamic algorithms | Native support for **PRL (Pearlhash)**, **QTC (Quantus)**, **Kaspa**, etc. |

---

## 📦 Quick Installation

### Linux One-Click (Ubuntu / Debian / CentOS / Rocky)

```bash
curl -fsSL https://raw.githubusercontent.com/LinkProxy-Core/linkproxy/main/install_en.sh | sudo bash
```

* Web Dashboard: `http://<SERVER_IP>:10010/ui/`
* Default User: `admin`
* Default Pass: `admin`
* CLI Tool: Type `linkproxy` in any terminal to manage the service.

### Windows 64-bit

Download `linkproxy-windows-amd64.zip` from [Releases](https://github.com/LinkProxy-Core/linkproxy/releases/latest):
1. Extract and run `windows/start.bat` for interactive console.
2. Run `windows/install-service.bat` as Administrator to install background auto-start service.

---

## 🛠️ Repository Ecosystem

* **Scripts**:
  * [scripts/sysctl-tune.sh](scripts/sysctl-tune.sh) - Linux kernel & TCP BBR tuning for 10k miners
  * [scripts/check-ports.sh](scripts/check-ports.sh) - Port & pool latency testing tool
* **Linux Daemon**:
  * [linux/linkproxy.service](linux/linkproxy.service) - Production Systemd unit file
  * [linux/update.sh](linux/update.sh) - Standalone hot upgrade and auto-rollback script
* **Windows Suite**:
  * [windows/start.bat](windows/start.bat) - Interactive launcher
  * [windows/install-service.bat](windows/install-service.bat) - Background service installer
  * [windows/uninstall-service.bat](windows/uninstall-service.bat) - Service uninstaller
* **Guides**:
  * [docs/01_quickstart.md](docs/01_quickstart.md) - Quickstart Guide
  * [docs/02_linux_tuning.md](docs/02_linux_tuning.md) - High Concurrency Linux Kernel Tuning
  * [docs/03_coins_and_pools.md](docs/03_coins_and_pools.md) - Supported Coins & Pool Setup
  * [docs/04_security_defense.md](docs/04_security_defense.md) - Security Hardening & Defense
  * [docs/05_faq_troubleshooting.md](docs/05_faq_troubleshooting.md) - Troubleshooting FAQ

---

## 💬 Community & Support

* Telegram Group: https://t.me/+c7GZIMR-k0I5NWQx
* Documentation: https://linkproxy-core.github.io/linkproxy/
