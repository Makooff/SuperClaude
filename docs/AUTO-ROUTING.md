# Auto-routing des skills

SuperClaude invoque les skills **tout seul**. Pas de mot-clé à retenir : un hook lit chaque message et injecte les skills pertinents avant que Claude réponde.

## Comment ça marche

1. À chaque message, le hook `UserPromptSubmit` exécute `.claude/scripts/skill-router.js`.
2. Le script classe l'intention via des regex sémantiques (design, debug, marketing…).
3. Il imprime `⚡ SKILLS REQUIS` (ou `⚡ SKILLS DISPONIBLES` si 3+ matchs) avec la liste.
4. `CLAUDE.md` ordonne à Claude d'invoquer immédiatement ces skills.
5. Un second hook injecte les learnings projet accumulés.

Les skills sont **combinés, pas priorisés** : chacun a un rôle distinct, aucun doublon.

## Table catégorie → skills

| Intention détectée | Skills invoqués |
|---|---|
| Design produit, flow, onboarding, dashboard | `product-design` |
| UI, page, composant, hero, layout | `product-design` + `impeccable` + `taste-skill` |
| Animation, motion, easing, "feel weird" | `emil-design-eng` + `review-animations` |
| Review, refactor, audit, optimise | `code-review` |
| Test, TDD, coverage, E2E | `tdd-workflow` |
| Bug, crash, erreur, "marche pas" | `systematic-debugging` |
| Auth, token, clé, permission, vuln | `security` |
| Feature, architecture, conception | `writing-plans` + `executing-plans` |
| Vérifier, deploy, CI, build | `verify` |
| Avant commit/push, proprement | `agentic-practice` |
| Blog, README, doc, "sans IA" | `prose-clean` |
| Landing, ad copy, CRO, conversion, SEO | `marketing-growth` |
| Compare, benchmark, tendance | `web-research` |
| Orchestre, décompose, audit exhaustif | `context-engineering` |
| Vidéo, spot, teaser, Remotion | `video-generation` |
| Spot, campagne Meta/Google, site client, SEO local | `nova-agency` |

## Ordre de priorité (tie-break)

Quand plusieurs catégories matchent, l'ordre d'affichage suit :

```
security → debug → product-design → design → animation → review →
nova → research → marketing → prose → multi-agent → video →
tests → plan → agentic → verify → feature
```

La sécurité et le debug passent devant : un bug de token s'affiche `security` puis `debug`.

## Anti-collision

- `product-design` est le **hub** design ; `impeccable`/`taste-skill` **exécutent** ; `emil-design-eng`/`review-animations` gèrent le **motion**. Rôles distincts, pas de doublon.
- Review de code → `code-review` (général). Review d'animation → `review-animations` (spécialisé). Pas de conflit.
- 3+ skills → header « SKILLS DISPONIBLES, chacun dans son rôle » : Claude choisit ceux qui s'appliquent.

## Tester le routing

```bash
echo '{"message":"refais ce hero"}' | node .claude/scripts/skill-router.js
```

Sortie attendue :
```
⚡ SKILLS REQUIS — invoquer AVANT de répondre:
  → Skill(product-design) + Skill(impeccable) + Skill(taste-skill)  [tâche UI/design détectée]
```

## Ajouter une catégorie

Édite `classify()` dans `.claude/scripts/skill-router.js` : ajoute un bloc `add('clé', 'Skill(nom)', 'raison')`, puis référence `'clé'` dans le tableau `PRIORITY`.
