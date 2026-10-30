# 09. Troubleshooting & Ops FAQ

This chapter covers common operational issues and diagnostic steps for LinkProxy.

---

## Miner Cannot Connect to Proxy

If miners fail to connect after creating a port, verify the following:

1. **Cloud Security Group Inbound Rules (Most Common)**:
   - AWS, Google Cloud, Alibaba Cloud, Tencent Cloud, etc., require opening inbound TCP ports in their web consoles.
2. **Linux Host Firewall**:
   - Check if the local firewall is blocking the port:
     ```bash
     sudo ufw allow 8888/tcp
     ```
3. **Verify Listening Sockets**:
   - Run the following command on the server:
     ```bash
     ss -tulpn | grep 8888
     ```
   - If nothing is returned, the port might conflict with another local daemon.
4. **Protocol Selection**:
   - Set the port protocol to **`SSLMIX`**, allowing both plain TCP and SSL miners to connect adaptively.

---

## High Rejection Rate Troubleshooting

1. **High Network Latency to Pool**:
   - Check pool ping latency in the **Port Overview** tab.
   - If round-trip latency exceeds 150ms, submitted shares become **Stale Shares**. Choose closer pool nodes or deploy the **Encrypted Tunnel Client**.
2. **Correct Mining Protocol**:
   - When mining ETC / ETHW, ensure your mining software uses `ETH_PROXY` or standard `Stratum`.
3. **Enable AntiBan**:
   - Enable **AntiBan** in the port's **Advanced Settings** to suppress transient pool rejection noise.

---

## Admin Password Reset

### Linux:
Run the management command in terminal:
```bash
linkproxy
```
Enter option **`9`** (Reset admin password & web port), or reset directly in SQLite:
```bash
sqlite3 /root/linkproxy/data/proxy.db "UPDATE global_configs SET admin_account='admin', admin_password='admin';"
sudo systemctl restart linkproxy
```

### Windows:
Use SQLite database manager or reinstall the background task.

---

## Seamless Online Upgrades (Zero Data Loss)

All port mappings, fee rules, and telemetry stats are persisted in SQLite `proxy.db`. Upgrades **never** overwrite your data.

### Linux Upgrade:
Type `linkproxy` in terminal and select option **`2`** (Check and upgrade to latest release). The service updates and restarts seamlessly in seconds.

### Windows Upgrade:
Download the latest `linkproxy-windows-amd64.zip`, extract, replace the executable, and restart.
