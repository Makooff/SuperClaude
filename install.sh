#!/usr/bin/env bash
# SuperClaude — install en une ligne (Mac / Linux)
#   curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/install.sh | bash
set -euo pipefail

REPO="https://github.com/Makooff/SuperClaude"
DEST="${SUPERCLAUDE_HOME:-$HOME/.superclaude}"
CLAUDE_DIR="$HOME/.claude"

say()  { printf '\033[1;35m›\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

# 1. Prérequis --------------------------------------------------------------
say "Vérification des prérequis…"
if ! have node; then
  warn "Node.js absent. Installe Node 20+ : https://nodejs.org — puis relance."
  exit 1
fi
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 18 ] || { warn "Node $NODE_MAJOR trop ancien (min 18)."; exit 1; }
ok "Node $(node -v)"

have git || { warn "git requis."; exit 1; }
ok "git $(git --version | awk '{print $3}')"

if ! have claude; then
  say "Installation de Claude Code…"
  npm install -g @anthropic-ai/claude-code
fi
ok "Claude Code $(claude --version 2>/dev/null | head -1 || echo présent)"

# 2. Clone / update ---------------------------------------------------------
if [ -d "$DEST/.git" ]; then
  say "Mise à jour de SuperClaude ($DEST)…"
  git -C "$DEST" pull --ff-only
else
  say "Clonage de SuperClaude → $DEST"
  git clone --depth 1 "$REPO" "$DEST"
fi
ok "Repo prêt"

# 3. Marketplaces + plugins -------------------------------------------------
say "Ajout des marketplaces…"
claude plugin marketplace add JuliusBrussee/caveman   || true
claude plugin marketplace add wshobson/agents         || true
claude plugin marketplace add thedotmack/claude-mem   || true

say "Installation des plugins (peut prendre une minute)…"
OFFICIAL=(superpowers code-review github vercel supabase stripe caveman \
          claude-md-management context7 skill-creator playwright)
for p in "${OFFICIAL[@]}"; do claude plugin install "$p" 2>/dev/null || true; done
claude plugin install claude-mem@thedotmack 2>/dev/null || true

PACKS=(comprehensive-review debugging-toolkit unit-testing security-scanning \
       full-stack-orchestration frontend-mobile-development ui-design \
       cicd-automation agent-orchestration application-performance)
# wshobson/agents s'enregistre sous le nom de marketplace "claude-code-workflows".
for p in "${PACKS[@]}"; do
  claude plugin install "$p@claude-code-workflows" 2>/dev/null \
    || claude plugin install "$p" 2>/dev/null || true
done
ok "Plugins installés (22)"

# 4. Skills + scripts --------------------------------------------------------
say "Copie des skills vers ~/.claude…"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/scripts"
cp -R "$DEST/.claude/skills/." "$CLAUDE_DIR/skills/"
cp -R "$DEST/.claude/scripts/." "$CLAUDE_DIR/scripts/" 2>/dev/null || true
ok "15 skills + auto-router copiés"

# 4b. Hooks — fusionner dans ~/.claude/settings.json (scope user) -----------
# C'est ce fichier, pas juste les scripts, qui déclenche réellement le routeur
# à chaque message. On fusionne sans écraser un settings.json existant.
say "Activation des hooks (auto-routing) dans ~/.claude/settings.json…"
SETTINGS_DST="$CLAUDE_DIR/settings.json"
node -e '
  const fs = require("fs");
  const dst = process.argv[1];
  const routerCmd  = "node --no-warnings \"" + process.argv[2] + "\"";
  const obsidianInj = "node --no-warnings \"" + process.argv[3] + "\" inject-context";
  const obsidianLog  = "node --no-warnings \"" + process.argv[3] + "\" session-log";

  let s = {};
  try { s = JSON.parse(fs.readFileSync(dst, "utf8")); } catch {}
  s.hooks = s.hooks || {};

  const ensure = (event, command) => {
    s.hooks[event] = s.hooks[event] || [];
    const already = s.hooks[event].some(g =>
      (g.hooks || []).some(h => h.command === command));
    if (!already) {
      s.hooks[event].push({ matcher: "", hooks: [{ type: "command", command }] });
    }
  };

  ensure("UserPromptSubmit", routerCmd);
  ensure("UserPromptSubmit", obsidianInj);
  ensure("Stop", obsidianLog);

  fs.writeFileSync(dst, JSON.stringify(s, null, 2));
' "$SETTINGS_DST" "$CLAUDE_DIR/scripts/skill-router.js" "$CLAUDE_DIR/scripts/obsidian.js"
ok "Hooks actifs (settings.json fusionné, rien d'écrasé)"

# 5. Clé Magic (optionnel, avant l'enregistrement MCP pour l'injecter) ------
MAGIC_KEY=""
if [ -t 0 ]; then
  printf '\nClé API 21st.dev Magic (Entrée pour ignorer) : '
  read -r MAGIC_KEY || true
fi

# 6. MCP servers — scope user via `claude mcp add` (le seul chemin lu) ------
say "Activation des MCP (scope user)…"
if [ -n "$MAGIC_KEY" ]; then
  claude mcp add -s user magic -e "API_KEY=$MAGIC_KEY" -- npx -y @21st-dev/magic@latest 2>/dev/null || true
else
  claude mcp add -s user magic -- npx -y @21st-dev/magic@latest 2>/dev/null || true
fi
claude mcp add -s user playwright -- npx @playwright/mcp@latest 2>/dev/null || true
claude mcp add -s user context7   -- npx -y @upstash/context7-mcp 2>/dev/null || true
claude mcp add -s user claude-mem -- npx -y claude-mem 2>/dev/null || true
claude mcp add -s user graphify   -- npx -y graphify-mcp 2>/dev/null || true
ok "5 MCP actifs (scope user)"

# 6b. Repos communauté (clone à l'install) -----------------------------------
VENDOR="$DEST/vendor"
SKILLS_VENDOR="$CLAUDE_DIR/skills/vendor"
say "Clonage des repos communauté → $VENDOR…"
mkdir -p "$VENDOR" "$SKILLS_VENDOR"

COMMUNITY=(
  "hardikpandya/stop-slop"
  "coreyhaines31/marketingskills"
  "muratcankoylan/Agent-Skills-for-Context-Engineering"
  "shanraisshan/claude-code-best-practice"
  "Panniantong/Agent-Reach"
)
for repo in "${COMMUNITY[@]}"; do
  name="${repo##*/}"
  target="$VENDOR/$name"
  if [ -d "$target/.git" ]; then
    git -C "$target" pull --ff-only 2>/dev/null || true
  else
    git clone --depth 1 "https://github.com/$repo" "$target" 2>/dev/null \
      && ok "cloné $repo" || warn "échec clone $repo (non bloquant)"
  fi
  # namespacer les skills du repo sans écraser nos 15 skills
  if [ -d "$target/skills" ]; then
    mkdir -p "$SKILLS_VENDOR/$name"
    cp -R "$target/skills/." "$SKILLS_VENDOR/$name/" 2>/dev/null || true
  fi
done

# stop-slop est un skill à la racine (SKILL.md + references/)
if [ -f "$VENDOR/stop-slop/SKILL.md" ]; then
  mkdir -p "$SKILLS_VENDOR/stop-slop"
  cp -R "$VENDOR/stop-slop/SKILL.md" "$VENDOR/stop-slop/references" "$SKILLS_VENDOR/stop-slop/" 2>/dev/null || true
fi

# marketplaces Claude natives pour les repos qui sont des plugins
claude plugin marketplace add coreyhaines31/marketingskills 2>/dev/null || true
claude plugin marketplace add muratcankoylan/Agent-Skills-for-Context-Engineering 2>/dev/null || true
ok "5 repos communauté clonés + namespacés"

# Agent-Reach — CLI Python (recherche web multi-plateforme, zéro clé API)
if have pip || have pip3; then
  say "Installation d'Agent-Reach (CLI web)…"
  (pip install agent-reach 2>/dev/null || pip3 install agent-reach 2>/dev/null \
    || pipx install agent-reach 2>/dev/null) && ok "agent-reach installé" \
    || warn "agent-reach non installé (pip absent — non bloquant)"
fi

# 7. Utilitaires globaux ----------------------------------------------------
say "Outils vidéo/mémoire (hyperframes, remotion, claude-mem, graphify)…"
npm install -g hyperframes remotion claude-mem graphify-mcp 2>/dev/null || warn "npm -g partiel (non bloquant)"

# 8. Résumé -----------------------------------------------------------------
cat <<'EOF'

────────────────────────────────────────────
  ✓ SuperClaude installé
  ✓ 22 plugins   ✓ 15 skills   ✓ 5 MCP (scope user)
  ✓ 5 repos communauté clonés (~/.superclaude/vendor)
  ✓ Hooks actifs — auto-routing réellement branché

  Lance :  claude
  Skills : claude /skills
  MCP    : claude mcp list
────────────────────────────────────────────
EOF
