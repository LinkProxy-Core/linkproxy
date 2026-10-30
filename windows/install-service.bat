@echo off
chcp 65001 >nul
title LinkProxy - 安装后台开机自启服务

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 请右键选择“以管理员身份运行”此脚本！
    pause
    exit /b 1
)

set SERVICE_NAME=LinkProxyService
set TASK_NAME=LinkProxy_AutoStart
set CURRENT_DIR=%~dp0

set EXE_PATH=
if exist "%CURRENT_DIR%linkproxy-windows-amd64.exe" set EXE_PATH=%CURRENT_DIR%linkproxy-windows-amd64.exe
if exist "%CURRENT_DIR%linkproxy.exe" set EXE_PATH=%CURRENT_DIR%linkproxy.exe
if exist "%CURRENT_DIR%..\linkproxy-windows-amd64.exe" set EXE_PATH=%CURRENT_DIR%..\linkproxy-windows-amd64.exe

if "%EXE_PATH%"=="" (
    echo [错误] 未找到可执行文件 linkproxy-windows-amd64.exe！
    echo 请确认程序文件位于当前目录或上级目录。
    pause
    exit /b 1
)

echo 目标可执行文件: %EXE_PATH%
echo 正在创建系统级开机自启计划任务 (%TASK_NAME%)...

schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
schtasks /create /tn "%TASK_NAME%" /tr "\"%EXE_PATH%\"" /sc onstart /ru "SYSTEM" /rl HIGHEST /f

if %errorLevel% equ 0 (
    echo.
    echo ======================================================
    echo  [成功] LinkProxy 开机自启服务已创建！
    echo  系统将在每次开机时自动以 SYSTEM 权限在后台静默运行。
    echo ======================================================
    echo.
    echo 正在立即启动任务...
    schtasks /run /tn "%TASK_NAME%"
    echo 已发送启动指令。请在浏览器访问: http://127.0.0.1:10010/ui/
) else (
    echo [失败] 创建计划任务失败，错误码: %errorLevel%
)

echo.
pause
