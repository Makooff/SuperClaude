# SuperClaude Setup — Windows PowerShell
# Usage: .\setup.ps1
# Run once per machine to install Claude Code plugins

Write-Host "=== SuperClaude Machine Setup ===" -ForegroundColor Cyan

# 1. Install plugins (global, one-time per machine)
Write-Host "`n[1/2] Installation plugins Claude Code..." -ForegroundColor Yellow
$plugins = @("superpowers", "impeccable", "taste-skill", "caveman", "claude-mem", "context7", "playwright")
foreach ($p in $plugins) {
    Write-Host "  Installing $p..." -ForegroundColor Gray
    claude plugin install $p 2>&1 | Out-Null
}
Write-Host "  OK: plugins installes" -ForegroundColor Green

# 2. Add MCP servers (user scope)
Write-Host "`n[2/2] MCPs a ajouter (copier-coller les commandes):" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Remplacer VOTRE_MAGIC_KEY par ta cle 21st.dev" -ForegroundColor Gray
Write-Host "  claude mcp add magic --scope user --env API_KEY=`"VOTRE_MAGIC_KEY`" -- npx -y @21st-dev/magic@latest" -ForegroundColor Cyan
Write-Host "  claude mcp add playwright --scope user -- npx @playwright/mcp@latest" -ForegroundColor Cyan
Write-Host "  claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp" -ForegroundColor Cyan

Write-Host "`n=== Setup termine ===" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaine etape:" -ForegroundColor White
Write-Host "  1. Copier .env.example -> .env.local dans chaque projet" -ForegroundColor White
Write-Host "  2. Remplir OBSIDIAN_API_KEY et OBSIDIAN_VAULT dans .env.local" -ForegroundColor White
Write-Host "  3. Ouvrir Claude Code dans le projet -> tout fonctionne" -ForegroundColor White
