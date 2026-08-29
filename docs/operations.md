# 日常运行手册

## 启动顺序

1. 唤醒并登录 Windows 电脑。
2. 打开原 DeepSeek Harness，确认原工作区可以在电脑端显示。
3. 确认 Tailscale Windows 节点在线。
4. 确认 Serve 仍然代理到 `127.0.0.1:3080` 且是 `tailnet only`。
5. HarmonyOS 打开本地客户端；Android 打开官方 Tailscale，并连接私网。
6. 等待 VPN 图标出现后，再打开 Edge 或 Chrome。

## 手机访问顺序

1. 首次页面初始化预留约 1 分钟。
2. 先确认工作区列表出现，再进入原会话。
3. 发送短测试消息，确认电脑端同步。
4. 再进行实际文件或模型操作。

Android 不需要 USB。HarmonyOS 日常运行也不需要 USB，只有 HAP 安装、覆盖安装
和读取 HDC 日志时才连接数据线。

## 连接失败的标准重试

```text
连接私网失败
  -> 关闭其他 VPN（Android）
  -> 当前 Tailscale 客户端退出/断开
  -> 等待 5 秒
  -> 再次连接私网
  -> 等待 VPN 图标
  -> 打开 Edge 并等待约 1 分钟
```

这个顺序优先于卸载、清数据或重新安装。连接失败通常是手机 VPN 后端启动
时序问题，不会删除 Harness 会话。

## 安装前电脑检测

在每次交付或 Harness/Tailscale 更新后，于管理员 PowerShell 运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test-windows-readiness.ps1"
```

该脚本为只读检查。`RESULT=READY` 只证明电脑侧条件满足，最终仍需完成手机消息
往返测试。

## 关机与休眠

- 电脑休眠期间手机无法控制 Harness。
- 电脑重启后需要确认 Harness 和 Tailscale 都已重新启动。
- 手机重启后需要重新打开应用并点击连接；USB 不属于恢复条件。

## 变更记录建议

每次修改电脑端 Harness、Serve 端口、Tailscale 节点或手机 HAP 后，记录：

- 日期和版本；
- 电脑端口与 Serve 状态；
- 手机是否出现 VPN 图标；
- Edge 首次加载耗时；
- 是否能看到原工作区和原会话；
- 是否完成一次短消息回传测试。
