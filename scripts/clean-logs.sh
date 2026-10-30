#!/usr/bin/env bash
# ==============================================================================
# LinkProxy 运行日志归档与定时清理脚本
# 建议通过 crontab 每天执行一次: 0 3 * * * bash /etc/linkproxy/scripts/clean-logs.sh
# ==============================================================================

set -euo pipefail

LOG_DIR="/etc/linkproxy/logs"
KEEP_DAYS=7

if [ ! -d "$LOG_DIR" ]; then
    LOG_DIR="/var/log/linkproxy"
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "未找到日志目录，跳过清理。"
    exit 0
fi

echo "正在清理 ${LOG_DIR} 目录下超过 ${KEEP_DAYS} 天的旧日志..."
find "$LOG_DIR" -name "*.log" -type f -mtime +"$KEEP_DAYS" -exec rm -f {} +
find "$LOG_DIR" -name "*.gz" -type f -mtime +"$KEEP_DAYS" -exec rm -f {} +

echo "正在压缩超过 1 天的未压缩历史日志..."
find "$LOG_DIR" -name "*.log.*" -type f ! -name "*.gz" -mtime +1 -exec gzip -f {} +

echo "日志清理与归档已完成。当前日志占用:"
du -sh "$LOG_DIR" 2>/dev/null || true
