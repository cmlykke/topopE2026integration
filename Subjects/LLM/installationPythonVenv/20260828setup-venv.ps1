# Recreate the shared .venv used by this project.
# Run from PowerShell. Requires uv: https://docs.astral.sh/uv/

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$VenvDir = Join-Path $RepoRoot ".venv"

$Requirements = Join-Path $RepoRoot "requirements.txt"
$PythonVersion = "3.14"

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw "uv is not installed. On the other machine run: powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`""
}

if (-not (Test-Path $Requirements)) {
    throw "Missing requirements.txt next to this script."
}

Write-Host "Creating $VenvDir with Python $PythonVersion"
uv python install $PythonVersion
uv venv $VenvDir --python $PythonVersion --clear --seed

$Python = Join-Path $VenvDir "Scripts\python.exe"
Write-Host "Installing packages from requirements.txt"
uv pip install --python $Python -r $Requirements

& $Python -m ipykernel install --user --name idea-llm --display-name "Python (IdeaProjects)" --force

$RuntimeDir = Join-Path (Split-Path -Parent $VenvDir) ".jupyter-runtime"
New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null
[System.Environment]::SetEnvironmentVariable("JUPYTER_RUNTIME_DIR", $RuntimeDir, "User")

Write-Host ""
Write-Host "Done."
Write-Host "Interpreter: $Python"
Write-Host "In PyCharm: Settings -> Python Interpreter -> Existing -> that python.exe"



