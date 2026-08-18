# SuperClaude Lite

Le même setup, réduit à ce que tu utilises vraiment. ~4× moins de contexte permanent, et tout s'invoque tout seul.

```bash
# Mac / Linux
curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.sh | bash

# Windows
iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.ps1 | iex
```

Déjà le setup complet ? Ajoute `--replace-full` (bash) ou `-ReplaceFull` (PowerShell) : les 12 plugins superflus, `graphify`, `magic` et les hooks Obsidian sont retirés, les fichiers déplacés dans `~/.claude/skills.bak-<date>`.

## Comment ça s'invoque tout seul

Rien n'est routé à la main. Trois mécanismes natifs font le travail :

| Couche | Mécanisme | Coût avant usage |
|---|---|---|
| Skills | leur champ `description` déclenche l'invocation | nom + description |
| MCP | `ToolSearch` — les schémas sont **différés** par défaut | noms seulement |
| claude-mem | 5 hooks lifecycle | ~0 |

Le hook `skill-router-lite.js` ne fait qu'une chose en plus : forcer les **combinaisons** (`impeccable` + `taste-skill` ensemble sur une tâche UI). Il ne cite jamais un skill absent du disque, et reste silencieux quand rien ne matche.

## Constant

| Composant | Rôle |
|---|---|
| `superpowers` | brainstorming, writing-plans, executing-plans, systematic-debugging, TDD, git worktrees — 14 skills |
| `caveman` | réponses compressées (output style — lance `/caveman` une fois) |
| `code-review` | `/code-review` sur un diff ou une PR |
| `claude-mem` | mémoire cross-session, capture et réinjecte automatiquement |
| `Skill(context-engineering)` | délègue la lecture lourde aux sous-agents |

## Auto — zéro coût avant usage

**Skills** — `impeccable` · `taste-skill` · `emil-design-eng` · `review-animations` · `animation-vocabulary` · `marketing-growth` · `web-research`

**MCP différés** — `github` · `vercel` · `supabase` · `stripe` · `playwright` · `context7`

**CLI** — `agent-reach` (Reddit, YouTube, X, GitHub, HN, web — zéro clé API) alimente `web-research`

## Le seul arbitrage

`vercel`, `stripe` et `supabase` sont ajoutés en **MCP seul**. Leurs plugins chargeraient 44 descriptions de skills à chaque session :

| Plugin | Contenu | Coût permanent |
|---|---|---|
| `vercel` | 34 skills + 23 commandes/agents | **~3 800 tok** |
| `supabase` | 2 skills | ~400 tok |
| `stripe` | 8 skills + 2 commandes | ~100 tok |

Tu les récupères le jour où tu bosses vraiment dessus :

```bash
sc plugin vercel on     # puis  sc plugin vercel off  quand le projet est fini
```

## Bascules

```bash
sc status                  # MCP, plugins et skills actifs
sc mcp playwright on       # ou off
sc mcp magic on            # 21st.dev, demande la clé API
sc plugin vercel on        # ajoute les 34 skills Vercel
```

Ajoute `~/.claude/scripts` à ton PATH pour que `sc` soit disponible partout.

## Options d'installation

| Flag | Effet |
|---|---|
| `--with-vercel-skills` | installe le plugin vercel complet dès le départ |
| `--with-stripe-skills` / `--with-supabase-skills` | idem |
| `--with-security` | ajoute le skill `security` (auth, secrets, OWASP) |
| `--with-tdd` | ajoute le skill `tdd-workflow` |
| `--no-mcp` | aucun MCP |
| `--no-agent-reach` | pas de CLI de recherche web |
| `--replace-full` | désinstalle l'ancien setup complet |

## Ce qui n'est pas installé

Les 10 packs `wshobson/agents` · `graphify` · `magic` · `product-design` · `nova-agency` · `prose-clean` · `video-generation` · `agentic-practice` · `claude-md-management` · `skill-creator` · les hooks Obsidian · les 4 repos vendor (`marketingskills`, `stop-slop`, `Agent-Skills-for-Context-Engineering`, `claude-code-best-practice`) · les npm globaux (`hyperframes`, `remotion`).

## Corrections par rapport au setup complet

| Problème | Correction |
|---|---|
| `impeccable`, `taste-skill`, `tdd-workflow`, `security` étaient des `.md` plats sans front-matter — jamais chargés | réécrits en `<nom>/SKILL.md` avec `name` + `description` |
| Le router citait `Skill(verify)`, qui n'existe pas (le vrai nom est `verification-before-completion`) | le router valide chaque nom sur le disque avant de le citer |
| `self-learn.js` copié mais jamais branché dans `settings.json` | supprimé |
| `CLAUDE.md` jamais installé globalement — les règles ne s'appliquaient que dans les projets bootstrappés | écrit dans `~/.claude/CLAUDE.md`, entre marqueurs, sans toucher au reste |
| `claude-mem` ajouté en MCP seul — les 5 hooks n'étaient pas enregistrés | `npx claude-mem install`, la méthode officielle |
| `obsidian.js` posait `NODE_TLS_REJECT_UNAUTHORIZED=0` sur tout le process | hook retiré |
| `caveman` déclaré always-on alors que c'est un output style | documenté : `/caveman` une fois |

## Tester le router

```bash
echo '{"prompt":"refais le hero avec une transition douce"}' \
  | node ~/.claude/scripts/skill-router-lite.js
```
