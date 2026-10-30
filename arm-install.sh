#!/usr/bin/env bash
# ==============================================================================
# LinkProxy ARM64 / ARMv7 Linux One-Click Installer
# GitHub: https://github.com/LinkProxy-Core/linkproxy
# Suitable for: Raspberry Pi (3B+/4B/5), Orange Pi, Rockchip, AWS Graviton, Oracle ARM
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

WORK_DIR="/root/linkproxy"
SERVICE_NAME="linkproxy"
GITHUB_REPO="LinkProxy-Core/linkproxy"

echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}   LinkProxy ARM Architecture One-Click Installer     ${NC}"
echo -e "${CYAN}======================================================${NC}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[Error] Please run this script as root (sudo bash $0)${NC}"
    exit 1
fi

ARCH=$(uname -m)
case "$ARCH" in
    aarch64|arm64)
        TARGET_ARCH="arm64"
        ;;
    armv7*|armhf)
        TARGET_ARCH="armv7"
        ;;
    x86_64|amd64)
        echo -e "${YELLOW}[Note] Detected x86_64 architecture. Redirecting to standard install.sh...${NC}"
        exec curl -fsSL "https://raw.githubusercontent.com/${GITHUB_REPO}/main/install.sh" | bash
        exit 0
        ;;
    *)
        echo -e "${RED}[Error] Unsupported architecture: ${ARCH}${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}[1/4] Detected ARM Architecture: ${TARGET_ARCH}${NC}"

get_latest_release_tag() {
    local tag=""
    if command -v curl >/dev/null 2>&1; then
        tag=$(curl -sI "https://github.com/${GITHUB_REPO}/releases/latest" 2>/dev/null | grep -i '^location:' | sed 's/.*tag\///' | tr -d '\r\n')
    fi
    if [[ "$tag" =~ ^v[0-9]+\.[0-9]+ ]]; then
        echo "$tag"
    else
        echo "v2.2.143"
    fi
}

VERSION=$(get_latest_release_tag)
DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/linkproxy-linux-${TARGET_ARCH}.tar.gz"

echo -e "${GREEN}[2/4] Target Version: ${VERSION}${NC}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo -e "${GREEN}[3/4] Downloading release package...${NC}"
if curl -fsSL -o "linkproxy-linux-${TARGET_ARCH}.tar.gz" "$DOWNLOAD_URL"; then
    tar -zxvf "linkproxy-linux-${TARGET_ARCH}.tar.gz" -C "$WORK_DIR"
    chmod +x "$WORK_DIR/linkproxy-linux-${TARGET_ARCH}" 2>/dev/null || chmod +x "$WORK_DIR/linkproxy" 2>/dev/null || true
    echo -e "${GREEN}Extraction completed.${NC}"
else
    echo -e "${YELLOW}[Notice] Dedicated pre-compiled ARM binary is packaging in Release. Falling back to universal installation...${NC}"
    curl -fsSL "https://raw.githubusercontent.com/${GITHUB_REPO}/main/install.sh" | bash
    exit 0
fi

# Create systemd service
echo -e "${GREEN}[4/4] Setting up systemd service (${SERVICE_NAME})...${NC}"
cat << EOF > "/etc/systemd/system/${SERVICE_NAME}.service"
[Unit]
Description=LinkProxy ARM Mining Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${WORK_DIR}
ExecStart=${WORK_DIR}/linkproxy-linux-${TARGET_ARCH}
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}   LinkProxy ARM Installation Complete!               ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Web Console: http://YOUR_SERVER_IP:10010/ui/"
echo -e "Default User: admin / admin"
echo -e "Status Command: systemctl status ${SERVICE_NAME}"
echo ""
