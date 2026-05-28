# Claude Code — Config de session

## Skill Routing automatique

### Design (UI, pages, composants, animations)
TOUJOURS invoquer ces 3 skills avant tout travail design:
- `Skill(impeccable)`
- `Skill(taste-skill)`
- `Skill(emil-design-eng)`

Triggers: design, page, composant, component, UI, landing, dashboard, redesign, style, layout, couleur, animation, hero, card, button, font, refaire

### Code review
`Skill(code-review)` — après chaque modification de code, avant chaque commit.

### Tests / TDD
`Skill(tdd-workflow)` — nouvelle feature, bug fix, "test", "tdd".

### Debugging
`Skill(systematic-debugging)` — erreur, crash, bug, "debug", "plante".

### Sécurité
`Skill(security)` — auth, token, password, API key, paiements.

### Planning feature complexe
`Skill(writing-plans)` → `Skill(executing-plans)` — multi-fichiers, architecture.

### Vérification / QA
`Skill(verify)` — avant deploy, "check", "qa", "verif".

---

## Mémoire Obsidian

Vault: défini par `OBSIDIAN_VAULT` dans `.env.local` (ex: `MonProjet`).

Lire les tâches:
```bash
node --no-warnings ".claude/scripts/obsidian.js" read "$OBSIDIAN_VAULT/Taches.md"
```

Logger une action:
```bash
node --no-warnings ".claude/scripts/obsidian.js" append "$OBSIDIAN_VAULT/Sessions/YYYY-MM-DD.md" "## HH:MM — [action]\n[details]"
```

Le hook `UserPromptSubmit` injecte automatiquement le contexte Obsidian à chaque message.

---

## MCP disponibles

- `magic` — `/ui generate [description]` pour composants 21st.dev
- `playwright` — browser automation, screenshots, E2E
- `context7` — ajouter `use context7` dans le prompt = docs live

---

## Framer Motion

Toujours utiliser context7 pour les APIs à jour.
Easing par défaut: `cubic-bezier(0.16, 1, 0.3, 1)`.
Press feedback: `scale(0.97)` on `:active`. Stagger: 30-80ms.

---

## Interdictions absolues (design)
- Pas de gradient text (`background-clip: text`)
- Pas de `transition-all` (utiliser `transition-colors`, `transition-opacity`)
- Pas de Inter font (utiliser Outfit ou la font du projet)
- Pas de glassmorphism par défaut
- Pas de modal comme première solution

---

## Commits
```
feat: description
fix: description
refactor: description
```
Pas de Co-Authored-By.
