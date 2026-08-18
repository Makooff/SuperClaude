# SuperClaude Lite

Version allégée du setup. Même puissance sur les tâches qui comptent, ~10× moins de contexte permanent.

```bash
# Mac / Linux
curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.sh | bash

# Windows
iwr -useb https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.ps1 | iex
```

Déjà le setup complet installé ? Ajoute `--replace-full` (bash) ou `-ReplaceFull` (PowerShell) : les 19 plugins, les 10 packs et les hooks Obsidian sont retirés, les fichiers déplacés dans `~/.claude/skills.bak-<date>`.

## Ce qui est installé

### Noyau — chargé en permanence

| Composant | ⭐ | Rôle |
|---|---|---|
| `superpowers` | 273k | brainstorm, plans, debug systématique, TDD, revue par sous-agents |
| `caveman` | — | compresse les réponses |
| `claude-mem` (MCP) | 91k | mémoire persistante cross-session |
| `graphify` (MCP) | — | knowledge graph |
| `context-engineering` | — | déléguer la lecture lourde aux sous-agents |

### À la demande — le router les propose selon l'intention

| Catégorie | Skills | MCP |
|---|---|---|
| **design** | `product-design` (+5 refs) · `ui-ux-pro-max` (118k ⭐) · `impeccable` · `taste-skill` · `emil-design-eng` · `review-animations` | `magic` |
| **dev** | `code-review` · `tdd-workflow` · `agentic-practice` + les 14 skills superpowers | `playwright`, `context7` |
| **sécurité** | `security` | — |

`ui-ux-pro-max` embarque 3,6 Mo de données locales — 79 styles, 192 palettes, 74 pairings typographiques, 119 règles UX, 25 types de graphiques, 22 stacks — lues à la demande par le skill. Coût en contexte : une description, ~150 tokens. Seul ce dossier est installé, pas les 6 autres skills du repo qui doublonnent avec `product-design`.

### Jamais installé

19 plugins (dont `github` ≈ 60 outils MCP, `vercel`, `supabase`, `stripe`), les 10 packs `wshobson/agents`, les 4 repos communauté copiés à une profondeur où Claude ne les charge pas, les paquets npm globaux, `pip install agent-reach`, les hooks Obsidian, `self-learn.js`.

## Coût en contexte

| | Complet | Lite |
|---|---|---|
| MCP (schémas d'outils) | ~23k | ~2,7k |
| Plugins et packs | ~4,5k | ~0,7k |
| Skills | ~1,5k | ~1k |
| **Total permanent** | **~30k** | **~4,5k** |

Le poste dominant, ce sont les schémas d'outils MCP, pas les skills. D'où le choix : deux MCP mémoire allumés en permanence, les trois lourds éteints.

## MCP à la demande

```bash
sc-mcp magic on        # composants 21st.dev
sc-mcp playwright on   # browser, E2E, screenshots
sc-mcp context7 on     # docs live d'une lib
sc-mcp all off
sc-mcp list
```

Un MCP enregistré charge ses schémas dans **chaque** session. On l'allume pour la durée où on en a besoin, pas plus.

## Le router

`~/.claude/scripts/skill-router-lite.js`, branché sur `UserPromptSubmit`.

- Il scanne le disque et **ne propose que des skills réellement présents**. Le router de la version complète pointait vers `Skill(verify)`, `Skill(impeccable)`, `Skill(taste-skill)` — aucun n'existait.
- Silencieux quand rien ne correspond : zéro token sur une conversation ordinaire.
- Trois lignes maximum, trois skills par ligne.
- Si un MCP manque pour la catégorie détectée, il affiche la commande pour l'allumer.

```bash
echo '{"prompt":"refais le hero"}' | node ~/.claude/scripts/skill-router-lite.js
```

## Options

| Flag bash | Flag PowerShell | Effet |
|---|---|---|
| `--no-design` | `-NoDesign` | retire les 6 skills design + ui-ux-pro-max |
| `--no-dev` | `-NoDev` | retire `code-review`, `tdd-workflow`, `agentic-practice` |
| `--no-security` | `-NoSecurity` | retire `security` |
| `--with-magic` | `-WithMagic` | enregistre le MCP dès l'install |
| `--with-playwright` | `-WithPlaywright` | idem |
| `--with-context7` | `-WithContext7` | idem |
| `--replace-full` | `-ReplaceFull` | désinstalle le setup complet |

## Ce que l'installeur écrit

| Chemin | Traitement |
|---|---|
| `~/.claude/skills/<skill>/` | un dossier par skill de la whitelist, rien d'autre |
| `~/.claude/scripts/` | `skill-router-lite.js`, `sc-mcp` |
| `~/.claude/settings.json` | fusionné — les hooks existants sont conservés, ceux d'Obsidian retirés |
| `~/.claude/CLAUDE.md` | bloc entre `<!-- superclaude-lite:start -->` et `:end` — le reste du fichier est intact |
| `~/.superclaude/vendor/ui-ux-pro-max` | clone sparse, 4,7 Mo au lieu de 23 |

## Corrections par rapport au setup complet

- `impeccable`, `taste-skill`, `tdd-workflow`, `security` étaient des `.md` plats sans front-matter : jamais chargés comme skills. Convertis en `dossier/SKILL.md`.
- Le router appelait `Skill(verify)` ; le nom réel dans superpowers est `verification-before-completion`.
- `caveman` et `claude-mem` ne sont pas dans le marketplace officiel — sans le suffixe `@caveman` / `@thedotmack`, l'installation échouait en silence.
- `self-learn.js` était copié mais jamais branché, et le router lisait un `learnings.md` que rien n'écrivait.
- `CLAUDE.md` n'était jamais installé globalement : la règle « invoque les skills du hook » n'existait que dans les projets créés par `new-project.sh`.
