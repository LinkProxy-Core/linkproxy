#!/usr/bin/env bash
# ==============================================================================
# LinkProxy 端口连通性与矿池延迟快速自检工具
# 用法: bash scripts/check-ports.sh [端口号 / 矿池地址:端口]
# ==============================================================================

set -euo pipefail

TARGET="${1:-10010}"

echo "======================================================"
echo "   LinkProxy 端口连通性与延迟测试工具"
echo "======================================================"

test_tcp() {
    local host="$1"
    local port="$2"
    local start_time end_time elapsed_ms

    if command -v nc >/dev/null 2>&1; then
        start_time=$(date +%s%N)
        if nc -z -w 3 "$host" "$port" 2>/dev/null; then
            end_time=$(date +%s%N)
            elapsed_ms=$(( (end_time - start_time) / 1000000 ))
            echo -e "[✓ 成功] $host:$port 连通正常 | 握手延迟: ${elapsed_ms} ms"
            return 0
        fi
    else
        start_time=$(date +%s%N)
        if (echo > /dev/tcp/"$host"/"$port") >/dev/null 2>&1; then
            end_time=$(date +%s%N)
            elapsed_ms=$(( (end_time - start_time) / 1000000 ))
            echo -e "[✓ 成功] $host:$port 连通正常 | 握手延迟: ${elapsed_ms} ms"
            return 0
        fi
    fi

    echo -e "[✗ 失败] 无法连通 $host:$port (请检查防火墙、安全组或服务状态)"
    return 1
}

if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
    echo "检测本机监听端口: $TARGET ..."
    test_tcp "127.0.0.1" "$TARGET"
elif [[ "$TARGET" =~ : ]]; then
    HOST=$(echo "$TARGET" | cut -d':' -f1)
    PORT=$(echo "$TARGET" | cut -d':' -f2)
    echo "检测远程目标: $HOST:$PORT ..."
    test_tcp "$HOST" "$PORT"
else
    echo "未知格式。请输入端口号 (如 8888) 或目标地址 (如 btc.f2pool.com:1315)"
fi
