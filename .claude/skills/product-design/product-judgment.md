# Product Judgment

Load before any Shape, Implement, Harden, or material change. Write a compact internal brief before touching UI. The brief is thinking scaffolding, not a deliverable — keep it short.

## The brief (answer each, one line)

- **User** — who is acting? Their role, expertise, and context.
- **Job** — what are they trying to accomplish? The real outcome, not the click.
- **Current behavior** — what does the product do today for this job?
- **Desired outcome** — what should happen instead, and why is it better?
- **Success signal** — how do we know it worked? (observable, not vibes)
- **Non-goals** — what this change explicitly does NOT address.
- **Object** — the product entity being acted on (a project, a deploy, a row…).
- **Scope** — one item, a selection, or everything?
- **Action** — create / read / update / delete / trigger / configure.
- **Consequence** — what changes in the system and for other users?
- **Reversibility** — can the user undo? How, and within what window?
- **Permissions** — who is allowed? What happens when they aren't?
- **Open decisions** — unresolved product choices. Mark these explicitly; do not bury them in implementation.

## Materiality test

A decision is **material** (needs a brief) when it changes the user's task, a default, scope, a consequence, navigation, the interaction surface, or which states are reachable.

It is **not material** (skip the brief) for copy mechanics, token replacement, or swapping one established component for its documented equivalent.

## Anti-patterns

- Solving one job by adding an unrelated setting or toggle.
- Adding configuration where a strong default would serve everyone.
- Designing only the populated success case and calling it done.
- Treating an existing shipped screen as proof that its pattern is correct.
- Hiding an unresolved product question inside a styling choice.

## Smallest coherent intervention

Before adding UI, in order: (1) can a better default remove the need? (2) can existing behavior be adjusted? (3) can an existing component be reused? Only then (4) add new UI. The best change is often the one that removes a decision from the user.
