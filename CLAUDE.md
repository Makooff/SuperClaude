# SuperClaude

## Toujours actifs (chaque message, sans condition)

| Outil | Rôle |
|---|---|
| `caveman` | compresse les réponses — zéro prose |
| `Skill(superpowers)` | méta-orchestration (brainstorm, plans, debug, git) |
| `Skill(context-engineering)` | délègue la lecture lourde aux sous-agents — économie de tokens |
| MCP `graphify` | knowledge graph mémoire cross-session |
| MCP `claude-mem` | mémoire persistante cross-session |

Ce noyau tourne en permanence. Tout le reste ci-dessous est **à la demande** : ne l'invoquer QUE si l'intention le justifie, jamais par réflexe. C'est ce qui rend le setup puissant (accès aux gros outils) sans consommer plus qu'un Claude nu par défaut.

## À la demande — le router les invoque seul selon l'intention

**AVANT chaque réponse**, si le hook `⚡ SKILLS REQUIS` / `⚡ SKILLS DISPONIBLES` précise des skills/outils : invoquer IMMÉDIATEMENT. Sinon, ne rien charger de plus que le noyau.

| Catégorie | Skill | Outil concret | Trigger |
|---|---|---|---|
| Design produit / flow | `product-design` | — | flow utilisateur, onboarding, dashboard, settings, revoir un écran |
| UI / design / visuel | `product-design` + `impeccable` + `taste-skill` | MCP `magic` (génère les composants) | créer page, composant, hero, layout |
| Animation / motion | `emil-design-eng` + `review-animations` | — | transition, easing, micro-interaction, "feel weird", polish |
| Revue / qualité | `code-review` | — | relire code, refactorer, optimiser, inspecter PR |
| Tests | `tdd-workflow` | MCP `playwright` (E2E) | écrire tests, coverage, spec, E2E |
| Debug / fix | `systematic-debugging` | MCP `playwright` (repro navigateur) | bug, crash, erreur, ne fonctionne pas |
| Sécurité | `security` | — | auth, tokens, clés, permissions, vulnérabilités |
| Plan / architecture | `writing-plans` + `executing-plans` | — | nouvelle feature, conception, comment implémenter |
| Vérification | `verify` | MCP `playwright` (vérif visuelle) | vérifier avant push, QA, CI, deploy |
| Discipline agentic | `agentic-practice` | — | avant commit/push, proprement, production-ready |
| Prose / rédaction | `prose-clean` | — | blog, README, doc, email, "sans IA", réécris |
| Marketing / growth | `marketing-growth` | — | landing, ad copy, CRO, conversion, funnel, SEO |
| Recherche web | `web-research` | CLI `agent-reach` (vendor, si présent) sinon WebSearch | compare, benchmark, tendance, "que disent les gens" |
| Docs / lib précise | — | MCP `context7` | "comment utiliser X", version d'une lib, API précise |
| Vidéo / ads / motion | `video-generation` | Pika / Hyperframes / Remotion | pub, teaser, spot, motion |
| Agence Nova | `nova-agency` | — | spot, campagne Meta/Google, site client, SEO local, agent IA |

**Combiner, pas prioriser.** Chaque skill a un rôle distinct — les invoquer ensemble sans doublon. `product-design` est le hub design ; `impeccable`/`taste-skill` exécutent ; `emil-design-eng`/`review-animations` gèrent le motion.

## Économie de tokens (always-on)
- **Lecture lourde → sous-agent.** Recherche/exploration/mapping : déléguer via Explore/Task, garder la conclusion, pas les extraits bruts. Voir `Skill(context-engineering)`.
- Ne pas relire un fichier déjà édité pour « vérifier » (le harness confirme l'édition).
- Ne pas relancer une recherche déjà déléguée — attendre le résultat.
- `caveman` compresse l'output. Réponses courtes, zéro prose de remplissage.
- Les MCP lourds (`magic`, `playwright`, `context7`) ne se chargent que sur intention précise (table ci-dessus) — jamais mentionnés hors contexte.

## Self-learning

Les learnings accumulés sont injectés automatiquement. Les appliquer sans question.

## Output
- Réponses courtes. Pas de prose. Pas de résumé sauf demandé. Zéro commentaire code sauf WHY non-obvious.

## MCPs — deux niveaux

**Mémoire (toujours utiles, coût faible) :**
- `claude-mem` → mémoire persistante cross-session
- `graphify` → knowledge graph

**Outils lourds (invoqués sur intention précise par le router — jamais par défaut) :**
- `magic` → composants 21st.dev — seulement si design/frontend détecté
- `playwright` → browser/E2E — seulement si test/screenshot/navigation détecté
- `context7` → docs live — seulement si lib/framework précis nommé

## Vidéo / Ads
- `Pika` → ads IA, teaser, vidéo depuis prompt. API key: `$PIKA_API_KEY`
- `Hyperframes` → motion design HTML→vidéo. CLI: `npx hyperframes render`
- Voir `Skill(video-generation)` pour workflow complet

## Design — interdictions absolues
- NO `transition-all` / `background-clip:text` / Inter font / glassmorphism
- Framer Motion easing: `cubic-bezier(0.16,1,0.3,1)`. Press: `scale(0.97)`.

## Commits
`feat|fix|refactor: desc` — Pas de Co-Authored-By.
