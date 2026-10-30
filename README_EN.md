<div align="center">
  <img src="images/banner.svg" alt="LinkProxy Banner" width="100%"/>

  <p align="center">
    <strong>Enterprise High-Performance Multi-Coin Stratum / EthProxy Gateway &amp; Tunnel Service</strong>
  </p>

  <p align="center">
    <a href="https://github.com/LinkProxy-Core/linkproxy/releases/latest"><img src="https://img.shields.io/badge/Release-v2.2.144-blue.svg?style=flat-square" alt="Version"></a>
    <a href="https://linkproxy-core.github.io/linkproxy/"><img src="https://img.shields.io/badge/Docs-Online%20Manual-brightgreen.svg?style=flat-square" alt="Docs"></a>
    <img src="https://img.shields.io/badge/Protocol-Stratum%20%7C%20EthProxy-success.svg?style=flat-square" alt="Protocol">
    <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20ARM64-lightgrey.svg?style=flat-square" alt="Platform">
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
- **Enterprise Whitelist Filter (`FilterWallet`)**: Exclude VIP mining accounts with O(1) hash table lookup.

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

### ARM64 Architecture (Raspberry Pi / Orange Pi / AWS Graviton)

```bash
curl -fsSL https://raw.githubusercontent.com/LinkProxy-Core/linkproxy/main/arm-install.sh | sudo bash
```

### Windows 64-bit

Download `linkproxy-windows-amd64.zip` from [Releases](https://github.com/LinkProxy-Core/linkproxy/releases/latest):
1. Extract and run `windows/start.bat` for interactive console.
2. Run `windows/install-service.bat` as Administrator to install background auto-start service.

---

## 🛠️ Repository Ecosystem

* **Templates**:
  * [excel端口导入模板.xlsx](excel端口导入模板.xlsx) - Batch port import workbook
  * [templates/ports.example.json](templates/ports.example.json) - JSON port configuration sample
  * [origin.json](origin.json) - Base configuration file
* **Scripts**:
  * [scripts/sysctl-tune.sh](scripts/sysctl-tune.sh) - Linux kernel & TCP BBR tuning for 10k miners
  * [scripts/check-ports.sh](scripts/check-ports.sh) - Port & pool latency testing tool
  * [scripts/clean-logs.sh](scripts/clean-logs.sh) - Log cleanup and compression
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
