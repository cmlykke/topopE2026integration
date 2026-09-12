# Local worker smoke: env is not 100.x, tags on 127.0.0.1, optional pong.
# Usage:
#   .\verify-ollama-local.ps1
#   .\verify-ollama-local.ps1 -Chat

param(
    [switch]$Chat,
    [string]$Model = "qwen2.5-coder:7b"
)

$ErrorActionPreference = "Continue"
$fail = 0

$userHost = [Environment]::GetEnvironmentVariable("OLLAMA_HOST", "User")
$machineHost = [Environment]::GetEnvironmentVariable("OLLAMA_HOST", "Machine")
Write-Output "OLLAMA_HOST User='$userHost' Machine='$machineHost'"
if ($userHost -match "^100\." -or $machineHost -match "^100\.") {
    Write-Output "FAIL: permanent OLLAMA_HOST is a Tailscale 100.x address. Clear User/Machine."
    $fail = 1
}

$tags = curl.exe --noproxy "*" -s --max-time 10 http://127.0.0.1:11434/api/tags
Write-Output "local_tags_exit=$LASTEXITCODE"
if ($LASTEXITCODE -ne 0 -or -not $tags) {
    Write-Output "FAIL: 127.0.0.1:11434/api/tags. Start with start-ollama-worker.ps1"
    exit 1
}
Write-Output $tags
if ($tags -notmatch [regex]::Escape($Model)) {
    Write-Output "WARN: tags JSON does not mention $Model"
}

if ($Chat) {
    $jsonPath = Join-Path $PSScriptRoot "peer-pong.json"
    if (-not (Test-Path $jsonPath)) {
        Set-Content -Path $jsonPath -Value ('{"model":"' + $Model + '","messages":[{"role":"user","content":"Reply with the single word: pong"}],"stream":false}') -Encoding utf8
    }
    $chat = curl.exe --noproxy "*" -s --max-time 180 http://127.0.0.1:11434/api/chat -H "Content-Type: application/json" --data-binary "@$jsonPath"
    Write-Output "chat_exit=$LASTEXITCODE"
    Write-Output $chat
    if ($LASTEXITCODE -ne 0 -or $chat -notmatch "(?i)pong") {
        Write-Output "FAIL: local /api/chat did not return pong"
        $fail = 1
    } else {
        Write-Output "PASS: local pong"
    }
}

if ($fail -eq 0) { Write-Output "PASS: local Ollama tags OK" }
exit $fail
