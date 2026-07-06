# Copy

Load for Copy mode or any user-facing language and accessible names. Edit language and directly required JSX only; report structural blockers instead of silently widening scope.

## Principles

- **Clarity over cleverness.** The user is mid-task, not reading for pleasure.
- **Lead with the object and outcome.** "Delete 3 projects" beats "Are you sure?".
- **Name the consequence.** Destructive and irreversible actions say what is lost and whether it returns.
- **Speak the user's words**, not the system's internals (say "workspace", not "tenant row").
- **Consistent terms.** One concept, one word, everywhere. Don't alternate "remove"/"delete"/"clear" for the same action.

## Buttons & actions

- Verb + object: "Create project", "Invite member", "Cancel deploy".
- Match the button label to the dialog title's action.
- Avoid "OK" / "Submit" / "Yes". Say what happens.

## Errors

- Actionable: what went wrong + what to do next. "Couldn't connect — check your network and retry."
- Never blame the user. Never expose stack traces or codes without a human sentence.
- Preserve their input; never make them retype after an error.

## Empty states

- Say why it's empty and the one action to fill it. Empty is an onboarding moment, not a dead end.

## Accessible names

- Every icon-only control has an `aria-label` describing the action, not the icon ("Close", not "X icon").
- Labels tied to inputs (`<label for>`), not placeholder-as-label.
- Announce async results to screen readers (`aria-live`) when state changes without focus moving.

## Tone

- Calm, direct, second person ("you"). Present tense.
- No hype, no emoji in product chrome unless brand-intentional.
- See `Skill(prose-clean)` to strip AI tells from longer copy.

## Micro-rules

- Sentence case for UI labels and buttons (not Title Case) unless the design system says otherwise.
- No trailing punctuation on labels/buttons; full sentences in body/help text.
- Numbers: localize thousands separators; pluralize correctly ("1 item" / "2 items").
