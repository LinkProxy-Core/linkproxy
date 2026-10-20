#!/bin/bash
# MinerLink-Proxy One-Click Deployment & Tuning Script

echo "==================================================="
echo "  MinerLink-Proxy 一键安装部署 - 全自动极限优化"
echo "==================================================="

if [ "$EUID" -ne 0 ]; then
  echo "[错误] 请使用 root 权限执行此脚本 (sudo bash install.sh)"
  exit 1
fi

echo "[1/7] 初始化基础环境并同步系统时间..."
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y >/dev/null 2>&1
    apt-get install -y unzip wget curl ufw chrony tzdata >/dev/null 2>&1
    systemctl enable chrony >/dev/null 2>&1
    systemctl restart chrony >/dev/null 2>&1
elif command -v yum >/dev/null 2>&1; then
    yum install -y unzip wget curl firewalld chrony tzdata >/dev/null 2>&1
    systemctl enable chronyd >/dev/null 2>&1
    systemctl restart chronyd >/dev/null 2>&1
fi

timedatectl set-timezone Asia/Shanghai >/dev/null 2>&1
if command -v chronyc >/dev/null 2>&1; then
    chronyc -a makestep >/dev/null 2>&1
fi
echo "  -> 系统时间同步完成 (大幅减少 Stale 份额)"

echo "[2/7] 配置后台管理面板端口..."
while true; do
  read -p "请输入后台管理面板端口 (默认 10010): " WEB_PORT
  WEB_PORT=${WEB_PORT:-10010}
  
  if ! [[ "$WEB_PORT" =~ ^[0-9]+$ ]] || [ "$WEB_PORT" -lt 1 ] || [ "$WEB_PORT" -gt 65535 ]; then
    echo "[错误] 端口范围必须在 1 - 65535 之间，请重新输入"
    continue
  fi
  
  if command -v ss >/dev/null 2>&1; then
    if ss -tuln | grep -E ":$WEB_PORT\b" > /dev/null; then
      echo "[错误] 端口 $WEB_PORT 已被占用，请更换其他端口"
      continue
    fi
  elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln | grep -E ":$WEB_PORT\b" > /dev/null; then
      echo "[错误] 端口 $WEB_PORT 已被占用，请更换其他端口"
      continue
    fi
  fi
  
  echo "  -> 面板端口设置为: $WEB_PORT"
  break
done

echo "[3/7] 自动放行防火墙面板端口..."
if command -v ufw >/dev/null 2>&1; then
    ufw allow $WEB_PORT/tcp >/dev/null 2>&1
    echo "  -> UFW 防火墙已放行 $WEB_PORT 端口"
elif command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --zone=public --add-port=$WEB_PORT/tcp --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    echo "  -> Firewalld 防火墙已放行 $WEB_PORT 端口"
else
    echo "  -> 未检测到已知防火墙，已跳过"
fi

echo "[4/7] 开启内核 Google BBR 拥塞控制算法..."
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p > /dev/null 2>&1
BBR_STATUS=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}' 2>/dev/null)
if [[ "$BBR_STATUS" == *"bbr"* ]]; then
    echo "  -> BBR 拥塞控制已开启"
else
    echo "  -> BBR 开启失败 (内核可能不支持或已手动开启)，跳过"
fi

echo "[5/7] 解除系统 TCP 连接并发限制..."
sed -i '/# ==== MinerLink Tuning ====/,+7d' /etc/sysctl.conf 2>/dev/null || true
cat >> /etc/sysctl.conf << EOF

# ==== MinerLink Tuning ====
fs.file-max = 1000000
net.core.somaxconn = 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 15
EOF
sysctl -p > /dev/null 2>&1

sed -i '/# ==== MinerLink Limits ====/,\$d' /etc/security/limits.conf 2>/dev/null || true
cat >> /etc/security/limits.conf << EOF

# ==== MinerLink Limits ====
* soft nofile 1000000
* hard nofile 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF

if [ -f "/etc/systemd/system.conf" ]; then
    sed -i 's/#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1000000/g' /etc/systemd/system.conf
fi
echo "  -> 网络并发参数优化完毕(百万级连接支持)"

echo "[6/7] 正在拉取代理核心与构建守护进程..."
WORK_DIR="/root/MinerLink-Proxy"
PROXY_BIN="$WORK_DIR/MinerLink-Proxy-linux-amd64"
mkdir -p $WORK_DIR
cd $WORK_DIR

echo "  -> 正在从 Github 获取最新 MinerLink-Proxy 核心包 (请保持网络畅通)..."
if wget -q --timeout=30 -O MinerLink-Proxy-Linux.zip "https://github.com/niuniu06/MinerLink-Proxy/releases/latest/download/MinerLink-Proxy-Linux.zip"; then
    unzip -o MinerLink-Proxy-Linux.zip
    chmod +x MinerLink-Proxy-linux-amd64
    rm -f MinerLink-Proxy-Linux.zip
    echo "  -> 下载与解压完成，已赋予执行权限"
else
    echo "  [致命错误] 下载核心包失败，请检查服务器与 Github Release 的连通性！"
    echo "  [提示] 你可以尝试手动将 ZIP 包上传到 $WORK_DIR 目录然后重新执行脚本"
    exit 1
fi

cat > /etc/systemd/system/minerlink-proxy.service << EOF
[Unit]
Description=MinerLink-Proxy Transparent Mining Proxy
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$WORK_DIR
ExecStart=$PROXY_BIN -api-port $WEB_PORT
Restart=always
RestartSec=3
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable minerlink-proxy > /dev/null 2>&1
systemctl restart minerlink-proxy > /dev/null 2>&1
echo "  -> 系统服务已注册并成功启动"

echo "==================================================="
echo "[7/7] 🎉 MinerLink-Proxy 安装部署圆满完成！"
echo ""
echo "🚀 立即访问后台面板: http://服务器公网IP:$WEB_PORT/ui/"
echo ""
echo "常用维护命令"
echo "- 启动代理: systemctl start minerlink-proxy"
echo "- 停止代理: systemctl stop minerlink-proxy"
echo "- 重启代理: systemctl restart minerlink-proxy"
echo "- 查看状态: systemctl status minerlink-proxy"
echo "- 实时运行日志: journalctl -u minerlink-proxy -f"
echo "==================================================="