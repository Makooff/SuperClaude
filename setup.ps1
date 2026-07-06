# SuperClaude Setup — Windows PowerShell
# Usage: .\setup.ps1
# Run once per machine to install Claude Code plugins and MCP servers

Write-Host ""
Write-Host "=== SuperClaude Machine Setup ===" -ForegroundColor Cyan
Write-Host ""

# --- Check prerequisites ---
Write-Host "[0/3] Verification des prerequis..." -ForegroundColor Yellow

$nodeOk = $false
$claudeOk = $false

try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK: Node.js $nodeVersion" -ForegroundColor Green
        $nodeOk = $true
    }
} catch {}
if (-not $nodeOk) {
    Write-Host "  ERREUR: Node.js non trouve. Installer depuis https://nodejs.org" -ForegroundColor Red
    exit 1
}

try {
    $claudeVersion = claude --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK: Claude Code $claudeVersion" -ForegroundColor Green
        $claudeOk = $true
    }
} catch {}
if (-not $claudeOk) {
    Write-Host "  ERREUR: Claude Code non trouve. Installer depuis https://claude.ai/code" -ForegroundColor Red
    exit 1
}

# --- Install plugins ---
Write-Host ""
Write-Host "[1/3] Installation plugins Claude Code..." -ForegroundColor Yellow
# NB: impeccable/taste-skill sont des skills locaux (pas des plugins marketplace) —
# ils sont copiés dans ~/.claude/skills plus bas, pas installés via plugin.
$plugins = @("superpowers", "caveman", "claude-mem", "context7", "playwright")
foreach ($p in $plugins) {
    Write-Host "  Installing $p..." -ForegroundColor Gray
    claude plugin install $p 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK: $p" -ForegroundColor Green
    } else {
        Write-Host "  WARN: $p (deja installe ou erreur, on continue)" -ForegroundColor DarkYellow
    }
}

# --- Skills locaux (impeccable, taste-skill, product-design, etc.) ---
$skillsSrc = Join-Path $PSScriptRoot ".claude\skills"
$skillsDst = Join-Path $HOME ".claude\skills"
if (Test-Path $skillsSrc) {
    New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null
    Copy-Item (Join-Path $skillsSrc '*') $skillsDst -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  OK: skills locaux copies vers ~/.claude/skills" -ForegroundColor Green
}

# --- Magic API key ---
Write-Host ""
Write-Host "[2/3] Configuration MCP Magic (21st.dev)..." -ForegroundColor Yellow
Write-Host "  Obtenir la cle sur: https://21st.dev/magic/console" -ForegroundColor Gray
Write-Host ""
$magicKey = Read-Host "  Entrer ta Magic API key (laisser vide pour ignorer)"

# --- Add MCP servers ---
Write-Host ""
Write-Host "[3/3] Ajout des MCP servers..." -ForegroundColor Yellow

if ($magicKey -ne "") {
    Write-Host "  Adding magic..." -ForegroundColor Gray
    claude mcp add magic --scope user --env "API_KEY=$magicKey" -- npx -y @21st-dev/magic@latest 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK: magic" -ForegroundColor Green
    } else {
        Write-Host "  WARN: magic (erreur lors de l'ajout, verifier la cle)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  SKIP: magic (pas de cle fournie)" -ForegroundColor DarkYellow
}

Write-Host "  Adding playwright..." -ForegroundColor Gray
claude mcp add playwright --scope user -- npx @playwright/mcp@latest 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK: playwright" -ForegroundColor Green
} else {
    Write-Host "  WARN: playwright (deja configure ou erreur)" -ForegroundColor DarkYellow
}

Write-Host "  Adding context7..." -ForegroundColor Gray
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK: context7" -ForegroundColor Green
} else {
    Write-Host "  WARN: context7 (deja configure ou erreur)" -ForegroundColor DarkYellow
}

# --- Summary ---
Write-Host ""
Write-Host "=== Setup termine ===" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor White
Write-Host "  1. Bootstrapper un projet :  .\new-project.ps1 -Name MonProjet" -ForegroundColor Cyan
Write-Host "  2. Ouvrir Claude Code dans le projet -> tout fonctionne" -ForegroundColor White
Write-Host ""
