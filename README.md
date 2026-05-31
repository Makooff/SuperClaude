<div align="center">

# ⚡ SuperClaude

**Setup Claude Code ultra-poussé — en 1 clic.**

22 plugins · 191 agents · 155 skills · mémoire cross-session · agent ultra · MCPs préconfigurés

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-7c3aed)
![Electron](https://img.shields.io/badge/app-Electron-09090b)
![License](https://img.shields.io/badge/license-MIT-10b981)

</div>

---

## C'est quoi ?

Une **app desktop** (Mac + PC) qui transforme Claude Code en agent ultra-puissant en quelques clics :

- Installe les **meilleurs plugins** de l'écosystème (officiels + `wshobson/agents`)
- Active **191 agents** et **155 skills** spécialisés (review, debug, test, sécurité, fullstack, perf, orchestration…)
- Configure les **MCPs** : génération de composants UI, docs live, automation browser
- Rend Claude **conscient** avec mémoire cross-session (`claude-mem` + Obsidian)
- Active un **agent ultra** (`bypassPermissions`) — Claude agit sans demander
- Tu **choisis ton dossier projet** dans l'UI → Claude s'ouvre dedans, prêt

---

## ⚡ Quickstart

```bash
git clone https://github.com/Makooff/SuperClaude.git
cd SuperClaude
./build.sh          # Mac/Linux  ·  Windows : .\build.ps1
```

L'app se construit dans `installer-app/dist/`. Lance-la, clique **Installer**, choisis ton dossier projet. Fini.

> Pas envie de builder ? Mode dev direct : `cd installer-app && npm install && npm start`

---

## 📖 Tutoriel complet

### Étape 0 — Prérequis

| Outil | Version | Lien |
|---|---|---|
| Node.js | 18+ | [nodejs.org](https://nodejs.org) |
| Claude Code | dernière | [claude.ai/code](https://claude.ai/code) |

> L'app vérifie ces deux outils à l'écran 2 et te donne les liens si l'un manque.

### Étape 1 — Récupérer SuperClaude

**Option A — git (recommandé)**
```bash
git clone https://github.com/Makooff/SuperClaude.git
cd SuperClaude
```

**Option B — ZIP**
[Télécharger le ZIP](https://github.com/Makooff/SuperClaude/archive/refs/heads/main.zip) → extraire → ouvrir le dossier dans un terminal.

### Étape 2 — Construire l'app

**Mac / Linux**
```bash
./build.sh
```

**Windows**
```powershell
.\build.ps1
```

Artefact généré dans `installer-app/dist/` :
- Windows → `.exe` (NSIS)
- macOS → `.dmg`

> Détails build : voir [`BUILD.md`](BUILD.md).

### Étape 3 — Lancer & installer

Ouvre l'app. Elle te guide en 6 écrans :

1. **Bienvenue** — aperçu de ce qui sera installé
2. **Prérequis** — vérifie Node.js + Claude Code
3. **Config** — clés API optionnelles (Magic 21st.dev, Obsidian) + options
4. **Installation** — installe plugins + MCPs en live (logs visibles)
5. **Choisir le projet** — bouton → tu sélectionnes ton dossier → copie config + active l'agent ultra
6. **Fini** — Claude Code s'ouvre dans ton dossier

### Étape 4 — Premier message

Dans Claude Code, écris simplement :
```
Crée une landing page pour une app de todo, design moderne dark.
```
Le mot « design » déclenche auto `impeccable` + `taste-skill` + `emil-design-eng`. Aucun setup manuel.

---

## 📦 Ce qui est installé

### Plugins officiels (12)
| Plugin | Rôle |
|---|---|
| `superpowers` | Skills méta (brainstorming, plans, TDD, debug) |
| `code-review` | Review de PR/diff |
| `github` | Opérations GitHub |
| `vercel` / `supabase` / `stripe` | Intégrations services |
| `claude-mem` | Mémoire auto cross-session |
| `caveman` | Mode réponse compact (économie tokens) |
| `claude-md-management` | Maintenance CLAUDE.md |
| `context7` | Docs live |
| `skill-creator` | Création de skills |
| `playwright` | Automation browser |

### Packs `wshobson/agents` — 191 agents, 155 skills (10)
| Pack | Contenu |
|---|---|
| `comprehensive-review` | Review multi-angle |
| `debugging-toolkit` | Debug + optimisation DX |
| `unit-testing` | Tests auto Python/JS |
| `security-scanning` | SAST + sécurité API |
| `full-stack-orchestration` | Feature end-to-end |
| `frontend-mobile-development` | React / React Native |
| `ui-design` | Agents UI/UX |
| `cicd-automation` | Pipelines CI/CD |
| `agent-orchestration` | Systèmes multi-agents |
| `application-performance` | Profiling + optimisation |

### MCP servers (3)
| MCP | Usage |
|---|---|
| `magic` | `/ui generate [description]` → composants 21st.dev |
| `context7` | `use context7` dans le prompt → docs à jour |
| `playwright` | Tests E2E + screenshots |

---

## 🤖 Agent ultra

L'installeur écrit dans le `.claude/settings.json` du projet :
```json
{ "permissions": { "defaultMode": "bypassPermissions" } }
```
Claude exécute tout (commandes, éditions) **sans demander confirmation**. Puissance max.

> ⚠️ **Sécurité** : `bypassPermissions` donne à l'agent un contrôle total sur le dossier projet. À n'utiliser que sur des projets de confiance, sur ta machine. Pour revenir à un mode prudent, change `defaultMode` en `acceptEdits` ou supprime la clé.

---

## 🧠 Mémoire — Claude conscient

Deux couches :

1. **`claude-mem`** — mémoire auto cross-session, zéro config. Installée par défaut.
2. **Obsidian** (optionnel) — injecte tâches / décisions / contexte produit à chaque message via un hook `UserPromptSubmit`.

Setup Obsidian détaillé : [`docs/obsidian-setup.md`](docs/obsidian-setup.md).
Renseigne `OBSIDIAN_VAULT` et `OBSIDIAN_API_KEY` dans `.env.local`.

---

## 🎯 Skill routing automatique

Aucune commande à taper — les skills s'invoquent selon les mots du prompt :

| Mot dans le prompt | Skills invoqués |
|---|---|
| design, UI, composant, animation, page, layout, hero, card, button, font | `impeccable` + `taste-skill` + `emil-design-eng` |
| review, audit | `code-review` |
| test, tdd, coverage | `tdd-workflow` |
| bug, crash, erreur, debug | `systematic-debugging` |
| auth, token, password, API key | `security` |
| plan, feature, architecture | `writing-plans` + `executing-plans` |
| check, qa, verif, deploy | `verify` |

---

## 🔌 Exemples MCP

**Magic — générer un composant**
```
/ui generate une card produit avec image, titre, prix, bouton panier
```

**Context7 — docs live**
```
Anime cette card avec Framer Motion. use context7 pour les APIs à jour.
```

**Playwright — E2E**
```
Vérifie que le formulaire de login fonctionne avec Playwright.
```

---

## 🆕 Nouveau projet (sans l'app)

Fallback CLI si tu ne veux pas relancer l'app :

**Windows**
```powershell
.\new-project.ps1 -Name MonProjet -Path C:\Projets\MonProjet
```

**Mac / Linux**
```bash
./new-project.sh MonProjet ~/Projets/MonProjet
```

Copie la config, remplit `.env.local` interactivement, met à jour `.gitignore`.

---

## 📁 Structure

```
SuperClaude/
├── installer-app/            ← app Electron (Mac + PC)
│   ├── main.js               ← process principal + IPC (copie config, picker)
│   ├── preload.js
│   └── src/                  ← UI (index.html, renderer.js, styles.css)
├── build.sh / build.ps1      ← build l'app en .dmg / .exe
├── BUILD.md                  ← guide de build
├── CLAUDE.md                 ← instructions + skill routing (injecté chaque session)
├── .mcp.json                 ← MCP servers (magic, playwright, context7)
├── .env.example              ← template secrets → .env.local
├── setup.ps1 / setup.sh      ← install machine CLI (alternatif)
├── new-project.ps1 / .sh     ← bootstrap projet (fallback)
├── .claude/
│   ├── settings.json         ← hooks auto-skill + plugins + marketplaces
│   ├── skills/               ← 5 skills custom (impeccable, taste-skill, emil-design-eng, tdd-workflow, security)
│   └── scripts/obsidian.js   ← bridge Obsidian REST API
└── docs/
    ├── prompts.md            ← prompts prêts par type de tâche
    └── obsidian-setup.md     ← guide Obsidian
```

---

## ❓ Dépannage

| Problème | Solution |
|---|---|
| « Node.js non trouvé » | Installer Node 18+ depuis [nodejs.org](https://nodejs.org), relancer l'app |
| « Claude Code non trouvé » | Installer depuis [claude.ai/code](https://claude.ai/code), vérifier `claude --version` |
| Un plugin échoue à l'install | Non-bloquant — l'installeur continue. Réinstaller plus tard : `claude plugin install <nom>` |
| Claude demande encore confirmation | Vérifier `defaultMode: bypassPermissions` dans `.claude/settings.json` du projet |
| `./build.sh: permission denied` | `chmod +x build.sh` puis relancer |

---

<div align="center">

MIT · fait avec ⚡ pour Claude Code

</div>
