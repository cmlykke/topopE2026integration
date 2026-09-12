# Session-only Ollama bind for Tailscale peers.
# Do NOT set User/Machine OLLAMA_HOST.
# Quit tray Ollama first (system tray -> Quit Ollama).

$exe = Join-Path $env:LOCALAPPDATA "Programs\Ollama\ollama.exe"
if (-not (Test-Path $exe)) { throw "ollama.exe not found: $exe" }

$userHost = [Environment]::GetEnvironmentVariable("OLLAMA_HOST", "User")
$machineHost = [Environment]::GetEnvironmentVariable("OLLAMA_HOST", "Machine")
if ($userHost -or $machineHost) {
    throw "OLLAMA_HOST is set permanently (User='$userHost' Machine='$machineHost'). Clear it first."
}

$env:OLLAMA_HOST = "0.0.0.0:11434"
Write-Output "session OLLAMA_HOST=$($env:OLLAMA_HOST)"
$ts = "C:\Program Files\Tailscale\tailscale.exe"
if (Test-Path $ts) {
    $ip = (& $ts ip -4 | Select-Object -First 1).Trim()
    Write-Output "this PC Tailscale IPv4=$ip  (collaborators: http://${ip}:11434)"
} else {
    Write-Output "tailscale.exe not found; still binding 0.0.0.0:11434"
}
Write-Output "Leave this window open. Verify: .\verify-ollama-local.ps1 ; .\verify-ollama-tailscale.ps1"
& $exe serve
