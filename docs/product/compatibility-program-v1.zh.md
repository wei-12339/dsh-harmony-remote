# 兼容性数据计划 V1

## 1. 目标

持续积累真实设备上的安装、连接、后台运行和浏览器/客户端表现，形成难以通过
一次复制获得的兼容性知识库，同时严格避免收集用户内容和身份秘密。

## 2. 建设顺序

1. 先生成本地诊断报告，由用户查看和手动导出。
2. 建立公开的错误码、测试矩阵和贡献模板。
3. 只有隐私设计、字段审计和删除机制完成后，才增加自愿匿名上传。

V1 默认不上云，不因用户拒绝遥测而降低产品功能。

## 3. 允许收集的字段

- 随机安装 ID，不使用账号、邮箱、设备序列号或广告 ID。
- Windows 主版本、架构和补丁级别。
- Harness、Tailscale、网关和客户端版本。
- 手机平台、厂商、型号族、系统主版本。
- 浏览器名称和主版本，仅兼容模式需要。
- 网络类型：Wi-Fi、移动数据、DERP/直连结果，不记录公网 IP。
- 安装或连接阶段、标准错误码、耗时和是否恢复成功。
- 电池优化/后台权限的布尔状态，不读取其他应用列表。
- L0-L4 验收结果。

## 4. 禁止收集的字段

- 提示词、回复、会话标题和聊天记录。
- 文件名、文件内容、真实工作区路径和用户名。
- Tailscale IP、机器名、tailnet 名称、登录 URL 和 auth key。
- DeepSeek API Key、`.credentials.yaml`、Cookie 和访问令牌。
- 手机序列号、IMEI、电话号码、邮箱和精确位置。
- 屏幕截图、剪贴板、通讯录和已安装应用列表。

## 5. 本地报告格式草案

```json
{
  "schema_version": 1,
  "report_id": "random-uuid",
  "created_at": "2026-08-30T00:00:00Z",
  "consent": "local_only",
  "platform": {
    "windows_major": "11",
    "windows_arch": "x64",
    "phone_os": "android",
    "phone_vendor": "example",
    "phone_model_family": "example-family",
    "phone_os_major": "16"
  },
  "versions": {
    "gateway": "0.1.0",
    "client": "0.1.0",
    "tailscale": "1.x",
    "harness": "detected-or-unknown"
  },
  "result": {
    "stage": "PAIR",
    "code": "PAIR_TIMEOUT",
    "recovered": true,
    "duration_ms": 12000,
    "acceptance_level": "L3"
  }
}
```

示例值不能替换为真实用户地址、机器名或路径。

## 6. 错误码体系

错误码格式：`<COMPONENT>_<STAGE>_<CAUSE>`。

组件前缀：

- `INS`：安装器
- `TS`：Tailscale/Serve
- `GW`：安全网关
- `HA`：Harness Adapter
- `AND`：Android 客户端
- `HOS`：HarmonyOS 客户端
- `WEB`：浏览器兼容模式

示例：

- `TS_SERVE_TARGET_MISMATCH`
- `GW_PAIR_TOKEN_EXPIRED`
- `HA_CAPABILITY_UNAVAILABLE`
- `HOS_VPN_PROCESS_RECLAIMED`
- `WEB_HISTORY_RESPONSE_ABORTED`

每个错误码必须绑定用户可理解说明、开发者诊断字段和安全的恢复建议。

## 7. 兼容性测试矩阵

至少覆盖：

| 维度 | 分组 |
|---|---|
| Windows | 10、11；x64；普通用户/管理员安装 |
| Harness | 当前稳定版、上一个可用版、未知新版受限模式 |
| Tailscale | 当前稳定版、上一个稳定版；直连/DERP |
| Android | Google、Samsung、小米、OPPO/vivo 等系统策略族 |
| HarmonyOS | 已验证 Mate 80 版本及后续系统更新 |
| 网络 | 同 Wi-Fi、异地 Wi-Fi、移动数据、切网、弱网 |
| 生命周期 | 锁屏、后台、系统省电、重启、升级、撤销 |
| 会话规模 | 空会话、短会话、长历史、持续事件流 |

## 8. 贡献与隐私流程

1. 用户在客户端生成本地报告。
2. 客户端显示将被导出的完整 JSON。
3. 用户可删除任意可选字段。
4. 报告通过 GitHub Issue 模板或未来上报接口提交。
5. 服务端按报告 ID 支持删除请求。
6. 原始报告设置保留期，聚合统计不保留可逆设备标识。

## 9. 兼容性评分

不使用单一“支持/不支持”结论，记录四项：

- 安装成功率。
- 首次配对成功率。
- 24 小时后台连接稳定性。
- L4 消息往返成功率。

只有具备足够样本且完成版本标注时，才公开某设备“已验证”。单次成功只能标记
为“报告成功”，不能泛化到同品牌全部设备。
