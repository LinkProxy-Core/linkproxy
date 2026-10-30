# 03. Port Management & Protocols

In LinkProxy, a **Port** is the fundamental routing unit for miner ingestion, protocol negotiation, and hashrate forwarding.

---

## Creating a Port

Navigate to **Port Overview** and click **+ Add Port**:

### Core Parameters
- **Port Name**: A descriptive label (e.g. `btc-f2pool-main`).
- **Listen Port**: The TCP port opened on the server (e.g. `8888`). Ensure the port is allowed in your firewall.
- **Protocol Mode**: Recommended: **`SSLMIX`** or **`ECCP256MIX`**.
- **Target Pool**: Primary Stratum address and port (e.g. `btc.f2pool.com:1315`).

---

## Protocol Modes Explained

| Mode | Characteristics & Scenarios | Recommendation |
| :--- | :--- | :--- |
| **`SSLMIX`** | **Universal Adaptive Hybrid**. Accepts plaintext TCP, SSL/TLS encrypted, and tunnel connections on the same port automatically. | ⭐⭐⭐⭐⭐ (Recommended) |
| **`ECCP256MIX`** | **High-Concurrency ECC Hybrid**. Lightweight elliptic curve acceleration to reduce CPU overhead under heavy load. | ⭐⭐⭐⭐⭐ (Large Clusters) |
| **`TCP`** | Raw unencrypted TCP only. Miners must not use `ssl://`. Best for closed LANs. | ⭐⭐⭐ |
| **`SSL`** | Strict TLS only. Miners must enable SSL. | ⭐⭐⭐ |

---

## Primary & Backup Pool Failover

- Fill in the **Target Pool** (e.g. `btc.f2pool.com:1315`).
- Fill in the **Backup Pool** (e.g. `btc-asia.f2pool.com:1315`).
- If the primary pool encounters downtime, LinkProxy automatically and smoothly fails over to the backup pool in seconds without miner disconnects.

---

## One-Click Port Cloning

When managing hundreds of ports for different accounts or coins:
1. Locate an existing port card in the dashboard.
2. Click **Clone**.
3. The configuration is pre-filled. Simply adjust the **Port Name** and **Port Number** (e.g. `8888` -> `8889`).
4. Click **Create** to launch the new port immediately.
