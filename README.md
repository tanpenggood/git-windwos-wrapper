# Git Windows Wrapper

`git.exe` 命令包装器，用于拦截 IDEA (包括 GitToolbox 插件) 执行的所有 Git 命令，并记录执行时间、耗时等信息。

使用 PowerShell 实现，避免 batch 脚本的 `%` 变量展开、时间解析等问题。

## 文件说明

```
git-windwos-wrapper/
├── git-wrapper.bat           # 启动器 (调用 PowerShell 脚本)
├── git-wrapper.ps1           # 核心 PowerShell 包装脚本
├── git-wrapper-config.ps1    # PowerShell 配置文件
├── log-viewer.bat            # 日志查看器
├── setup-idea.bat            # IDEA 集成安装脚本
├── setup-git-trace.bat       # Git Trace 替代方案
└── README.md
```

## 快速开始

### 1. 安装

运行安装脚本自动配置 IDEA:

```cmd
setup-idea.bat
```

或手动配置:
1. 打开 IDEA → Settings → Version Control → Git
2. 将 "Path to Git executable" 设置为 `git-wrapper.bat` 的完整路径
3. 点击 Test 验证 (应显示 git 版本号)
4. 点击 Apply → OK

### 2. 使用

配置完成后，IDEA 执行的所有 Git 命令会被自动记录到:

```
%USERPROFILE%\.git-wrapper-logs\git-commands.log
```

(日志在项目目录外，避免触发 IDEA 的文件监听反馈循环)

### 3. 查看日志

运行日志查看器:
```cmd
log-viewer.bat
```

### 日志格式

```csv
"2026-01-15 10:30:45","C:\project","git branch",125ms,0
```

字段: 时间戳 | 工作目录 | 命令 | 耗时 | 退出码

## 配置

编辑 `git-wrapper-config.ps1`:

```powershell
# 启用/禁用日志
$global:GIT_WRAPPER_ENABLED = $true

# 日志目录 (必须在项目目录外)
$global:GIT_WRAPPER_LOG_DIR = Join-Path $env:USERPROFILE ".git-wrapper-logs"

# Git 可执行文件路径
$global:GIT_WRAPPER_REAL_GIT = "git.exe"
```

## 日志查看器功能

| 选项 | 功能 |
|------|------|
| 1. View all logs | 显示最后 50 条记录 |
| 2. View slow commands | 筛选耗时超过 1000ms 的命令 |
| 3. Search | 按关键字搜索 |
| 4. Statistics | 命令频率、平均/最大耗时统计 |
| 5. Live tail | 实时监控新命令 (Ctrl+C 退出) |
| 6. Clear logs | 清空日志 |

## 常见问题

### 找不到日志文件
日志在 `%USERPROFILE%\.git-wrapper-logs\git-commands.log`

### 需要恢复原生 Git
IDEA 设置中将 Git executable 改回 `git.exe` 或留空

### 日志增长过快
删除或清空日志文件即可，不会影响 git 功能

## 技术实现

基于 PowerShell 的 Git 包装器，相比 batch 版本的改进:

- ✅ 正确处理 `%` 格式化字符串 (如 `--pretty=format:"%H%P%s"`)
- ✅ 准确的时间计算 (PowerShell `TimeSpan.TotalMilliseconds`)
- ✅ 日志在项目目录外 (无反馈循环)
- ✅ 更好的错误处理和重试机制
- ✅ 无 console flash
