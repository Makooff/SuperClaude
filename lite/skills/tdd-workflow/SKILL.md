---
name: tdd-workflow
description: >-
  Test-driven development — écrire le test avant le code, cycle red/green/refactor.
  Use when adding tests, fixing a bug that needs a regression test, or building a
  feature that should be spec'd first. Trigger on test, TDD, spec, coverage,
  jest, vitest, "écris les tests", "ajoute un test".
---

# tdd-workflow

## Cycle

**RED** — un test, pour un comportement. Il doit échouer : un test qui passe du premier coup ne teste rien. Nommer `should <comportement> when <condition>`.

**GREEN** — le minimum de code pour passer. Pas d'anticipation, pas de généralisation.

**REFACTOR** — dédupliquer, renommer. Les tests restent verts.

## Règles

**Unitaire** — une assertion par test si possible · dépendances externes mockées · < 100 ms · aucune logique (`if`/`for`) dans le test.

**Intégration** — chemins critiques bout en bout · pas de mock entre composants qu'on teste ensemble · données isolées via factories.

**Coverage** — 90%+ sur le critique, 80%+ sur les utils. Ne pas chasser le 100%.

## Nommage

```
describe('UserService', () => {
  describe('createUser', () => {
    it('should return user with id when email is valid', ...)
    it('should throw ValidationError when email is missing', ...)
    it('should throw DuplicateError when email already exists', ...)
  })
})
```

## Quand ne PAS faire le test d'abord

Prototypage exploratoire (tests après stabilisation) · code généré (scaffolding, migrations) · script one-shot.
