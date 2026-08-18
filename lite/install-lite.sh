#!/usr/bin/env bash
# SuperClaude Lite — installe exactement la liste choisie, rien d'autre.
#   curl -fsSL https://raw.githubusercontent.com/Makooff/SuperClaude/main/lite/install-lite.sh | bash
#
# CONSTANT (chargé à chaque session)
#   plugins : superpowers · caveman · code-review
#   mémoire : claude-mem (5 hooks lifecycle, automatiques)
#   skill   : context-engineering
#
# AUTO — zéro coût avant usage (MCP différés par ToolSearch)
#   MCP    : github · vercel · supabase · stripe · playwright · context7
#   skills : impeccable · taste-skill · emil-design-eng · review-animations
#            animation-vocabulary · marketing-growth · web-research
#   CLI    : agent-reach (alimente web-research, zéro clé API)
#
# vercel / stripe / supabase sont ajoutés en MCP SEUL : leurs plugins chargeraient
# 44 descriptions de skills en permanence (~4300 tokens). `sc plugin vercel on`
# les ajoute le jour où tu en as besoin.
#
# Options
#   --with-vercel-skills --with-stripe-skills --with-supabase-skills
#   --with-security --with-tdd        (2 skills convertis, hors liste par défaut)
#   --no-agent-reach --no-mcp
#   --replace-full                    désinstalle l'ancien setup complet
set -euo pipefail

REPO="https://github.com/Makooff/SuperClaude"
DEST="${SUPERCLAUDE_HOME:-$HOME/.superclaude}"
CLAUDE_DIR="$HOME/.claude"

WITH_MCP=1; WITH_REACH=1; REPLACE_FULL=0
EXTRA_PLUGINS=(); EXTRA_SKILLS=()

for arg in "$@"; do
  case "$arg" in
    --with-vercel-skills)   EXTRA_PLUGINS+=(vercel) ;;
    --with-stripe-skills)   EXTRA_PLUGINS+=(stripe) ;;
    --with-supabase-skills) EXTRA_PLUGINS+=(supabase) ;;
    --with-security)        EXTRA_SKILLS+=(security) ;;
    --with-tdd)             EXTRA_SKILLS+=(tdd-workflow) ;;
    --no-agent-reach)       WITH_REACH=0 ;;
    --no-mcp)               WITH_MCP=0 ;;
    --replace-full)         REPLACE_FULL=1 ;;
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
have git || { warn "git requis."; exit 1; }
have claude || { say "Installation de Claude Code…"; npm install -g @anthropic-ai/claude-code; }
ok "node $(node -v) · claude $(claude --version 2>/dev/null | head -1)"

# 2. Source ------------------------------------------------------------------
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
if [ ! -f "${SRC:-/nonexistent}/lite/CLAUDE.lite.md" ]; then
  if [ -d "$DEST/.git" ]; then git -C "$DEST" pull --ff-only >/dev/null 2>&1 || true
  else say "Clonage → $DEST"; git clone --depth 1 "$REPO" "$DEST" >/dev/null; fi
  SRC="$DEST"
fi
ok "Source : $SRC"

# 3. Retrait de l'ancien setup complet (optionnel) ---------------------------
if [ "$REPLACE_FULL" = "1" ]; then
  say "Retrait du setup complet…"
  OLD=(claude-md-management skill-creator comprehensive-review debugging-toolkit \
       unit-testing security-scanning full-stack-orchestration \
       frontend-mobile-development ui-design cicd-automation \
       agent-orchestration application-performance)
  for p in "${OLD[@]}"; do claude plugin uninstall "$p" >/dev/null 2>&1 || true; done
  claude mcp remove -s user graphify >/dev/null 2>&1 || true
  claude mcp remove -s user magic    >/dev/null 2>&1 || true
  BAK="$CLAUDE_DIR/skills.bak-$(date +%Y%m%d-%H%M%S)"
  [ -d "$CLAUDE_DIR/skills/vendor" ] && { mkdir -p "$BAK"; mv "$CLAUDE_DIR/skills/vendor" "$BAK/vendor"; }
  for f in impeccable.md taste-skill.md tdd-workflow.md security.md video-generation.md; do
    [ -f "$CLAUDE_DIR/skills/$f" ] && { mkdir -p "$BAK"; mv "$CLAUDE_DIR/skills/$f" "$BAK/"; }
  done
  for s in product-design nova-agency prose-clean agentic-practice; do
    [ -d "$CLAUDE_DIR/skills/$s" ] && { mkdir -p "$BAK"; mv "$CLAUDE_DIR/skills/$s" "$BAK/"; }
  done
  [ -d "$BAK" ] && ok "Anciens fichiers déplacés → $BAK"
  ok "12 plugins + graphify + magic retirés"
fi

# 4. Plugins constants (3) ----------------------------------------------------
say "Plugins…"
claude plugin marketplace add JuliusBrussee/caveman >/dev/null 2>&1 || true
claude plugin install superpowers >/dev/null 2>&1 || warn "superpowers"
claude plugin install caveman@caveman >/dev/null 2>&1 || claude plugin install caveman >/dev/null 2>&1 || warn "caveman"
claude plugin install code-review >/dev/null 2>&1 || warn "code-review"
ok "superpowers · caveman · code-review"

for p in "${EXTRA_PLUGINS[@]:-}"; do
  [ -z "$p" ] && continue
  claude plugin install "$p" >/dev/null 2>&1 && warn "plugin $p installé — ses skills chargent à chaque session"
done

# 5. claude-mem — l'installeur enregistre les 5 hooks (plugin seul ne suffit pas)
say "Mémoire cross-session…"
npx -y claude-mem install >/dev/null 2>&1 && ok "claude-mem — 5 hooks actifs" \
  || warn "claude-mem : relance à la main → npx claude-mem install"

# 6. Skills (whitelist stricte) ----------------------------------------------
SKILLS=(context-engineering impeccable taste-skill emil-design-eng review-animations
        animation-vocabulary marketing-growth web-research)
for s in "${EXTRA_SKILLS[@]:-}"; do [ -n "$s" ] && SKILLS+=("$s"); done

say "Skills…"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/scripts"
for s in "${SKILLS[@]}"; do
  if   [ -d "$SRC/lite/skills/$s" ];    then from="$SRC/lite/skills/$s"
  elif [ -d "$SRC/.claude/skills/$s" ]; then from="$SRC/.claude/skills/$s"
  else warn "skill introuvable : $s"; continue; fi
  rm -rf "$CLAUDE_DIR/skills/$s"; cp -R "$from" "$CLAUDE_DIR/skills/$s"
done
ok "${#SKILLS[@]} skills → ~/.claude/skills"

# 7. Hook de combinaison + outil sc ------------------------------------------
cp "$SRC/lite/scripts/skill-router-lite.js" "$CLAUDE_DIR/scripts/"
cp "$SRC/lite/scripts/sc" "$CLAUDE_DIR/scripts/sc"; chmod +x "$CLAUDE_DIR/scripts/sc"

node -e '
  const fs = require("fs");
  const [dst, router] = process.argv.slice(1);
  const cmd = "node --no-warnings \"" + router + "\"";
  let s = {}; try { s = JSON.parse(fs.readFileSync(dst, "utf8")); } catch {}
  s.hooks = s.hooks || {};
  for (const ev of Object.keys(s.hooks)) {
    s.hooks[ev] = (s.hooks[ev] || [])
      .map(g => ({ ...g, hooks: (g.hooks || []).filter(h =>
        !/obsidian\.js|skill-router\.js|self-learn\.js/.test(h.command || "")) }))
      .filter(g => (g.hooks || []).length);
    if (!s.hooks[ev].length) delete s.hooks[ev];
  }
  s.hooks.UserPromptSubmit = s.hooks.UserPromptSubmit || [];
  if (!s.hooks.UserPromptSubmit.some(g => (g.hooks || []).some(h => h.command === cmd)))
    s.hooks.UserPromptSubmit.push({ matcher: "", hooks: [{ type: "command", command: cmd }] });
  fs.writeFileSync(dst, JSON.stringify(s, null, 2));
' "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/scripts/skill-router-lite.js"
ok "1 hook (combinaisons) — hooks Obsidian/self-learn retirés"

# 8. CLAUDE.md global — bloc délimité, ne détruit rien -----------------------
node -e '
  const fs = require("fs");
  const [dst, src] = process.argv.slice(1);
  const S = "<!-- superclaude-lite:start -->", E = "<!-- superclaude-lite:end -->";
  const block = S + "\n" + fs.readFileSync(src, "utf8").trim() + "\n" + E;
  let cur = ""; try { cur = fs.readFileSync(dst, "utf8"); } catch {}
  const i = cur.indexOf(S), j = cur.indexOf(E);
  fs.writeFileSync(dst, (i !== -1 && j !== -1)
    ? cur.slice(0, i) + block + cur.slice(j + E.length)
    : (cur.trim() ? cur.trimEnd() + "\n\n" : "") + block + "\n");
' "$CLAUDE_DIR/CLAUDE.md" "$SRC/lite/CLAUDE.lite.md"
ok "~/.claude/CLAUDE.md — bloc superclaude-lite (reste du fichier intact)"

# 9. MCP — tous différés par ToolSearch, coût ~0 avant usage -----------------
if [ "$WITH_MCP" = "1" ]; then
  say "MCP (différés)…"
  claude mcp add -s user --transport http github   https://api.githubcopilot.com/mcp/ >/dev/null 2>&1 || true
  claude mcp add -s user --transport http vercel   https://mcp.vercel.com             >/dev/null 2>&1 || true
  claude mcp add -s user --transport http stripe   https://mcp.stripe.com             >/dev/null 2>&1 || true
  claude mcp add -s user --transport http context7 https://mcp.context7.com/mcp       >/dev/null 2>&1 || true
  claude mcp add -s user supabase   -- npx -y @supabase/mcp-server-supabase@latest >/dev/null 2>&1 || true
  claude mcp add -s user playwright -- npx @playwright/mcp@latest                  >/dev/null 2>&1 || true
  ok "github · vercel · supabase · stripe · context7 · playwright"
  warn "vercel, stripe et github demandent une autorisation OAuth au premier usage : /mcp"
fi

# 10. Agent-Reach — CLI pour web-research ------------------------------------
if [ "$WITH_REACH" = "1" ]; then
  if have pipx || have pip3 || have pip; then
    (pipx install agent-reach || pip3 install agent-reach || pip install agent-reach) >/dev/null 2>&1 \
      && { agent-reach install >/dev/null 2>&1 || true; ok "agent-reach installé (zéro clé API)"; } \
      || warn "agent-reach non installé (non bloquant)"
  else warn "pip absent — agent-reach ignoré"; fi
fi

# 11. Résumé ------------------------------------------------------------------
cat <<EOF

────────────────────────────────────────────
  ✓ SuperClaude Lite

  Constant   superpowers · caveman · code-review · claude-mem
             + Skill(context-engineering)
  Auto       ${#SKILLS[@]} skills (description native)
             6 MCP différés (ToolSearch — coût ~0 avant appel)
  Bascules   sc status · sc mcp <nom> on|off · sc plugin vercel on

  Non installé : les 10 packs wshobson, graphify, magic, product-design,
  nova-agency, prose-clean, video-generation, les hooks Obsidian, les
  npm globaux, les 4 repos vendor.

  ⚠ caveman est un output style : lance /caveman une fois pour l'activer.
  ⚠ ajoute ~/.claude/scripts au PATH pour la commande \`sc\`.
────────────────────────────────────────────
EOF
