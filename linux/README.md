# LinkProxy Linux 运维与服务管理手册

本目录包含适用于 Linux 环境的标准 Systemd 服务模板与运维升级脚本。

---

## 常用服务管理命令

系统安装后，LinkProxy 默认注册为标准 systemd 守护进程 `linkproxy.service`：

```bash
# 查看实时运行状态
systemctl status linkproxy

# 启动服务
systemctl start linkproxy

# 停止服务
systemctl stop linkproxy

# 重启服务
systemctl restart linkproxy

# 查看实时滚动运行日志
journalctl -u linkproxy -f --no-tail

# 查看最近 100 行日志
journalctl -u linkproxy -n 100
```

---

## 目录说明

* 程序安装路径：`/root/linkproxy/`
* 主配置文件 / 数据库：`/root/linkproxy/data.db`
* 备份归档路径：`/root/linkproxy/backup/`
* 服务配置文件：`/etc/systemd/system/linkproxy.service`
* 终端快捷指令：`/usr/local/bin/linkproxy`（终端直接输入 `linkproxy` 唤出交互式管理菜单）

---

## 一键无感平滑升级

在已安装的主机上，可直接运行本目录提供的 `update.sh` 或通过交互菜单选择升级：

```bash
bash /root/linkproxy/linux/update.sh
```
脚本会自动备份当前数据库与二进制，拉取最新 Release，替换并热重启服务；若启动失败将自动回滚。
