@echo off
:: IDEA Git-Trace 方案配置工具
::
:: 使用 Git 自带的 GIT_TRACE 机制记录所有 git 命令
:: 无需 wrapper，不干扰 git 操作
::
:: 使用方法:
::   1. 运行本脚本
::   2. 在 IDEA 中移除 wrapper 设置，恢复为 git.exe
::   3. 重启 IDEA

setlocal enabledelayedexpansion

set "TRACE_DIR=%USERPROFILE%\.git-wrapper-logs"
set "TRACE_FILE=%TRACE_DIR%\git-trace.log"
set "PERF_FILE=%TRACE_DIR%\git-perf.log"

echo ============================================
echo   Git Trace 方案 - 替代 Wrapper
echo ============================================
echo.
echo 原理: Git 原生支持 GIT_TRACE 环境变量，
echo 无需 wrapper 脚本，无兼容性问题。
echo.
echo 日志目录: %TRACE_DIR%
echo.

:: 创建日志目录
if not exist "%TRACE_DIR%" mkdir "%TRACE_DIR%"

:: 测试日志写入
echo Test entry at %DATE% %TIME% > "%TRACE_FILE%"
echo Test entry at %DATE% %TIME% > "%PERF_FILE%"

echo Steps:
echo  1. 恢复 IDEA Git 设置为默认 git.exe
echo  2. 在 IDEA 中配置环境变量:
echo     GIT_TRACE=%TRACE_FILE%
echo     GIT_TRACE_PERFORMANCE=%PERF_FILE%
echo.
echo  手动配置方法:
echo    IDEA → Settings → Tools → Terminal → 
echo    Environment variables 中添加:
echo.
echo    GIT_TRACE=%TRACE_FILE%;GIT_TRACE_PERFORMANCE=%PERF_FILE%
echo.
echo  或者在系统环境变量中设置（需重启 IDEA）:
echo    setx GIT_TRACE "%TRACE_FILE%"
echo    setx GIT_TRACE_PERFORMANCE "%PERF_FILE%"
echo.
echo  IDEA 中恢复 git 设置:
echo    Settings → Version Control → Git →
echo    Path to Git executable: 改回 git.exe
echo.
pause
