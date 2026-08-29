# 安卓手机远程控制 DeepSeek Harness

本指南适用于普通 Android 手机连接使用者自己的 Windows 电脑。安卓端使用
官方 Tailscale，不需要编译或安装本仓库的 HarmonyOS HAP，也不需要 USB。

## 安全模型

每位使用者必须建立自己的 Tailscale tailnet，并让自己的电脑和安卓手机登录
同一个账号。不要使用仓库作者的账号、机器地址、邀请链接或认证密钥。

```text
Android Edge / Chrome
  -> official Tailscale Android VPN
  -> the user's private encrypted tailnet
  -> Windows Tailscale Serve (tailnet only)
  -> http://127.0.0.1:3080
  -> the user's DeepSeek Harness
```

## 准备条件

### Windows 电脑

- DeepSeek Harness 已安装，电脑浏览器能打开 `http://127.0.0.1:3080/`。
- 原工作区、会话和凭据仍保存在电脑上。
- 电脑可以安装并登录 Tailscale。
- 使用期间电脑保持开机、唤醒，Harness 和 Tailscale 均在运行。

### 安卓手机

- 建议 Android 8 或更高版本。
- 安装官方 Tailscale，以及 Edge 或 Chrome。
- 允许 Tailscale 创建系统 VPN、使用移动数据并在后台运行。
- 测试时关闭其他 VPN、代理、加速器或会占用 VPN 槽位的应用。

## 第一次安装

### 1. 验证电脑本地 Harness

在电脑浏览器打开：

```text
http://127.0.0.1:3080/
```

必须先确认原工作区和会话正常。这里打不开时，不要继续配置远程访问。

### 2. 安装并登录 Windows Tailscale

从 [Tailscale Windows 下载页](https://tailscale.com/download/windows) 安装。
登录使用者自己的账号，确认 Windows 节点显示在线。

### 3. 启用 tailnet-only HTTPS

以管理员身份打开 PowerShell，在本仓库目录运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\enable-tailscale-harness-https.ps1"
```

成功输出必须包含：

```text
RESULT=SUCCESS
(tailnet only)
proxy http://127.0.0.1:3080
DNSName=<computer>.<tailnet>.ts.net.
```

手机地址为 `https://<computer>.<tailnet>.ts.net/`。复制时去掉 DNSName 最后的
句点。禁止启用 Funnel，也不要在路由器上公开映射端口 3080。

### 4. 运行电脑自动检测

检测脚本只读取状态，不修改任何配置。请在管理员 PowerShell 中运行，以便读取
Windows Tailscale 服务状态：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test-windows-readiness.ps1"
```

理想结果是：

```text
RESULT=READY
```

出现 `RESULT=NEEDS_ADMIN` 时，改用管理员 PowerShell 再运行一次。出现
`RESULT=NOT_READY` 时，根据表格中的 `FAIL` 项修复，不要忽略后直接测试手机。

### 5. 安装并登录安卓 Tailscale

1. 从 [Tailscale Android 下载页](https://tailscale.com/download/android) 安装官方应用。
2. 使用与 Windows 电脑完全相同的账号登录。
3. 点击连接，并允许 Android 创建 VPN。
4. 等待应用显示已连接，状态栏出现 VPN 标识。
5. 在系统电池设置中允许 Tailscale 后台运行；若系统提供“不受限制”，可在
   排障时临时选择。

### 6. 用浏览器打开 Harness

1. 打开 Edge 或 Chrome。
2. 输入电脑脚本输出的 `https://...ts.net/` 地址。
3. 首次加载预留约一分钟，不要连续刷新。
4. 选择电脑原来的工作区和会话。
5. 发送一条短消息，确认电脑端出现同步消息并收到回复。

## 验收远程能力

完成一次移动数据测试：

1. 安卓手机关闭 Wi-Fi，使用移动数据。
2. 保持 Tailscale 已连接。
3. 重新打开 HTTPS 地址。
4. 发送 `ANDROID_REMOTE_OK`。
5. 确认电脑端同一会话出现消息和回复。

只有完成消息往返，才证明手机能够远程控制 Harness。仅显示“VPN 已连接”或
仅打开首页都不算完整验收。

完整清单见 [安装验收清单](installation-checklist.zh.md)。

## 日常使用

1. 唤醒电脑并启动 DeepSeek Harness。
2. 确认 Windows Tailscale 在线。
3. 安卓手机连接 Tailscale。
4. 用浏览器打开已保存的 HTTPS 地址。

日常使用不需要 USB，也不要求手机和电脑连接同一个 Wi-Fi。

## 安卓常见问题

### Tailscale 无法连接

- 关闭其他 VPN、代理和网络加速器；Android 通常同时只能启用一个 VPN。
- 允许 Tailscale 使用移动数据、后台数据和后台活动。
- 断开 Tailscale，等待 5 秒，再连接一次。

### 锁屏后连接消失

在系统的应用电池管理中允许 Tailscale 后台运行，并避免一键清理该应用。不同
手机厂商的菜单名称可能是“应用启动管理”“电池优化”或“后台活动”。

### HTTPS 地址无法解析

确认手机和电脑登录的是同一 Tailscale 账号，并先在 Tailscale 应用中确认电脑
节点可见。临时关闭会接管 DNS 的广告拦截器、私人 DNS 或第三方 VPN 后重试。

### 页面出现 403 或 Host 错误

把当前 `*.ts.net` 主机名加入 Harness 的 `trustedHosts` 配置，并完全退出后重新
启动 Harness。`trustedHosts` 不是登录认证，不能替代 Tailscale 权限。

### 页面加载很久或历史记录失败

首次加载等待约一分钟；超过两分钟后关闭当前标签页，再打开一次。长会话可能
超过手机浏览器的内存能力，电脑端完整历史仍然保留，不要删除 `DSH_HOME`。

## 分享本方案

可以公开分享本仓库。其他人应复制操作方法，建立自己的账号和私网，连接自己
的电脑。不要分享任何真实 Tailscale IP、机器名、登录二维码、认证密钥、API Key、
聊天记录或签名材料。
