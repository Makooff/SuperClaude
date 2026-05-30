# Skill: emil-design-eng
# Design engineering — bridge between design and production code

## Trigger
Design, composant, animation, Framer Motion, CSS, interaction, micro-animation, transition

## Behavior

Quand invoqué pour implémenter du design en code :

### Animations — defaults

**Easing signature**
```css
cubic-bezier(0.16, 1, 0.3, 1)  /* spring-like, snappy */
```

**Durées**
- Micro (hover, focus): 120-150ms
- Élément (apparition, disparition): 200-300ms
- Page transition: 350-450ms
- Jamais plus de 500ms sauf animation narrative intentionnelle

**Framer Motion defaults**
```js
const spring = { type: "spring", stiffness: 400, damping: 30 }
const easeOut = { duration: 0.25, ease: [0.16, 1, 0.3, 1] }

// Stagger enfants
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.05 }
  }
}
```

### Interactions

**Press feedback**
```css
:active { transform: scale(0.97); }
/* ou Framer Motion: whileTap={{ scale: 0.97 }} */
```

**Hover lift subtil**
```css
:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
```

### Composants — patterns

**Skeleton loading** plutôt que spinner pour contenu
**Optimistic UI** — mettre à jour l'UI avant la réponse serveur
**Error states** — toujours prévoir, jamais ignorer
**Empty states** — illustrés, pas juste "Aucun résultat"

### CSS — patterns production

```css
/* Focus visible accessible */
:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

/* Scroll smooth */
@media (prefers-reduced-motion: no-preference) {
  html { scroll-behavior: smooth; }
}

/* Text truncate */
.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
```
