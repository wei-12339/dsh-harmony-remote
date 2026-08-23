# 故障排查

## 页面无法访问 / NXDOMAIN

电脑执行：

```powershell
tailscale status
tailscale serve status
```

确认 Windows 节点在线、Serve 显示 `tailnet only`、代理目标为
`http://127.0.0.1:3080`。如果手机提示 `DNS_PROBE_FINISHED_NXDOMAIN`，改用
当前 Tailscale IPv4 的 `http://100.x.y.z:3080/`。

## 页面加载但工作区为空

确认打开的是电脑原来的工作区，不要创建新目录。若出现 403，更新 Harness
trusted-host 白名单并完整重启 Harness。

## `crypto.randomUUID is not a function`

清除手机浏览器对当前私网 IP 的站点数据，关闭标签页后重新打开。仓库中的
兼容补丁使用 `getRandomValues()` 回退，不需要把页面改成公网服务。

## `历史加载失败：The user aborted a request`

这是手机解析大历史窗口时的资源限制，不表示会话被删除。刷新后先加载最近
消息；电脑端仍保留完整历史。不要清除 `DSH_HOME` 或浏览器全部数据。

## 手机 VPN 断开

重新打开 HarmonyOS 应用并点击连接，接受 VPN 授权。检查系统电池管理是否
限制该应用后台运行。电脑必须在线，移动数据不需要与电脑同一 Wi-Fi。

## 点击“连接私网”显示连接出现问题

如果错误包含 `FAILED | VPN backend | restart timeout`，按以下顺序恢复：

1. 在应用中点击“退出/断开”（如果按钮可用）。
2. 等待 5 秒，不要重复点击。
3. 再点击“连接私网”，重新接受系统 VPN 授权。
4. 等待顶部 VPN 图标出现，再打开浏览器。

这是手机端后端偶发启动超时的恢复流程。通常退出后再次连接即可，不需要
USB、卸载应用或清除应用数据。连续三次仍失败时，再重启手机；仍失败才
需要 USB 读取日志或覆盖安装。

## Edge 页面长时间初始化

首次进入或 Harness 刚重启后，Edge 需要加载插件、建立 WebSocket 并读取工作区
摘要，等待约 1 分钟是预期行为。等待期间保持 VPN 连接和页面打开，不要连续刷新。
超过 2 分钟仍停留在启动画面时，关闭当前标签页，重新打开当前私网地址一次。

## USB 相关

USB 仅用于安装和调试。远程使用阶段拔线是正常的；若重新部署 HAP、读取
HDC 日志或更新签名，才需要重新连接 USB。

## 快速判断故障位置

| 现象 | 优先检查 | 不要做 |
|---|---|---|
| 应用显示 `restart timeout` | 退出后再次连接、检查 VPN 图标 | 不要先清数据 |
| 浏览器 NXDOMAIN | 使用当前 Tailscale IPv4 | 不要启用 Funnel |
| Edge 启动画面约 1 分钟 | 保持页面等待 | 不要连续刷新 |
| 历史加载失败 | 等待小历史窗口、刷新一次 | 不要删除 DSH_HOME |
| 电脑端也打不开 | Harness、Serve、Windows 睡眠状态 | 不要迁移工作区 |
