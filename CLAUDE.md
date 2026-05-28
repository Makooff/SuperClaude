# SuperClaude — Instructions globales

## Stack Qwillio
React 19, TypeScript, Vite, Tailwind CSS, Framer Motion, Recharts, React Router v7, Zustand.
Backend: Node.js/Express (Render). Frontend: Vercel.
Brand: Indigo `oklch(56% 0.22 264)` + Violet `oklch(67% 0.26 299)`. Font: Outfit.

## Skill Routing automatique

### Design (UI, pages, composants, animations)
TOUJOURS invoquer ces 3 skills avant tout travail design :
- `Skill(impeccable)`
- `Skill(taste-skill)`
- `Skill(emil-design-eng)`

Triggers: design, page, composant, component, UI, landing, dashboard, redesign, style, layout, couleur, animation, hero, card, button

### Code review
`Skill(code-review)` — après chaque modification de code.

### Tests / TDD
`Skill(tdd-workflow)` — nouvelle feature, bug fix, "test".

### Debugging
`Skill(systematic-debugging)` — erreur, crash, bug.

### Sécurité
`Skill(security)` — auth, token, password, API key.

### Planning
`Skill(writing-plans)` → `Skill(executing-plans)` — feature complexe.

### Vérification
`Skill(verify)` — avant deploy, "check", "qa".

## Mémoire Obsidian

Vault: `C:\Users\matpo\Documents\Spram\Spram\Qwillio\`

Lire les tâches:
```powershell
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" read "Qwillio/Taches.md"
```

Après chaque action significative, logger dans Obsidian:
```powershell
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" append "Qwillio/Sessions/YYYY-MM-DD.md" "## HH:MM — [action]\n[details]"
```

## Design System tokens

```css
--q-bg:       oklch(8% 0.009 265)
--q-accent:   oklch(56% 0.22 264)
--q-violet:   oklch(67% 0.26 299)
--q-text:     oklch(95% 0.004 265)
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1)
```

## Interdictions absolues
- Pas de gradient text (`background-clip: text`)
- Pas de `transition-all` (utiliser `transition-colors`, `transition-opacity`)
- Pas de Inter (utiliser Outfit)
- Pas de tiret em (utiliser virgule, deux-points, parenthèses)
- Pas de glassmorphism par défaut
- Pas de modal comme première solution

## Framer Motion
Toujours utiliser context7 pour les APIs Framer Motion à jour.
Easing par défaut: `cubic-bezier(0.16, 1, 0.3, 1)`.
Press feedback: `scale(0.97)` on `:active`. Stagger: 30-80ms.

## MCP disponibles
- `magic` — composants UI (@21st-dev)
- `playwright` — browser automation
- `context7` — docs live (ajouter "use context7" dans le prompt)
- `claude-mem` — mémoire cross-session

## Commits
```
feat: description
fix: description
refactor: description
```
Pas de Co-Authored-By.
