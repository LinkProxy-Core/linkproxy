# LinkProxy Official Documentation

LinkProxy is an enterprise-grade, high-performance Stratum and EthProxy mining gateway designed for cryptocurrency mining farms, hashrate hosting providers, and cross-border networking scenarios.

The system features an intuitive Web dashboard, supports tens of thousands of concurrent miner connections, provides zero-hashrate-loss fee switching, automatic protocol detection, encrypted tunnel transport, and end-to-end telemetry.

---

## Key Features

- **15+ Major PoW Coins Supported**: Full native protocol support for BTC, BCH, LTC, ETC, ETHW, ZEC, SC, DASH, CKB, CFX, ALEO, KAS, ALPH, as well as next-generation algorithms **PRL (Pearlhash)** and **QTC (Quantus)**.
- **Unified Port Multi-Protocol Ingestion**: A single business port accepts raw TCP, SSL/TLS encrypted connections, and tunnel client streams simultaneously.
- **Stealth Zero-Loss Fee Switching**: State-machine-aligned 10ms pacing prevents ASIC hashboard resets (0 hashrate dips, 0 chip reboots, 0 deadlocks).
- **Multi-Wallet Proportionate Routing (PayList)**: Distribute fee shares proportionally across multiple wallets, with support for O(1) VIP zero-fee whitelist (`FilterWallet`).
- **Zero-Config Encrypted Tunnel**: Single-binary tunnel client with traffic obfuscation and up to 70% bandwidth compression.
- **Real-Time Telemetry & True Hashrate**: Live 10-minute, 1-hour, and 24-hour hashrate curves with real-time worker lists and reject forensics.

---

## Recommended Topologies

### Topology 1: Local Mining Farm Direct Gateway
Miners connect directly to LinkProxy on the local farm LAN. LinkProxy maintains high-speed upstream connections to target pools:
```
[Miner Cluster] ─── (TCP / SSL) ───► [LinkProxy Gateway] ──────► [Upstream Pools]
```

### Topology 2: Encrypted Cross-Border Tunnel
Deploy the lightweight tunnel client on a local farm machine and the LinkProxy server on an offshore VPS:
```
[Farm Miners] ───► [Tunnel Client] ─── (Encrypted Stream) ───► [LinkProxy Server] ───► [Global Pools]
```

---

## Quick Navigation

- **First-time deployment**: Read [01. Installation & Quick Start](en/01_quickstart.md) and [03. Port Management & Protocols](en/03_ports_and_pools.md)
- **Fee configuration**: See [04. Fee Mining & PayList Distribution](en/04_fee_mining.md)
- **Cross-border tunnel**: See [05. Encrypted Tunnel Guide](en/05_encrypted_tunnel.md)
- **Troubleshooting**: See [09. Troubleshooting & Ops FAQ](en/09_faq_troubleshooting.md)
