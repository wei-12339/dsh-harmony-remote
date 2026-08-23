$ErrorActionPreference = 'Stop'

$tailscale = Join-Path $env:ProgramFiles 'Tailscale\tailscale.exe'
if (-not (Test-Path -LiteralPath $tailscale)) {
  throw "Tailscale executable not found: $tailscale"
}

& $tailscale serve --bg --yes 3080
if ($LASTEXITCODE -ne 0) {
  throw "Tailscale Serve failed with exit code $LASTEXITCODE."
}

$serveStatus = & $tailscale serve status
$statusJson = & $tailscale status --json | ConvertFrom-Json
$self = $statusJson.Self

Write-Output 'RESULT=SUCCESS'
Write-Output 'TailscaleServeStatus:'
$serveStatus | ForEach-Object { Write-Output $_ }
Write-Output "DNSName=$($self.DNSName)"
Write-Output "TailscaleIP=$($self.TailscaleIPs -join ',')"

