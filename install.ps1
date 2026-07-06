# SuperClaude - install en une ligne (Windows)
#   iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/install.ps1 | iex
#
# NB: ASCII-only + erreurs non bloquantes -> compatible Windows PowerShell 5.1
# (pas de BOM requis, pas d'abort sur stderr natif).
$ErrorActionPreference = 'Continue'

$Repo      = 'https://github.com/Makooff/SuperClaude'
$Dest      = if ($env:SUPERCLAUDE_HOME) { $env:SUPERCLAUDE_HOME } else { Join-Path $HOME '.superclaude' }
$ClaudeDir = Join-Path $HOME '.claude'

function Say  ($m) { Write-Host "> $m" -ForegroundColor Magenta }
function Ok   ($m) { Write-Host "[ok] $m" -ForegroundColor Green }
function Warn ($m) { Write-Host "[!] $m" -ForegroundColor Yellow }
function Have ($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# 1. Prerequis
Say 'Verification des prerequis...'
if (-not (Have 'node')) { Warn 'Node.js absent. Installe Node 20+ : https://nodejs.org puis relance.'; return }
Ok  ("Node " + (node -v))
if (-not (Have 'git'))  { Warn 'git requis : https://git-scm.com'; return }
Ok  'git present'
if (-not (Have 'claude')) {
  Say 'Installation de Claude Code...'
  npm install -g '@anthropic-ai/claude-code'
}
Ok 'Claude Code present'

# 2. Clone / update
if (Test-Path (Join-Path $Dest '.git')) {
  Say "Mise a jour de SuperClaude ($Dest)..."
  git -C $Dest pull --ff-only
} else {
  Say "Clonage de SuperClaude -> $Dest"
  git clone --depth 1 $Repo $Dest
}
Ok 'Repo pret'

# 3. Marketplaces + plugins
Say 'Ajout des marketplaces...'
claude plugin marketplace add JuliusBrussee/caveman  2>$null
claude plugin marketplace add wshobson/agents        2>$null
claude plugin marketplace add thedotmack/claude-mem  2>$null

Say 'Installation des plugins (peut prendre une minute)...'
$official = @('superpowers','code-review','github','vercel','supabase','stripe','caveman',
              'claude-md-management','context7','skill-creator','playwright')
foreach ($p in $official) { claude plugin install $p 2>$null }
claude plugin install 'claude-mem@thedotmack' 2>$null

# wshobson/agents s'enregistre sous le nom de marketplace "claude-code-workflows".
# On tente ce suffixe, puis le pack nu en repli.
$packs = @('comprehensive-review','debugging-toolkit','unit-testing','security-scanning',
           'full-stack-orchestration','frontend-mobile-development','ui-design',
           'cicd-automation','agent-orchestration','application-performance')
foreach ($p in $packs) {
  claude plugin install "$p@claude-code-workflows" 2>$null
  if ($LASTEXITCODE -ne 0) { claude plugin install $p 2>$null }
}
Ok 'Plugins installes'

# 4. Skills + scripts
Say 'Copie des skills et hooks vers ~/.claude...'
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'skills')  | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'scripts') | Out-Null
Copy-Item (Join-Path $Dest '.claude\skills\*')  (Join-Path $ClaudeDir 'skills')  -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Dest '.claude\scripts\*') (Join-Path $ClaudeDir 'scripts') -Recurse -Force -ErrorAction SilentlyContinue
Ok '15 skills + auto-router copies'

# 5. MCP servers
Say 'Configuration des MCP...'
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
Ok '5 MCP configures'

# 5b. Repos communaute (clone a l'install)
$Vendor       = Join-Path $Dest 'vendor'
$SkillsVendor = Join-Path $ClaudeDir 'skills\vendor'
Say "Clonage des repos communaute -> $Vendor..."
New-Item -ItemType Directory -Force -Path $Vendor       | Out-Null
New-Item -ItemType Directory -Force -Path $SkillsVendor | Out-Null

$community = @(
  'hardikpandya/stop-slop',
  'coreyhaines31/marketingskills',
  'muratcankoylan/Agent-Skills-for-Context-Engineering',
  'shanraisshan/claude-code-best-practice',
  'Panniantong/Agent-Reach'
)
foreach ($repo in $community) {
  $name   = $repo.Split('/')[-1]
  $target = Join-Path $Vendor $name
  if (Test-Path (Join-Path $target '.git')) {
    git -C $target pull --ff-only 2>$null
  } else {
    git clone --depth 1 "https://github.com/$repo" $target 2>$null
    if ($LASTEXITCODE -eq 0) { Ok "clone $repo" } else { Warn "echec clone $repo (non bloquant)" }
  }
  $skillsDir = Join-Path $target 'skills'
  if (Test-Path $skillsDir) {
    $ns = Join-Path $SkillsVendor $name
    New-Item -ItemType Directory -Force -Path $ns | Out-Null
    Copy-Item (Join-Path $skillsDir '*') $ns -Recurse -Force -ErrorAction SilentlyContinue
  }
}
$ss = Join-Path $Vendor 'stop-slop\SKILL.md'
if (Test-Path $ss) {
  $nsss = Join-Path $SkillsVendor 'stop-slop'
  New-Item -ItemType Directory -Force -Path $nsss | Out-Null
  Copy-Item (Join-Path $Vendor 'stop-slop\SKILL.md')   $nsss -Force -ErrorAction SilentlyContinue
  Copy-Item (Join-Path $Vendor 'stop-slop\references') $nsss -Recurse -Force -ErrorAction SilentlyContinue
}
claude plugin marketplace add coreyhaines31/marketingskills 2>$null
claude plugin marketplace add muratcankoylan/Agent-Skills-for-Context-Engineering 2>$null
Ok '5 repos communaute clones + namespaces'

# Agent-Reach - CLI Python
if ((Have 'pip') -or (Have 'pip3') -or (Have 'pipx')) {
  Say "Installation d'Agent-Reach (CLI web)..."
  pip install agent-reach 2>$null
  if ($LASTEXITCODE -ne 0) { pipx install agent-reach 2>$null }
  Ok 'agent-reach installe (si pip present)'
}

# 6. Utilitaires globaux
Say 'Outils video/memoire (hyperframes, remotion, claude-mem, graphify)...'
npm install -g hyperframes remotion claude-mem graphify-mcp 2>$null

# 7. Cle Magic (optionnel) - saute si non-interactif (evite le hang sous iex)
if ([Environment]::UserInteractive -and $Host.UI.RawUI) {
  try {
    $magic = Read-Host 'Cle API 21st.dev Magic (Entree pour ignorer)'
    if ($magic) { Add-Content (Join-Path $ClaudeDir '.env') "MAGIC_API_KEY=$magic"; Ok 'Cle Magic enregistree' }
  } catch { Warn 'Prompt Magic saute (non-interactif). Ajoute MAGIC_API_KEY dans ~/.claude/.env plus tard.' }
}

# 8. Resume
Write-Host ''
Write-Host '--------------------------------------------' -ForegroundColor Magenta
Write-Host '  SuperClaude installe' -ForegroundColor Green
Write-Host '  22 plugins   15 skills   5 MCP'
Write-Host '  5 repos communaute clones (~/.superclaude/vendor)'
Write-Host '  Auto-routing actif (skills invoques tout seuls)'
Write-Host ''
Write-Host '  Lance :  claude'
Write-Host '  Skills : claude /skills'
Write-Host '--------------------------------------------' -ForegroundColor Magenta
