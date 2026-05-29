# SuperClaude — Bootstrap Nouveau Projet (Windows PowerShell)
# Usage: .\new-project.ps1 -Name MonProjet [-Path C:\Projets\MonProjet]

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location).Path
)

$SuperClaudePath = $PSScriptRoot

Write-Host ""
Write-Host "=== SuperClaude — Nouveau Projet ===" -ForegroundColor Cyan
Write-Host "  Vault Obsidian : $Name" -ForegroundColor Gray
Write-Host "  Chemin projet  : $Path" -ForegroundColor Gray
Write-Host ""

# --- Create project directory ---
Write-Host "[1/4] Creation du dossier projet..." -ForegroundColor Yellow
if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Write-Host "  OK: dossier cree -> $Path" -ForegroundColor Green
} else {
    Write-Host "  OK: dossier existant -> $Path" -ForegroundColor Green
}

# --- Copy SuperClaude config ---
Write-Host ""
Write-Host "[2/4] Copie de la config SuperClaude..." -ForegroundColor Yellow

# .claude/
$claudeSrc = Join-Path $SuperClaudePath ".claude"
$claudeDst = Join-Path $Path ".claude"
if (Test-Path $claudeSrc) {
    Copy-Item -Recurse -Force $claudeSrc $claudeDst
    Write-Host "  OK: .claude/" -ForegroundColor Green
} else {
    Write-Host "  WARN: .claude/ non trouve dans SuperClaude" -ForegroundColor DarkYellow
}

# CLAUDE.md
$claudeMdSrc = Join-Path $SuperClaudePath "CLAUDE.md"
if (Test-Path $claudeMdSrc) {
    Copy-Item -Force $claudeMdSrc (Join-Path $Path "CLAUDE.md")
    Write-Host "  OK: CLAUDE.md" -ForegroundColor Green
}

# .mcp.json
$mcpSrc = Join-Path $SuperClaudePath ".mcp.json"
if (Test-Path $mcpSrc) {
    Copy-Item -Force $mcpSrc (Join-Path $Path ".mcp.json")
    Write-Host "  OK: .mcp.json" -ForegroundColor Green
}

# .env.example -> .env.local
$envSrc = Join-Path $SuperClaudePath ".env.example"
$envDst = Join-Path $Path ".env.local"
if (Test-Path $envSrc) {
    Copy-Item -Force $envSrc $envDst
    Write-Host "  OK: .env.example -> .env.local" -ForegroundColor Green
} else {
    Write-Host "  WARN: .env.example non trouve" -ForegroundColor DarkYellow
}

# --- Interactive secrets ---
Write-Host ""
Write-Host "[3/4] Configuration des secrets..." -ForegroundColor Yellow
Write-Host "  (Obsidian -> Settings -> Local REST API -> copier la cle)" -ForegroundColor Gray
Write-Host ""

$obsidianKey = Read-Host "  OBSIDIAN_API_KEY"
$magicKey    = Read-Host "  MAGIC_API_KEY (21st.dev, laisser vide si pas encore)"

# Write .env.local with filled values
$envContent = @"
# SuperClaude — Secrets projet
# NE JAMAIS commiter ce fichier

# Obsidian Local REST API
OBSIDIAN_API_KEY=$obsidianKey
OBSIDIAN_API_HOST=127.0.0.1
OBSIDIAN_API_PORT=27124

# Nom du vault Obsidian pour ce projet
OBSIDIAN_VAULT=$Name

# 21st.dev Magic MCP
MAGIC_API_KEY=$magicKey
"@

Set-Content -Path $envDst -Value $envContent -Encoding UTF8
Write-Host ""
Write-Host "  OK: .env.local rempli" -ForegroundColor Green

# --- .gitignore ---
Write-Host ""
Write-Host "[4/4] Mise a jour .gitignore..." -ForegroundColor Yellow
$gitignorePath = Join-Path $Path ".gitignore"
$envEntry = ".env.local"

if (Test-Path $gitignorePath) {
    $content = Get-Content $gitignorePath -Raw
    if ($content -notmatch [regex]::Escape($envEntry)) {
        Add-Content -Path $gitignorePath -Value "`n$envEntry"
        Write-Host "  OK: .env.local ajoute au .gitignore existant" -ForegroundColor Green
    } else {
        Write-Host "  OK: .env.local deja dans .gitignore" -ForegroundColor Green
    }
} else {
    Set-Content -Path $gitignorePath -Value $envEntry -Encoding UTF8
    Write-Host "  OK: .gitignore cree avec .env.local" -ForegroundColor Green
}

# --- Summary ---
Write-Host ""
Write-Host "=== Projet pret ===" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor White
Write-Host "  1. Dans Obsidian, creer le dossier : $Name/" -ForegroundColor Cyan
Write-Host "     avec Taches.md, Decisions.md, PRODUCT.md, Sessions/" -ForegroundColor Gray
Write-Host "  2. Ouvrir le projet dans VS Code : $Path" -ForegroundColor Cyan
Write-Host "  3. Claude Code -> nouveau chat -> premier message" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Obsidian doit etre ouvert pour la memoire cross-session." -ForegroundColor Gray
Write-Host ""
