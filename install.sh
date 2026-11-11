#!/bin/bash
# ==============================================================================
# LinkProxy Management & Installation Script
# GitHub: https://github.com/LinkProxy-Core/linkproxy
# ==============================================================================

WORK_DIR="/root/linkproxy"
SERVICE_NAME="linkproxy"
BINARY_NAME="linkproxy-linux-amd64"
GITHUB_REPO="LinkProxy-Core/linkproxy"
DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/linkproxy-linux-amd64.tar.gz"
SCRIPT_VERSION="6.2.2"

# 动态探测 GitHub 最新 Release 标签，毫秒级 302 重定向解析，免除每次推送手动维护
get_latest_release_tag() {
    local tag=""
    if command -v curl >/dev/null 2>&1; then
        tag=$(curl -sI "https://github.com/${GITHUB_REPO}/releases/latest" 2>/dev/null | grep -i '^location:' | sed 's/.*tag\///' | tr -d '\r\n')
    fi
    if [ -z "$tag" ] && command -v wget >/dev/null 2>&1; then
        tag=$(wget -q -S --spider "https://github.com/${GITHUB_REPO}/releases/latest" 2>&1 | grep -i 'Location:' | sed 's/.*tag\///' | tr -d '\r\n')
    fi
    if [[ "$tag" =~ ^v[0-9]+\.[0-9]+ ]]; then
        echo "$tag"
    else
        echo "v2.2.149"
    fi
}
SOFTWARE_VERSION="$(get_latest_release_tag)"

# Detect active working directory if already installed
LEGACY_DIR=""
if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
    _custom_wd=$(grep -oP '(?<=WorkingDirectory=).*' "/etc/systemd/system/${SERVICE_NAME}.service" 2>/dev/null)
    [ -n "$_custom_wd" ] && [ -d "$_custom_wd" ] && WORK_DIR="$_custom_wd"
elif [ -f "/etc/systemd/system/minerlink-proxy.service" ]; then
    _custom_lwd=$(grep -oP '(?<=WorkingDirectory=).*' "/etc/systemd/system/minerlink-proxy.service" 2>/dev/null)
    [ -n "$_custom_lwd" ] && [ -d "$_custom_lwd" ] && LEGACY_DIR="$_custom_lwd"
fi
[ -z "$LEGACY_DIR" ] && [ -d "/root/MinerLink-Proxy" ] && LEGACY_DIR="/root/MinerLink-Proxy"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Safe TTY reader for curl | bash execution
read_tty() {
    local prompt="$1"
    local var_name="$2"
    if [ -t 0 ]; then
        read -r -p "$prompt" "$var_name"
    elif [ -e /dev/tty ]; then
        read -r -p "$prompt" "$var_name" < /dev/tty
    else
        read -r -p "$prompt" "$var_name"
    fi
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[错误 / Error] 请使用 root 权限执行此脚本 (Please run as root: sudo bash install.sh)${NC}"
        exit 1
    fi
}

check_root

# Setup convenient shortcut 'minerlink'
setup_shortcut() {
    if [ ! -f "/usr/local/bin/linkproxy" ] || [ "$0" != "/usr/local/bin/linkproxy" ]; then
        if [ -f "$0" ] && [ "$(basename -- "$0")" = "install.sh" ]; then
            cp -f "$0" /usr/local/bin/linkproxy 2>/dev/null && chmod +x /usr/local/bin/linkproxy 2>/dev/null
        else
            curl -fsSL "https://github.com/${GITHUB_REPO}/releases/latest/download/install.sh" -o /usr/local/bin/linkproxy 2>/dev/null && chmod +x /usr/local/bin/linkproxy 2>/dev/null
        fi
        ln -sf /usr/local/bin/linkproxy /usr/bin/linkproxy 2>/dev/null
        ln -sf /usr/local/bin/linkproxy /usr/local/bin/minerlink 2>/dev/null
        ln -sf /usr/local/bin/linkproxy /usr/bin/minerlink 2>/dev/null
    fi
}
setup_shortcut

# Language Selection
select_language() {
    if [ -z "$ML_LANG" ]; then
        echo -e "${CYAN}Please select language / 请选择语言：${NC}"
        echo "1. English"
        echo "2. 中文"
        read_tty "Enter choice [1-2] (default 2): " lang_choice
        lang_choice=${lang_choice:-2}
        if [ "$lang_choice" = "1" ]; then
            ML_LANG="en"
        else
            ML_LANG="zh"
        fi
    fi
}

get_status_text() {
    if [ -f "$WORK_DIR/$BINARY_NAME" ]; then
        if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
            if [ "$ML_LANG" = "en" ]; then
                echo -e "${GREEN}<< Proxy Installed (Running) >>${NC}"
            else
                echo -e "${GREEN}<< 代理已安装 (运行中) >>${NC}"
            fi
        else
            if [ "$ML_LANG" = "en" ]; then
                echo -e "${YELLOW}<< Proxy Installed (Stopped) >>${NC}"
            else
                echo -e "${YELLOW}<< 代理已安装 (已停止) >>${NC}"
            fi
        fi
    else
        if [ "$ML_LANG" = "en" ]; then
            echo -e "${RED}<< Proxy Not Installed >>${NC}"
        else
            echo -e "${RED}<< 代理未安装 >>${NC}"
        fi
    fi
}

get_web_port() {
    local port=""
    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
        port=$(grep -oP '(?<=-api-port )[0-9]+' "/etc/systemd/system/${SERVICE_NAME}.service" 2>/dev/null)
    fi
    echo "${port:-10010}"
}

get_public_ip() {
    local ip=""
    ip=$(curl -s --connect-timeout 2 http://ifconfig.me 2>/dev/null)
    [ -z "$ip" ] && ip=$(curl -s --connect-timeout 2 http://api.ipify.org 2>/dev/null)
    [ -z "$ip" ] && ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    echo "${ip:-服务器IP}"
}

get_software_version() {
    local bin="$WORK_DIR/$BINARY_NAME"
    if [ -f "$bin" ]; then
        local ver
        ver=$("$bin" -v 2>/dev/null | tr -d '\r\n')
        if [ -n "$ver" ]; then
            echo "$ver"
            return
        fi
    fi
    echo "$SOFTWARE_VERSION"
}

show_menu() {
    clear
    local status_banner
    status_banner=$(get_status_text)
    
    echo -e "          ${BOLD}${status_banner}${NC}"
    echo ""
    if [ "$ML_LANG" = "en" ]; then
        echo -e "${YELLOW}Notice: If you previously installed other proxy software, please completely remove them to avoid port conflicts and hashrate impact.${NC}"
        echo -e "Script Management Interface ready (Recommended: Debian / Ubuntu / CentOS)"
        echo -e "Route: ${CYAN}Default${NC}"
        echo -e "Script Version: ${CYAN}${SCRIPT_VERSION}${NC}"
        echo -e "Software Version: ${CYAN}$(get_software_version)${NC}"
        echo -e "Linux Max Connections automatically optimized to 1,048,576"
        echo -e "Auto-start service on boot configured"
        echo -e "Web Admin Port configured upon install. Shortcut command: ${GREEN}linkproxy${NC} (or minerlink)"
        echo ""
        echo -e "${CYAN}0.${NC} Exit"
        echo -e "${CYAN}1.${NC} Install"
        echo -e "${CYAN}2.${NC} Update"
        echo -e "${CYAN}3.${NC} Uninstall"
        echo -e "${CYAN}4.${NC} Start Proxy"
        echo -e "${CYAN}5.${NC} Stop Proxy"
        echo -e "${CYAN}6.${NC} Check Linux Max Connections"
        echo -e "${CYAN}7.${NC} Modify Linux Max Connections to 1,048,576"
        echo -e "${CYAN}8.${NC} Enable Auto-Start on Boot"
        echo -e "${CYAN}9.${NC} View or Reset Admin Password & Web Port"
        echo -e "${CYAN}10.${NC} View Running Status & Configuration"
        echo -e "${CYAN}11.${NC} Clear Logs & Cache"
        echo ""
        read_tty "Please enter choice [0-11]: " choice
    else
        echo -e "${YELLOW}如果您之前安装其它代理软件，请彻底停止卸载，避免端口冲突与算力影响${NC}"
        echo -e "脚本管理界面安装完成 (推荐使用 Debian / Ubuntu / CentOS 系统)"
        echo -e "线路：${CYAN}Default${NC}"
        echo -e "脚本版本：${CYAN}${SCRIPT_VERSION}${NC}"
        echo -e "软件版本：${CYAN}$(get_software_version)${NC}"
        echo -e "安装过程中已将 Linux 最大连接数默认修改为 1048576 (需服务器重启彻底生效)"
        echo -e "安装过程中已设置开机自启"
        echo -e "浏览器默认端口为自定义端口（默认 10010）。后续随时在终端输入 ${GREEN}linkproxy${NC} 唤出本菜单"
        echo ""
        echo -e "${CYAN}0.${NC} 退出"
        echo -e "${CYAN}1.${NC} 安装"
        echo -e "${CYAN}2.${NC} 更新"
        echo -e "${CYAN}3.${NC} 卸载"
        echo -e "${CYAN}4.${NC} 启动"
        echo -e "${CYAN}5.${NC} 停止"
        echo -e "${CYAN}6.${NC} 检查 Linux 最大连接数"
        echo -e "${CYAN}7.${NC} 修改 Linux 最大连接数为 1048576 (需要服务器重启)"
        echo -e "${CYAN}8.${NC} 手动设置开机自启"
        echo -e "${CYAN}9.${NC} 查看或重置管理员密码与管理端口"
        echo -e "${CYAN}10.${NC} 查看运行状态与配置"
        echo -e "${CYAN}11.${NC} 删除错误与运行日志"
        echo ""
        read_tty "请输入选择 [0-11]: " choice
    fi
}

pause() {
    if [ "$ML_LANG" = "en" ]; then
        read_tty "Press Enter to return to main menu..." dummy
    else
        read_tty "按回车键返回主菜单..." dummy
    fi
}

optimize_system() {
    echo -e "${CYAN}[1/4] 同步系统时间...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y >/dev/null 2>&1
        apt-get install -y unzip wget curl chrony tzdata >/dev/null 2>&1
        systemctl enable chrony >/dev/null 2>&1
        systemctl restart chrony >/dev/null 2>&1
    elif command -v yum >/dev/null 2>&1; then
        yum install -y unzip wget curl chrony tzdata >/dev/null 2>&1
        systemctl enable chronyd >/dev/null 2>&1
        systemctl restart chronyd >/dev/null 2>&1
    fi
    timedatectl set-timezone Asia/Shanghai >/dev/null 2>&1
    if command -v chronyc >/dev/null 2>&1; then
        chronyc -a makestep >/dev/null 2>&1
    fi

    echo -e "${CYAN}[2/4] 开启 Google BBR 拥塞控制...${NC}"
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf 2>/dev/null
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf 2>/dev/null
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1

    echo -e "${CYAN}[3/4] 调优 Linux 百万级连接数并发 (1,048,576)...${NC}"
    sed -i '/# ==== LinkProxy Tuning ====/,+7d' /etc/sysctl.conf 2>/dev/null || true
    cat >> /etc/sysctl.conf << EOF

# ==== LinkProxy Tuning ====
fs.file-max = 1048576
net.core.somaxconn = 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 15
EOF
    sysctl -p >/dev/null 2>&1

    sed -i '/# ==== LinkProxy Limits ====/,\$d' /etc/security/limits.conf 2>/dev/null || true
    cat >> /etc/security/limits.conf << EOF

# ==== LinkProxy Limits ====
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF

    if [ -f "/etc/systemd/system.conf" ]; then
        sed -i 's/#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1048576/g' /etc/systemd/system.conf
        sed -i 's/DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1048576/g' /etc/systemd/system.conf
    fi
}

download_with_fallback() {
    local out_file="$1"
    local raw_url="$2"
    local urls=(
        "$raw_url"
        "https://ghfast.top/${raw_url}"
        "https://gh-proxy.com/${raw_url}"
        "https://ghproxy.net/${raw_url}"
    )
    for u in "${urls[@]}"; do
        rm -f "$out_file"
        if wget -q --timeout=20 --tries=1 -O "$out_file" "$u" && [ -s "$out_file" ]; then
            return 0
        fi
        if command -v curl >/dev/null 2>&1; then
            if curl -fsSL --connect-timeout 10 --max-time 90 -o "$out_file" "$u" && [ -s "$out_file" ]; then
                return 0
            fi
        fi
    done
    rm -f "$out_file"
    return 1
}

install_proxy() {
    clear
    echo -e "${BOLD}${GREEN}==============================================${NC}"
    if [ "$ML_LANG" = "en" ]; then
        echo -e "${BOLD}  LinkProxy Installation${NC}"
    else
        echo -e "${BOLD}  LinkProxy 一键安装${NC}"
    fi
    echo -e "${BOLD}${GREEN}==============================================${NC}"

    local current_port="10010"
    if [ "$ML_LANG" = "en" ]; then
        read_tty "Please enter Web Console port (default 10010): " input_port
    else
        read_tty "请输入后台管理面板端口 (默认 10010): " input_port
    fi
    current_port=${input_port:-10010}

    optimize_system

    echo -e "${CYAN}[4/4] 下载并安装代理核心...${NC}"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR" || exit 1

    echo -e "  -> 正在拉取官方稳定版安装包..."
    if download_with_fallback linkproxy-linux-amd64.tar.gz "$DOWNLOAD_URL"; then
        tar -zxf linkproxy-linux-amd64.tar.gz
        chmod +x "$BINARY_NAME"
        rm -f linkproxy-linux-amd64.tar.gz
    else
        echo -e "${RED}[错误] 下载核心包失败，请检查服务器与 GitHub 的网络连接！${NC}"
        pause
        return 1
    fi

    # Release port on firewall
    if command -v ufw >/dev/null 2>&1; then
        ufw allow "$current_port"/tcp >/dev/null 2>&1
    elif command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --zone=public --add-port="$current_port"/tcp --permanent >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
    fi

    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=LinkProxy High Performance Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$WORK_DIR
ExecStart=$WORK_DIR/$BINARY_NAME -api-port $current_port
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1

    local pub_ip
    pub_ip=$(get_public_ip)

    echo ""
    echo -e "${BOLD}${GREEN}==============================================${NC}"
    if [ "$ML_LANG" = "en" ]; then
        echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
        echo -e "🚀 Web Console URL: ${CYAN}http://${pub_ip}:${current_port}/ui/${NC}"
        echo -e "💡 Command shortcut: Type ${GREEN}linkproxy${NC} anytime to manage."
        echo -e "💬 Community Support:"
        echo -e "   • Telegram: ${CYAN}https://t.me/+fKG-u6OEDexlMDIx${NC}"
        echo -e "   • QQ Group:  ${CYAN}812127094${NC}"
        echo -e "🌟 If it helps, please star us on GitHub: ${YELLOW}https://github.com/LinkProxy-Core/linkproxy${NC}"
    else
        echo -e "${GREEN}🎉 安装部署圆满完成！${NC}"
        echo -e "🚀 控制台访问地址: ${CYAN}http://${pub_ip}:${current_port}/ui/${NC}"
        echo -e "💡 快捷管理命令: 以后在终端随时输入 ${GREEN}linkproxy${NC} 即可打开本控制台"
        echo -e "💬 交流与社区支持:"
        echo -e "   • Telegram 官方群: ${CYAN}https://t.me/+fKG-u6OEDexlMDIx${NC}"
        echo -e "   • 官方 QQ 交流群:  ${CYAN}812127094${NC}"
        echo -e "🌟 如果对您有帮助，请前往 GitHub 给项目点个 Star 支持：${YELLOW}https://github.com/LinkProxy-Core/linkproxy${NC}"
    fi
    echo -e "${BOLD}${GREEN}==============================================${NC}"
    pause
}

update_proxy() {
    clear
    echo -e "${CYAN}正在检查并更新 LinkProxy 到最新版本...${NC}"
    if [ ! -f "$WORK_DIR/$BINARY_NAME" ]; then
        if [ -n "$LEGACY_DIR" ] && [ -f "$LEGACY_DIR/MinerLink-Proxy-linux-amd64" ]; then
            echo -e "${YELLOW}-> 检测到历史老版本 MinerLink-Proxy: ${LEGACY_DIR}${NC}"
            echo -e "${GREEN}-> 正在自动平滑迁移数据库与配置至 LinkProxy 架构...${NC}"
            mkdir -p "$WORK_DIR"
            cd "$WORK_DIR" || exit 1
            if download_with_fallback linkproxy-linux-amd64-new.tar.gz "$DOWNLOAD_URL"; then
                systemctl stop minerlink-proxy >/dev/null 2>&1
                systemctl disable minerlink-proxy >/dev/null 2>&1
                mkdir -p "$WORK_DIR/data"
                if [ -f "$LEGACY_DIR/data/proxy.db" ]; then
                    cp -af "$LEGACY_DIR/data/proxy.db" "$WORK_DIR/data/proxy.db"
                    echo -e "${GREEN}✅ 历史矿池端口与钱包配置已无损继承 (data/proxy.db)！${NC}"
                fi
                if [ -f "$LEGACY_DIR/miner_proxy.db" ]; then
                    cp -af "$LEGACY_DIR/miner_proxy.db" "$WORK_DIR/miner_proxy.db"
                    [ ! -f "$WORK_DIR/data/proxy.db" ] && cp -af "$LEGACY_DIR/miner_proxy.db" "$WORK_DIR/data/proxy.db"
                    echo -e "${GREEN}✅ 历史矿池端口与钱包配置已无损继承 (miner_proxy.db)！${NC}"
                fi
                tar -zxf linkproxy-linux-amd64-new.tar.gz
                chmod +x "$BINARY_NAME"
                rm -f linkproxy-linux-amd64-new.tar.gz
                old_port="10010"
                if [ -f "/etc/systemd/system/minerlink-proxy.service" ]; then
                    _op=$(grep -oP '(?<=-api-port\s+)[0-9]+' "/etc/systemd/system/minerlink-proxy.service" 2>/dev/null)
                    [ -n "$_op" ] && old_port="$_op"
                fi
                cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=LinkProxy High Performance Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$WORK_DIR
ExecStart=$WORK_DIR/$BINARY_NAME -api-port $old_port
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
                systemctl daemon-reload
                systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
                systemctl start "$SERVICE_NAME" >/dev/null 2>&1
                cp -f "$0" /usr/local/bin/linkproxy 2>/dev/null && chmod +x /usr/local/bin/linkproxy 2>/dev/null
                ln -sf /usr/local/bin/linkproxy /usr/bin/linkproxy 2>/dev/null
                ln -sf /usr/local/bin/linkproxy /usr/local/bin/minerlink 2>/dev/null
                echo -e "${BOLD}${GREEN}==============================================${NC}"
                echo -e "${GREEN}🎉 老版本已成功平滑迁移升级至 LinkProxy 最新版！${NC}"
                echo -e "🚀 核心已平滑重启，历史配置与全部矿机端口已无缝恢复！"
                echo -e "${BOLD}${GREEN}==============================================${NC}"
                pause
                return 0
            else
                echo -e "${RED}❌ 下载最新更新包失败，请检查网络！${NC}"
                pause
                return 1
            fi
        fi
        echo -e "${RED}尚未检测到已安装的代理，请先执行安装！${NC}"
        pause
        return 1
    fi

    echo -e "-> 正在拉取最新版本核心包..."
    cd "$WORK_DIR" || exit 1
    if download_with_fallback linkproxy-linux-amd64-new.tar.gz "$DOWNLOAD_URL"; then
        systemctl stop "$SERVICE_NAME" >/dev/null 2>&1
        # Backup database
        if [ -f "miner_proxy.db" ]; then
            cp -f miner_proxy.db "miner_proxy.db.bak.$(date +%Y%m%d%H%M%S)"
        fi
        tar -zxf linkproxy-linux-amd64-new.tar.gz
        chmod +x "$BINARY_NAME"
        rm -f linkproxy-linux-amd64-new.tar.gz
        systemctl start "$SERVICE_NAME" >/dev/null 2>&1
        # 同步更新快捷管理脚本自身
        curl -fsSL "https://github.com/${GITHUB_REPO}/releases/latest/download/install.sh" -o /usr/local/bin/linkproxy 2>/dev/null && chmod +x /usr/local/bin/linkproxy 2>/dev/null
        ln -sf /usr/local/bin/linkproxy /usr/bin/linkproxy 2>/dev/null
        ln -sf /usr/local/bin/linkproxy /usr/local/bin/minerlink 2>/dev/null
        echo -e "${GREEN}✅ 更新成功，代理服务已平滑重启！${NC}"
    else
        echo -e "${RED}❌ 下载最新更新包失败，请检查网络！${NC}"
    fi
    pause
}

uninstall_proxy() {
    clear
    local confirm
    if [ "$ML_LANG" = "en" ]; then
        read_tty "Are you sure you want to uninstall LinkProxy? [y/N]: " confirm
    else
        read_tty "确定要卸载 LinkProxy 代理吗？[y/N]: " confirm
    fi
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消 / Cancelled."
        pause
        return
    fi

    systemctl stop "$SERVICE_NAME" >/dev/null 2>&1
    systemctl disable "$SERVICE_NAME" >/dev/null 2>&1
    rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
    systemctl daemon-reload

    local del_data
    if [ "$ML_LANG" = "en" ]; then
        read_tty "Do you want to delete all configuration and database files? [y/N]: " del_data
    else
        read_tty "是否同时删除所有配置与数据库文件($WORK_DIR)？[y/N]: " del_data
    fi
    if [ "$del_data" = "y" ] || [ "$del_data" = "Y" ]; then
        rm -rf "$WORK_DIR"
        echo "数据目录已清理。"
    fi

    rm -f /usr/local/bin/linkproxy /usr/bin/linkproxy /usr/local/bin/minerlink /usr/bin/minerlink 2>/dev/null
    echo -e "${GREEN}✅ 卸载完成。${NC}"
    pause
}

start_proxy() {
    systemctl start "$SERVICE_NAME" >/dev/null 2>&1
    sleep 1
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}✅ 代理服务已成功启动！${NC}"
    else
        echo -e "${RED}❌ 启动失败，请检查日志 (journalctl -u $SERVICE_NAME -n 20)${NC}"
    fi
    pause
}

stop_proxy() {
    systemctl stop "$SERVICE_NAME" >/dev/null 2>&1
    echo -e "${YELLOW}✅ 代理服务已停止。${NC}"
    pause
}

check_limits() {
    clear
    echo -e "${BOLD}${CYAN}========== Linux 连接数与句柄限制检查 ==========${NC}"
    echo -e "当前 Shell 最大文件描述符 (ulimit -n): ${GREEN}$(ulimit -n)${NC}"
    echo -e "系统级最大文件句柄数 (fs.file-max):    ${GREEN}$(cat /proc/sys/fs/file-max 2>/dev/null)${NC}"
    echo -e "TCP 全连接队列上限 (somaxconn):       ${GREEN}$(cat /proc/sys/net/core/somaxconn 2>/dev/null)${NC}"
    echo ""
    echo -e "limits.conf 配置项:"
    grep -E 'nofile' /etc/security/limits.conf 2>/dev/null || echo "  未找到自定义配置"
    echo -e "${BOLD}${CYAN}=================================================${NC}"
    pause
}

set_limits() {
    optimize_system
    echo -e "${GREEN}✅ 已将 Linux 最大连接数修改为 1048576 并完成内核参数注入！${NC}"
    echo -e "${YELLOW}提示：部分修改需要重新连接 SSH 或重启服务器方可对全局环境生效。${NC}"
    pause
}

enable_autostart() {
    systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
    echo -e "${GREEN}✅ 开机自启已成功启用！${NC}"
    pause
}

reset_admin() {
    clear
    local current_port
    current_port=$(get_web_port)
    local pub_ip
    pub_ip=$(get_public_ip)
    local db_file=""
    if [ -f "$WORK_DIR/data/proxy.db" ]; then
        db_file="$WORK_DIR/data/proxy.db"
    elif [ -f "$WORK_DIR/miner_proxy.db" ]; then
        db_file="$WORK_DIR/miner_proxy.db"
    elif [ -f "/root/linkproxy/data/proxy.db" ]; then
        db_file="/root/linkproxy/data/proxy.db"
    elif [ -f "/root/MinerLink-Proxy/data/proxy.db" ]; then
        db_file="/root/MinerLink-Proxy/data/proxy.db"
    fi

    local current_account="admin"
    local current_password="admin"

    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
        if command -v python3 >/dev/null 2>&1; then
            local queried
            queried=$(python3 -c "import sqlite3
try:
    c = sqlite3.connect('$db_file')
    r = c.cursor().execute('SELECT admin_account, admin_password FROM global_configs LIMIT 1').fetchone()
    if r:
        print((r[0] or 'admin') + '|||' + (r[1] or 'admin'))
except Exception:
    pass" 2>/dev/null)
            if [ -n "$queried" ]; then
                current_account="${queried%%|||*}"
                current_password="${queried##*|||}"
            fi
        elif command -v sqlite3 >/dev/null 2>&1; then
            local db_acc
            db_acc=$(sqlite3 "$db_file" "SELECT admin_account FROM global_configs LIMIT 1;" 2>/dev/null)
            [ -n "$db_acc" ] && current_account="$db_acc"
            local db_pwd
            db_pwd=$(sqlite3 "$db_file" "SELECT admin_password FROM global_configs LIMIT 1;" 2>/dev/null)
            [ -n "$db_pwd" ] && current_password="$db_pwd"
        fi
    fi

    if [ "$ML_LANG" = "en" ]; then
        echo -e "${BOLD}${CYAN}========== View or Reset Admin Password & Web Port ==========${NC}"
        echo -e "${BOLD}Current Web Console Configuration:${NC}"
        echo -e "  • Admin Username:  ${GREEN}${current_account}${NC}"
        echo -e "  • Admin Password:  ${GREEN}${current_password}${NC}"
        echo -e "  • Web Listen Port: ${GREEN}${current_port}${NC}"
        echo -e "  • Web Console URL: ${CYAN}http://${pub_ip}:${current_port}/ui/${NC}"
        echo -e "${BOLD}${CYAN}------------------------------------------------------------${NC}"
        echo -e "Available Actions:"
        echo -e "  ${CYAN}1.${NC} Reset / Modify Admin Password"
        echo -e "  ${CYAN}2.${NC} Modify Admin Username"
        echo -e "  ${CYAN}3.${NC} Change Web Console Port"
        echo -e "  ${CYAN}4.${NC} Restore Defaults (admin / admin / 10010)"
        echo -e "  ${CYAN}0.${NC} Return to Main Menu"
        echo ""
        local op_choice
        read_tty "Enter choice [0-4] (default 0): " op_choice
        op_choice=${op_choice:-0}

        case "$op_choice" in
            1)
                echo ""
                read_tty "Enter new admin password: " new_pass
                if [ -n "$new_pass" ]; then
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3, sys
con = sqlite3.connect('$db_file')
cur = con.cursor()
r = cur.execute('SELECT id FROM global_configs LIMIT 1').fetchone()
if r:
    cur.execute('UPDATE global_configs SET admin_password=? WHERE id=?', (sys.argv[1], r[0]))
else:
    cur.execute('INSERT INTO global_configs (admin_account, admin_password, web_port, enable_logging) VALUES (?, ?, ?, ?)', ('admin', sys.argv[1], 10010, 1))
con.commit()" "$new_pass" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            local esc_pass="${new_pass//\'/\'\'}"
                            sqlite3 "$db_file" "UPDATE global_configs SET admin_password='$esc_pass' WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ Password successfully updated to: ${new_pass}${NC}"
                else
                    echo -e "${RED}Input empty, cancelled.${NC}"
                fi
                pause
                ;;
            2)
                echo ""
                read_tty "Enter new admin username: " new_acc
                if [ -n "$new_acc" ]; then
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3, sys
con = sqlite3.connect('$db_file')
cur = con.cursor()
r = cur.execute('SELECT id FROM global_configs LIMIT 1').fetchone()
if r:
    cur.execute('UPDATE global_configs SET admin_account=? WHERE id=?', (sys.argv[1], r[0]))
else:
    cur.execute('INSERT INTO global_configs (admin_account, admin_password, web_port, enable_logging) VALUES (?, ?, ?, ?)', (sys.argv[1], 'admin', 10010, 1))
con.commit()" "$new_acc" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            local esc_acc="${new_acc//\'/\'\'}"
                            sqlite3 "$db_file" "UPDATE global_configs SET admin_account='$esc_acc' WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ Username successfully updated to: ${new_acc}${NC}"
                else
                    echo -e "${RED}Input empty, cancelled.${NC}"
                fi
                pause
                ;;
            3)
                echo ""
                read_tty "Enter new Web Console port (1-65535): " new_port
                if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1 ] && [ "$new_port" -le 65535 ]; then
                    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
                        sed -i "s/-api-port [0-9]*/-api-port $new_port/g" "/etc/systemd/system/${SERVICE_NAME}.service"
                    fi
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3
con = sqlite3.connect('$db_file')
con.cursor().execute('UPDATE global_configs SET web_port=? WHERE id=(SELECT id FROM global_configs LIMIT 1)', ($new_port,))
con.commit()" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            sqlite3 "$db_file" "UPDATE global_configs SET web_port=$new_port WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    if command -v ufw >/dev/null 2>&1; then
                        ufw allow "$new_port"/tcp >/dev/null 2>&1
                    elif command -v firewall-cmd >/dev/null 2>&1; then
                        firewall-cmd --zone=public --add-port="$new_port"/tcp --permanent >/dev/null 2>&1
                        firewall-cmd --reload >/dev/null 2>&1
                    fi
                    systemctl daemon-reload
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ Port updated to $new_port and service restarted!${NC}"
                    echo -e "New Console URL: ${CYAN}http://${pub_ip}:${new_port}/ui/${NC}"
                else
                    echo -e "${RED}Invalid port, cancelled.${NC}"
                fi
                pause
                ;;
            4)
                echo ""
                read_tty "Reset username and password to admin / admin? [y/N]: " confirm_reset
                if [ "$confirm_reset" = "y" ] || [ "$confirm_reset" = "Y" ]; then
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3
con = sqlite3.connect('$db_file')
con.cursor().execute('UPDATE global_configs SET admin_account=\"admin\", admin_password=\"admin\" WHERE id=(SELECT id FROM global_configs LIMIT 1)')
con.commit()" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            sqlite3 "$db_file" "UPDATE global_configs SET admin_account='admin', admin_password='admin' WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ Successfully restored default credentials (admin / admin)!${NC}"
                else
                    echo "Cancelled."
                fi
                pause
                ;;
            0|*)
                return
                ;;
        esac
    else
        echo -e "${BOLD}${CYAN}========== 查看或重置管理员密码与管理端口 ==========${NC}"
        echo -e "${BOLD}当前管理面板配置信息：${NC}"
        echo -e "  • 管理员账号:   ${GREEN}${current_account}${NC}"
        echo -e "  • 管理员密码:   ${GREEN}${current_password}${NC}"
        echo -e "  • 面板监听端口: ${GREEN}${current_port}${NC}"
        echo -e "  • 控制台访问地址: ${CYAN}http://${pub_ip}:${current_port}/ui/${NC}"
        echo -e "${BOLD}${CYAN}------------------------------------------------------------${NC}"
        echo -e "请选择操作："
        echo -e "  ${CYAN}1.${NC} 重置/修改管理员密码"
        echo -e "  ${CYAN}2.${NC} 修改管理员账号"
        echo -e "  ${CYAN}3.${NC} 修改管理面板端口"
        echo -e "  ${CYAN}4.${NC} 一键恢复默认设置 (admin / admin / 10010)"
        echo -e "  ${CYAN}0.${NC} 返回主菜单"
        echo ""
        local op_choice
        read_tty "请输入选项 [0-4] (默认 0): " op_choice
        op_choice=${op_choice:-0}

        case "$op_choice" in
            1)
                echo ""
                read_tty "请输入新的管理员密码: " new_pass
                if [ -n "$new_pass" ]; then
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3, sys
con = sqlite3.connect('$db_file')
cur = con.cursor()
r = cur.execute('SELECT id FROM global_configs LIMIT 1').fetchone()
if r:
    cur.execute('UPDATE global_configs SET admin_password=? WHERE id=?', (sys.argv[1], r[0]))
else:
    cur.execute('INSERT INTO global_configs (admin_account, admin_password, web_port, enable_logging) VALUES (?, ?, ?, ?)', ('admin', sys.argv[1], 10010, 1))
con.commit()" "$new_pass" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            local esc_pass="${new_pass//\'/\'\'}"
                            sqlite3 "$db_file" "UPDATE global_configs SET admin_password='$esc_pass' WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ 管理员密码已成功修改为: ${new_pass}${NC}"
                    echo -e "${YELLOW}提示：服务已安全重载生效，任何之前的密码错误 IP 锁定已同时自动解除。${NC}"
                else
                    echo -e "${RED}输入为空，取消修改。${NC}"
                fi
                pause
                ;;
            2)
                echo ""
                read_tty "请输入新的管理员账号: " new_acc
                if [ -n "$new_acc" ]; then
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3, sys
con = sqlite3.connect('$db_file')
cur = con.cursor()
r = cur.execute('SELECT id FROM global_configs LIMIT 1').fetchone()
if r:
    cur.execute('UPDATE global_configs SET admin_account=? WHERE id=?', (sys.argv[1], r[0]))
else:
    cur.execute('INSERT INTO global_configs (admin_account, admin_password, web_port, enable_logging) VALUES (?, ?, ?, ?)', (sys.argv[1], 'admin', 10010, 1))
con.commit()" "$new_acc" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            local esc_acc="${new_acc//\'/\'\'}"
                            sqlite3 "$db_file" "UPDATE global_configs SET admin_account='$esc_acc' WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ 管理员账号已成功修改为: ${new_acc}${NC}"
                else
                    echo -e "${RED}输入为空，取消修改。${NC}"
                fi
                pause
                ;;
            3)
                echo ""
                read_tty "请输入新的面板端口 (1-65535): " new_port
                if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1 ] && [ "$new_port" -le 65535 ]; then
                    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
                        sed -i "s/-api-port [0-9]*/-api-port $new_port/g" "/etc/systemd/system/${SERVICE_NAME}.service"
                    fi
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3
con = sqlite3.connect('$db_file')
con.cursor().execute('UPDATE global_configs SET web_port=? WHERE id=(SELECT id FROM global_configs LIMIT 1)', ($new_port,))
con.commit()" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            sqlite3 "$db_file" "UPDATE global_configs SET web_port=$new_port WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    if command -v ufw >/dev/null 2>&1; then
                        ufw allow "$new_port"/tcp >/dev/null 2>&1
                    elif command -v firewall-cmd >/dev/null 2>&1; then
                        firewall-cmd --zone=public --add-port="$new_port"/tcp --permanent >/dev/null 2>&1
                        firewall-cmd --reload >/dev/null 2>&1
                    fi
                    systemctl daemon-reload
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ 端口已更改为 $new_port 并重启服务！${NC}"
                    echo -e "新控制台地址: ${CYAN}http://${pub_ip}:${new_port}/ui/${NC}"
                else
                    echo -e "${RED}端口输入无效，已取消。${NC}"
                fi
                pause
                ;;
            4)
                echo ""
                read_tty "确认要将账号、密码恢复为默认 (admin / admin) 吗？[y/N]: " confirm_reset
                if [ "$confirm_reset" = "y" ] || [ "$confirm_reset" = "Y" ]; then
                    if [ -n "$db_file" ] && [ -f "$db_file" ]; then
                        if command -v python3 >/dev/null 2>&1; then
                            python3 -c "import sqlite3
con = sqlite3.connect('$db_file')
con.cursor().execute('UPDATE global_configs SET admin_account=\"admin\", admin_password=\"admin\" WHERE id=(SELECT id FROM global_configs LIMIT 1)')
con.commit()" 2>/dev/null
                        elif command -v sqlite3 >/dev/null 2>&1; then
                            sqlite3 "$db_file" "UPDATE global_configs SET admin_account='admin', admin_password='admin' WHERE id=(SELECT id FROM global_configs LIMIT 1);" 2>/dev/null
                        fi
                    fi
                    systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
                    echo -e "${GREEN}✅ 已成功恢复默认：账号 admin，密码 admin！${NC}"
                else
                    echo "已取消。"
                fi
                pause
                ;;
            0|*)
                return
                ;;
        esac
    fi
}

show_status() {
    clear
    echo -e "${BOLD}${CYAN}========== LinkProxy 运行状态 ==========${NC}"
    local status_line
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        status_line="${GREEN}运行中 (Active / Running)${NC}"
    else
        status_line="${RED}未运行 (Inactive / Stopped)${NC}"
    fi
    echo -e "服务状态: $status_line"
    echo -e "Web 访问: ${CYAN}http://$(get_public_ip):$(get_web_port)/ui/${NC}"
    echo -e "工作目录: $WORK_DIR"
    echo ""
    echo -e "${BOLD}监听端口信息:${NC}"
    if command -v ss >/dev/null 2>&1; then
        ss -tulpn | grep -E "(linkproxy|MinerLink|$(get_web_port))" || echo "  未检测到活跃监听"
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulpn | grep -E "(linkproxy|MinerLink|$(get_web_port))" || echo "  未检测到活跃监听"
    fi
    echo ""
    echo -e "${BOLD}最近 5 条运行日志:${NC}"
    journalctl -u "$SERVICE_NAME" -n 5 --no-pager 2>/dev/null || echo "  无日志"
    echo -e "${BOLD}${CYAN}==============================================${NC}"
    pause
}

clean_logs() {
    echo -e "${CYAN}正在清理日志缓存...${NC}"
    journalctl --vacuum-time=1d >/dev/null 2>&1
    find "$WORK_DIR" -name "*.log" -type f -delete 2>/dev/null
    echo -e "${GREEN}✅ 运行日志已清空！${NC}"
    pause
}

# Main Loop
select_language

while true; do
    show_menu
    case "$choice" in
        0)
            echo "Goodbye!"
            exit 0
            ;;
        1)
            install_proxy
            ;;
        2)
            update_proxy
            ;;
        3)
            uninstall_proxy
            ;;
        4)
            start_proxy
            ;;
        5)
            stop_proxy
            ;;
        6)
            check_limits
            ;;
        7)
            set_limits
            ;;
        8)
            enable_autostart
            ;;
        9)
            reset_admin
            ;;
        10)
            show_status
            ;;
        11)
            clean_logs
            ;;
        *)
            echo -e "${RED}输入错误，请输入 0-11 之间的数字！${NC}"
            sleep 1
            ;;
    esac
done
