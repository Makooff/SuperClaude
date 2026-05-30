# SuperClaude — build the desktop app (Windows)
$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\installer-app"
Write-Host "==> npm install" -ForegroundColor Yellow
npm install
Write-Host "==> build Windows app" -ForegroundColor Yellow
npm run build-win
Write-Host "==> Done. Artefact dans installer-app\dist\" -ForegroundColor Green
