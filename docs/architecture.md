# 架构与数据流

## 组件

| 组件 | 作用 | 是否保存会话 |
|---|---|---|
| Mate 80 HarmonyOS 应用 | 登录 Tailscale、创建 VPN、持久化后端状态 | 不保存 Harness 会话 |
| Mate 80 浏览器 | 显示 Harness 页面、发送用户操作 | 浏览器缓存可能保存页面状态 |
| Tailscale tailnet | 加密连接手机和电脑 | 不负责 Harness 会话 |
| Windows Tailscale Serve | 将私网请求代理到 `127.0.0.1:3080` | 不改变会话 |
| DeepSeek Harness | 执行模型、工具、文件操作并保存会话 | 是，仍在电脑上 |

## 请求路径

1. 手机浏览器请求 tailnet 地址。
2. HarmonyOS VPN Extension 将 tailnet 数据包送入 Tailscale 用户态后端。
3. Tailscale 加密传输到 Windows 节点。
4. Windows Serve 反向代理到 Harness 本机监听器。
5. Harness 使用原来的 `DSH_HOME`、工作区和会话存储响应。

## 为什么 USB 可以拔掉

USB 只承载安装、调试和 HDC 通道。真正的远程流量走 Tailscale VPN；只要
手机 VPN 已连接、电脑在线，USB 不参与数据路径。

## 地址选择

- 首选：Serve 输出的 HTTPS `ts.net` 主机名。
- 回退：电脑当前 Tailscale IPv4 加 `:3080`。这是为 MagicDNS 返回 NXDOMAIN
  或 Harmony 浏览器不支持安全上下文 API 时准备的实用路径。

