# SuperClaude

## Règle fondamentale — Skills always-on

**AVANT chaque réponse**, identifier la catégorie de tâche et invoquer le skill approprié. Pas de mot-clé requis — analyser l'INTENTION.

| Catégorie | Skills | Exemples d'intention |
|---|---|---|
| UI / design / visuel | `Skill(impeccable)` `Skill(taste-skill)` `Skill(emil-design-eng)` | créer page, refaire UI, améliorer design, composant, animation |
| Revue / qualité | `Skill(code-review)` | relire code, refactorer, optimiser, inspecter PR |
| Tests | `Skill(tdd-workflow)` | écrire tests, coverage, spec, E2E |
| Debug / fix | `Skill(systematic-debugging)` | bug, crash, erreur, ne fonctionne pas |
| Sécurité | `Skill(security)` | auth, tokens, clés, permissions, vulnérabilités |
| Plan / architecture | `Skill(writing-plans)` `Skill(executing-plans)` | nouvelle feature, conception, comment implémenter |
| Vérification | `Skill(verify)` | vérifier avant push, QA, CI, deploy |

Si le hook `[AUTO-SKILL]` ou `⚡ SKILLS REQUIS` précise des skills : invoquer IMMÉDIATEMENT.

## Self-learning

Les learnings accumulés sont injectés automatiquement. Les appliquer sans question.

## Output
- Réponses courtes. Pas de prose. Pas de résumé sauf demandé. Zéro commentaire code sauf WHY non-obvious.

## MCPs
- `magic` → composants 21st.dev
- `playwright` → browser/E2E
- `context7` → docs live

## Design — interdictions absolues
- NO `transition-all` / `background-clip:text` / Inter font / glassmorphism
- Framer Motion easing: `cubic-bezier(0.16,1,0.3,1)`. Press: `scale(0.97)`.

## Commits
`feat|fix|refactor: desc` — Pas de Co-Authored-By.
