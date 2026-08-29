# DeepSeek Harness HarmonyOS + Android Mobile Remote

> [中文说明](README.zh.md)

Use a HarmonyOS or Android phone to access an existing DeepSeek Harness instance
on Windows through a private Tailscale network. The computer keeps the
workspace, sessions, credentials, and model execution; the phone is only a
remote browser and VPN client.

Android uses the official Tailscale app and requires no development tools or
USB. HarmonyOS uses the locally signed client documented by this project. Every
user creates their own tailnet and connects only to their own computer.

This repository is a documentation and operations guide for the tested setup.
It is not a redistribution of DeepSeek Harness, Tailscale, Huawei SDKs, or any
signing material.

## What it provides

- HarmonyOS and Android connectivity over Wi-Fi or mobile data.
- A HarmonyOS VPN Extension that carries tailnet traffic to the Windows host.
- An official-app Android path with no custom APK or USB requirement.
- Tailscale Serve forwarding to the existing Harness web console on port 3080.
- Workspace and session access without moving or clearing the original data.
- Troubleshooting notes for MagicDNS and Harmony browser compatibility.

## Architecture

```text
HarmonyOS browser or Android Edge/Chrome
  -> HarmonyOS VPN Extension or official Tailscale Android VPN
  -> encrypted Tailscale tailnet
  -> Windows Tailscale Serve (tailnet only)
  -> http://127.0.0.1:3080
  -> existing DeepSeek Harness process
```

The URL must remain tailnet-only. Do not enable Tailscale Funnel or publish
port 3080 to the public internet.

## Prerequisites

- Windows computer with the existing DeepSeek Harness installation.
- Huawei Mate 80 running a compatible HarmonyOS build, or an Android phone.
- One Tailscale account signed in on both devices.
- DevEco Studio and HarmonyOS SDK 6.1.0 (API 23) for building the local app.
- USB debugging only for the first install, replacement install, or diagnosis.

DevEco Studio, the HarmonyOS SDK, and USB are not required for Android.

## Quick operation

1. Start DeepSeek Harness on Windows and confirm the desktop page works.
2. Start Tailscale on Windows and confirm the computer is online.
3. Run the Windows Serve helper and keep its result tailnet-only:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\enable-tailscale-harness-https.ps1
   ```

4. On Android, install the official Tailscale app; on HarmonyOS, open the local
   client. Sign in with the same user-owned account as Windows and approve the
   system VPN request.
5. Open the URL printed by `tailscale serve status` in the phone browser.
6. On the tested HarmonyOS deployment only, if MagicDNS returns
   `DNS_PROBE_FINISHED_NXDOMAIN` and Harness is already listening on the
   Tailscale interface, use the Windows Tailscale IPv4 and port 3080, for
   example:

   ```text
   http://100.x.y.z:3080/
   ```

   The address is device-specific; never copy the example address literally.
   Android should keep the HTTPS Serve URL and fix account, VPN, MagicDNS, or
   Private DNS conflicts instead.
7. Select the original workspace, open the existing session, and send a short
   test message. A successful reply proves the phone-to-computer path.

The first Edge visit can take about one minute while plugins, the connection
channel, and the workspace initialize. Keep the page open during this phase.
If the phone reports a connection problem or `restart timeout`, exit/disconnect
once, wait five seconds, and connect again. This transient VPN startup failure
does not mean that sessions or workspace data are lost.

USB can be unplugged after the VPN is connected and the page is reachable.
The computer must stay powered on, awake, and running Harness and Tailscale.

Run the read-only Windows preflight from an elevated PowerShell before phone
testing:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-windows-readiness.ps1
```

`RESULT=NEEDS_ADMIN` means it must be rerun as Administrator. Resolve every
`FAIL` until the script prints `RESULT=READY`.

## Documentation

- [中文完整操作手册](README.zh.md)
- [Android guide](docs/android-guide.md)
- [安卓独立指南](docs/android-guide.zh.md)
- [Installation acceptance checklist](docs/installation-checklist.md)
- [安装验收清单](docs/installation-checklist.zh.md)
- [Architecture and data flow](docs/architecture.md)
- [Manual steps and boundaries](docs/manual-steps.md)
- [Security and privacy](docs/security.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Operations runbook](docs/operations.md)
- [Verification checklist](docs/verification.md)

## Limitations

- The remote address can change after a Tailscale re-authentication or machine
  replacement; obtain the current address from `tailscale status`.
- HarmonyOS may need the documented MagicDNS fallback. Android should prefer
  the HTTPS Serve name and the official Tailscale DNS path.
- Large sessions can exceed mobile browser memory. The current web client loads
  a small recent-history window first; older events remain on the computer.
- This is an engineering setup, not an AppGallery release.

## License

MIT. The guide describes integration work and does not grant rights to the
DeepSeek Harness or Tailscale trademarks and software.
