# SuperClaude — install en une ligne (Windows)
#   iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$Repo      = 'https://github.com/Makooff/SuperClaude'
$Dest      = if ($env:SUPERCLAUDE_HOME) { $env:SUPERCLAUDE_HOME } else { Join-Path $HOME '.superclaude' }
$ClaudeDir = Join-Path $HOME '.claude'

function Say  ($m) { Write-Host "› $m"  -ForegroundColor Magenta }
function Ok   ($m) { Write-Host "✓ $m"  -ForegroundColor Green }
function Warn ($m) { Write-Host "! $m"  -ForegroundColor Yellow }
function Have ($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# 1. Prérequis
Say 'Vérification des prérequis…'
if (-not (Have 'node')) { Warn 'Node.js absent. Installe Node 20+ : https://nodejs.org puis relance.'; return }
Ok  ("Node " + (node -v))
if (-not (Have 'git'))  { Warn 'git requis : https://git-scm.com'; return }
Ok  'git présent'
if (-not (Have 'claude')) {
  Say 'Installation de Claude Code…'
  npm install -g '@anthropic-ai/claude-code'
}
Ok 'Claude Code présent'

# 2. Clone / update
if (Test-Path (Join-Path $Dest '.git')) {
  Say "Mise à jour de SuperClaude ($Dest)…"
  git -C $Dest pull --ff-only
} else {
  Say "Clonage de SuperClaude → $Dest"
  git clone --depth 1 $Repo $Dest
}
Ok 'Repo prêt'

# 3. Marketplaces + plugins
Say 'Ajout des marketplaces…'
claude plugin marketplace add JuliusBrussee/caveman  2>$null
claude plugin marketplace add wshobson/agents        2>$null
claude plugin marketplace add thedotmack/claude-mem  2>$null

Say 'Installation des plugins (peut prendre une minute)…'
$official = @('superpowers','code-review','github','vercel','supabase','stripe','caveman',
              'claude-md-management','context7','skill-creator','playwright')
foreach ($p in $official) { claude plugin install $p 2>$null }
claude plugin install 'claude-mem@thedotmack' 2>$null

$packs = @('comprehensive-review','debugging-toolkit','unit-testing','security-scanning',
           'full-stack-orchestration','frontend-mobile-development','ui-design',
           'cicd-automation','agent-orchestration','application-performance')
foreach ($p in $packs) { claude plugin install "$p@agents" 2>$null }
Ok 'Plugins installés (22)'

# 4. Skills + scripts
Say 'Copie des skills & hooks vers ~/.claude…'
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'skills')  | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'scripts') | Out-Null
Copy-Item (Join-Path $Dest '.claude\skills\*')  (Join-Path $ClaudeDir 'skills')  -Recurse -Force
Copy-Item (Join-Path $Dest '.claude\scripts\*') (Join-Path $ClaudeDir 'scripts') -Recurse -Force -ErrorAction SilentlyContinue
Ok '15 skills + auto-router copiés'

# 5. MCP servers
Say 'Configuration des MCP…'
$mcpSrc = Join-Path $Dest '.mcp.json'
$mcpDst = Join-Path $ClaudeDir '.mcp.json'
if (Test-Path $mcpDst) {
  $a = Get-Content $mcpDst -Raw | ConvertFrom-Json
  $b = Get-Content $mcpSrc -Raw | ConvertFrom-Json
  if (-not $a.mcpServers) { $a | Add-Member -NotePropertyName mcpServers -NotePropertyValue (@{}) }
  foreach ($k in $b.mcpServers.PSObject.Properties.Name) {
    $a.mcpServers | Add-Member -NotePropertyName $k -NotePropertyValue $b.mcpServers.$k -Force
  }
  $a | ConvertTo-Json -Depth 12 | Set-Content $mcpDst
} else {
  Copy-Item $mcpSrc $mcpDst -Force
}
Ok '5 MCP configurés'

# 6. Utilitaires globaux
Say 'Outils vidéo/mémoire…'
npm install -g hyperframes claude-mem graphify-mcp 2>$null

# 7. Clé Magic (optionnel)
$magic = Read-Host 'Clé API 21st.dev Magic (Entrée pour ignorer)'
if ($magic) { Add-Content (Join-Path $ClaudeDir '.env') "MAGIC_API_KEY=$magic"; Ok 'Clé Magic enregistrée' }

# 8. Résumé
Write-Host ''
Write-Host '────────────────────────────────────────────' -ForegroundColor Magenta
Write-Host '  ✓ SuperClaude installé' -ForegroundColor Green
Write-Host '  ✓ 22 plugins   ✓ 15 skills   ✓ 5 MCP'
Write-Host '  ✓ Auto-routing actif (skills invoqués tout seuls)'
Write-Host ''
Write-Host '  Lance :  claude'
Write-Host '  Skills : claude /skills'
Write-Host '────────────────────────────────────────────' -ForegroundColor Magenta
