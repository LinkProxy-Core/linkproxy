# 06. Advanced Parameters & Vardiff

In the **⚡ Advanced Settings** tab of the port modal, LinkProxy provides fine-grained controls for ASIC hardware, difficulty alignment, and pool-specific heuristics.

---

## 1. Algorithm & Difficulty Alignment (VarDiff)

```
[🎛️ Algorithm & Difficulty Alignment]
├── Miner Starting Diff (WorkerStartDiff): [       ] [☑ ViaBTC Pool Optimization (65536)]
├── Main Pool Forced Diff (MainFixedDiff): [ e.g. d=2048 or auto, empty to bypass ]
└── Fee Pool Forced Diff (FeeFixedDiff):   [ Recommended: auto or d=2048 ]
```

### WorkerStartDiff
- **`0` (Default)**: Inherits initial difficulty assigned by the upstream pool.
- **ViaBTC Optimization (Preset 65536)**: Locks starting difficulty to 65536, preventing Antminer ASICs from flooding the connection with low-difficulty shares upon initial handshake.
- **Custom Value**: Manually set a fixed starting difficulty for specific high-hashrate rigs.

---

## 2. Chip Compatibility & Defense Flags

| Flag | Recommended | Description & Use Case |
| :--- | :--- | :--- |
| **🛡️ AntiBan (0 Rejections)** | **Enabled** | Masks transient pool rejection errors locally, preventing miner firmware from resetting or dropping connections. |
| **⚡ TCP NoDelay** | **Enabled** | Disables Nagle's algorithm for microsecond packet delivery, minimizing stale shares during block transitions. |
| **🚀 0ms FastResponse** | **Enabled** | Acknowledges valid shares locally while asynchronously piping them upstream, eliminating ASIC chip wait stalls. |
| **📊 Real-time RtCalHash** | **Enabled** | 1-minute sliding window captures instant hardware hashrate fluctuations, aligning dashboard metrics with pool records. |
| **🤖 Professional ASIC Compatibility** | **Enabled** | Optimized state machine transitions for Antminer S19/S21 and Whatsminer M30/M50 series. |
| **🐜 Antminer E9/E9 Pro Optimization** | Per Hardware | Strict 8-byte Nonce alignment for Ethash ASICs, eliminating disconnect bugs. |
| **💡 ETH/ETC Target Hash Alignment** | Target-specific | Seamlessly aligns Target Hash when switching pools, preventing hashrate dips. |
| **🕷️ SpiderPool Difficulty Clamp** | Pool-specific | Clamps anomalous low-difficulty spikes from SpiderPool during block transitions. |
