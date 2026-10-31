#!/bin/bash
# ==============================================================================
# LinkProxy International Installer & Service Manager (English)
# GitHub: https://github.com/LinkProxy-Core/linkproxy
# ==============================================================================

set -euo pipefail

WORK_DIR="/root/linkproxy"
SERVICE_NAME="linkproxy"
BINARY_NAME="linkproxy-linux-amd64"
GITHUB_REPO="LinkProxy-Core/linkproxy"
DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/linkproxy-linux-amd64.tar.gz"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

get_latest_release_tag() {
    local tag=""
    if command -v curl >/dev/null 2>&1; then
        tag=$(curl -sI "https://github.com/${GITHUB_REPO}/releases/latest" 2>/dev/null | grep -i '^location:' | sed 's/.*tag\///' | tr -d '\r\n')
    fi
    if [[ "$tag" =~ ^v[0-9]+\.[0-9]+ ]]; then
        echo "$tag"
    else
        echo "v2.2.145"
    fi
}
SOFTWARE_VERSION="$(get_latest_release_tag)"

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}    LinkProxy High-Performance Mining Gateway Installer (v${SOFTWARE_VERSION}) ${NC}"
echo -e "${CYAN}================================================================${NC}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[Error] Root privileges required. Please run with sudo.${NC}"
    exit 1
fi

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo -e "${YELLOW}[1/3] Downloading latest release from GitHub...${NC}"
curl -fL -# -o "${WORK_DIR}/package.tar.gz" "$DOWNLOAD_URL"

echo -e "${YELLOW}[2/3] Extracting files...${NC}"
tar -zxvf "${WORK_DIR}/package.tar.gz" -C "$WORK_DIR"
rm -f "${WORK_DIR}/package.tar.gz"
chmod +x "${WORK_DIR}/${BINARY_NAME}"

# Link CLI shortcut
ln -sf "${WORK_DIR}/${BINARY_NAME}" /usr/local/bin/linkproxy

echo -e "${YELLOW}[3/3] Configuring systemd service...${NC}"
cat << EOF > "/etc/systemd/system/${SERVICE_NAME}.service"
[Unit]
Description=LinkProxy High Performance Mining Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${WORK_DIR}
ExecStart=${WORK_DIR}/${BINARY_NAME} -api-port 10010
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}    LinkProxy Installation Completed Successfully!              ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "Web Console:  ${BOLD}http://<YOUR_SERVER_IP>:10010/ui/${NC}"
echo -e "Default User: ${BOLD}admin${NC}"
echo -e "Default Pass: ${BOLD}admin${NC}"
echo -e "Service Cmd:  ${BOLD}systemctl status ${SERVICE_NAME}${NC}"
echo -e "CLI Shortcut: ${BOLD}linkproxy${NC}"
echo ""
