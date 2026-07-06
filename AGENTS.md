# AGENTS.md — Instructions pour Claude / agents

Si l'utilisateur te donne ce repo avec une intention du type **« installe et active ce setup »**, exécute la procédure ci-dessous **sans poser de question** (sauf la clé Magic, optionnelle).

## Installation + activation (à exécuter)

1. **Lancer l'installeur** (détecte l'OS, installe Claude Code si absent, plugins, skills, MCP, clone les repos communauté) :

   **macOS / Linux**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/install.sh | bash
   ```

   **Windows (PowerShell)**
   ```powershell
   iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/install.ps1 | iex
   ```

   Si tu es déjà dans un clone local du repo, exécute directement `bash install.sh` (ou `.\install.ps1`).

2. **Vérifier l'activation** :
   ```bash
   claude plugin list           # 22 plugins
   claude mcp list              # 5 MCP : magic, playwright, context7, claude-mem, graphify
   ls ~/.claude/skills          # 15 skills + dossier vendor/
   ```

3. **Confirmer à l'utilisateur** ce qui est actif : nombre de plugins, MCP, skills, repos communauté clonés, et que l'auto-routing (`~/.claude/scripts/skill-router.js`) est en place.

## Ce que « activer » signifie

- **Skills always-on** : le hook `UserPromptSubmit` (`skill-router.js`) lit chaque message et invoque le bon skill selon l'intention — sans mot-clé. Voir `docs/AUTO-ROUTING.md`.
- **MCP auto-actifs** : `magic`, `playwright`, `context7`, `claude-mem`, `graphify` déclarés dans `.mcp.json`.
- **Combiner, pas prioriser** : chaque skill a un rôle distinct, aucun doublon.

## Règle de comportement post-install

Après activation, pour **chaque** demande de l'utilisateur : identifier la catégorie (voir table dans `CLAUDE.md`) et invoquer le(s) skill(s) approprié(s) avant de répondre. Réponses courtes, zéro slop, français par défaut.

## Ne pas faire

- Ne pas committer/pusher sans demande explicite.
- Ne pas modifier `installer-app/` (legacy).
- Ne pas dupliquer un skill existant — router vers celui en place.
