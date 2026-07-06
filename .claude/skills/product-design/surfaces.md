# Surfaces

How to pick where UI lives, and how persistent it should be. Match the surface to the importance and lifetime of the interaction.

## Surface ladder (least → most disruptive)

| Surface | Use when | Avoid when |
| --- | --- | --- |
| **Inline** (in-place edit, expand, hint) | The change belongs in context; user keeps their place | The action needs focus or has heavy consequence |
| **Popover / dropdown** | Short, contextual choice anchored to a trigger | Content is long, or needs its own validation flow |
| **Toast / snackbar** | Transient confirmation or undo of a completed action | The user must act, or the message is critical |
| **Inline banner** | Persistent state that affects the whole view (quota, outage) | It's a one-off event → use a toast |
| **Sheet / drawer** | A secondary task alongside the main context | It's the primary task → use a page |
| **Modal / dialog** | A focused decision that must block until resolved | It could be inline; stacking modals; routine confirms |
| **Full page / route** | A primary task, or deep content with its own URL | It's a quick edit; would lose the user's context needlessly |

## Rules

- **Prefer inline disclosure before a modal.** Modals interrupt — earn the interruption.
- **Never stack modals.** If a modal spawns a modal, the flow is wrong.
- **Persistence matches importance.** Critical, ongoing state → banner. Momentary → toast.
- **Anchored surfaces animate from their trigger origin**, not screen center (see `Skill(emil-design-eng)`).
- **Destructive confirms** are proportional: low-impact → inline undo toast; high-impact/irreversible → modal that names the consequence and requires deliberate confirmation.
- **URL-worthy state gets a URL.** If a user would bookmark, share, or back-button into it, it's a route — reflect it in the URL (params/query), not hidden local state.
- **Return path.** Every surface a user enters has an obvious, non-destructive way out that restores prior context.

## Toast with undo pattern

Prefer "act now, undo briefly" over "confirm then act" for reversible, low-stakes actions — it's faster and less interruptive. Reserve pre-confirmation for irreversible or high-blast-radius actions.
