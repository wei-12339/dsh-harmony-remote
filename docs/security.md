# 安全与隐私

## 网络边界

本方案使用 Tailscale tailnet-only。未启用 Funnel，未配置公网端口转发。URL
即使被看到，也必须从已加入同一 tailnet 且通过 ACL 的设备访问。

## 重要提醒

`trustedHosts` 只解决 Harness 的 Host/DNS-rebinding 检查，不等于用户认证。
Tailscale 账号、设备登录、ACL、手机锁屏和电脑账户仍是安全边界。

## GitHub 发布边界

公开仓库只应包含通用说明、示例配置和不含秘密的脚本。以下内容禁止提交：

- Tailscale auth key、节点私钥、登录 URL；
- DeepSeek API Key、`.credentials.yaml`、DSH_HOME 数据；
- HAP 签名证书、私钥、密码；
- 个人聊天记录、截图、设备序列号和真实私网地址；
- 任何下载后可直接控制你电脑的 token。

## 分享给别人

可以分享 GitHub 仓库的说明页，但不要分享你当前机器的 IP、设备名、登录
二维码或 Tailscale 邀请链接。别人需要建立自己的 Tailscale tailnet 和
自己的 Harness 实例，不能直接使用你的会话。

