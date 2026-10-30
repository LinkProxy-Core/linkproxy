# LinkProxy Windows 运行与部署指南

本目录包含适用于 Windows 64 位（Windows 10 / 11 / Windows Server 2016+）环境的启动脚本与后台服务安装工具。

---

## 快速上手

### 1. 下载程序
从 [GitHub Releases](https://github.com/LinkProxy-Core/linkproxy/releases/latest) 下载 `linkproxy-windows-amd64.zip`，并解压到任意目录（例如 `D:\LinkProxy`）。

### 2. 方式 A：前台窗口运行（调试推荐）
双击运行 `start.bat`，程序将在控制台窗口中启动，并显示实时网络日志。
* 管理后台地址：`http://127.0.0.1:10010/ui/`
* 默认用户名：`admin`
* 默认密码：`admin`

### 3. 方式 B：后台静默运行（开机自启，生产推荐）
右键点击 `install-service.bat`，选择 **以管理员身份运行**。
* 脚本将自动注册 Windows 高权限系统级自启计划任务，并在每次电脑开机时在后台静默运行，无需人工登录桌面。
* 即使窗口关闭或服务器重启，中转服务也会持续稳定运行。

### 4. 停止与卸载服务
如需停止服务或彻底清理，请右键管理员运行 `uninstall-service.bat` 即可。

---

## 防火墙与端口放行

若局域网内其他矿机需要连接本机的代理端口（例如 `8888`、`3333`、`5555`）：
1. 打开 Windows Defender 防火墙 -> 高级设置。
2. 在“入站规则”中新建规则 -> 选择“端口” -> TCP -> 填入开放的端口号。
3. 允许连接并保存。
