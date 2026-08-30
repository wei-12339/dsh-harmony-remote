# 产品建设基线

本目录定义 DeepSeek Harness 手机远程项目从工程教程升级为可安装产品时使用的
需求、架构、安全和兼容性基线。它是后续 Windows 安装器、Android 客户端、
HarmonyOS 客户端和安全网关共同遵循的上层合同。

## 产品定位

产品目标不是简单地“在手机浏览器打开电脑网页”，而是：

> 安全、可靠地用手机远程管理自己电脑上的 AI Agent，并对设备、权限、风险
> 操作、审计、断线恢复和升级过程提供明确控制。

## 文档入口

- [V1 产品需求](product-requirements-v1.zh.md)
- [V1 系统架构](system-architecture-v1.zh.md)
- [V1 安全模型](security-model-v1.zh.md)
- [兼容性数据计划](compatibility-program-v1.zh.md)
- [分阶段建设路线](roadmap.zh.md)
- [ADR-0001：默认引入本地安全网关](../adr/0001-managed-gateway.md)
- [ADR-0002：双原生客户端，共享协议](../adr/0002-native-clients-shared-protocol.md)

## 当前状态

当前仓库已经验证 HarmonyOS/Android 经 Tailscale 访问 Windows Harness。该路径
继续作为 `Legacy Bridge Mode` 保留。产品版默认建设 `Managed Gateway Mode`，
由 Windows 本地网关承接设备认证、策略、审计和紧急停止。

这里的文档确认架构方向，不表示安装器、网关或统一客户端已经开发完成。
