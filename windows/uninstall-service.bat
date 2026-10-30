@echo off
chcp 65001 >nul
title LinkProxy - 卸载后台开机自启服务

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 请右键选择“以管理员身份运行”此脚本！
    pause
    exit /b 1
)

set TASK_NAME=LinkProxy_AutoStart

echo 正在停止并删除计划任务 (%TASK_NAME%)...
schtasks /end /tn "%TASK_NAME%" >nul 2>&1
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

echo 正在结束正在运行的 LinkProxy 进程...
taskkill /f /im linkproxy-windows-amd64.exe >nul 2>&1
taskkill /f /im linkproxy.exe >nul 2>&1

echo.
echo ======================================================
echo  [成功] LinkProxy 开机自启服务已完全卸载并清理进程。
echo ======================================================
echo.
pause
