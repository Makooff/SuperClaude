# SuperClaude

Un seul fichier. Copié à la racine d'un projet, Claude Code le lit tout seul à chaque démarrage — c'est lui qui porte tout le setup.

## Démarrage — vérification silencieuse

Avant de répondre à un premier message de session, vérifier que ces 4 briques répondent :

```bash
claude plugin list 2>/dev/null | grep -qi superpowers          && echo ok-superpowers
claude plugin list 2>/dev/null | grep -qi claude-mem            && echo ok-claude-mem
claude plugin list 2>/dev/null | grep -qi context-engineering   && echo ok-context-engineering
[ -f ~/.claude/skills/stop-slop/SKILL.md ]                      && echo ok-stop-slop
```

- Les 4 répondent → ne rien dire, continuer normalement.
- Il en manque → une seule ligne, rien d'autre :
  `il manque <liste des manquants> — dis "installe et active ce setup"`

## Installation

### Machine — une seule fois (persiste ensuite dans `~/.claude/` pour tous les projets)

**Plugins** — CLI `claude plugin`, jamais les commandes slash :

```bash
claude plugin install superpowers

claude plugin marketplace add thedotmack/claude-mem
claude plugin install claude-mem@thedotmack
npx claude-mem install    # enregistre les 5 hooks lifecycle — le plugin seul ne le fait pas

claude plugin marketplace add muratcankoylan/Agent-Skills-for-Context-Engineering
claude plugin install context-engineering@context-engineering-marketplace

claude plugin marketplace add Hainrixz/claude-ads
claude plugin install claude-ads@tododeia-claude-ads
```

> `claude-ads` : celui de `Hainrixz` couvre Meta/Google/TikTok (95% du budget pub, plugin mature). Si Nova a besoin de LinkedIn/Snapchat/Pinterest/etc., remplacer par `AgriciDaniel/claude-ads` (12 plateformes) — une ligne à changer ci-dessus.

**Skills** — CLI `npx skills add` ([vercel-labs/skills](https://github.com/vercel-labs/skills)), scope machine avec `-g` :

```bash
npx skills add leonxlnx/taste-skill --skill taste-skill -g -a claude-code -y
npx skills add coreyhaines31/marketingskills --skill '*' -g -a claude-code -y
```

**stop-slop** — pas de marketplace, clone direct à la racine des skills (sinon Claude Code ne le voit pas) :

```bash
git clone --depth 1 https://github.com/hardikpandya/stop-slop ~/.claude/skills/stop-slop
```

**agent-reach** — CLI de recherche web multi-plateforme (Reddit, YouTube, X, GitHub, HN...), zéro clé API. Ce n'est pas une skill :

```bash
pipx install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto     # vérification read-only par défaut
# --system seulement après accord explicite de l'utilisateur — jamais tout seul
```

### Projet — à refaire à chaque nouveau projet

```bash
npx impeccable install
```

Puis dans Claude Code : `/impeccable init`.

Ajouter seulement si CE projet en a besoin :

```bash
npm install remotion     # motion design programmable
pip install scrapling    # scraping web adaptatif
```

## Routage — chargé tout seul, sans qu'on te le nomme

### Toujours actifs
- `superpowers` (`Skill(superpowers:*)`) avant toute tâche de code non triviale — brainstorm, plan, debug, TDD, git
- `claude-mem` — mémoire cross-session, automatique via ses hooks
- `context-engineering-collection` (+ ses 17 skills dédiés : `context-fundamentals`, `harness-engineering`, `multi-agent-patterns`, `memory-systems`, etc. — invoquer le plus précis) dès qu'une tâche dépasse quelques fichiers
- `stop-slop` sur toute prose que je vais lire ou envoyer — jamais sur du code

### Sur déclenchement
| Contexte | Outil |
|---|---|
| Frontend, UI | `taste-skill` |
| Design | `impeccable` (craft / audit / polish / harden) |
| Marketing, SEO, copy, pricing | une skill de `marketingskills` — choisir la plus précise, ne pas toutes invoquer |
| Ads | `claude-ads` (`/ads start`, `/ads next`) |
| Motion design | Remotion |
| Scraping | Scrapling |
| Comprendre un repo GitHub, veille | `agent-reach` |

Remotion, Scrapling et agent-reach ne sont **pas des skills** — rien ne les déclenche tout seul. C'est à toi d'y penser au bon moment.

## Contexte

- Réponds en français.
- Nova — agence vidéo et pub.
- Qwillio — agents IA.
- Tu proposes, tu implémentes, tu testes — sans pause pour demander la permission sur une décision réversible.

## Nouveau projet

```bash
curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/CLAUDE.md -o CLAUDE.md
```
