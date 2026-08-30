# V1 系统架构

## 1. 架构原则

1. 用户数据留在用户自己的电脑。
2. 私网传输与产品身份认证分层。
3. 安装器有管理员权限，运行时网关使用最小权限。
4. 所有系统修改可检测、可解释、可回滚。
5. 客户端共享协议和产品语义，不以强行共用代码牺牲平台稳定性。
6. 上游 Harness 接口通过 Adapter 隔离。

## 2. 目标架构

```text
Android native client              HarmonyOS native client
  Kotlin + Compose                   ArkTS + native VPN integration
          \                               /
           \-- shared protocol v1 ------/
                        |
                 Tailscale tailnet
                        |
              HTTPS Tailscale Serve
                        |
               127.0.0.1:3081
              Managed Gateway Service
       auth | policy | audit | diagnostics | stop
                        |
                  Harness Adapter
                        |
               127.0.0.1:3080
                DeepSeek Harness
                        |
             existing DSH_HOME/workspaces
```

端口是建议默认值，最终实现必须允许配置和冲突检测。网关不得默认监听
`0.0.0.0` 或局域网地址。

## 3. 组件职责

### Windows Bootstrapper

- 检测系统、Harness、Tailscale、端口和旧版本。
- 展示变更计划并取得用户确认。
- 验证安装包签名和哈希。
- 创建备份、安装网关、配置 Serve、执行验收。
- 失败时恢复旧配置和旧版本。

### Managed Gateway Service

- 设备注册、认证、会话和撤销。
- 工作区授权和风险策略。
- 请求幂等、限流和审计。
- 运行状态、诊断和紧急停止。
- 通过 Adapter 与 Harness 通信。

### Desktop Control Console

- 显示安装状态、远程地址和安全模式。
- 生成短期配对二维码。
- 查看、重命名、暂停和撤销设备。
- 管理工作区授权、日志保留和兼容性上报选择。
- 执行更新、回滚和卸载。

第一阶段可以由网关提供本机管理页面，后续再决定是否拆为独立桌面 UI。

### Harness Adapter

- 封装 Harness HTTP/WebSocket/事件接口。
- 将上游错误转换为稳定的产品错误码。
- 发现 Harness 版本和能力。
- 对不支持的能力明确返回 `CAPABILITY_UNAVAILABLE`，不得伪装成功。

### Mobile Clients

- 安全保存设备私钥。
- 配对、设备认证和会话恢复。
- 会话列表、消息发送、状态展示、风险确认和紧急停止。
- 平台后台限制和 VPN 状态诊断。

### Compatibility Reporter

- 默认只在本机生成脱敏报告。
- 用户明确同意后才上传匿名兼容性数据。
- 对敏感字段使用允许列表，而不是事后黑名单清洗。

## 4. 信任边界

| 边界 | 信任假设 | 必须控制 |
|---|---|---|
| 手机设备 | 可能丢失或被解锁 | 设备密钥、系统安全存储、撤销、短会话 |
| Tailscale tailnet | 提供加密传输和网络成员控制 | 仍需网关设备认证，禁止 Funnel |
| Windows 网关 | 本机可信组件但可能被错误配置 | 回环监听、最小权限、签名更新、审计 |
| Harness | 高权限上游应用 | Adapter 隔离、能力探测、工作区限制 |
| 兼容性服务 | 不应获得用户内容 | 明确同意、字段允许列表、匿名 ID |

## 5. 两种运行模式

### Managed Gateway Mode

```text
Serve -> 127.0.0.1:3081 -> Gateway -> Harness 3080
```

具备产品身份认证、设备撤销和审计。安装器默认配置此模式。

### Legacy Bridge Mode

```text
Serve -> 127.0.0.1:3080 -> Harness
```

仅用于兼容和诊断。控制台必须显示风险提示，并提供迁移到网关模式的入口。

## 6. 设备配对协议草案

1. 电脑控制台请求网关创建 `pairing_session`。
2. 网关生成 256 位随机一次性令牌，保存其哈希，默认 5 分钟过期。
3. 二维码包含网关地址、会话 ID、一次性令牌和协议版本，不包含长期秘密。
4. 手机生成设备密钥对，私钥写入系统安全存储。
5. 手机通过 tailnet HTTPS 提交公钥、设备显示名和一次性令牌。
6. 电脑显示指纹和设备信息，由本机用户确认。
7. 网关签发设备注册记录；一次性令牌立即失效。
8. 后续会话使用设备签名挑战换取短期访问令牌。

正式实现前需要通过密码学和重放攻击专项评审。不得自行发明不经过评审的加密
算法；优先使用平台标准 Ed25519/P-256、系统安全存储和成熟令牌库。

## 7. 请求与事件模型

每个客户端请求至少包含：

- `request_id`：UUID，用于幂等。
- `device_id`：已注册设备标识。
- `session_id`：短期认证会话。
- `workspace_id`：网关生成的稳定别名，不暴露真实路径。
- `operation`：稳定操作名。
- `client_protocol_version`。

网关事件至少包含：

- `request.accepted`
- `request.progress`
- `approval.required`
- `approval.resolved`
- `request.completed`
- `request.failed`
- `session.revoked`
- `gateway.paused`

事件必须有单调序号。客户端重连时从最后确认序号恢复，防止重复显示或重复执行。

## 8. 风险操作与审批能力

网关只能对“能够可靠识别和拦截”的操作实施细粒度审批。实施顺序：

1. 先完成 Harness 接口和事件流能力探测。
2. 将可识别操作映射到稳定风险类型。
3. 不可识别时回退到任务级确认或只读模式。
4. 客户端不得显示虚假的“已保护每条命令”。

这是 Phase B 前的强制技术门槛。

## 9. 安装事务

安装器采用阶段化事务：

```text
DISCOVER
  -> PLAN
  -> USER_CONFIRM
  -> BACKUP
  -> INSTALL_GATEWAY
  -> CONFIGURE_SERVE
  -> HEALTH_CHECK
  -> PAIR
  -> L0-L4_ACCEPTANCE
  -> COMMIT
```

在 `COMMIT` 前失败均进入 `ROLLBACK`。回滚范围只包括本产品创建或明确修改的
文件、服务和 Serve 配置，不删除 Harness、DSH_HOME、工作区或 Tailscale 身份。

## 10. 本地数据目录草案

```text
%ProgramData%\DshRemote\
  config\
  state\
  logs\
  backups\
  updates\
```

- 配置和状态使用版本化格式。
- 设备公钥与权限记录加访问控制，仅服务账户和管理员可读写。
- 日志默认轮转并设置保留期。
- 工作区真实路径不进入移动端或兼容性上报。

具体 ACL、服务账户和凭据保护方式在 Windows 技术验证后冻结。

## 11. 版本协商

- 客户端、网关和 Adapter 各有独立版本。
- `/v1/capabilities` 返回协议范围和 Harness 可用能力。
- 不兼容客户端收到可理解的升级提示，不允许静默降级安全策略。
- 未识别字段向后兼容；涉及身份、审批和签名的未知字段必须拒绝。

## 12. 可观测性

- 健康状态：Harness、Tailscale、Serve、Gateway、Adapter、客户端。
- 统一错误码：组件、阶段、类别、恢复建议。
- 诊断包默认脱敏，可由用户预览后导出。
- 不把“进程存在”当作端到端成功；最终验证仍要求消息往返。
