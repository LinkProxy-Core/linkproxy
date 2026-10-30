#!/usr/bin/env bash
# ==============================================================================
# LinkProxy 万台矿机高并发 Linux 内核与网络栈调优脚本
# 适用系统: Ubuntu 18.04+, Debian 10+, CentOS 7/8/9, Rocky Linux, AlmaLinux
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PLAIN='\033[0m'

echo -e "${BLUE}======================================================${PLAIN}"
echo -e "${BLUE}   LinkProxy 万台高并发 Linux 内核网络栈一键调优   ${PLAIN}"
echo -e "${BLUE}======================================================${PLAIN}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[错误] 必须使用 root 权限运行此脚本 (例如: sudo bash $0)${PLAIN}"
    exit 1
fi

SYSCTL_CONF="/etc/sysctl.conf"
LIMITS_CONF="/etc/security/limits.conf"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

# 1. 备份现有配置
echo -e "${YELLOW}[1/4] 备份当前系统配置...${PLAIN}"
cp "$SYSCTL_CONF" "${SYSCTL_CONF}.bak.${BACKUP_DATE}"
echo -e "${GREEN}已备份到: ${SYSCTL_CONF}.bak.${BACKUP_DATE}${PLAIN}"

if [ -f "$LIMITS_CONF" ]; then
    cp "$LIMITS_CONF" "${LIMITS_CONF}.bak.${BACKUP_DATE}"
    echo -e "${GREEN}已备份到: ${LIMITS_CONF}.bak.${BACKUP_DATE}${PLAIN}"
fi

# 2. 调优最大文件描述符与进程限制 (limits.conf)
echo -e "${YELLOW}[2/4] 配置最大文件句柄 (1048576)...${PLAIN}"
cat << 'EOF' >> "$LIMITS_CONF"

# LinkProxy High Concurrency Limits
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 524288
* hard nproc 524288
root soft nofile 1048576
root hard nofile 1048576
root soft nproc 524288
root hard nproc 524288
EOF

# 3. 写入 sysctl.conf 关键内核参数
echo -e "${YELLOW}[3/4] 写入 TCP 高并发与低延迟内核参数...${PLAIN}"
cat << 'EOF' >> "$SYSCTL_CONF"

# ==============================================================================
# LinkProxy High-Performance Mining Gateway Sysctl Tuning
# ==============================================================================
# 系统最大打开文件描述符数
fs.file-max = 2097152

# 增大连接队列深度与 Socket 监听队列
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# 优化 TIME_WAIT 套接字快速回收与复用
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# 优化心跳与保持保活机制 (防网络抖动断连)
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5

# 增大 TCP 读写缓冲区 (适配高算力瞬时并发份额)
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# 允许最大连接跟踪数 (针对大量 ASIC 矿机)
net.netfilter.nf_conntrack_max = 1048576 2>/dev/null || true

# 开启 TCP BBR 拥塞控制算法 (如果内核支持)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
# ==============================================================================
EOF

# 4. 生效内核参数
echo -e "${YELLOW}[4/4] 重新加载内核参数...${PLAIN}"
sysctl -p >/dev/null 2>&1 || true

echo -e "\n${GREEN}======================================================${PLAIN}"
echo -e "${GREEN}   内核优化完成！当前系统已全面就绪万台高并发。   ${PLAIN}"
echo -e "${GREEN}======================================================${PLAIN}"
echo -e "当前文件描述符限制: $(ulimit -n) (重新登录终端后生效为 1048576)"
echo -e "当前拥塞控制算法:   $(sysctl net.ipv4.tcp_congestion_control 2>/dev/null || echo '未支持BBR')"
echo ""
