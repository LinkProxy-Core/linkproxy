#!/usr/bin/env bash
# ==============================================================================
# LinkProxy Linux 独立更新与平滑升级脚本
# ==============================================================================

set -euo pipefail

WORK_DIR="/root/linkproxy"
SERVICE_NAME="linkproxy"
BINARY_NAME="linkproxy-linux-amd64"
GITHUB_REPO="LinkProxy-Core/linkproxy"

echo "======================================================"
echo "   LinkProxy 独立检查与一键升级"
echo "======================================================"

if [ "$(id -u)" -ne 0 ]; then
    echo "[错误] 请使用 root 权限执行此脚本。"
    exit 1
fi

get_latest_release_tag() {
    curl -sI "https://github.com/${GITHUB_REPO}/releases/latest" 2>/dev/null | grep -i '^location:' | sed 's/.*tag\///' | tr -d '\r\n'
}

LATEST_TAG=$(get_latest_release_tag)
if [ -z "$LATEST_TAG" ]; then
    echo "[错误] 无法获取 GitHub 最新版本号，请检查网络。"
    exit 1
fi

echo "发现最新版本: $LATEST_TAG"
DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${LATEST_TAG}/linkproxy-linux-amd64.tar.gz"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "正在下载最新发布包..."
curl -fL -# -o "$TMP_DIR/package.tar.gz" "$DOWNLOAD_URL"

echo "正在解压校验..."
tar -zxvf "$TMP_DIR/package.tar.gz" -C "$TMP_DIR"

if [ ! -f "$TMP_DIR/$BINARY_NAME" ]; then
    echo "[错误] 解压后未找到可执行文件 $BINARY_NAME"
    exit 1
fi

echo "备份当前版本与数据库..."
mkdir -p "$WORK_DIR/backup"
BACKUP_TAG=$(date +%Y%m%d_%H%M%S)
[ -f "$WORK_DIR/$BINARY_NAME" ] && cp "$WORK_DIR/$BINARY_NAME" "$WORK_DIR/backup/${BINARY_NAME}.${BACKUP_TAG}"
[ -f "$WORK_DIR/data.db" ] && cp "$WORK_DIR/data.db" "$WORK_DIR/backup/data.db.${BACKUP_TAG}"

echo "停止现有服务..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true

echo "替换最新二进制文件..."
cp "$TMP_DIR/$BINARY_NAME" "$WORK_DIR/$BINARY_NAME"
chmod +x "$WORK_DIR/$BINARY_NAME"

echo "重新启动服务..."
systemctl start "$SERVICE_NAME"
sleep 2

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "升级成功！当前版本已更新为: $LATEST_TAG"
    echo "服务状态: $(systemctl is-active "$SERVICE_NAME")"
else
    echo "[警告] 服务启动异常，正在自动回滚..."
    cp "$WORK_DIR/backup/${BINARY_NAME}.${BACKUP_TAG}" "$WORK_DIR/$BINARY_NAME"
    systemctl start "$SERVICE_NAME"
    echo "已回滚至先前版本。"
fi
