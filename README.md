# SuperClaude

Config Claude Code complète. Skills auto-routés, MCPs actifs, mémoire Obsidian cross-session.
Copier dans un projet → tout fonctionne au premier message.

---

## Ce que ça fait

| Ce qui se passe | Comment |
|-----------------|---------|
| Claude connaît tes tâches en cours | Obsidian injecte `Taches.md` à chaque message |
| Claude sait les décisions passées | Obsidian injecte `Decisions.md` automatiquement |
| Skills s'activent seuls | Tu écris "design" → impeccable+taste-skill s'invoquent |
| Composants UI générés | MCP Magic → `/ui generate [description]` |
| Docs live | MCP Context7 → ajouter `use context7` dans le prompt |
| Tests E2E + screenshots | MCP Playwright → automatique |

---

## SETUP MACHINE — une seule fois

### Prérequis
- [Claude Code](https://claude.ai/code) installé
- [Obsidian](https://obsidian.md) + plugin **Local REST API** activé
- Node.js installé

### 1. Cloner SuperClaude
```powershell
git clone https://github.com/Makooff/SuperClaude.git C:/SuperClaude
```

### 2. Installer les plugins Claude Code
```powershell
cd C:/SuperClaude
.\setup.ps1
```

Installe : `superpowers` `impeccable` `taste-skill` `caveman` `claude-mem` `context7` `playwright`

### 3. Ajouter les MCP servers
```bash
claude mcp add magic --scope user --env API_KEY="TA_CLÉ_MAGIC" -- npx -y @21st-dev/magic@latest
claude mcp add playwright --scope user -- npx @playwright/mcp@latest
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
```

> Clé Magic sur [21st.dev/magic/console](https://21st.dev/magic/console)

---

## NOUVEAU PROJET — à chaque fois

### Étape 1 — Copier la config dans le projet
```powershell
# Depuis la racine de ton projet
cp -r C:/SuperClaude/.claude .
cp C:/SuperClaude/CLAUDE.md .
cp C:/SuperClaude/.mcp.json .
cp C:/SuperClaude/.env.example .env.local
```

### Étape 2 — Remplir `.env.local`
```env
OBSIDIAN_API_KEY=ta_clé      # Obsidian → Settings → Local REST API → copier la clé
OBSIDIAN_VAULT=NomDuProjet   # Nom du sous-dossier dans ton vault (ex: NailArt, Qwillio)
MAGIC_API_KEY=ta_clé         # 21st.dev
```

### Étape 3 — Créer le vault Obsidian
Dans Obsidian, créer ce dossier (remplacer `NomDuProjet`) :
```
NomDuProjet/
├── Taches.md           ← - [ ] Tâche 1
│                          - [ ] Tâche 2
├── 04 - Decisions.md   ← décisions techniques
├── PRODUCT.md          ← contexte produit
└── Sessions/           ← Claude loggue ici automatiquement
```

### Étape 4 — Ignorer les secrets
```bash
echo ".env.local" >> .gitignore
```

### Étape 5 — Ouvrir Claude Code
```
VS Code → Open Folder → ton projet
Ctrl+Shift+P → "Claude: New Chat"
```

**Premier message → Obsidian injecte le contexte. C'est parti.**

---

## EXEMPLE COMPLET — projet NailArt

```powershell
# 1. Créer le projet
mkdir C:/Projets/NailArt
cd C:/Projets/NailArt
git init

# 2. Copier la config
cp -r C:/SuperClaude/.claude .
cp C:/SuperClaude/CLAUDE.md .
cp C:/SuperClaude/.mcp.json .
cp C:/SuperClaude/.env.example .env.local

# 3. Remplir .env.local
#    OBSIDIAN_API_KEY=xxxxx
#    OBSIDIAN_VAULT=NailArt

# 4. Ignorer les secrets
echo ".env.local" >> .gitignore
```

Dans Obsidian → créer `NailArt/Taches.md` avec les premières tâches.

```
VS Code → Open Folder → C:/Projets/NailArt
Claude Code → nouveau chat → taper le premier message
```

---

## SKILL ROUTING automatique

| Mot dans le prompt | Skills invoqués |
|--------------------|-----------------|
| design, UI, composant, animation, page, layout | `impeccable` + `taste-skill` + `emil-design-eng` |
| review, audit, check, revu | `code-review` |
| test, tdd, coverage | `tdd-workflow` |
| bug, crash, erreur, debug, plante | `systematic-debugging` |
| auth, token, password, API key, sécurité | `security` |
| plan, feature, architecture | `writing-plans` |

Rien à faire — les skills s'invoquent selon les mots détectés dans le prompt.

---

## MCP SERVERS

### Magic — générer un composant UI
```
/ui generate une card produit avec image, titre, prix et bouton ajouter au panier
```

### Context7 — docs live
Ajouter `use context7` dans n'importe quel prompt :
```
Anime cette card avec Framer Motion. use context7 pour les APIs à jour.
```

### Playwright — browser automation
Automatique pour les tests E2E. Exemple de prompt :
```
Vérifie que le formulaire de login fonctionne avec Playwright.
```

---

## MÉMOIRE OBSIDIAN — schéma

```
Tu envoies un message
       ↓
Hook déclenche .claude/scripts/obsidian.js
       ↓
Lit : Taches.md + Sessions/aujourd'hui.md + Decisions.md + PRODUCT.md
       ↓
Injecte tout dans Claude AVANT qu'il réponde
       ↓
Claude sait où tu en es — sans réexpliquer
```

Fin de session → Claude loggue automatiquement dans `Sessions/YYYY-MM-DD.md`.

> **Obsidian doit être ouvert.** Si fermé → Claude démarre sans contexte (session normale, pas de plantage).

---

## STRUCTURE DU REPO

```
SuperClaude/
├── CLAUDE.md                  ← instructions + skill routing
├── .mcp.json                  ← MCP servers (magic, playwright, context7)
├── .env.example               ← template secrets → copier en .env.local
├── setup.ps1                  ← install plugins (une fois par machine)
├── .claude/
│   ├── settings.json          ← hooks auto-skill + plugins activés
│   └── scripts/
│       └── obsidian.js        ← bridge Obsidian REST API
└── docs/
    ├── prompts.md             ← prompts prêts par type de tâche
    └── obsidian-setup.md      ← guide détaillé Obsidian
```

---

## PROMPTS PRÊTS

Voir [docs/prompts.md](docs/prompts.md) — prompts par type : démarrage session, feature UI, debug, Framer Motion, Magic, code review.
