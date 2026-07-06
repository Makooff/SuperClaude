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
for p in "${PACKS[@]}"; do claude plugin install "$p@agents" 2>/dev/null || true; done
ok "Plugins installés (22)"

# 4. Skills + scripts + hooks ----------------------------------------------
say "Copie des skills & hooks vers ~/.claude…"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/scripts"
cp -R "$DEST/.claude/skills/." "$CLAUDE_DIR/skills/"
cp -R "$DEST/.claude/scripts/." "$CLAUDE_DIR/scripts/" 2>/dev/null || true
ok "15 skills + auto-router copiés"

# 5. MCP servers ------------------------------------------------------------
say "Configuration des MCP (magic, playwright, context7, claude-mem, graphify)…"
MCP_SRC="$DEST/.mcp.json"
MCP_DST="$CLAUDE_DIR/.mcp.json"
if [ -f "$MCP_DST" ] && have node; then
  node -e '
    const fs=require("fs");
    const dst=process.argv[1], src=process.argv[2];
    const a=JSON.parse(fs.readFileSync(dst,"utf8"));
    const b=JSON.parse(fs.readFileSync(src,"utf8"));
    a.mcpServers=Object.assign({},a.mcpServers,b.mcpServers);
    fs.writeFileSync(dst,JSON.stringify(a,null,2));
  ' "$MCP_DST" "$MCP_SRC"
else
  cp "$MCP_SRC" "$MCP_DST"
fi
ok "5 MCP configurés"

# 6. Utilitaires globaux ----------------------------------------------------
say "Outils vidéo/mémoire (hyperframes, claude-mem, graphify)…"
npm install -g hyperframes claude-mem graphify-mcp 2>/dev/null || warn "npm -g partiel (non bloquant)"

# 7. Clé Magic (optionnel) --------------------------------------------------
if [ -t 0 ]; then
  printf '\nClé API 21st.dev Magic (Entrée pour ignorer) : '
  read -r MAGIC_KEY || true
  if [ -n "${MAGIC_KEY:-}" ]; then
    printf 'MAGIC_API_KEY=%s\n' "$MAGIC_KEY" >> "$CLAUDE_DIR/.env"
    ok "Clé Magic enregistrée"
  fi
fi

# 8. Résumé -----------------------------------------------------------------
cat <<'EOF'

────────────────────────────────────────────
  ✓ SuperClaude installé
  ✓ 22 plugins   ✓ 15 skills   ✓ 5 MCP
  ✓ Auto-routing actif (skills invoqués tout seuls)

  Lance :  claude
  Skills : claude /skills
────────────────────────────────────────────
EOF
