# AGENTS.md — SuperClaude Lite

Si l'utilisateur demande d'installer ou d'activer SuperClaude Lite, exécute ceci **sans poser de question**.

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.sh | bash
```

**Windows (PowerShell)**
```powershell
iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.ps1 | iex
```

Ajoute `--replace-full` / `-ReplaceFull` si la machine porte déjà l'ancien setup complet.

Vérifie ensuite avec `claude plugin list`, `claude mcp list` et `ls ~/.claude/skills`, puis confirme à l'utilisateur ce qui est actif.

Signale-lui deux choses :

- `caveman` est un output style : lancer `/caveman` une fois.
- `vercel`, `stripe` et `github` demandent une autorisation OAuth au premier usage, via `/mcp`.

Détail des composants et des options : [`README.md`](README.md).
