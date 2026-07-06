# Interface Quality

Load for implementation, material visual change, or full review. This is the craft checklist once the product decision is settled.

## Hierarchy

- One clear primary action per surface. Secondary actions visibly subordinate.
- Size, weight, and color encode priority — not four equal blocks fighting for attention.
- One H1 per view. Heading levels descend without skipping.
- Group related controls; separate unrelated ones with space, not just borders.

## Spacing & layout

- Use a consistent spacing scale (4 / 8 / 12 / 16 / 24 / 32 / 48 / 64). No `padding: 13px`.
- Prefer hierarchy, spacing, and alignment before adding containers, cards, or dividers.
- Align to a grid. Optical alignment beats mathematical alignment when they disagree.
- Whitespace is a feature. Density should match the task (dense for data, airy for onboarding).

## Components

- Use semantic design-system components and their documented APIs before custom HTML.
- Navigation uses navigation components; actions use buttons. Never a link styled as a button doing a mutation.
- Match the component to the importance: inline < popover < modal < full page.
- Don't rebuild what the design system already provides (menus, toasts, dialogs, inputs).

## Typography

- One type family, two or three weights max. Body line-height 1.4–1.6, headings 1.1–1.25.
- Line length 45–80 characters for reading text.
- Numbers that align in tables use tabular figures.

## Color & contrast

- Body text ≥ 4.5:1, large text ≥ 3:1. Muted = same hue at lower opacity, not a random gray.
- Semantic tokens (success/warning/error/info), never raw hex scattered in components.
- Never rely on color alone to convey state — pair with icon, text, or shape.

## Focus & interaction

- `:focus-visible` on every interactive element. Visible ring, 2px, offset.
- Logical tab order. Focus moves into opened overlays and returns on close.
- Hit targets ≥ 44px on touch. Hover states gated behind `@media (hover: hover)`.
- Loading affordance on the control that triggered it; keep its label stable.

## Motion

- Defer to `Skill(emil-design-eng)` and `Skill(review-animations)`. Baseline: transform/opacity only, ≤ 300ms UI, no `transition: all`, respect `prefers-reduced-motion`.

## Review pass (rendered, not code)

1. Compact + wide viewport.
2. Every reachable state (see `resilience.md`).
3. Keyboard-only walkthrough.
4. Long content / large numbers / empty.
5. Localization / RTL risk.

## Absolute don'ts

- `transition: all`
- `background-clip: text` on body-length copy
- Inter as a "default" without reason; glassmorphism without purpose
- Magic numbers unjustified by the spacing scale
- Approving visual quality from reading code alone
