# Worker hat: this PC's Tailscale IPv4 must answer :11434 (0.0.0.0 serve).
# That is what collaborators curl: http://<your-100.x>:11434
# Usage: .\verify-ollama-tailscale.ps1

$ErrorActionPreference = "Continue"

$ts = "C:\Program Files\Tailscale\tailscale.exe"
if (-not (Test-Path $ts)) { throw "tailscale.exe not found" }

$ip = (& $ts ip -4 | Select-Object -First 1).Trim()
Write-Output "this_pc_tailscale_ip=$ip"
if ($ip -notmatch "^100\.") {
    Write-Output "FAIL: expected 100.x from tailscale ip -4"
    exit 1
}

$listen = (netstat -an | Select-String ":11434" | ForEach-Object { $_.Line }) -join "`n"
Write-Output $listen
$listeningLocalhostOnly = ($listen -match "127\.0\.0\.1:11434\s+.*LISTENING") -and ($listen -notmatch "0\.0\.0\.0:11434\s+.*LISTENING") -and ($listen -notmatch "\[::\]:11434\s+.*LISTENING")
if ($listeningLocalhostOnly) {
    Write-Output "FAIL: Ollama is localhost-only. Quit tray Ollama, then start-ollama-worker.ps1"
    exit 1
}

$url = "http://${ip}:11434/api/tags"
$tags = curl.exe --noproxy "*" -s --max-time 15 $url
Write-Output "ts_tags_exit=$LASTEXITCODE url=$url"
Write-Output $tags
if ($LASTEXITCODE -ne 0 -or -not $tags) {
    Write-Output "FAIL: collaborators cannot reach this PC on Tailscale :11434"
    Write-Output "Check: serve on 0.0.0.0, Windows Firewall allows TCP 11434 on Tailscale."
    exit 1
}
Write-Output "PASS: Tailscale $ip :11434 answers /api/tags"
Write-Output "Tell collaborators: curl.exe --noproxy `"*`" -s http://${ip}:11434/api/tags"
exit 0
