# SuperClaude Lite - installe le strict necessaire, rien d'autre (Windows).
#   iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.ps1 | iex
#
# ASCII-only + erreurs non bloquantes -> compatible Windows PowerShell 5.1.
param(
  [switch]$NoDesign, [switch]$NoDev, [switch]$NoSecurity,
  [switch]$WithMagic, [switch]$WithPlaywright, [switch]$WithContext7,
  [switch]$ReplaceFull
)
$ErrorActionPreference = 'Continue'

$Repo      = 'https://github.com/Makooff/SuperClaude'
$Dest      = if ($env:SUPERCLAUDE_HOME) { $env:SUPERCLAUDE_HOME } else { Join-Path $HOME '.superclaude' }
$ClaudeDir = Join-Path $HOME '.claude'

function Say  ($m) { Write-Host "> $m"    -ForegroundColor Magenta }
function Ok   ($m) { Write-Host "[ok] $m" -ForegroundColor Green }
function Warn ($m) { Write-Host "[!] $m"  -ForegroundColor Yellow }
function Have ($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# 1. Prerequis ----------------------------------------------------------------
if (-not (Have node)) { Warn 'Node.js 18+ requis : https://nodejs.org'; exit 1 }
if ([int](node -p 'process.versions.node.split(".")[0]') -lt 18) { Warn 'Node 18+ requis.'; exit 1 }
if (-not (Have git))  { Warn 'git requis.'; exit 1 }
if (-not (Have claude)) { Say 'Installation de Claude Code...'; npm install -g '@anthropic-ai/claude-code' }
Ok "Prerequis ok - node $(node -v)"

# 2. Source -------------------------------------------------------------------
$Src = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Src 'lite/CLAUDE.lite.md'))) {
  if (Test-Path (Join-Path $Dest '.git')) { git -C $Dest pull --ff-only 2>$null | Out-Null }
  else { Say "Clonage -> $Dest"; git clone --depth 1 $Repo $Dest 2>$null | Out-Null }
  $Src = $Dest
}
Ok "Source : $Src"

# 3. Nettoyage de l'ancien setup complet --------------------------------------
if ($ReplaceFull) {
  Say 'Desinstallation du setup complet...'
  $full = @('github','vercel','supabase','stripe','claude-md-management','skill-creator',
            'context7','playwright','claude-mem','comprehensive-review','debugging-toolkit',
            'unit-testing','security-scanning','full-stack-orchestration',
            'frontend-mobile-development','ui-design','cicd-automation',
            'agent-orchestration','application-performance')
  foreach ($p in $full) { claude plugin uninstall $p 2>$null | Out-Null }
  foreach ($m in @('magic','playwright','context7')) { claude mcp remove -s user $m 2>$null | Out-Null }
  $bak = Join-Path $ClaudeDir ('skills.bak-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
  $vendor = Join-Path $ClaudeDir 'skills/vendor'
  if (Test-Path $vendor) { New-Item -ItemType Directory -Force -Path $bak | Out-Null; Move-Item $vendor (Join-Path $bak 'vendor') }
  foreach ($f in @('impeccable.md','taste-skill.md','tdd-workflow.md','security.md','video-generation.md')) {
    $fp = Join-Path $ClaudeDir "skills/$f"
    if (Test-Path $fp) { New-Item -ItemType Directory -Force -Path $bak | Out-Null; Move-Item $fp $bak }
  }
  if (Test-Path $bak) { Ok "Anciens fichiers deplaces -> $bak" }
  Ok '19 plugins + 10 packs retires'
}

# 4. Plugins (3) --------------------------------------------------------------
Say 'Plugins...'
claude plugin marketplace add JuliusBrussee/caveman 2>$null | Out-Null
claude plugin install superpowers 2>$null | Out-Null
claude plugin install 'caveman@caveman' 2>$null | Out-Null
if (-not $NoDev) { claude plugin install code-review 2>$null | Out-Null; Ok '3 plugins : superpowers, caveman, code-review' }
else { Ok '2 plugins : superpowers, caveman' }

# 5. Skills (whitelist stricte) -----------------------------------------------
$skills = @('context-engineering')
if (-not $NoDesign)   { $skills += @('product-design','impeccable','taste-skill','emil-design-eng','review-animations') }
if (-not $NoDev)      { $skills += @('tdd-workflow','agentic-practice') }
if (-not $NoSecurity) { $skills += @('security') }

Say 'Skills...'
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'skills'), (Join-Path $ClaudeDir 'scripts') | Out-Null
foreach ($s in $skills) {
  $from = Join-Path $Src "lite/skills/$s"
  if (-not (Test-Path $from)) { $from = Join-Path $Src ".claude/skills/$s" }
  if (-not (Test-Path $from)) { Warn "skill introuvable : $s"; continue }
  $to = Join-Path $ClaudeDir "skills/$s"
  if (Test-Path $to) { Remove-Item -Recurse -Force $to }
  Copy-Item -Recurse $from $to
}
Ok "$($skills.Count) skills -> ~/.claude/skills"

# 5b. ui-ux-pro-max (118k etoiles) - uniquement le dossier du skill -----------
if (-not $NoDesign) {
  Say 'ui-ux-pro-max (192 palettes, 74 pairings typo, 119 regles UX)...'
  $uiuxSrc = Join-Path $Dest 'vendor/ui-ux-pro-max'
  $uiuxSub = '.claude/skills/ui-ux-pro-max'
  if (Test-Path (Join-Path $uiuxSrc '.git')) { git -C $uiuxSrc pull --ff-only 2>$null | Out-Null }
  else {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $uiuxSrc) | Out-Null
    git clone --depth 1 --filter=blob:none --sparse `
      'https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git' $uiuxSrc 2>$null | Out-Null
    if (Test-Path (Join-Path $uiuxSrc '.git')) { git -C $uiuxSrc sparse-checkout set $uiuxSub 2>$null | Out-Null }
    else { Warn 'clone ui-ux-pro-max echoue (non bloquant)' }
  }
  $uiuxFrom = Join-Path $uiuxSrc $uiuxSub
  if (Test-Path $uiuxFrom) {
    $to = Join-Path $ClaudeDir 'skills/ui-ux-pro-max'
    if (Test-Path $to) { Remove-Item -Recurse -Force $to }
    Copy-Item -Recurse $uiuxFrom $to
    Ok 'ui-ux-pro-max installe (~150 tok en contexte)'
  }
}

# 6. Router (1 seul hook) -----------------------------------------------------
Copy-Item (Join-Path $Src 'lite/scripts/skill-router-lite.js') (Join-Path $ClaudeDir 'scripts') -Force
Copy-Item (Join-Path $Src 'lite/scripts/sc-mcp.ps1')           (Join-Path $ClaudeDir 'scripts') -Force

$mergeHooks = @'
  const fs = require("fs");
  const [dst, router] = process.argv.slice(1);
  const cmd = "node --no-warnings \"" + router + "\"";
  let s = {};
  try { s = JSON.parse(fs.readFileSync(dst, "utf8")); } catch {}
  s.hooks = s.hooks || {};
  for (const ev of Object.keys(s.hooks)) {
    s.hooks[ev] = (s.hooks[ev] || [])
      .map(g => ({ ...g, hooks: (g.hooks || []).filter(h =>
        !/obsidian\.js|skill-router\.js|self-learn\.js/.test(h.command || "")) }))
      .filter(g => (g.hooks || []).length);
    if (!s.hooks[ev].length) delete s.hooks[ev];
  }
  s.hooks.UserPromptSubmit = s.hooks.UserPromptSubmit || [];
  const already = s.hooks.UserPromptSubmit.some(g => (g.hooks || []).some(h => h.command === cmd));
  if (!already) s.hooks.UserPromptSubmit.push({ matcher: "", hooks: [{ type: "command", command: cmd }] });
  fs.writeFileSync(dst, JSON.stringify(s, null, 2));
'@
node -e $mergeHooks (Join-Path $ClaudeDir 'settings.json') (Join-Path $ClaudeDir 'scripts/skill-router-lite.js')
Ok '1 hook actif (router lite) - hooks Obsidian/self-learn retires'

# 7. CLAUDE.md global - bloc delimite ----------------------------------------
$mergeMd = @'
  const fs = require("fs");
  const [dst, src] = process.argv.slice(1);
  const S = "<!-- superclaude-lite:start -->", E = "<!-- superclaude-lite:end -->";
  const block = S + "\n" + fs.readFileSync(src, "utf8").trim() + "\n" + E;
  let cur = "";
  try { cur = fs.readFileSync(dst, "utf8"); } catch {}
  const i = cur.indexOf(S), j = cur.indexOf(E);
  const next = (i !== -1 && j !== -1)
    ? cur.slice(0, i) + block + cur.slice(j + E.length)
    : (cur.trim() ? cur.trimEnd() + "\n\n" : "") + block + "\n";
  fs.writeFileSync(dst, next);
'@
node -e $mergeMd (Join-Path $ClaudeDir 'CLAUDE.md') (Join-Path $Src 'lite/CLAUDE.lite.md')
Ok '~/.claude/CLAUDE.md - bloc superclaude-lite ecrit (reste du fichier intact)'

# 8. MCP ----------------------------------------------------------------------
Say 'MCP memoire (noyau)...'
claude mcp add -s user claude-mem -- npx -y claude-mem   2>$null | Out-Null
claude mcp add -s user graphify   -- npx -y graphify-mcp 2>$null | Out-Null
Ok 'claude-mem + graphify'

if ($WithMagic)      { claude mcp add -s user magic      -- npx -y '@21st-dev/magic@latest' 2>$null | Out-Null; Ok 'magic active' }
if ($WithPlaywright) { claude mcp add -s user playwright -- npx '@playwright/mcp@latest'    2>$null | Out-Null; Ok 'playwright active' }
if ($WithContext7)   { claude mcp add -s user context7   -- npx -y '@upstash/context7-mcp'  2>$null | Out-Null; Ok 'context7 active' }

# 9. Resume -------------------------------------------------------------------
Write-Host ''
Write-Host '--------------------------------------------' -ForegroundColor Magenta
Write-Host '  SuperClaude Lite installe' -ForegroundColor Green
Write-Host ''
Write-Host '  Noyau (permanent) : superpowers (273k *) . caveman . context-engineering'
Write-Host '                      MCP claude-mem (91k *) + graphify'
Write-Host "  A la demande      : $($skills.Count) skills locaux + ui-ux-pro-max (118k *)"
Write-Host '  MCP lourds        : eteints - sc-mcp magic on / playwright / context7'
Write-Host ''
Write-Host '  Non installe      : 19 plugins, 10 packs wshobson, 4 repos vendor,'
Write-Host '                      npm globaux, pip, hooks Obsidian'
Write-Host ''
Write-Host '  Verifier : claude plugin list . claude mcp list . ls ~/.claude/skills'
Write-Host '--------------------------------------------' -ForegroundColor Magenta
