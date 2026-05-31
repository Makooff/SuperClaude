<div align="center">

<img src="assets/banner.svg" alt="SuperClaude" width="100%" />

<br/>

[![Platform](https://img.shields.io/badge/macOS%20%2B%20Windows-7c3aed?style=flat-square&logo=electron&logoColor=white&label=app)](https://github.com/Makooff/SuperClaude)
[![Plugins](https://img.shields.io/badge/22%20plugins-10b981?style=flat-square&label=installed)](https://github.com/Makooff/SuperClaude)
[![Agents](https://img.shields.io/badge/191%20agents%20%C2%B7%20155%20skills-7c3aed?style=flat-square&label=wshobson)](https://github.com/wshobson/agents)
[![License](https://img.shields.io/badge/MIT-71717a?style=flat-square&label=license)](LICENSE)

**App desktop qui transforme Claude Code en agent ultra-puissant — 1 clic, 60 secondes.**

[Quickstart](#quickstart) · [Tutoriel](#tutoriel) · [Ce qui est installé](#ce-qui-est-installé) · [FAQ](#dépannage)

</div>

---

## Pourquoi SuperClaude ?

Claude Code natif = puissant mais vierge. Tu dois setup plugins, MCPs, skills, mémoire, permissions manuellement. SuperClaude automatise tout ça en 1 clic via une app desktop.

| Sans SuperClaude | Avec SuperClaude |
|---|---|
| 0 plugin installé | 22 plugins + 10 packs agents |
| Claude demande confirmation à chaque action | Agent ultra — agit sans interrompre |
| Pas de mémoire entre sessions | `claude-mem` + Obsidian cross-session |
| Pas de skill routing | Mots-clés → skills auto-invoqués |
| MCPs à configurer manuellement | magic, context7, playwright préconfigurés |

---

## Quickstart

```bash
git clone https://github.com/Makooff/SuperClaude.git
cd SuperClaude/installer-app && npm install && npm start
```

> Builder en .exe/.dmg : `./build.sh` (Mac) ou `.\build.ps1` (Windows) — voir [BUILD.md](BUILD.md)

---

## Tutoriel

### Étape 0 — Prérequis

| Outil | Version min | Lien |
|---|---|---|
| Node.js | 18+ | [nodejs.org/en/download](https://nodejs.org/en/download) |
| Claude Code CLI | dernière | [claude.ai/code](https://claude.ai/code) |

Vérifie :
```bash
node --version   # v18+
claude --version
```

> L'app vérifie ces deux automatiquement à l'écran 2 et donne les liens d'install si manquants.

---

### Étape 1 — Récupérer SuperClaude

**Option A — git**
```bash
git clone https://github.com/Makooff/SuperClaude.git
cd SuperClaude
```

**Option B — ZIP**
[Télécharger le ZIP](https://github.com/Makooff/SuperClaude/archive/refs/heads/main.zip) → extraire → ouvrir un terminal dans le dossier.

---

### Étape 2 — Lancer l'app

**Mode dev (direct, aucun build)**
```bash
cd installer-app
npm install
npm start
```

**Mode production (génère .dmg / .exe)**
```bash
# Mac / Linux
./build.sh

# Windows
.\build.ps1
```
Artefact dans `installer-app/dist/`. Voir [BUILD.md](BUILD.md) pour détails.

---

### Étape 3 — L'app — 6 écrans

```
┌─────────────────────────────────────────────────┐
│  1. Welcome     → aperçu des features           │
│  2. Prérequis   → vérif Node.js + Claude Code   │
│  3. Config      → clés API optionnelles          │
│  4. Installation→ 25 commandes, logs live        │
│  5. Projet      → choix dossier + copie config   │
│  6. Fini        → Claude Code s'ouvre            │
└─────────────────────────────────────────────────┘
```

**Écran 3 — Config (tout optionnel)**

| Champ | Usage |
|---|---|
| Magic API Key | Génération de composants UI via 21st.dev |
| Obsidian API Key | Mémoire cross-session via vault Obsidian |
| Ouvrir Claude après install | Ouvre Claude Code automatiquement |

**Écran 5 — Choisir le projet**

1. Clic "Choisir le dossier projet" → dialog natif OS
2. Sélectionne (ou crée) ton dossier projet
3. Clic "Installer dans ce projet" → copie `.claude/`, `CLAUDE.md`, `.mcp.json`
4. Active agent ultra dans `.claude/settings.json`
5. Ouvre Claude Code dans ce dossier

---

### Étape 4 — Premier message

Dans Claude Code :
```
Crée une landing page dark pour une app de todo, avec hero animé et card features.
```

Le mot `design` détecte automatiquement → invoque `impeccable` + `taste-skill` + `emil-design-eng`. Zéro setup manuel.

---

## Ce qui est installé

### Plugins officiels (12)

| Plugin | Rôle |
|---|---|
| `superpowers` | Skills méta : brainstorming, plans, TDD, debug, git |
| `code-review` | Review PR/diff avec findings sévérisés |
| `github` | Issues, PRs, CI via MCP GitHub |
| `vercel` | Deploy, env vars, AI SDK, middleware |
| `supabase` | DB, auth, edge functions |
| `stripe` | Paiements, webhooks, test cards |
| `claude-mem` | Mémoire auto cross-session, zéro config |
| `caveman` | Mode réponse compact — économie tokens |
| `claude-md-management` | Mise à jour CLAUDE.md depuis la session |
| `context7` | Docs live (React, Next.js, Prisma…) |
| `skill-creator` | Création de skills custom |
| `playwright` | Automation browser, E2E, screenshots |

### Packs `wshobson/agents` — 191 agents, 155 skills

| Pack | Contenu |
|---|---|
| `comprehensive-review` | Review multi-angle : perf, sécu, maintenabilité |
| `debugging-toolkit` | Debug systématique + optimisation DX |
| `unit-testing` | Tests auto Python/JS/TS |
| `security-scanning` | SAST, secrets, sécurité API |
| `full-stack-orchestration` | Feature complète end-to-end |
| `frontend-mobile-development` | React, React Native, mobile |
| `ui-design` | Agents UI/UX + accessibilité |
| `cicd-automation` | Pipelines CI/CD, GitHub Actions |
| `agent-orchestration` | Systèmes multi-agents |
| `application-performance` | Profiling, Core Web Vitals |

### MCP servers (3)

| MCP | Invocation |
|---|---|
| `magic` | Composants UI via 21st.dev |
| `context7` | `use context7` dans le prompt → docs à jour |
| `playwright` | Tests E2E, capture d'écran, automation |

---

## Agent ultra

L'app écrit dans `.claude/settings.json` du projet :
```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

Claude exécute commandes et éditions **sans demander confirmation**. Idéal pour builder vite.

> **Sécurité** : `bypassPermissions` = contrôle total sur le dossier. Utiliser sur projets de confiance uniquement. Pour revenir à un mode prudent : changer `defaultMode` en `acceptEdits`.

---

## Mémoire cross-session

Deux couches :

**1. `claude-mem`** — installé par défaut, zéro config. Mémorise automatiquement faits importants entre sessions.

**2. Obsidian** (optionnel) — injecte tâches ouvertes, décisions, contexte produit à chaque prompt via hook `UserPromptSubmit`.

Setup : [`docs/obsidian-setup.md`](docs/obsidian-setup.md)
Variables dans `.env.local` :
```bash
OBSIDIAN_VAULT=/chemin/vers/vault
OBSIDIAN_API_KEY=ta_cle
```

---

## Skill routing automatique

CLAUDE.md détecte les mots-clés et invoque les skills sans commande :

| Mot dans le prompt | Skills invoqués |
|---|---|
| `design` `UI` `composant` `animation` `page` `layout` `hero` `card` `button` `font` | `impeccable` + `taste-skill` + `emil-design-eng` |
| `review` `audit` | `code-review` |
| `test` `tdd` `coverage` | `tdd-workflow` |
| `bug` `crash` `erreur` `debug` | `systematic-debugging` |
| `auth` `token` `password` `API key` | `security` |
| `plan` `feature` `architecture` | `writing-plans` + `executing-plans` |
| `check` `qa` `verif` `deploy` | `verify` |

---

## Exemples MCP

**Générer un composant UI (magic)**
```
Crée une card pricing avec 3 tiers, toggle mensuel/annuel, highlight tier Pro.
```

**Docs live (context7)**
```
Anime cette liste avec Framer Motion. use context7 pour les APIs à jour.
```

**Automation browser (playwright)**
```
Vérifie que le form de login accepte les credentials valides et rejette les invalides.
```

---

## Nouveau projet (sans relancer l'app)

Fallback CLI :

```bash
# Mac / Linux
./new-project.sh MonProjet ~/Projets/MonProjet

# Windows
.\new-project.ps1 -Name MonProjet -Path C:\Projets\MonProjet
```

Copie config, remplit `.env.local` interactivement, met à jour `.gitignore`.

---

## Structure du repo

```
SuperClaude/
├── installer-app/          ← app Electron (Mac + PC)
│   ├── main.js             ← IPC : pick-folder, setup-project, open-claude
│   ├── preload.js          ← bridge contextBridge → renderer
│   └── src/                ← UI (index.html, renderer.js, styles.css)
├── assets/
│   └── banner.svg          ← bannière GitHub
├── build.sh / build.ps1    ← build .dmg / .exe
├── BUILD.md                ← guide de build complet
├── CLAUDE.md               ← skill routing + instructions session
├── .mcp.json               ← MCPs : magic, playwright, context7
├── .env.example            ← template → .env.local
├── setup.ps1 / setup.sh    ← install CLI (alternatif app)
├── new-project.ps1 / .sh   ← bootstrap projet sans app
├── .claude/
│   ├── settings.json       ← plugins, marketplaces, hooks
│   ├── skills/             ← impeccable, taste-skill, emil-design-eng, tdd-workflow, security
│   └── scripts/obsidian.js ← bridge Obsidian REST API
└── docs/
    ├── prompts.md          ← prompts prêts par tâche
    └── obsidian-setup.md   ← guide Obsidian
```

---

## Dépannage

| Problème | Solution |
|---|---|
| « Node.js non trouvé » | Installer Node 18+ → [nodejs.org](https://nodejs.org), relancer l'app |
| « Claude Code non trouvé » | Installer CLI → [claude.ai/code](https://claude.ai/code), vérifier `claude --version` |
| Plugin échoue à l'install | Non-bloquant. Réinstaller : `claude plugin install <nom>` |
| Claude demande encore confirmation | Vérifier `"defaultMode": "bypassPermissions"` dans `.claude/settings.json` du projet |
| `./build.sh: permission denied` | `chmod +x build.sh && ./build.sh` |
| App ne se lance pas (Windows) | Installer [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe) |

---

<div align="center">

MIT · [Makooff](https://github.com/Makooff) · fait avec ⚡ pour Claude Code

</div>
