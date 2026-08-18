#!/usr/bin/env bash
# SuperClaude Lite — installe le strict nécessaire, rien d'autre.
#   curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.sh | bash
#
# Installé par défaut :
#   3 plugins  : superpowers, caveman, code-review
#   2 MCP      : claude-mem, graphify           (mémoire — coût faible)
#   9 skills   : noyau + design + dev + sécurité
#   1 hook     : skill-router-lite (silencieux quand rien ne matche)
#
# JAMAIS installé : les 19 autres plugins, les 10 packs wshobson (191 agents),
# les 5 repos communauté, les npm globaux, pip, les hooks Obsidian.
#
# Options :
#   --no-design  --no-dev  --no-security     retirer une catégorie
#   --with-magic --with-playwright --with-context7   activer un MCP lourd
#   --replace-full                            désinstaller l'ancien setup complet
set -euo pipefail

REPO="https://github.com/Makooff/SuperClaude"
DEST="${SUPERCLAUDE_HOME:-$HOME/.superclaude}"
CLAUDE_DIR="$HOME/.claude"

WITH_DESIGN=1; WITH_DEV=1; WITH_SECURITY=1; REPLACE_FULL=0
HEAVY_MCP=()

for arg in "$@"; do
  case "$arg" in
    --no-design)      WITH_DESIGN=0 ;;
    --no-dev)         WITH_DEV=0 ;;
    --no-security)    WITH_SECURITY=0 ;;
    --with-magic)     HEAVY_MCP+=(magic) ;;
    --with-playwright) HEAVY_MCP+=(playwright) ;;
    --with-context7)  HEAVY_MCP+=(context7) ;;
    --replace-full)   REPLACE_FULL=1 ;;
    *) echo "Option inconnue : $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\033[1;35m›\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# 1. Prérequis ---------------------------------------------------------------
have node || { warn "Node.js 18+ requis : https://nodejs.org"; exit 1; }
[ "$(node -p 'process.versions.node.split(".")[0]')" -ge 18 ] || { warn "Node 18+ requis."; exit 1; }
have git  || { warn "git requis."; exit 1; }
have claude || { say "Installation de Claude Code…"; npm install -g @anthropic-ai/claude-code; }
ok "Prérequis ok — node $(node -v)"

# 2. Source ------------------------------------------------------------------
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
if [ ! -f "$SRC/lite/CLAUDE.lite.md" ]; then
  if [ -d "$DEST/.git" ]; then
    git -C "$DEST" pull --ff-only >/dev/null 2>&1 || true
  else
    say "Clonage → $DEST"; git clone --depth 1 "$REPO" "$DEST" >/dev/null
  fi
  SRC="$DEST"
fi
ok "Source : $SRC"

# 3. Nettoyage de l'ancien setup complet (optionnel) --------------------------
if [ "$REPLACE_FULL" = "1" ]; then
  say "Désinstallation du setup complet…"
  FULL_PLUGINS=(github vercel supabase stripe claude-md-management skill-creator \
                context7 playwright claude-mem comprehensive-review debugging-toolkit \
                unit-testing security-scanning full-stack-orchestration \
                frontend-mobile-development ui-design cicd-automation \
                agent-orchestration application-performance)
  for p in "${FULL_PLUGINS[@]}"; do claude plugin uninstall "$p" >/dev/null 2>&1 || true; done
  for m in magic playwright context7; do claude mcp remove -s user "$m" >/dev/null 2>&1 || true; done
  BAK="$CLAUDE_DIR/skills.bak-$(date +%Y%m%d-%H%M%S)"
  if [ -d "$CLAUDE_DIR/skills/vendor" ]; then
    mkdir -p "$BAK"; mv "$CLAUDE_DIR/skills/vendor" "$BAK/vendor"
  fi
  for f in impeccable.md taste-skill.md tdd-workflow.md security.md video-generation.md; do
    [ -f "$CLAUDE_DIR/skills/$f" ] && { mkdir -p "$BAK"; mv "$CLAUDE_DIR/skills/$f" "$BAK/"; }
  done
  [ -d "$BAK" ] && ok "Anciens fichiers déplacés → $BAK" || true
  ok "19 plugins + 10 packs retirés"
fi

# 4. Plugins (3) --------------------------------------------------------------
say "Plugins…"
claude plugin marketplace add JuliusBrussee/caveman >/dev/null 2>&1 || true
claude plugin install superpowers  >/dev/null 2>&1 || warn "superpowers"
claude plugin install caveman@caveman >/dev/null 2>&1 || claude plugin install caveman >/dev/null 2>&1 || warn "caveman"
if [ "$WITH_DEV" = "1" ]; then
  claude plugin install code-review >/dev/null 2>&1 || warn "code-review"
  ok "3 plugins : superpowers, caveman, code-review"
else
  ok "2 plugins : superpowers, caveman"
fi

# 5. Skills (whitelist stricte) ----------------------------------------------
SKILLS=(context-engineering)
[ "$WITH_DESIGN"   = "1" ] && SKILLS+=(product-design impeccable taste-skill emil-design-eng review-animations)
[ "$WITH_DEV"      = "1" ] && SKILLS+=(tdd-workflow agentic-practice)
[ "$WITH_SECURITY" = "1" ] && SKILLS+=(security)

say "Skills…"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/scripts"
for s in "${SKILLS[@]}"; do
  if   [ -d "$SRC/lite/skills/$s" ];    then from="$SRC/lite/skills/$s"
  elif [ -d "$SRC/.claude/skills/$s" ]; then from="$SRC/.claude/skills/$s"
  else warn "skill introuvable : $s"; continue; fi
  rm -rf "$CLAUDE_DIR/skills/$s"
  cp -R "$from" "$CLAUDE_DIR/skills/$s"
done
ok "${#SKILLS[@]} skills → ~/.claude/skills"

# 6. Router (1 seul hook) -----------------------------------------------------
cp "$SRC/lite/scripts/skill-router-lite.js" "$CLAUDE_DIR/scripts/"
cp "$SRC/lite/scripts/sc-mcp" "$CLAUDE_DIR/scripts/" && chmod +x "$CLAUDE_DIR/scripts/sc-mcp"

node -e '
  const fs = require("fs");
  const [dst, router] = process.argv.slice(1);
  const cmd = "node --no-warnings \"" + router + "\"";
  let s = {};
  try { s = JSON.parse(fs.readFileSync(dst, "utf8")); } catch {}
  s.hooks = s.hooks || {};
  // retirer les hooks du setup complet (obsidian + ancien router)
  for (const ev of Object.keys(s.hooks)) {
    s.hooks[ev] = (s.hooks[ev] || [])
      .map(g => ({ ...g, hooks: (g.hooks || []).filter(h =>
        !/obsidian\.js|skill-router\.js|self-learn\.js/.test(h.command || "")) }))
      .filter(g => (g.hooks || []).length);
    if (!s.hooks[ev].length) delete s.hooks[ev];
  }
  s.hooks.UserPromptSubmit = s.hooks.UserPromptSubmit || [];
  const already = s.hooks.UserPromptSubmit.some(g =>
    (g.hooks || []).some(h => h.command === cmd));
  if (!already) s.hooks.UserPromptSubmit.push({ matcher: "", hooks: [{ type: "command", command: cmd }] });
  fs.writeFileSync(dst, JSON.stringify(s, null, 2));
' "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/scripts/skill-router-lite.js"
ok "1 hook actif (router lite) — hooks Obsidian/self-learn retirés"

# 7. CLAUDE.md global — bloc délimité, ne détruit rien -----------------------
node -e '
  const fs = require("fs");
  const [dst, src] = process.argv.slice(1);
  const S = "<!-- superclaude-lite:start -->", E = "<!-- superclaude-lite:end -->";
  const block = S + "\n" + fs.readFileSync(src, "utf8").trim() + "\n" + E;
  let cur = "";
  try { cur = fs.readFileSync(dst, "utf8"); } catch {}
  const i = cur.indexOf(S), j = cur.indexOf(E);
  const next = (i !== -1 && j !== -1)
    ? cur.slice(0, i) + block + cur.slice(j + E.length)
    : (cur.trim() ? cur.trimEnd() + "\n\n" : "") + block + "\n";
  fs.writeFileSync(dst, next);
' "$CLAUDE_DIR/CLAUDE.md" "$SRC/lite/CLAUDE.lite.md"
ok "~/.claude/CLAUDE.md — bloc superclaude-lite écrit (reste du fichier intact)"

# 8. MCP ----------------------------------------------------------------------
say "MCP mémoire (noyau)…"
claude mcp add -s user claude-mem -- npx -y claude-mem   >/dev/null 2>&1 || true
claude mcp add -s user graphify   -- npx -y graphify-mcp >/dev/null 2>&1 || true
ok "claude-mem + graphify"

for m in "${HEAVY_MCP[@]:-}"; do
  [ -z "$m" ] && continue
  case "$m" in
    magic)      claude mcp add -s user magic      -- npx -y @21st-dev/magic@latest  >/dev/null 2>&1 && ok "magic activé" ;;
    playwright) claude mcp add -s user playwright -- npx @playwright/mcp@latest     >/dev/null 2>&1 && ok "playwright activé" ;;
    context7)   claude mcp add -s user context7   -- npx -y @upstash/context7-mcp   >/dev/null 2>&1 && ok "context7 activé" ;;
  esac
done

# 9. Résumé -------------------------------------------------------------------
cat <<EOF

────────────────────────────────────────────
  ✓ SuperClaude Lite installé

  Noyau (permanent) : superpowers · caveman · context-engineering
                      MCP claude-mem + graphify
  À la demande      : ${#SKILLS[@]} skills, activés par le router selon l'intention
  MCP lourds        : éteints — \`sc-mcp magic on\` / \`playwright\` / \`context7\`

  Non installé      : 19 plugins, 191 agents wshobson, 5 repos vendor,
                      npm globaux, pip, hooks Obsidian

  Vérifier : claude plugin list · claude mcp list · ls ~/.claude/skills
  Router   : echo '{"prompt":"refais le hero"}' | node ~/.claude/scripts/skill-router-lite.js
────────────────────────────────────────────
EOF
