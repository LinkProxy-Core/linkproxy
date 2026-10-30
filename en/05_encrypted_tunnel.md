# 05. Encrypted Tunnel Guide

When mining across international borders or restricted networks, direct connections to overseas pools often suffer from packet loss, latency spikes, and ISP throttling. LinkProxy features a built-in high-speed encrypted tunnel engine.

---

## Benefits of the Tunnel

1. **Anti-Inspection & Anti-DPI**: Encrypts and obfuscates Stratum traffic into TLS/AES-GCM streams.
2. **Bandwidth Compression**: Microsecond stream compression reduces total bandwidth consumption by 60%~75%.
3. **Connection Aggregation**: Aggregates thousands of miner streams into persistent pipelines, preventing ISP connection limits.

---

## Quick Setup (1 Minute)

The Web dashboard provides zero-config single-binary downloads:

### 1. Download Client
- Log into the LinkProxy Web console.
- Navigate to the **Tunnel Clients** tab.
- Click **Generate Linux Binary** or **Generate Windows Binary (.exe)**.
- Downloaded file: `linkproxy-tunnel` (Linux) or `linkproxy-tunnel.exe` (Windows).

### 2. Run Client

#### On Linux:
```bash
chmod +x linkproxy-tunnel
nohup ./linkproxy-tunnel > tunnel.log 2>&1 &
```

> **Note**: Generated client binaries have all existing port mappings embedded. They connect and tunnel automatically upon startup.

#### On Windows:
Double-click `linkproxy-tunnel.exe` or add it to startup tasks.

---

## Dashboard Monitoring & Remote Restart

The **Tunnel Clients** tab displays live node telemetry:
- Node IP, uptime, connected miners, compression ratio, and health status.

### Remote Hot-Reload
When port mappings change on the server, click **Remote Restart** on the dashboard. The server dispatches a hot-reload command through the bidirectional control channel to apply new configurations instantly.
