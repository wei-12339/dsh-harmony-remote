# DeepSeek Harness 鸿蒙手机远程控制

> [English](README.md)

这是一个针对华为 Mate 80（纯血鸿蒙）的实操说明：手机通过私有
Tailscale 网络访问 Windows 电脑上已经运行的 DeepSeek Harness。工作区、
原会话、聊天记录、模型和文件仍保存在电脑上，手机只是远程浏览器和 VPN
客户端。

本仓库是说明和运维文档，不包含 DeepSeek Harness、Tailscale、DevEco Studio
的重新分发包，也不包含任何 API Key、登录令牌、节点私钥、签名证书、聊天
记录或个人电脑路径。

## 最终效果

- 手机使用 Wi-Fi 或移动数据均可访问电脑上的 Harness。
- 不需要 USB 线保持连接。
- 不需要手机和电脑处于同一个 Wi-Fi。
- 原来的 Windows 工作区和会话不迁移、不清空、不重建。
- 只有同一 Tailscale tailnet 中的设备可以访问。

## 工作原理

```text
Mate 80 Edge/系统浏览器
  -> 鸿蒙 Tailscale VPN Extension
  -> 加密 Tailscale 私网
  -> Windows Tailscale Serve（tailnet only）
  -> 127.0.0.1:3080
  -> 电脑原有 DeepSeek Harness
```

Tailscale Serve 只是把电脑本机的 `127.0.0.1:3080` 代理到私网，不能把
它当成登录认证。必须保持 `tailnet only`，禁止 Funnel，禁止公网端口映射。

## 需要准备什么

### 电脑

- Windows 已安装并能正常打开 DeepSeek Harness。
- Harness 使用的原工作区仍在电脑本地，例如：
  `C:\Users\<用户名>\Desktop\影视剧风`。
- Tailscale Windows 客户端已安装，并登录与你手机相同的账号。
- 电脑不能关机或休眠；Harness 和 Tailscale 服务必须运行。

### 手机

- 华为 Mate 80，已安装本项目对应的本地签名应用。
- 手机 Tailscale 登录与电脑相同的账号。
- 首次安装、覆盖安装或调试时需要 USB 调试；日常使用不需要 USB。

### 构建者额外准备

- DevEco Studio。
- HarmonyOS SDK 6.1.0（API 23，含 Native SDK）。
- 华为开发者账号和本地自动签名配置。

## 第一次部署：哪些必须手动操作

以下动作必须由手机使用者确认，自动脚本不能代替系统授权：

1. 在 Mate 80 开启开发者模式和 USB 调试。
2. USB 连接电脑，选择“传输文件”，并在手机上授权这台电脑调试。
3. 首次安装应用时确认 HarmonyOS 安装和 VPN 权限提示。
4. 在应用内登录 Tailscale，并在系统弹窗中允许创建 VPN 连接。
5. 用手机浏览器第一次打开远程地址时，按浏览器提示继续操作。
6. 在 Harness 页面选择原工作区和原会话。

安装完成并验证页面可访问后，可以拔掉 USB。拔线不会删除应用数据，也不会
影响电脑上的会话记录。

## 电脑端操作

### 1. 启动原 Harness

先在电脑桌面打开原来的 DeepSeek Harness，确认已有工作区和会话在电脑浏览器
中正常显示。不要为了远程控制而新建工作区或迁移 `C:\Users\...` 数据。

### 2. 启动 Tailscale Serve

在管理员 PowerShell 运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\enable-tailscale-harness-https.ps1"
```

输出中会出现 `TailscaleServeStatus`、`DNSName` 和 `TailscaleIP`。记录当前
`TailscaleIP`；它可能在设备重建或重新登录后变化。

确认输出包含：

```text
(tailnet only)
proxy http://127.0.0.1:3080
```

不要运行 `tailscale funnel`，不要把 `tailnet only` 改成公网模式。

### 3. 检查可信主机

如果页面能打开但 API 返回 403，说明 Harness 的 trusted-host 白名单没有
包含 Serve 的主机名。把当前 Serve 主机名加入 Harness 的 web 配置后，完全
退出并重新打开 Harness。此项是 DNS-rebinding 防护，不是登录认证。

## 手机端操作

1. 打开“DeepSeek 私网遥控”。
2. 登录与电脑相同的 Tailscale 账号。
3. 点击连接，允许系统创建 VPN；顶部出现 VPN 图标后等待约 10 秒。
4. 首选打开 Serve 输出的 `https://<机器名>.<tailnet>.ts.net/`。
5. 如果出现 `DNS_PROBE_FINISHED_NXDOMAIN`，这是当前测试 tailnet 的
   MagicDNS 兼容性限制。改用电脑 Tailscale IPv4：

   ```text
   http://100.x.y.z:3080/
   ```

   用电脑当前 `tailscale status` 显示的地址替换 `100.x.y.z`。
6. 页面加载后选择原工作区，进入原来的会话。
7. 发送短消息验证链路；电脑上的 Harness 应该同步出现该消息并执行。

## 已知兼容性处理

### Harmony 浏览器提示 `crypto.randomUUID is not a function`

某些鸿蒙浏览器在 HTTP 私网 IP 页面上没有 `crypto.randomUUID()`。本方案的
网页客户端已加入 `getRandomValues()`/本地 UUID 回退；如果仍看到错误，关闭
页面、清除该 IP 地址的站点数据，再重新打开。

### 历史加载失败 / `The user aborted a request`

长会话包含大量逐字 token 事件，手机一次性解析可能超过内存或触发请求中止。
方案先加载少量最近消息，完整历史仍保存在电脑端；不要清除 Harness 数据。

## 日常使用

- 电脑保持开机、唤醒，Harness 和 Tailscale 保持运行。
- 手机打开 Tailscale VPN 后，用 Edge 访问当前私网地址。
- 不需要 USB，不需要同一 Wi-Fi。
- 手机锁屏后若 VPN 被系统暂停，重新打开应用并连接即可。
- 电脑 Tailscale IP 或 Serve 主机名变化时，以 `tailscale status` 和
  `tailscale serve status` 的新输出为准。

## 安全边界

- 访问范围是同一 tailnet，不是互联网公开网站。
- 不启用 Funnel，不做端口转发，不分享带个人机器名的地址到公开场合。
- trusted-host 不是身份认证；Tailscale 账号、ACL 和设备安全仍然重要。
- 不要把 `DSH_HOME`、`.credentials.yaml`、API Key、HAP 签名文件、私钥、
  手机截图和聊天日志提交到 GitHub。
- 共享本仓库时，别人只能看到操作方法，不能因此访问你的电脑 Harness。

## 目录

```text
dsh-harmony-remote/
├── README.md
├── README.zh.md
├── docs/
│   ├── architecture.md
│   ├── manual-steps.md
│   ├── security.md
│   └── troubleshooting.md
└── scripts/
    └── enable-tailscale-harness-https.ps1
```

