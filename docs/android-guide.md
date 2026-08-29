# Android Remote Access for DeepSeek Harness

This guide connects an Android phone to the owner's own Windows computer.
Android uses the official Tailscale app, so it does not need the HarmonyOS HAP,
DevEco Studio, USB debugging, or a USB cable.

## Isolation model

Every user creates their own Tailscale tailnet and signs their own Windows PC
and Android phone into the same account. Never reuse the repository owner's
account, device address, invitation URL, or authentication key.

```text
Android Edge / Chrome
  -> official Tailscale Android VPN
  -> the user's private encrypted tailnet
  -> Windows Tailscale Serve (tailnet only)
  -> http://127.0.0.1:3080
  -> the user's DeepSeek Harness
```

## Requirements

- Windows can open the existing Harness at `http://127.0.0.1:3080/`.
- The original workspace and sessions remain on that Windows computer.
- Windows and Android can sign in to the same user-owned Tailscale account.
- The PC stays powered on and awake while Harness and Tailscale are running.
- Android should allow Tailscale to create a VPN and run in the background.
- Disable other VPN apps during setup because Android normally permits one
  active VPN provider at a time.

## Windows setup

1. Open `http://127.0.0.1:3080/` on Windows and verify the original workspace.
2. Install Tailscale from the
   [official Windows download page](https://tailscale.com/download/windows).
3. Sign in with the user's own account and confirm that the Windows node is
   online.
4. Open an elevated PowerShell in this repository and run:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\enable-tailscale-harness-https.ps1"
   ```

5. Confirm the output contains `RESULT=SUCCESS`, `(tailnet only)`, and a proxy
   target of `http://127.0.0.1:3080`.
6. Run the read-only preflight check from an elevated PowerShell so it can read
   the Windows Tailscale service state:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\test-windows-readiness.ps1"
   ```

   `RESULT=NEEDS_ADMIN` means the check must be rerun as Administrator. Resolve
   every `FAIL` until it prints `RESULT=READY`.

The phone URL is the reported `https://<computer>.<tailnet>.ts.net/` address.
Remove a trailing dot from `DNSName` when copying it. Never enable Funnel or
publish port 3080 through the router.

## Android setup

1. Install the official app from the
   [Tailscale Android download page](https://tailscale.com/download/android).
2. Sign in with exactly the same user-owned account as Windows.
3. Connect and approve Android's VPN permission prompt.
4. Wait until Tailscale reports connected and Android shows the VPN indicator.
5. Allow background data and background activity for Tailscale.
6. Open Edge or Chrome and visit the HTTPS address reported by Windows.
7. Allow about one minute for the first load without repeatedly refreshing.
8. Select the original workspace and session, then send a short test message.

## End-to-end acceptance

Turn off Wi-Fi on Android and repeat the test over mobile data. Send
`ANDROID_REMOTE_OK` and confirm that the same message and reply appear on the
Windows Harness session. A VPN icon or a visible home page alone is not a
complete verification.

Use the [installation acceptance checklist](installation-checklist.md) for a
repeatable handoff.

## Troubleshooting

- **Tailscale will not connect:** disable other VPN/proxy apps, allow mobile and
  background data, disconnect, wait five seconds, and reconnect once.
- **Connection disappears after screen lock:** exclude Tailscale from aggressive
  battery optimization or app cleanup.
- **The HTTPS name does not resolve:** confirm both devices are in the same
  tailnet and temporarily disable conflicting Private DNS, ad blockers, or VPNs.
- **HTTP 403 or Host error:** add the exact `*.ts.net` name to Harness
  `trustedHosts`, then fully restart Harness.
- **Slow first load:** wait one minute; after two minutes, close the tab and open
  the address once more. Do not delete Harness data.

Sharing this repository shares instructions only. It does not grant anyone
access to the owner's computer, tailnet, workspace, or sessions.
