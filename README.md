# SuperClaude — Setup de session Claude Code

Config complète pour lancer Claude avec mémoire Obsidian, skills, agents et MCP prêts.

## Ce que ça inclut

| Composant | Ce que ça fait |
|-----------|----------------|
| **Skills** (superpowers, impeccable, taste-skill, caveman...) | Intelligence spécialisée par tâche |
| **MCP: Magic** | Génération de composants UI 21st.dev |
| **MCP: Playwright** | Tests E2E + screenshot browser |
| **MCP: Context7** | Docs à jour pour toute librairie |
| **MCP: claude-mem** | Mémoire persistante entre sessions |
| **Obsidian** | Source de vérité projet — journal + tâches |
| **Hooks auto** | Skill routing automatique selon le prompt |

---

## Installation rapide

### 1. Cloner ce repo

```bash
git clone https://github.com/Makooff/SuperClaude.git
cd SuperClaude
```

### 2. Lancer le setup (Windows PowerShell)

```powershell
.\setup.ps1
```

Le script copie settings.json, les scripts et rules dans `~/.claude/`.

### 3. Ajouter les MCPs

```bash
# Magic UI components (21st.dev)
claude mcp add magic --scope user --env API_KEY="VOTRE_KEY" -- npx -y @21st-dev/magic@latest

# Playwright (browser automation)
claude mcp add playwright --scope user -- npx @playwright/mcp@latest

# Context7 (live docs)
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
```

### 4. Installer les plugins Claude Code

```bash
claude plugin install superpowers
claude plugin install impeccable
claude plugin install taste-skill
claude plugin install claude-mem
claude plugin install caveman
claude plugin install context7
claude plugin install playwright
claude plugin install vercel
```

### 5. Copier obsidian.js

```powershell
copy scripts\obsidian.js $env:USERPROFILE\.claude\scripts\obsidian.js
```

---

## Structure du projet

```
SuperClaude/
├── README.md
├── setup.ps1              # Script d'installation Windows
├── CLAUDE.md              # Instructions globales pour Claude
├── settings.json          # Config Claude (template sans secrets)
├── .mcp.json              # MCP servers (projet)
├── scripts/
│   └── obsidian.js        # Bridge Obsidian REST API
└── docs/
    ├── skills.md           # Guide skill routing
    ├── mcp-guide.md        # Guide MCP servers
    ├── obsidian-setup.md   # Setup mémoire Obsidian
    └── prompts.md          # Prompts de démarrage session
```

---

## Démarrer une session

Coller ce prompt dans Claude Code au début de chaque session :

```
Nouvelle session. Lis le vault Obsidian via `node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" read "Qwillio/Taches.md"` pour voir les tâches ouvertes. Ensuite consulte les dernières décisions dans "Qwillio/04 - Decisions.md". Dis-moi ce qui est en cours et ce qu'on a prévu.
```

Voir `docs/prompts.md` pour les prompts par type de tâche.

---

## Skills clés

| Trigger | Skill(s) invoqué(s) |
|---------|---------------------|
| Design, UI, composant, page | `impeccable` + `taste-skill` + `emil-design-eng` |
| Code review | `code-review` |
| Bug, crash, erreur | `systematic-debugging` |
| Test, TDD | `tdd-workflow` |
| Feature complexe | `writing-plans` → `executing-plans` |
| Sécurité, auth | `security` |
| Vérification | `verify` |

---

## MCP servers actifs

| Serveur | Usage |
|---------|-------|
| `magic` | `/ui generate Button` — composants UI from 21st.dev |
| `playwright` | Browser automation, screenshots, E2E |
| `context7` | `use context7` dans le prompt = docs live |
| `claude-mem` | Mémoire cross-session automatique |
| `vercel` | Deploy, logs, env vars |
| `supabase` | DB queries, migrations |
| `stripe` | Paiements, test cards |

---

## Framer Motion

Context7 connaît Framer Motion. Dans chaque prompt d'animation :

```
Utilise context7 pour les dernières APIs Framer Motion.
Anime avec motion.div, variants, et useAnimation.
Easing: cubic-bezier(0.16, 1, 0.3, 1) — ease-out-expo.
```
