# SuperClaude

## Règle fondamentale — Skills always-on

**AVANT chaque réponse**, identifier la catégorie de tâche et invoquer le skill approprié. Pas de mot-clé requis — analyser l'INTENTION.

| Catégorie | Skills | Exemples d'intention |
|---|---|---|
| Design produit / flow | `Skill(product-design)` | flow utilisateur, onboarding, dashboard, settings, revoir un écran |
| UI / design / visuel | `Skill(product-design)` `Skill(impeccable)` `Skill(taste-skill)` | créer page, refaire UI, composant, hero, layout |
| Animation / motion | `Skill(emil-design-eng)` `Skill(review-animations)` | transition, easing, micro-interaction, "feel weird", polish |
| Revue / qualité | `Skill(code-review)` | relire code, refactorer, optimiser, inspecter PR |
| Tests | `Skill(tdd-workflow)` | écrire tests, coverage, spec, E2E |
| Debug / fix | `Skill(systematic-debugging)` | bug, crash, erreur, ne fonctionne pas |
| Sécurité | `Skill(security)` | auth, tokens, clés, permissions, vulnérabilités |
| Plan / architecture | `Skill(writing-plans)` `Skill(executing-plans)` | nouvelle feature, conception, comment implémenter |
| Vérification | `Skill(verify)` | vérifier avant push, QA, CI, deploy |
| Discipline agentic | `Skill(agentic-practice)` | avant commit/push, proprement, production-ready |
| Prose / rédaction | `Skill(prose-clean)` | blog, README, doc, email, "sans IA", réécris |
| Marketing / growth | `Skill(marketing-growth)` | landing, ad copy, CRO, conversion, funnel, SEO |
| Recherche web | `Skill(web-research)` | compare, benchmark, tendance, "que disent les gens" |
| Multi-agent / orchestration | `Skill(context-engineering)` | décompose, workflow complexe, audit exhaustif, migration |
| Vidéo / ads / motion | `Skill(video-generation)` | pub, teaser, spot, Pika, Hyperframes, Remotion |
| Agence Nova | `Skill(nova-agency)` | spot, campagne Meta/Google, site client, SEO local, agent IA |

**Combiner, pas prioriser.** Chaque skill a un rôle distinct — les invoquer ensemble sans doublon. `product-design` est le hub design ; `impeccable`/`taste-skill` exécutent ; `emil-design-eng`/`review-animations` gèrent le motion.

Si le hook `⚡ SKILLS REQUIS` / `⚡ SKILLS DISPONIBLES` précise des skills : invoquer IMMÉDIATEMENT.

## Économie de tokens (always-on)
- **Lecture lourde → sous-agent.** Recherche/exploration/mapping : déléguer via Explore/Task, garder la conclusion, pas les extraits bruts. Voir `Skill(context-engineering)`.
- Ne pas relire un fichier déjà édité pour « vérifier » (le harness confirme l'édition).
- Ne pas relancer une recherche déjà déléguée — attendre le résultat.
- `caveman` compresse l'output. Réponses courtes, zéro prose de remplissage.

## Self-learning

Les learnings accumulés sont injectés automatiquement. Les appliquer sans question.

## Output
- Réponses courtes. Pas de prose. Pas de résumé sauf demandé. Zéro commentaire code sauf WHY non-obvious.

## MCPs (tous auto-actifs)
- `magic` → composants 21st.dev
- `playwright` → browser/E2E
- `context7` → docs live
- `claude-mem` → mémoire persistante cross-session
- `graphify` → knowledge graph

## Vidéo / Ads
- `Pika` → ads IA, teaser, vidéo depuis prompt. API key: `$PIKA_API_KEY`
- `Hyperframes` → motion design HTML→vidéo. CLI: `npx hyperframes render`
- Voir `Skill(video-generation)` pour workflow complet

## Design — interdictions absolues
- NO `transition-all` / `background-clip:text` / Inter font / glassmorphism
- Framer Motion easing: `cubic-bezier(0.16,1,0.3,1)`. Press: `scale(0.97)`.

## Commits
`feat|fix|refactor: desc` — Pas de Co-Authored-By.
