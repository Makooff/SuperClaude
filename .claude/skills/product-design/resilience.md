# Resilience

Design every reachable state, then the ways real data and networks break your layout. Only design states the product can actually enter — but don't stop at the happy path.

## Reachable states (check each applies, then design it)

- **Loading** — initial, and subsequent/refetch. Skeleton for structure, spinner for actions.
- **Empty** — first-run (never had data) vs cleared (had data, now none). Different copy.
- **Sparse** — one item, two items. Layouts tuned for "many" often break at "one".
- **Populated** — the normal case.
- **Overflowing** — far more than expected. Pagination, virtualization, or truncation.
- **Validation** — per-field and form-level, before and after submit.
- **Error** — recoverable (retry) vs terminal (contact support). Preserve user input.
- **Permission** — allowed, read-only, and denied. Denied explains why + next step.
- **Disabled** — and why (tooltip or helper text; never a dead control with no reason).
- **Optimistic / pending** — action shown as done before the server confirms; reconcile on failure.
- **Stale** — data changed under the user; offer refresh without destroying their work.
- **Destructive** — proportional confirmation + undo where honestly supported.

## Content stress tests

- **Long strings** — names, titles, emails with no spaces. `min-width: 0`, `overflow-wrap`, truncation with full value in `title`/tooltip.
- **Large numbers** — 1,000,000 and 0 and negative. Localized separators. Column doesn't jump.
- **Constrained width** — 320px. Nothing clips, no horizontal page scroll.
- **Localization / RTL** — longer languages (German ~+35%), right-to-left mirroring, date/number formats.
- **Missing media** — broken image, absent avatar → graceful fallback, never a broken-icon.

## Network & failure

- Every fetch has loading + error + empty. No infinite spinner on failure.
- Retries are explicit and idempotent-safe. Don't double-submit on double-click (disable + guard).
- Slow network: optimistic UI where safe; otherwise a clear pending state.
- Offline / timeout: a human message and a retry, not a silent nothing.

## Layout integrity

- Content containers use `overflow-x: auto` for wide children (tables, code) so the page body never scrolls sideways.
- Images/media `max-width: 100%`. Fixed heights avoid layout shift on load.
- Test with browser zoom 200% and OS large-text settings.
