# sc - bascule les briques lourdes de SuperClaude Lite (Windows).
#   sc status | sc mcp <nom> on|off | sc plugin <nom> on|off
param([Parameter(Mandatory=$true)][string]$Cmd, [string]$Name, [string]$Action)

function Mcp-On($n) {
  switch ($n) {
    'github'     { claude mcp add --transport http github   https://api.githubcopilot.com/mcp/ }
    'vercel'     { claude mcp add --transport http vercel   https://mcp.vercel.com }
    'stripe'     { claude mcp add --transport http stripe   https://mcp.stripe.com }
    'context7'   { claude mcp add --transport http context7 https://mcp.context7.com/mcp }
    'supabase'   { claude mcp add -s user supabase   -- npx -y '@supabase/mcp-server-supabase@latest' }
    'playwright' { claude mcp add -s user playwright -- npx '@playwright/mcp@latest' }
    'magic' {
      $key = $env:MAGIC_API_KEY
      if (-not $key) { $key = Read-Host 'Cle 21st.dev Magic (Entree = ignorer)' }
      if ($key) { claude mcp add -s user magic -e "API_KEY=$key" -- npx -y '@21st-dev/magic@latest' }
      else      { claude mcp add -s user magic -- npx -y '@21st-dev/magic@latest' }
    }
    default { Write-Host "MCP inconnu : $n"; exit 1 }
  }
}

switch ($Cmd) {
  'status' {
    Write-Host '-- MCP --';     claude mcp list
    Write-Host '-- Plugins --'; claude plugin list
    Write-Host '-- Skills --';  Get-ChildItem "$HOME\.claude\skills" -Name
  }
  'mcp' {
    if ($Action -eq 'on')  { Mcp-On $Name; Write-Host "[ok] MCP $Name actif (differe - coute ~0 avant usage)" -ForegroundColor Green }
    elseif ($Action -eq 'off') { claude mcp remove -s user $Name 2>$null; Write-Host "[ok] MCP $Name retire" -ForegroundColor Green }
    else { Write-Host 'Action attendue : on | off'; exit 1 }
  }
  'plugin' {
    if ($Action -eq 'on')  { claude plugin install $Name 2>$null;   Write-Host "[ok] plugin $Name installe - ses skills chargent a chaque session" -ForegroundColor Green }
    elseif ($Action -eq 'off') { claude plugin uninstall $Name 2>$null; Write-Host "[ok] plugin $Name retire" -ForegroundColor Green }
    else { Write-Host 'Action attendue : on | off'; exit 1 }
  }
  default { Write-Host 'sc status | sc mcp <nom> on|off | sc plugin <nom> on|off' }
}
