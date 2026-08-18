# SuperClaude Lite - installe exactement la liste choisie, rien d'autre (Windows).
#   iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.ps1 | iex
#
# ASCII-only + erreurs non bloquantes -> compatible Windows PowerShell 5.1
param(
  [switch]$WithVercelSkills, [switch]$WithStripeSkills, [switch]$WithSupabaseSkills,
  [switch]$WithSecurity, [switch]$WithTdd,
  [switch]$NoAgentReach, [switch]$NoMcp, [switch]$ReplaceFull
)
$ErrorActionPreference = 'Continue'

$Repo      = 'https://github.com/Makooff/SuperClaude'
$Dest      = if ($env:SUPERCLAUDE_HOME) { $env:SUPERCLAUDE_HOME } else { "$HOME\.superclaude" }
$ClaudeDir = "$HOME\.claude"

function Say  ($m) { Write-Host "> $m"    -ForegroundColor Magenta }
function Ok   ($m) { Write-Host "[ok] $m" -ForegroundColor Green }
function Warn ($m) { Write-Host "[!] $m"  -ForegroundColor Yellow }
function Have ($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# 1. Prerequis
if (-not (Have node)) { Warn 'Node.js 18+ requis : https://nodejs.org'; exit 1 }
if (-not (Have git))  { Warn 'git requis.'; exit 1 }
if (-not (Have claude)) { Say 'Installation de Claude Code...'; npm install -g '@anthropic-ai/claude-code' }
Ok "node $(node -v)"

# 2. Source
$Src = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "$Src\lite\CLAUDE.lite.md")) {
  if (Test-Path "$Dest\.git") { git -C $Dest pull --ff-only 2>$null }
  else { Say "Clonage -> $Dest"; git clone --depth 1 $Repo $Dest 2>$null }
  $Src = $Dest
}
Ok "Source : $Src"

# 3. Retrait de l'ancien setup complet
if ($ReplaceFull) {
  Say 'Retrait du setup complet...'
  $old = @('claude-md-management','skill-creator','comprehensive-review','debugging-toolkit',
           'unit-testing','security-scanning','full-stack-orchestration',
           'frontend-mobile-development','ui-design','cicd-automation',
           'agent-orchestration','application-performance')
  foreach ($p in $old) { claude plugin uninstall $p 2>$null }
  claude mcp remove -s user graphify 2>$null
  claude mcp remove -s user magic 2>$null
  $bak = "$ClaudeDir\skills.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
  foreach ($n in @('vendor','product-design','nova-agency','prose-clean','agentic-practice')) {
    if (Test-Path "$ClaudeDir\skills\$n") { New-Item -ItemType Directory -Force -Path $bak | Out-Null; Move-Item "$ClaudeDir\skills\$n" "$bak\" }
  }
  foreach ($f in @('impeccable.md','taste-skill.md','tdd-workflow.md','security.md','video-generation.md')) {
    if (Test-Path "$ClaudeDir\skills\$f") { New-Item -ItemType Directory -Force -Path $bak | Out-Null; Move-Item "$ClaudeDir\skills\$f" "$bak\" }
  }
  Ok '12 plugins + graphify + magic retires'
}

# 4. Plugins constants
Say 'Plugins...'
claude plugin marketplace add JuliusBrussee/caveman 2>$null
claude plugin install superpowers 2>$null
claude plugin install 'caveman@caveman' 2>$null
claude plugin install code-review 2>$null
Ok 'superpowers . caveman . code-review'
if ($WithVercelSkills)   { claude plugin install vercel 2>$null;   Warn 'plugin vercel : ~3800 tokens permanents' }
if ($WithStripeSkills)   { claude plugin install stripe 2>$null }
if ($WithSupabaseSkills) { claude plugin install supabase 2>$null }

# 5. claude-mem (l'installeur enregistre les 5 hooks)
Say 'Memoire cross-session...'
npx -y claude-mem install 2>$null
Ok 'claude-mem - 5 hooks actifs (sinon : npx claude-mem install)'

# 6. Skills
$skills = @('context-engineering','impeccable','taste-skill','emil-design-eng',
            'review-animations','animation-vocabulary','marketing-growth','web-research')
if ($WithSecurity) { $skills += 'security' }
if ($WithTdd)      { $skills += 'tdd-workflow' }

Say 'Skills...'
New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills","$ClaudeDir\scripts" | Out-Null
foreach ($s in $skills) {
  $from = if (Test-Path "$Src\lite\skills\$s") { "$Src\lite\skills\$s" }
          elseif (Test-Path "$Src\.claude\skills\$s") { "$Src\.claude\skills\$s" } else { $null }
  if (-not $from) { Warn "skill introuvable : $s"; continue }
  if (Test-Path "$ClaudeDir\skills\$s") { Remove-Item -Recurse -Force "$ClaudeDir\skills\$s" }
  Copy-Item -Recurse $from "$ClaudeDir\skills\$s"
}
Ok "$($skills.Count) skills -> ~/.claude/skills"

# 7. Hook de combinaison + outil sc
Copy-Item "$Src\lite\scripts\skill-router-lite.js" "$ClaudeDir\scripts\" -Force
Copy-Item "$Src\lite\scripts\sc.ps1" "$ClaudeDir\scripts\" -Force

$mergeHooks = @'
  const fs = require("fs");
  const [dst, router] = process.argv.slice(1);
  const cmd = "node --no-warnings \"" + router + "\"";
  let s = {}; try { s = JSON.parse(fs.readFileSync(dst, "utf8")); } catch {}
  s.hooks = s.hooks || {};
  for (const ev of Object.keys(s.hooks)) {
    s.hooks[ev] = (s.hooks[ev] || [])
      .map(g => ({ ...g, hooks: (g.hooks || []).filter(h =>
        !/obsidian\.js|skill-router\.js|self-learn\.js/.test(h.command || "")) }))
      .filter(g => (g.hooks || []).length);
    if (!s.hooks[ev].length) delete s.hooks[ev];
  }
  s.hooks.UserPromptSubmit = s.hooks.UserPromptSubmit || [];
  if (!s.hooks.UserPromptSubmit.some(g => (g.hooks || []).some(h => h.command === cmd)))
    s.hooks.UserPromptSubmit.push({ matcher: "", hooks: [{ type: "command", command: cmd }] });
  fs.writeFileSync(dst, JSON.stringify(s, null, 2));
'@
$tmp = Join-Path $env:TEMP 'sc-lite-hooks.js'
Set-Content -Path $tmp -Value $mergeHooks -Encoding UTF8
node $tmp "$ClaudeDir\settings.json" "$ClaudeDir\scripts\skill-router-lite.js"
Remove-Item $tmp -Force
Ok '1 hook (combinaisons) - hooks Obsidian/self-learn retires'

# 8. CLAUDE.md global - bloc delimite
$mergeMd = @'
  const fs = require("fs");
  const [dst, src] = process.argv.slice(1);
  const S = "<!-- superclaude-lite:start -->", E = "<!-- superclaude-lite:end -->";
  const block = S + "\n" + fs.readFileSync(src, "utf8").trim() + "\n" + E;
  let cur = ""; try { cur = fs.readFileSync(dst, "utf8"); } catch {}
  const i = cur.indexOf(S), j = cur.indexOf(E);
  fs.writeFileSync(dst, (i !== -1 && j !== -1)
    ? cur.slice(0, i) + block + cur.slice(j + E.length)
    : (cur.trim() ? cur.trimEnd() + "\n\n" : "") + block + "\n");
'@
$tmp2 = Join-Path $env:TEMP 'sc-lite-md.js'
Set-Content -Path $tmp2 -Value $mergeMd -Encoding UTF8
node $tmp2 "$ClaudeDir\CLAUDE.md" "$Src\lite\CLAUDE.lite.md"
Remove-Item $tmp2 -Force
Ok 'CLAUDE.md - bloc superclaude-lite (reste du fichier intact)'

# 9. MCP - tous differes par ToolSearch
if (-not $NoMcp) {
  Say 'MCP (differes)...'
  claude mcp add -s user --transport http github   'https://api.githubcopilot.com/mcp/' 2>$null
  claude mcp add -s user --transport http vercel   'https://mcp.vercel.com'             2>$null
  claude mcp add -s user --transport http stripe   'https://mcp.stripe.com'             2>$null
  claude mcp add -s user --transport http context7 'https://mcp.context7.com/mcp'       2>$null
  claude mcp add -s user supabase   -- npx -y '@supabase/mcp-server-supabase@latest' 2>$null
  claude mcp add -s user playwright -- npx '@playwright/mcp@latest'                  2>$null
  Ok 'github . vercel . supabase . stripe . context7 . playwright'
  Warn 'vercel, stripe et github demandent une autorisation OAuth au premier usage : /mcp'
}

# 10. Agent-Reach
if (-not $NoAgentReach) {
  if (Have pipx) { pipx install agent-reach 2>$null }
  elseif (Have pip) { pip install agent-reach 2>$null }
  if (Have agent-reach) { agent-reach install 2>$null; Ok 'agent-reach installe' }
  else { Warn 'agent-reach non installe (non bloquant)' }
}

Write-Host ''
Write-Host '--------------------------------------------' -ForegroundColor Magenta
Write-Host '  SuperClaude Lite' -ForegroundColor Green
Write-Host '  Constant : superpowers . caveman . code-review . claude-mem'
Write-Host "  Auto     : $($skills.Count) skills + 6 MCP differes (cout ~0 avant appel)"
Write-Host '  Bascules : sc status | sc mcp <nom> on|off | sc plugin vercel on'
Write-Host ''
Write-Host '  [!] caveman est un output style : lance /caveman une fois.'
Write-Host '--------------------------------------------' -ForegroundColor Magenta
