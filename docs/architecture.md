# 架构与数据流

本文描述当前已经验证的 `Legacy Bridge Mode`。产品化目标架构、设备配对、网关
和版本协议见 [V1 系统架构](product/system-architecture-v1.zh.md)。未来默认链路
将由 Tailscale Serve 代理本地安全网关，再由网关访问 Harness；本文的直连链路
继续作为兼容和排障模式。

## 组件

| 组件 | 作用 | 是否保存会话 |
|---|---|---|
| Mate 80 HarmonyOS 应用 | 登录 Tailscale、创建 VPN、持久化后端状态 | 不保存 Harness 会话 |
| 官方 Tailscale Android 应用 | 登录使用者自己的 tailnet、创建 Android VPN | 不保存 Harness 会话 |
| HarmonyOS/Android 浏览器 | 显示 Harness 页面、发送用户操作 | 浏览器缓存可能保存页面状态 |
| Tailscale tailnet | 加密连接手机和电脑 | 不负责 Harness 会话 |
| Windows Tailscale Serve | 将私网请求代理到 `127.0.0.1:3080` | 不改变会话 |
| DeepSeek Harness | 执行模型、工具、文件操作并保存会话 | 是，仍在电脑上 |

## 请求路径

1. 手机浏览器请求 tailnet HTTPS 地址。
2. HarmonyOS VPN Extension 或官方 Android Tailscale VPN 承载私网数据包。
3. Tailscale 加密传输到 Windows 节点。
4. Windows Serve 反向代理到 Harness 本机监听器。
5. Harness 使用原来的 `DSH_HOME`、工作区和会话存储响应。

## 为什么 USB 可以拔掉

USB 只承载安装、调试和 HDC 通道。真正的远程流量走 Tailscale VPN；只要
手机 VPN 已连接、电脑在线，USB 不参与数据路径。

Android 使用官方 Tailscale，不存在 HAP 安装或 HDC 调试步骤，从第一次使用起
就不需要 USB。

## 地址选择

- 首选：Serve 输出的 HTTPS `ts.net` 主机名。
- HarmonyOS 回退：仅在当前部署已让 3080 监听 Tailscale 地址时，使用电脑当前
  Tailscale IPv4 加 `:3080`。Android 应优先修复同账号、MagicDNS、私人 DNS 或
  其他 VPN 冲突，并继续使用 HTTPS Serve 主机名。

## 多用户隔离

本项目不是中心服务器。每位使用者应复制仓库中的方法，在自己的 Windows 和
手机上登录自己的 tailnet。公开仓库不保存设备注册信息，也不会把不同使用者的
Harness、工作区或聊天记录连接在一起。

## 产品化迁移方向

```text
当前兼容模式：phone -> Serve -> Harness:3080
未来默认模式：phone -> Serve -> Gateway:3081 -> Harness:3080
```

本地安全网关负责独立设备认证、工作区策略、审计、幂等、诊断和紧急暂停。
Tailscale 仍然只承担私网加密传输，不替代产品身份认证。
