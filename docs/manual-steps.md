# 手动操作清单：HarmonyOS 与 Android

## HarmonyOS 仅首次安装需要

- [ ] 手机开启开发者模式。
- [ ] 开启 USB 调试并授权电脑。
- [ ] USB 模式选择“传输文件”。
- [ ] 安装本地签名 HAP。
- [ ] 在应用内登录同一 Tailscale 账号。
- [ ] 接受系统 VPN 创建授权。

## Android 仅首次安装需要

- [ ] 在 Windows 和 Android 安装官方 Tailscale。
- [ ] 两台设备登录使用者自己的同一个 Tailscale 账号。
- [ ] Android 接受系统 VPN 创建授权。
- [ ] 允许 Tailscale 使用移动数据和后台活动。
- [ ] 测试期间关闭其他 VPN、代理或网络加速器。
- [ ] Android 不需要 HAP、DevEco Studio、USB 调试或数据线。

## 每次远程使用需要

- [ ] 电脑开机且未休眠。
- [ ] DeepSeek Harness 正在运行。
- [ ] Windows Tailscale 在线。
- [ ] 手机 Tailscale VPN 显示已连接。
- [ ] 打开当前 Serve 地址。
- [ ] 选择原工作区和原会话。
- [ ] 先发送短消息验证电脑端同步，再执行实际任务。

## 不要做的事

- 不要卸载应用或清除应用数据来解决网页加载问题。
- 不要移动或重命名原 Harness 工作区。
- 不要启用 Funnel 或公网端口。
- 不要把 API Key、Tailscale 登录链接或签名文件发到 GitHub。
- 不要让其他使用者登录仓库作者的 Tailscale 账号；每个人建立自己的 tailnet。
- 不要在 Android 同时运行另一个 VPN。
