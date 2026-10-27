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
SCRIPT_VERSION="6.2.1"
SOFTWARE_VERSION="v2.2.138"

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
        echo -e "${CYAN}9.${NC} Reset Admin Password & Web Port"
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
        echo -e "${CYAN}9.${NC} 重置管理员密码与管理端口"
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
    if wget -q --timeout=30 -O linkproxy-linux-amd64.tar.gz "$DOWNLOAD_URL"; then
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
        echo -e "Web Console URL: ${CYAN}http://${pub_ip}:${current_port}/ui/${NC}"
        echo -e "Command shortcut: Type ${GREEN}linkproxy${NC} anytime to manage."
    else
        echo -e "${GREEN}🎉 安装部署圆满完成！${NC}"
        echo -e "🚀 控制台访问地址: ${CYAN}http://${pub_ip}:${current_port}/ui/${NC}"
        echo -e "💡 快捷管理命令: 以后在终端随时输入 ${GREEN}linkproxy${NC} 即可打开本控制台"
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
            if wget -q --timeout=30 -O linkproxy-linux-amd64-new.tar.gz "$DOWNLOAD_URL"; then
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
    if wget -q --timeout=30 -O linkproxy-linux-amd64-new.tar.gz "$DOWNLOAD_URL"; then
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
    echo -e "${BOLD}${CYAN}========== 重置面板端口与登录状态 ==========${NC}"
    local current_port
    current_port=$(get_web_port)
    echo -e "当前面板端口为: ${GREEN}${current_port}${NC}"
    echo ""
    read_tty "是否需要修改面板监听端口？[y/N]: " change_p
    if [ "$change_p" = "y" ] || [ "$change_p" = "Y" ]; then
        read_tty "请输入新的面板端口 (1-65535): " new_port
        if [[ "$new_port" =~ ^[0-9]+$ ]] && [ "$new_port" -ge 1 ] && [ "$new_port" -le 65535 ]; then
            sed -i "s/-api-port [0-9]*/-api-port $new_port/g" "/etc/systemd/system/${SERVICE_NAME}.service"
            systemctl daemon-reload
            systemctl restart "$SERVICE_NAME" >/dev/null 2>&1
            echo -e "${GREEN}✅ 端口已更改为 $new_port 并重启服务！${NC}"
        else
            echo -e "${RED}端口输入无效，已取消。${NC}"
        fi
    fi
    echo ""
    echo -e "若需重置管理员账密，代理在无初始管理员时会自动进入开放注册状态，"
    echo -e "您可通过浏览器直接访问: ${CYAN}http://$(get_public_ip):$(get_web_port)/ui/${NC}"
    pause
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
