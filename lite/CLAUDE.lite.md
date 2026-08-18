# SuperClaude Lite

## Noyau — actif en permanence
`caveman` (réponses compressées) · `superpowers` (brainstorm, plans, debug, TDD) · `Skill(context-engineering)` (déléguer la lecture lourde aux sous-agents) · MCP `claude-mem` + `graphify` (mémoire cross-session).

Rien d'autre n'est chargé par défaut.

## À la demande — jamais par réflexe
Le hook `UserPromptSubmit` analyse chaque message et n'affiche que des skills **réellement installés**. S'il affiche `⚡ REQUIS` / `⚡ PERTINENT`, invoquer immédiatement. S'il n'affiche rien, ne rien charger de plus que le noyau.

| Intention | Skills | MCP |
|---|---|---|
| design, UI, écran, composant | `product-design` + `impeccable` + `taste-skill` | `magic` |
| animation, motion, easing | `emil-design-eng` + `review-animations` | — |
| revue, refactor, audit | `code-review` | — |
| tests, TDD, coverage | `tdd-workflow` | `playwright` |
| bug, crash, erreur | `systematic-debugging` | — |
| sécurité, auth, secrets | `security` | — |
| plan, architecture | `writing-plans` + `executing-plans` | — |
| avant push / livraison | `verification-before-completion` + `agentic-practice` | — |
| doc d'une lib précise | — | `context7` |

**Combiner, pas prioriser** — chaque skill a un rôle distinct. `product-design` décide, `impeccable` exécute, `taste-skill` arbitre le visuel.

MCP lourds éteints par défaut pour économiser le contexte : `sc-mcp magic on` (idem `playwright`, `context7`), `sc-mcp list` pour l'état.

## Économie de tokens
Recherche/exploration/mapping → sous-agent, garder la conclusion pas les extraits. Ne pas relire un fichier déjà édité. Ne pas relancer une recherche déjà déléguée.

## Output
Réponses courtes. Zéro prose de remplissage. Pas de résumé sauf demandé. Commentaire de code seulement pour un WHY non évident.

## Design — interdictions absolues
Pas de `transition-all`, pas de `background-clip:text`, pas de font Inter, pas de glassmorphism. Easing : `cubic-bezier(0.16,1,0.3,1)`. Press : `scale(0.97)`.

## Commits
`feat|fix|refactor: description` — pas de `Co-Authored-By`.
