# SuperClaude

Config Claude Code complète — skills auto-routés, MCPs (Magic, Playwright, Context7), mémoire Obsidian cross-session.

Cloner dans chaque projet → tout s'active automatiquement au premier message.

---

## Ce que ça fait concrètement

Dès le premier message dans Claude Code:
- **Obsidian injecte le contexte** — tâches ouvertes, décisions récentes, session du jour
- **Skills se routent automatiquement** — tu écris "design" → impeccable+taste-skill+emil-design-eng s'activent
- **MCPs actifs** — Magic (composants UI), Playwright (browser), Context7 (docs live)
- **Mémoire cross-session** — claude-mem retient ce que Claude a fait avant

---

## Prérequis

- [Claude Code](https://claude.ai/code) installé
- [Obsidian](https://obsidian.md) avec le plugin **Local REST API** activé
- Node.js installé

---

## Installation — une seule fois par machine

### 1. Cloner SuperClaude

```powershell
git clone https://github.com/Makooff/SuperClaude.git C:/SuperClaude
cd C:/SuperClaude
```

### 2. Installer les plugins Claude Code

```powershell
.\setup.ps1
```

Installe: `superpowers`, `impeccable`, `taste-skill`, `caveman`, `claude-mem`, `context7`, `playwright`.

### 3. Ajouter les MCP servers

```bash
# Magic — composants UI 21st.dev (obtenir une clé sur 21st.dev)
claude mcp add magic --scope user --env API_KEY="TA_CLÉ_21ST_DEV" -- npx -y @21st-dev/magic@latest

# Playwright — browser automation
claude mcp add playwright --scope user -- npx @playwright/mcp@latest

# Context7 — docs live
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
```

---

## Ajouter SuperClaude à un projet

### Étape 1 — Copier la config

```powershell
# Depuis la racine de ton projet
cp -r C:/SuperClaude/.claude .
cp C:/SuperClaude/CLAUDE.md .
cp C:/SuperClaude/.mcp.json .
cp C:/SuperClaude/.env.example .env.local
```

### Étape 2 — Configurer `.env.local`

Ouvrir `.env.local` et remplir:

```env
OBSIDIAN_API_KEY=ta_clé_obsidian       # Settings > Local REST API dans Obsidian
OBSIDIAN_VAULT=NomDuProjet             # Sous-dossier dans ton vault (ex: "NailArt")
MAGIC_API_KEY=ta_clé_21st_dev          # Optionnel
```

### Étape 3 — Créer le vault Obsidian

Dans Obsidian, créer ce dossier:

```
NomDuProjet/
├── Taches.md           ← liste tes tâches ici (format: - [ ] Tâche)
├── 04 - Decisions.md   ← décisions architecturales
├── PRODUCT.md          ← contexte produit
└── Sessions/           ← Claude loggera ici automatiquement
```

### Étape 4 — Ajouter `.env.local` au `.gitignore`

```bash
echo ".env.local" >> .gitignore
```

### Étape 5 — Ouvrir Claude Code

```
VS Code → Open Folder → ton projet
Ctrl+Shift+P → "Claude: New Chat"
```

Premier message → Obsidian injecte tâches + contexte. C'est parti.

---

## Exemple concret — projet NailArt

```powershell
# Créer le projet
mkdir C:/Projets/NailArt
cd C:/Projets/NailArt
git init

# Copier la config
cp -r C:/SuperClaude/.claude .
cp C:/SuperClaude/CLAUDE.md .
cp C:/SuperClaude/.mcp.json .
cp C:/SuperClaude/.env.example .env.local

# Configurer
# Éditer .env.local:
#   OBSIDIAN_API_KEY=xxxxx
#   OBSIDIAN_VAULT=NailArt

# Ouvrir VS Code
code .
```

Dans Obsidian, créer `NailArt/Taches.md` avec les premières tâches.
Ouvrir Claude Code → taper le premier message → tout est là.

---

## Skill routing automatique

| Mot dans le prompt | Skills invoqués automatiquement |
|--------------------|----------------------------------|
| design, UI, composant, animation, page | `impeccable` + `taste-skill` + `emil-design-eng` |
| review, audit, check | `code-review` |
| test, tdd | `tdd-workflow` |
| bug, crash, erreur, debug | `systematic-debugging` |
| auth, token, password, API key | `security` |
| plan, feature, architecture | `writing-plans` |

---

## MCP servers inclus

| Serveur | Comment l'utiliser |
|---------|-------------------|
| `magic` | Taper `/ui generate [description du composant]` |
| `playwright` | Automatique pour tests E2E et screenshots |
| `context7` | Ajouter `use context7` dans le prompt = docs live à jour |

Exemple avec Framer Motion:
```
Anime cette card avec Framer Motion. use context7 pour les APIs.
Easing: cubic-bezier(0.16, 1, 0.3, 1). Stagger 50ms. Press: scale(0.97).
```

---

## Mémoire Obsidian — comment ça marche

```
Tu envoies un message
        ↓
Hook déclenche obsidian.js
        ↓
Lit Taches.md + Sessions/aujourd'hui.md + Decisions.md + PRODUCT.md
        ↓
Injecte dans Claude AVANT qu'il réponde
        ↓
Claude sait où tu en es sans réexpliquer
```

**Obsidian doit être ouvert** sur la machine. Si fermé → Claude démarre sans contexte, session normale.

À la fin de chaque session, Claude loggue automatiquement dans `Sessions/YYYY-MM-DD.md`.

---

## Structure du repo

```
SuperClaude/
├── CLAUDE.md                    # Skill routing + instructions Claude
├── .mcp.json                    # MCP servers projet
├── .env.example                 # Template secrets (copier en .env.local)
├── setup.ps1                    # Install plugins — une fois par machine
├── .claude/
│   ├── settings.json            # Hooks auto-skill + plugins activés
│   └── scripts/
│       └── obsidian.js          # Bridge Obsidian REST API
└── docs/
    ├── prompts.md               # Prompts prêts à copier par type de tâche
    └── obsidian-setup.md        # Guide détaillé config Obsidian
```

---

## Prompts utiles

Voir [docs/prompts.md](docs/prompts.md) — prompts prêts par type: démarrage session, feature UI, debug, Framer Motion, Magic MCP, code review.
