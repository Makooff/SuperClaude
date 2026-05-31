# Build du logiciel SuperClaude

App desktop Electron — companion Claude Code (Mac + PC).

## Prérequis
- Node.js 18+
- Claude Code installé

## Build

### Mac / Linux
```bash
./build.sh
```

### Windows
```powershell
.\build.ps1
```

Artefact généré dans `installer-app/dist/` :
- Windows → `.exe` (NSIS)
- macOS → `.dmg`

## Dev (sans build)
```bash
cd installer-app
npm install
npm start
```

## Ce que fait l'app
1. Vérifie Node.js + Claude Code
2. Installe les meilleurs plugins : superpowers, code-review, github, vercel, supabase, stripe, claude-mem, caveman, claude-md-management, context7, skill-creator, playwright
3. Configure les MCPs : context7, playwright (magic si clé API)
4. Écran "Choisir le projet" → copie skills + CLAUDE.md + .mcp.json + active l'agent ultra (`bypassPermissions`)
5. Ouvre Claude Code dans le dossier choisi
