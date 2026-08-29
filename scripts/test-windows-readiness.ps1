[CmdletBinding()]
param(
  [ValidateRange(1, 65535)]
  [int]$HarnessPort = 3080
)

$ErrorActionPreference = 'Stop'
$checks = [System.Collections.Generic.List[object]]::new()
$needsElevation = $false

function Add-Check {
  param(
    [string]$Name,
    [ValidateSet('PASS', 'WARN', 'FAIL')]
    [string]$State,
    [string]$Detail
  )

  $checks.Add([pscustomobject]@{
    State  = $State
    Check  = $Name
    Detail = $Detail
  })
}

Write-Output 'DeepSeek Harness mobile remote - Windows readiness check'
Write-Output 'This script is read-only and does not change Harness or Tailscale.'
Write-Output ''

if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) {
  Add-Check 'Windows' 'PASS' ([System.Environment]::OSVersion.VersionString)
} else {
  Add-Check 'Windows' 'FAIL' 'This helper supports Windows only.'
}

$loopback = Test-NetConnection -ComputerName '127.0.0.1' -Port $HarnessPort `
  -InformationLevel Quiet -WarningAction SilentlyContinue
if ($loopback) {
  Add-Check 'Harness TCP port' 'PASS' "127.0.0.1:$HarnessPort is listening."
} else {
  Add-Check 'Harness TCP port' 'FAIL' "Nothing is listening on 127.0.0.1:$HarnessPort."
}

if ($loopback) {
  try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:$HarnessPort/" `
      -UseBasicParsing -TimeoutSec 8
    Add-Check 'Harness HTTP' 'PASS' "HTTP status $([int]$response.StatusCode)."
  } catch {
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
      $statusCode = [int]$_.Exception.Response.StatusCode
      Add-Check 'Harness HTTP' 'WARN' "Harness responded with HTTP status $statusCode."
    } else {
      Add-Check 'Harness HTTP' 'FAIL' $_.Exception.Message
    }
  }
} else {
  Add-Check 'Harness HTTP' 'FAIL' 'Skipped because the local TCP port is closed.'
}

$tailscale = Join-Path $env:ProgramFiles 'Tailscale\tailscale.exe'
if (Test-Path -LiteralPath $tailscale) {
  $version = (& $tailscale version 2>&1 | Select-Object -First 1)
  Add-Check 'Tailscale installation' 'PASS' "Installed: $version"
} else {
  Add-Check 'Tailscale installation' 'FAIL' "Not found: $tailscale"
}

$tailscaleStatus = $null
if (Test-Path -LiteralPath $tailscale) {
  try {
    $statusText = & $tailscale status --json 2>&1
    if ($LASTEXITCODE -ne 0) {
      throw ($statusText -join ' ')
    }
    $tailscaleStatus = ($statusText -join "`n") | ConvertFrom-Json

    if ($tailscaleStatus.BackendState -eq 'Running' -and $tailscaleStatus.Self.Online) {
      Add-Check 'Tailscale connection' 'PASS' 'Windows node is online.'
    } else {
      Add-Check 'Tailscale connection' 'FAIL' `
        "BackendState=$($tailscaleStatus.BackendState); Online=$($tailscaleStatus.Self.Online)"
    }

    $dnsName = [string]$tailscaleStatus.Self.DNSName
    if ($dnsName) {
      $dnsName = $dnsName.TrimEnd('.')
      Add-Check 'Tailnet HTTPS name' 'PASS' "https://$dnsName/"
    } else {
      Add-Check 'Tailnet HTTPS name' 'WARN' 'No DNS name was returned. Check MagicDNS.'
    }
  } catch {
    if ($_.Exception.Message -match '(?i)access is denied') {
      $needsElevation = $true
      Add-Check 'Tailscale connection' 'WARN' `
        'Access was denied. Run this read-only check from Administrator PowerShell.'
    } else {
      Add-Check 'Tailscale connection' 'FAIL' $_.Exception.Message
    }
  }
}

if (Test-Path -LiteralPath $tailscale) {
  try {
    $serveLines = & $tailscale serve status 2>&1
    $serveExitCode = $LASTEXITCODE
    $serveText = $serveLines -join "`n"

    if ($serveExitCode -ne 0 -or $serveText -match 'No serve config') {
      Add-Check 'Tailscale Serve' 'FAIL' 'No active Serve configuration was found.'
    } elseif ($serveText -notmatch "127\.0\.0\.1:$HarnessPort") {
      Add-Check 'Tailscale Serve target' 'FAIL' `
        "Serve is not proxying to http://127.0.0.1:$HarnessPort."
    } else {
      Add-Check 'Tailscale Serve target' 'PASS' `
        "Serve proxies to http://127.0.0.1:$HarnessPort."
    }

    if ($serveText -match '(?i)funnel|available on the internet') {
      Add-Check 'Public exposure' 'FAIL' 'Funnel or public exposure appears to be enabled.'
    } else {
      Add-Check 'Public exposure' 'PASS' 'No Funnel marker was found in Serve status.'
    }
  } catch {
    if ($_.Exception.Message -match '(?i)access is denied') {
      $needsElevation = $true
      Add-Check 'Tailscale Serve' 'WARN' `
        'Access was denied. Run this read-only check from Administrator PowerShell.'
    } else {
      Add-Check 'Tailscale Serve' 'FAIL' $_.Exception.Message
    }
  }
}

Write-Output ($checks | Format-Table -AutoSize | Out-String -Width 240)

$failCount = @($checks | Where-Object State -eq 'FAIL').Count
$warnCount = @($checks | Where-Object State -eq 'WARN').Count
Write-Output "SUMMARY: PASS=$(@($checks | Where-Object State -eq 'PASS').Count) WARN=$warnCount FAIL=$failCount"

if ($failCount -gt 0) {
  Write-Output 'RESULT=NOT_READY'
  exit 1
}

if ($needsElevation) {
  Write-Output 'RESULT=NEEDS_ADMIN'
  exit 2
}

Write-Output 'RESULT=READY'
exit 0
