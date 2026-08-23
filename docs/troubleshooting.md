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

## USB 相关

USB 仅用于安装和调试。远程使用阶段拔线是正常的；若重新部署 HAP、读取
HDC 日志或更新签名，才需要重新连接 USB。

