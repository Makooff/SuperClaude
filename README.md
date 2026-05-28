# SuperClaude

Config Claude Code complète — skills, MCPs, mémoire Obsidian. Cloner dans chaque projet, tout s'active automatiquement.

## Ce que ça donne

Dès le premier message dans Claude Code:
- **Context Obsidian injecté** — tâches ouvertes, décisions récentes, session du jour
- **Skills auto-routés** — design → impeccable+taste-skill, bug → systematic-debugging, etc.
- **MCPs actifs** — magic (UI), playwright (browser), context7 (docs live)
- **Mémoire cross-session** via claude-mem plugin

---

## Usage — par projet

### 1. Copier ce repo dans ton projet
```bash
# Option A: cloner directement
git clone https://github.com/Makooff/SuperClaude.git MonProjet
cd MonProjet

# Option B: copier les fichiers dans un projet existant
cp -r SuperClaude/.claude MonProjet/
cp SuperClaude/CLAUDE.md MonProjet/
cp SuperClaude/.mcp.json MonProjet/
cp SuperClaude/.env.example MonProjet/
```

### 2. Configurer le projet
```bash
cp .env.example .env.local
# Editer .env.local:
#   OBSIDIAN_API_KEY=ta_clé
#   OBSIDIAN_VAULT=NomDuProjet   (sous-dossier dans ton vault Obsidian)
```

### 3. Ouvrir Claude Code
```bash
claude
```
Premier message → contexte Obsidian injecté automatiquement.

---

## Setup machine (une seule fois)

```powershell
.\setup.ps1
```

Installe: superpowers, impeccable, taste-skill, caveman, claude-mem, context7, playwright.

Puis ajouter Magic MCP:
```bash
claude mcp add magic --scope user --env API_KEY="TA_CLÉ" -- npx -y @21st-dev/magic@latest
```

---

## Structure

```
SuperClaude/
├── CLAUDE.md                    # Skill routing + instructions globales
├── .mcp.json                    # MCP servers (magic, playwright, context7)
├── .env.example                 # Template secrets
├── setup.ps1                    # Install plugins machine (one-time)
├── .claude/
│   ├── settings.json            # Hooks auto-skill + plugins activés
│   └── scripts/
│       └── obsidian.js          # Bridge Obsidian REST API
└── docs/
    ├── prompts.md               # Prompts de démarrage session
    └── obsidian-setup.md        # Guide config mémoire Obsidian
```

---

## Skill routing automatique

| Mot dans le prompt | Skills invoqués |
|--------------------|-----------------|
| design, UI, composant, animation | `impeccable` + `taste-skill` + `emil-design-eng` |
| review, audit, check | `code-review` |
| test, tdd | `tdd-workflow` |
| bug, crash, erreur, debug | `systematic-debugging` |
| auth, token, password, API key | `security` |
| plan, feature, architecture | `writing-plans` |

---

## MCP servers

| Serveur | Commande | Usage |
|---------|---------|-------|
| `magic` | `/ui generate [description]` | Composants UI 21st.dev |
| `playwright` | automatique | Browser automation, E2E, screenshots |
| `context7` | ajouter `use context7` au prompt | Docs live pour toute librairie |

---

## Framer Motion

```
Anime [composant]. use context7 pour les APIs Framer Motion.
Easing: cubic-bezier(0.16, 1, 0.3, 1). Stagger: 50ms. Press: scale(0.97).
```

---

## Prompts de démarrage

Voir [docs/prompts.md](docs/prompts.md) pour les prompts par type de tâche.
