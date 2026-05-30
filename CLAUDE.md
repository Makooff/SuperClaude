# SuperClaude

## Skills auto-routing
| Trigger | Skills |
|---|---|
| design/UI/page/composant/layout/animation/hero/card/button/font | `Skill(impeccable)` `Skill(taste-skill)` `Skill(emil-design-eng)` |
| review/audit | `Skill(code-review)` |
| test/tdd/coverage | `Skill(tdd-workflow)` |
| bug/crash/erreur/debug | `Skill(systematic-debugging)` |
| auth/token/password/API key | `Skill(security)` |
| plan/feature/architecture | `Skill(writing-plans)` `Skill(executing-plans)` |
| check/qa/verif/deploy | `Skill(verify)` |

## Output
- Réponses courtes par défaut. Pas de prose inutile.
- Pas de résumé de ce qui vient d'être fait sauf si demandé.
- Pas d'explication de code évident.
- Code: zéro commentaire sauf WHY non-obvious.

## MCPs
- `magic` → composants 21st.dev
- `playwright` → browser/E2E
- `context7` → docs live (ajouter "use context7")

## Design — interdictions
- Pas de `transition-all` / `background-clip:text` / Inter font / glassmorphism
- Framer Motion easing: `cubic-bezier(0.16,1,0.3,1)`. Press: `scale(0.97)`.

## Mémoire Obsidian
`OBSIDIAN_VAULT` dans `.env.local`. Hook inject-context actif.
Logger: `node .claude/scripts/obsidian.js append "$OBSIDIAN_VAULT/Sessions/YYYY-MM-DD.md" "## HH:MM — [action]"`

## Commits
`feat|fix|refactor: desc` — Pas de Co-Authored-By.
