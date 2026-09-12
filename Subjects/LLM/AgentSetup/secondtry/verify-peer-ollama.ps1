# Orchestrator smoke: THIS PC drives a friend's Ollama over Tailscale.
# Usage:
#   .\verify-peer-ollama.ps1 -PeerIp 100.101.98.59
#   .\verify-peer-ollama.ps1 -PeerIp 100.101.98.59 -Chat -Model qwen2.5-coder:7b
#   .\verify-peer-ollama.ps1 -PeerHost kevpc2 -PeerIp 100.101.98.59

param(
    [Parameter(Mandatory = $true)]
    [string]$PeerIp,
    [string]$PeerHost,
    [switch]$Chat,
    [string]$Model = "qwen2.5-coder:7b"
)

$ErrorActionPreference = "Continue"
$fail = 0

if ($PeerIp -notmatch "^100\.") {
    Write-Output "FAIL: PeerIp must be a Tailscale 100.x address"
    exit 1
}

$ts = "C:\Program Files\Tailscale\tailscale.exe"
if ((Test-Path $ts) -and $PeerHost) {
    & $ts ping --c 2 $PeerHost
    Write-Output "ping_exit=$LASTEXITCODE"
}

$url = "http://${PeerIp}:11434/api/tags"
$tags = curl.exe --noproxy "*" -s --max-time 15 $url
Write-Output "peer_tags_exit=$LASTEXITCODE url=$url"
Write-Output $tags
if ($LASTEXITCODE -ne 0 -or -not $tags) {
    Write-Output "FAIL: peer :11434/api/tags. They must session-serve 0.0.0.0:11434"
    exit 1
}

if ($Chat) {
    $body = '{"model":"' + $Model + '","messages":[{"role":"user","content":"Reply with the single word: pong"}],"stream":false}'
    $jsonPath = Join-Path $PSScriptRoot "peer-pong.json"
    Set-Content -Path $jsonPath -Value $body -Encoding utf8
    $chat = curl.exe --noproxy "*" -s --max-time 180 "http://${PeerIp}:11434/api/chat" -H "Content-Type: application/json" --data-binary "@$jsonPath"
    Write-Output "chat_exit=$LASTEXITCODE"
    Write-Output $chat
    if ($LASTEXITCODE -ne 0 -or $chat -notmatch "(?i)pong") {
        Write-Output "FAIL: peer /api/chat did not return pong (check model tag)"
        $fail = 1
    } else {
        Write-Output "PASS: peer pong from $PeerIp"
    }
}

if ($fail -eq 0) { Write-Output "PASS: peer tags OK from this PC" }
exit $fail
