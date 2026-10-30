# 02. Common Network Topologies

LinkProxy provides two deployment topologies to handle various infrastructure environments.

---

## Topology 1: Local Mining Farm Direct Gateway

### 1. Applicable Scenarios
- Farm network has low latency and stable connectivity to mining pools.
- Centralized hashrate routing, fee management, or masking miner local IP addresses.

### 2. Architecture
```
[Miner A] ──┐
[Miner B] ──┼──► [LinkProxy Local Gateway] ──► [Target Mining Pool]
[Miner C] ──┘
```

### 3. Setup Steps
1. Deploy LinkProxy on a local server or industrial PC within the farm LAN.
2. In the Web console, create a business port (e.g. BTC port `8888`).
3. Set the pool address in your miner dashboard to `stratum+tcp://192.168.1.100:8888`.

---

## Topology 2: Encrypted Cross-Border Tunnel

### 1. Applicable Scenarios
- High packet loss, latency spikes, or DPI throttling between the farm and overseas pools.
- Obfuscating mining traffic from ISP inspection.

### 2. Architecture
```
[Farm LAN Miners]
       │ (Standard LAN TCP)
       ▼
[Local PC (Running LinkProxy Tunnel Client)]
       │
       │ (TLS/AES-GCM encrypted, anti-DPI, 70% compression)
       ▼
[Offshore Cloud VPS (Running LinkProxy Server)]
       │ (High-speed connection to pool datacenter)
       ▼
[Global Mining Pools]
```

### 3. Setup Steps
1. Deploy LinkProxy on an offshore cloud server.
2. Download the pre-configured single-binary tunnel client from the **Tunnel Clients** tab.
3. Run the client on a local farm machine. Miners connect to the local client IP and enjoy encrypted low-latency transport.

---

## Session Lifecycle Protection

To guarantee 24/7 hashrate stability, LinkProxy implements:

- **Strict 1:1 Stratum Mapping**: Each physical miner negotiates its own Extranonce with the pool, preventing difficulty spikes and VarDiff collisions.
- **Hardware-Aligned Fee Pacing**: 10ms pacing synchronization during fee transitions prevents S19/S21 ASIC hashboard resets.
- **Graceful Disconnect Recovery**: 3-minute grace caching seamlessly migrates cumulative shares and hashrate metrics across network reconnects.
