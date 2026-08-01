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
Say 'Copie des skills vers ~/.claude...'
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'skills')  | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'scripts') | Out-Null
Copy-Item (Join-Path $Dest '.claude\skills\*')  (Join-Path $ClaudeDir 'skills')  -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Dest '.claude\scripts\*') (Join-Path $ClaudeDir 'scripts') -Recurse -Force -ErrorAction SilentlyContinue
Ok '15 skills + auto-router copies'

# 4b. Hooks - fusionner dans ~/.claude/settings.json (scope user)
# C'est ce fichier, pas juste les scripts, qui declenche reellement le routeur.
Say 'Activation des hooks (auto-routing) dans ~/.claude/settings.json...'
$SettingsDst = Join-Path $ClaudeDir 'settings.json'
$RouterPath   = Join-Path $ClaudeDir 'scripts\skill-router.js'
$ObsidianPath = Join-Path $ClaudeDir 'scripts\obsidian.js'

$s = $null
if (Test-Path $SettingsDst) {
  try { $s = Get-Content $SettingsDst -Raw | ConvertFrom-Json } catch { $s = $null }
}
if (-not $s) { $s = New-Object PSObject }
if (-not $s.PSObject.Properties['hooks']) {
  $s | Add-Member -NotePropertyName hooks -NotePropertyValue (New-Object PSObject) -Force
}

function Add-HookEntry($settingsObj, $eventName, $command) {
  if (-not $settingsObj.hooks.PSObject.Properties[$eventName]) {
    $settingsObj.hooks | Add-Member -NotePropertyName $eventName -NotePropertyValue @() -Force
  }
  $existing = @($settingsObj.hooks.$eventName)
  $already = $false
  foreach ($group in $existing) {
    foreach ($h in @($group.hooks)) {
      if ($h.command -eq $command) { $already = $true }
    }
  }
  if (-not $already) {
    $newGroup = [PSCustomObject]@{
      matcher = ''
      hooks   = @([PSCustomObject]@{ type = 'command'; command = $command })
    }
    $settingsObj.hooks.$eventName = $existing + $newGroup
  }
}

$routerCmd    = 'node --no-warnings "' + $RouterPath + '"'
$obsidianInj  = 'node --no-warnings "' + $ObsidianPath + '" inject-context'
$obsidianLog  = 'node --no-warnings "' + $ObsidianPath + '" session-log'

Add-HookEntry $s 'UserPromptSubmit' $routerCmd
Add-HookEntry $s 'UserPromptSubmit' $obsidianInj
Add-HookEntry $s 'Stop' $obsidianLog

$s | ConvertTo-Json -Depth 12 | Set-Content $SettingsDst
Ok 'Hooks actifs (settings.json fusionne, rien d ecrase)'

# 5. Cle Magic (optionnel, avant l'enregistrement MCP pour l'injecter)
$MagicKey = ''
if ([Environment]::UserInteractive -and $Host.UI.RawUI) {
  try { $MagicKey = Read-Host 'Cle API 21st.dev Magic (Entree pour ignorer)' }
  catch { Warn 'Prompt Magic saute (non-interactif).' }
}

# 6. MCP servers - scope user via `claude mcp add` (le seul chemin lu)
Say 'Activation des MCP (scope user)...'
if ($MagicKey) {
  claude mcp add -s user magic -e "API_KEY=$MagicKey" -- npx -y '@21st-dev/magic@latest' 2>$null
} else {
  claude mcp add -s user magic -- npx -y '@21st-dev/magic@latest' 2>$null
}
claude mcp add -s user playwright -- npx '@playwright/mcp@latest' 2>$null
claude mcp add -s user context7   -- npx -y '@upstash/context7-mcp' 2>$null
claude mcp add -s user claude-mem -- npx -y claude-mem 2>$null
claude mcp add -s user graphify   -- npx -y graphify-mcp 2>$null
Ok '5 MCP actifs (scope user)'

# 6b. Repos communaute (clone a l'install)
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

# 7. Utilitaires globaux
Say 'Outils video/memoire (hyperframes, remotion, claude-mem, graphify)...'
npm install -g hyperframes remotion claude-mem graphify-mcp 2>$null

# 8. Resume
Write-Host ''
Write-Host '--------------------------------------------' -ForegroundColor Magenta
Write-Host '  SuperClaude installe' -ForegroundColor Green
Write-Host '  22 plugins   15 skills   5 MCP (scope user)'
Write-Host '  5 repos communaute clones (~/.superclaude/vendor)'
Write-Host '  Hooks actifs - auto-routing reellement branche'
Write-Host ''
Write-Host '  Lance :  claude'
Write-Host '  Skills : claude /skills'
Write-Host '  MCP    : claude mcp list'
Write-Host '--------------------------------------------' -ForegroundColor Magenta
