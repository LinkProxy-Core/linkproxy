# 07. Security Defense & Live Logs

LinkProxy provides multi-layered defensive security and granular logging to protect and monitor your mining infrastructure.

---

## Web Dashboard Security & Brute-Force Defense

1. **Automatic Fail2Ban Defense**:
   - If an IP exceeds 5 failed login attempts within 10 minutes, it is locked out for 15 minutes.
   - Subsequent requests from that IP are rejected at the protocol layer with HTTP 429.
   - Administrators can reset credentials and clear lockouts via the `linkproxy` CLI tool.
2. **2-Hour Absolute Session Timeout**:
   - To prevent session hijacking on shared farm monitoring terminals, JWT authentication tokens expire after 2 hours of inactivity.

---

## Live System Events & Event Telemetry

In the **Logs** tab, the system provides real-time event tracking:

```
[00:48:18] [BTC] Miner 004 (whff88) ── Disconnected
[00:43:18] [BTC] Miner 004 (whff88) ── Reconnected
```

### 1. 2-Minute Network Flapping Damping
- Transient network hiccups lasting under 2 minutes do not pollute the global event log.
- Only miners that remain disconnected for more than 2 minutes trigger genuine offline alarms.

### 2. Standby Worker Noise Suppression
- Backup pool connections (Pool 2 / Pool 3) running at 0 hashrate are silenced from triggering false offline notifications.

---

## Per-Miner Forensics (`MinerLogModal`)

Click the **Logs** button next to any miner in the table:
- **General Logs**: Displays successful auth handshakes, keepalive pings, and socket reconnects.
- **Reject Logs**: Displays exact reject reasons, timestamps, difficulty values, and response latency for deep diagnostics.
