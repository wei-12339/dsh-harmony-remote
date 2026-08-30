# Changelog

## 2026-08-30 - Product architecture baseline

- Defined the V1 product requirements for a Windows one-click installer,
  managed gateway, Android client, HarmonyOS client, and compatibility program.
- Added the Managed Gateway and Legacy Bridge operating-mode distinction.
- Added device pairing, permissions, risk levels, audit, emergency pause,
  signed update, rollback, and privacy requirements.
- Added a compatibility data allowlist, error taxonomy, test matrix, and L0-L4
  evidence model.
- Added ADRs for the local managed gateway and native clients sharing one
  protocol instead of one forced cross-platform UI codebase.
- Added a staged roadmap and identified Harness interface discovery as the
  recommended next technical milestone.

## 2026-08-30 - Android expansion

- Expanded the project from HarmonyOS-only guidance to HarmonyOS and Android.
- Added standalone Chinese and English Android setup guides.
- Added a read-only Windows readiness script for Harness, Tailscale, Serve, and
  public-exposure checks.
- Added bilingual installation acceptance checklists with L0-L4 evidence levels.
- Added Android VPN, battery, Private DNS, and same-account troubleshooting.
- Documented the per-user tailnet isolation model for safely sharing the guide.

## 2026-08-23

- Added the HarmonyOS Mate 80 manual operation guide.
- Documented the transient private-network connection failure and the
  exit-then-reconnect recovery sequence.
- Documented the expected one-minute Edge initialization window.
- Added an operations runbook, verification levels, and a symptom matrix.
