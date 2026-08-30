# ADR-0001：产品默认使用本地安全网关

状态：接受

日期：2026-08-30

## 背景

当前方案通过 Tailscale Serve 直接代理 DeepSeek Harness。该方式已经验证可用，
但 `trustedHosts` 不是身份认证，同一 tailnet 的访问控制也不足以提供产品级设备
绑定、工作区权限、审计和紧急停止。

## 决策

产品默认使用 `Managed Gateway Mode`：

```text
phone -> Tailscale Serve -> local gateway -> Harness
```

网关只监听回环地址，负责产品设备认证、策略、审计、诊断和撤销。当前直连路径
保留为 `Legacy Bridge Mode`，用于兼容、迁移和排障，并明确显示风险提示。

## 结果

优点：

- Tailscale 传输身份与产品设备身份分层。
- 能统一 Android、HarmonyOS 和后续客户端协议。
- 能提供撤销、审计、限流、幂等和诊断。
- 上游 Harness 变化可由 Adapter 隔离。

代价：

- Windows 增加一个需要签名、更新和维护的本地服务。
- 延迟和故障点增加，需要严格健康检查和回滚。
- 细粒度审批能力仍受 Harness 可观察接口限制。

## 被否决方案

- 只依赖 Tailscale 成员身份：无法满足独立设备撤销和产品权限。
- 直接把 Harness 暴露到公网：风险不可接受。
- 让所有用户连接作者的中心服务器：增加数据、合规和单点风险，偏离本地优先。
