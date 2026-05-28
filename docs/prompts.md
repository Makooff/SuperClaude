# Prompts de démarrage session

## Prompt universel (coller au début de chaque session)

```
Nouvelle session Qwillio. Lis le vault Obsidian:
- node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" read "Qwillio/Taches.md"
- node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" read "Qwillio/04 - Decisions.md"

Dis-moi: tâches en cours, dernières décisions, ce qu'on devait faire aujourd'hui.
```

---

## Prompt feature UI / Design

```
Je veux [décrire la feature]. 
Stack: React 19 + Framer Motion + Tailwind + Zustand.
Utilise context7 pour les APIs Framer Motion à jour.
Design register: [product (dark) / brand (cream)].
```

Claude invoquera automatiquement `impeccable` + `taste-skill` + `emil-design-eng`.

---

## Prompt debug

```
[Décrire l'erreur / coller le message d'erreur].
Contexte: [ce qu'on faisait].
```

Claude invoquera `systematic-debugging`.

---

## Prompt feature complexe (planning d'abord)

```
Je veux implémenter [feature]. Commence par un plan détaillé avant de coder.
Fichiers concernés: [liste si connus].
```

Claude invoquera `writing-plans` → `executing-plans`.

---

## Prompt animation Framer Motion

```
Anime [composant] avec Framer Motion.
- Easing: cubic-bezier(0.16, 1, 0.3, 1)
- Stagger: 50ms entre éléments
- Press feedback: scale(0.97) on active
- Utilise context7 pour les dernières APIs motion.
Tokens CSS dans globals.css: --ease-out-expo, --ease-out.
```

---

## Prompt composant Magic (21st.dev)

```
/ui generate [description du composant]
Stack: React + TypeScript + Tailwind.
Design tokens: --q-accent oklch(56% 0.22 264), --q-bg oklch(8% 0.009 265).
```

---

## Prompt vérification avant deploy

```
Vérifie que [feature] fonctionne correctement avant de deployer.
Lance le app avec Playwright et teste: [décrire le flow].
```

Claude invoquera `verify`.

---

## Prompt code review

```
Review le code que je viens d'écrire dans [fichier(s)].
```

Claude invoquera `code-review`.

---

## Prompt mémoire — retrouver une décision passée

```
Cherche dans la mémoire: [sujet / décision].
Utilise claude-mem:mem-search.
```
