# SuperClaude Setup — Windows PowerShell
# Usage: .\setup.ps1

$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "=== SuperClaude Setup ===" -ForegroundColor Cyan

# 1. Copier settings.json
Write-Host "`n[1/4] Copie settings.json..." -ForegroundColor Yellow
$settingsSrc = Join-Path $PSScriptRoot "settings.json"
$settingsDst = Join-Path $ClaudeDir "settings.json"
if (Test-Path $settingsDst) {
    $backup = "$settingsDst.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $settingsDst $backup
    Write-Host "  Backup: $backup" -ForegroundColor Gray
}
Copy-Item $settingsSrc $settingsDst -Force
Write-Host "  OK: settings.json copie" -ForegroundColor Green

# 2. Copier obsidian.js
Write-Host "`n[2/4] Copie obsidian.js..." -ForegroundColor Yellow
$scriptsSrc = Join-Path $PSScriptRoot "scripts\obsidian.js"
$scriptsDst = Join-Path $ClaudeDir "scripts\obsidian.js"
New-Item -ItemType Directory -Path (Split-Path $scriptsDst) -Force | Out-Null
Copy-Item $scriptsSrc $scriptsDst -Force
Write-Host "  OK: obsidian.js copie" -ForegroundColor Green

# 3. Ajouter MCPs
Write-Host "`n[3/4] MCPs a ajouter manuellement:" -ForegroundColor Yellow
Write-Host "  claude mcp add magic --scope user --env API_KEY=`"VOTRE_KEY`" -- npx -y @21st-dev/magic@latest" -ForegroundColor Cyan
Write-Host "  claude mcp add playwright --scope user -- npx @playwright/mcp@latest" -ForegroundColor Cyan
Write-Host "  claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp" -ForegroundColor Cyan

# 4. Plugins
Write-Host "`n[4/4] Plugins a installer:" -ForegroundColor Yellow
Write-Host "  claude plugin install superpowers" -ForegroundColor Cyan
Write-Host "  claude plugin install impeccable" -ForegroundColor Cyan
Write-Host "  claude plugin install taste-skill" -ForegroundColor Cyan
Write-Host "  claude plugin install claude-mem" -ForegroundColor Cyan
Write-Host "  claude plugin install caveman" -ForegroundColor Cyan

Write-Host "`n=== Setup termine ===" -ForegroundColor Green
Write-Host "Ouvrir Claude Code dans ton projet et lancer le prompt de demarrage depuis docs/prompts.md" -ForegroundColor White
