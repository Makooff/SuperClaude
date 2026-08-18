# AGENTS.md — instructions pour Claude et autres agents

Si l'utilisateur donne ce repo avec une intention du type « installe et active ce setup », ou « installe SuperClaude Lite », exécute la procédure ci-dessous **sans poser de question**.

## Procédure par défaut — SuperClaude Lite

C'est la version à installer sauf demande explicite du contraire.

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.sh | bash
```

**Windows (PowerShell)**
```powershell
iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.ps1 | iex
```

Depuis un clone local : `bash lite/install-lite.sh` (ou `.\lite\install-lite.ps1`).

Si la machine porte déjà l'ancien setup complet, ajoute `--replace-full` (bash) ou `-ReplaceFull` (PowerShell) : les plugins superflus, `graphify`, `magic` et les hooks Obsidian sont retirés, et les fichiers écartés sont déplacés dans `~/.claude/skills.bak-<date>`.

## Vérifier

```bash
claude plugin list     # superpowers, caveman, code-review, claude-mem
claude mcp list        # github, vercel, supabase, stripe, playwright, context7
ls ~/.claude/skills    # 8 skills
```

Puis confirme à l'utilisateur : plugins actifs, MCP enregistrés, skills installés, et que le hook `~/.claude/scripts/skill-router-lite.js` est branché dans `~/.claude/settings.json`.

Deux points à lui signaler à la fin :

- `caveman` est un output style : il doit lancer `/caveman` une fois pour l'activer.
- `vercel`, `stripe` et `github` demandent une autorisation OAuth au premier usage, via `/mcp`.

## Ce que « activer » signifie

Rien n'est routé à la main. Trois mécanismes natifs font le travail :

- **Skills** — chacun s'invoque via son champ `description`.
- **MCP** — les schémas d'outils sont différés par `ToolSearch` (activé par défaut) : seuls les noms chargent au démarrage, les schémas arrivent au moment de l'appel.
- **claude-mem** — 5 hooks lifecycle capturent et réinjectent le contexte automatiquement.

Le hook `skill-router-lite.js` ne fait qu'une chose en plus : forcer les combinaisons que le déclenchement natif ne produit pas seul, par exemple `impeccable` + `taste-skill` ensemble sur une tâche UI. Il valide chaque nom sur le disque et reste silencieux quand rien ne correspond.

Détail complet des composants, des options d'installation et des bascules : [`lite/README.md`](lite/README.md).

## Setup complet — seulement sur demande explicite

Le setup d'origine installe 22 plugins, 5 MCP, 4 repos communauté et des paquets npm globaux. Il coûte nettement plus de contexte permanent. Ne l'installe que si l'utilisateur le nomme explicitement.

```bash
curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/install.sh | bash
```

## Règle de comportement post-install

Pour chaque demande, identifier l'intention et invoquer le ou les skills concernés avant de répondre. Réponses courtes, français par défaut.

## Ne pas faire

- Ne pas committer ni pusher sans demande explicite.
- Ne pas modifier `installer-app/` (legacy).
- Ne pas dupliquer un skill existant — router vers celui en place.
