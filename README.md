# SuperClaude

Config Claude Code complète — skills auto-routés, MCPs actifs, mémoire Obsidian cross-session.
Un script, un projet bootstrappé, premier message opérationnel.

---

## Install — une fois par machine

### Windows
1. [Télécharger SuperClaude.zip](https://github.com/Makooff/SuperClaude/archive/refs/heads/main.zip)
2. Extraire le ZIP
3. Double-cliquer sur `SuperClaude-Installer.ps1` → **Exécuter avec PowerShell**
4. Cliquer sur **Installer** — Claude Code s'ouvre automatiquement

### Mac / Linux
1. [Télécharger SuperClaude.zip](https://github.com/Makooff/SuperClaude/archive/refs/heads/main.zip)
2. Extraire le ZIP
3. Dans Terminal :
   ```bash
   chmod +x SuperClaude-Installer.command
   ./SuperClaude-Installer.command
   ```

> **Alternativement** — installation via git :
> ```bash
> # Windows
> git clone https://github.com/Makooff/SuperClaude.git C:/SuperClaude && cd C:/SuperClaude && .\setup.ps1
> # Mac/Linux
> git clone https://github.com/Makooff/SuperClaude.git ~/SuperClaude && cd ~/SuperClaude && chmod +x setup.sh && ./setup.sh
> ```

---

## Nouveau projet

### Windows
```powershell
cd C:/SuperClaude
.\new-project.ps1 -Name MonProjet -Path C:\Projets\MonProjet
```

### Mac / Linux
```bash
~/SuperClaude/new-project.sh MonProjet ~/Projets/MonProjet
```

Le script copie la config, remplit `.env.local` interactivement et configure `.gitignore`.

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

## Skill routing

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

## MCP servers

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

## Structure

```
SuperClaude/
├── CLAUDE.md                       ← instructions + skill routing
├── .mcp.json                       ← MCP servers (magic, playwright, context7)
├── .env.example                    ← template secrets → copier en .env.local
├── SuperClaude-Installer.ps1       ← installeur GUI WPF Windows (double-clic)
├── SuperClaude-Installer.command   ← installeur terminal Mac (double-clic)
├── setup.ps1                       ← install machine Windows (CLI)
├── setup.sh                        ← install machine Mac/Linux (CLI)
├── new-project.ps1                 ← bootstrap projet Windows
├── new-project.sh                  ← bootstrap projet Mac/Linux
├── .claude/
│   ├── settings.json          ← hooks auto-skill + plugins activés
│   └── scripts/
│       └── obsidian.js        ← bridge Obsidian REST API
└── docs/
    ├── prompts.md             ← prompts prêts par type de tâche
    └── obsidian-setup.md      ← guide détaillé Obsidian
```
