# HarmonyOS and Android Installation Acceptance Checklist

Use this checklist for installation handoff and repeatable troubleshooting.
Each item requires observable evidence, not just an installed application.

## Common Windows checks

- [ ] `http://127.0.0.1:3080/` opens on Windows.
- [ ] Harness shows the user's original workspace and sessions.
- [ ] Windows Tailscale is online in the user's own account.
- [ ] `tailscale serve status` reports `tailnet only`.
- [ ] Serve proxies to `http://127.0.0.1:3080`.
- [ ] Funnel and router port forwarding are disabled.
- [ ] `scripts\test-windows-readiness.ps1` prints `RESULT=READY`.
- [ ] Windows will not sleep during remote use.

## Android checks

- [ ] The official Tailscale Android app is installed.
- [ ] Android and Windows use the same user-owned Tailscale account.
- [ ] Android VPN, mobile data, background data, and background activity are
  allowed.
- [ ] Other VPN and proxy applications are disabled during testing.
- [ ] Edge or Chrome opens the Windows `https://...ts.net/` URL.
- [ ] The original workspace and session are visible.
- [ ] The page still works over mobile data with Wi-Fi disabled.
- [ ] Sending `ANDROID_REMOTE_OK` appears on Windows and receives a reply.

## HarmonyOS checks

- [ ] The locally signed HAP and first USB debugging authorization are complete.
- [ ] The app and Windows use the same user-owned Tailscale account.
- [ ] HarmonyOS approved the VPN and shows the VPN indicator.
- [ ] The app is allowed to run in the background.
- [ ] The browser opens the Windows `https://...ts.net/` URL.
- [ ] A test message appears on Windows and receives a reply.
- [ ] The round trip still works without USB and over mobile data.

## Security checks

- [ ] No repository-owner account, auth key, device address, or login URL is used.
- [ ] No API key, `.credentials.yaml`, `DSH_HOME`, or chat history is published.
- [ ] The user understands that Harness can access files and execute commands.
- [ ] The phone has a screen lock and the Tailscale account should use 2FA.

## Acceptance levels

| Level | Evidence | Result |
|---|---|---|
| L0 | Application installed | Network and Harness are unverified |
| L1 | VPN connected and Harness home page opens | Tailnet and Serve are usable |
| L2 | Original workspace and session are visible | Session read path works |
| L3 | Phone message syncs to Windows and gets a reply | Remote control is complete |
| L4 | L3 still works after reconnect and over mobile data | Daily remote use is accepted |

The final handoff target is L4. Android never requires USB; HarmonyOS uses USB
only for initial installation, replacement installation, and debugging.
