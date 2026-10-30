# 01. Installation & Quick Start

This guide walks you through deploying LinkProxy on Linux or Windows in under 3 minutes.

---

## Hardware Recommendations

LinkProxy is built on a high-concurrency Go runtime with minimal resource usage:

| Connected Miners | Recommended CPU | Recommended RAM | Network Bandwidth | Recommended OS |
| :--- | :--- | :--- | :--- | :--- |
| **1 ~ 500 miners** | 1 ~ 2 Cores | 1 GB ~ 2 GB | 10 Mbps | Debian 11/12, Ubuntu 20.04+ |
| **500 ~ 3,000 miners** | 2 ~ 4 Cores | 2 GB ~ 4 GB | 20 Mbps ~ 30 Mbps | Debian 12, Rocky Linux 9 |
| **3,000 ~ 15,000 miners** | 4 ~ 8 Cores | 8 GB | 50 Mbps ~ 100 Mbps | Debian 12 (with BBR enabled) |
| **15,000+ miners** | 8 ~ 16 Cores | 16 GB ~ 32 GB | 100 Mbps+ | High-performance Cloud VPS |

---

## Linux One-Click Installation

### 1. Execute Installer
Run the following command in your terminal:

```bash
bash <(curl -s -L https://raw.githubusercontent.com/LinkProxy-Core/linkproxy/main/install_en.sh)
```

The script will automatically download the binary, configure system permissions, and set up the systemd service. Upon completion, the terminal displays:
- **Web Console URL** (e.g. `http://YOUR_SERVER_IP:10010/ui/`)
- **Default Username**: `admin`
- **Default Password**: `admin`

### 2. Interactive CLI Manager
Type `linkproxy` in any terminal to open the management menu:

```bash
linkproxy
```

From this menu, you can start/stop the service, check status, optimize system file descriptors (`LimitNOFILE`), and perform seamless updates.

---

## Windows Installation

1. Download `linkproxy-windows-amd64.zip` from [GitHub Releases](https://github.com/LinkProxy-Core/linkproxy/releases/latest).
2. Extract to a directory of your choice (e.g. `D:\LinkProxy`).
3. Double-click `start.bat` for interactive console mode.
4. For production auto-start, right-click `install-service.bat` and select **Run as Administrator**.
5. Open your browser and navigate to `http://127.0.0.1:10010/ui/`.

---

## First Login & Security

1. Navigate to the console address in your browser (`http://YOUR_SERVER_IP:10010/ui/`).
2. Log in using `admin` / `admin`.
3. **Important**: Change the default admin password immediately in the **Settings** tab.
