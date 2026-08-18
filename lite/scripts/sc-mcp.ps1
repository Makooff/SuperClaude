# sc-mcp - allume/eteint les MCP lourds de SuperClaude Lite (Windows).
# Usage: sc-mcp magic on | sc-mcp playwright off | sc-mcp all on | sc-mcp list
param(
  [Parameter(Mandatory=$true)][string]$Name,
  [string]$Action
)

if ($Name -eq 'list') { claude mcp list; exit 0 }

if (-not $Action) {
  Write-Host 'sc-mcp <magic|playwright|context7|all> on|off'
  Write-Host 'sc-mcp list'
  exit 1
}

function Add-One($n) {
  switch ($n) {
    'magic' {
      $key = $env:MAGIC_API_KEY
      if (-not $key) { $key = Read-Host 'Cle API 21st.dev Magic (Entree pour ignorer)' }
      if ($key) { claude mcp add -s user magic -e "API_KEY=$key" -- npx -y '@21st-dev/magic@latest' }
      else      { claude mcp add -s user magic -- npx -y '@21st-dev/magic@latest' }
    }
    'playwright' { claude mcp add -s user playwright -- npx '@playwright/mcp@latest' }
    'context7'   { claude mcp add -s user context7   -- npx -y '@upstash/context7-mcp' }
    default { Write-Host "MCP inconnu : $n"; exit 1 }
  }
}

$targets = @($Name)
if ($Name -eq 'all') { $targets = @('magic','playwright','context7') }

foreach ($t in $targets) {
  if ($Action -eq 'on')  { Add-One $t;  Write-Host "[ok] $t active" -ForegroundColor Green }
  elseif ($Action -eq 'off') { claude mcp remove -s user $t 2>$null; Write-Host "[ok] $t desactive" -ForegroundColor Green }
  else { Write-Host 'Action attendue : on | off'; exit 1 }
}
Write-Host 'Redemarre Claude Code pour appliquer.'
