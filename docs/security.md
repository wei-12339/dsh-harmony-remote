# 安全与隐私

本文适用于当前可用的直连兼容方案。产品化的设备身份、权限、风险等级、审计、
紧急停止和供应链安全要求见 [V1 安全模型](product/security-model-v1.zh.md)。

## 网络边界

本方案使用 Tailscale tailnet-only。未启用 Funnel，未配置公网端口转发。URL
即使被看到，也必须从已加入同一 tailnet 且通过 ACL 的设备访问。

## 重要提醒

`trustedHosts` 只解决 Harness 的 Host/DNS-rebinding 检查，不等于用户认证。
Tailscale 账号、设备登录、ACL、手机锁屏和电脑账户仍是安全边界。

## 每位使用者独立部署

本仓库只分发文档和通用脚本，不提供中心中继账号或共享 Harness。每位使用者
必须：

- 在自己的 Windows 和手机上登录自己的 Tailscale 账号；
- 只连接自己的 Harness 和工作区；
- 不索取或复用作者的认证密钥、登录链接、机器名或私网地址；
- 团队 tailnet 使用 ACL 限制能够访问 Harness 节点的成员。

Android 使用官方 Tailscale 应用，不需要第三方 APK。HarmonyOS HAP 只能来自
使用者自己信任的构建者和签名流程。

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

## Harness 权限风险

Harness 可能读取工作区文件、调用工具并执行电脑命令。获得网页访问权不能被
当作普通只读网页权限。电脑应使用最小权限账户，手机应设置锁屏，Tailscale
账号建议开启两步验证；设备丢失时应立即从 tailnet 管理页面移除该设备。

## 当前方案与产品方案的差异

当前 `Legacy Bridge Mode` 主要依赖 tailnet 成员关系，不具备独立的产品设备密钥
和细粒度策略。未来 `Managed Gateway Mode` 会增加本地设备绑定、撤销、审计和
暂停入口。在安全网关实际发布前，不应把当前直连方式描述为已经具备这些能力。
