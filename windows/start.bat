@echo off
chcp 65001 >nul
title LinkProxy 控制台网关服务

echo ======================================================
echo    LinkProxy 高并发 Stratum / EthProxy 代理服务
echo ======================================================
echo.
echo 正在启动 LinkProxy 服务...
echo 启动成功后，请在浏览器中访问: http://127.0.0.1:10010/ui/
echo 默认账号: admin
echo 默认密码: admin
echo.
echo [提示] 如需作为后台开机自启服务运行，请右键管理员执行 install-service.bat
echo ======================================================
echo.

if exist "linkproxy-windows-amd64.exe" (
    linkproxy-windows-amd64.exe -api-port 10010
) else if exist "linkproxy.exe" (
    linkproxy.exe -api-port 10010
) else (
    echo [错误] 未在当前目录下找到 linkproxy-windows-amd64.exe!
    echo 请先从 GitHub Releases 下载 Windows 成品解压至本目录。
    pause
)
