#!/usr/bin/env bash
# SuperClaude Setup — Mac / Linux
# Usage: ./setup.sh
# Run once per machine to install Claude Code plugins and MCP servers

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
GRAY='\033[0;90m'
DARKYELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}=== SuperClaude Machine Setup ===${NC}"
echo ""

# --- Check prerequisites ---
echo -e "${YELLOW}[0/3] Verification des prerequis...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}  ERREUR: Node.js non trouve. Installer depuis https://nodejs.org${NC}"
    exit 1
fi
echo -e "${GREEN}  OK: Node.js $(node --version)${NC}"

if ! command -v claude &> /dev/null; then
    echo -e "${RED}  ERREUR: Claude Code non trouve. Installer depuis https://claude.ai/code${NC}"
    exit 1
fi
echo -e "${GREEN}  OK: Claude Code $(claude --version)${NC}"

# --- Install plugins ---
echo ""
echo -e "${YELLOW}[1/3] Installation plugins Claude Code...${NC}"
plugins=("superpowers" "impeccable" "taste-skill" "caveman" "claude-mem" "context7" "playwright")
for p in "${plugins[@]}"; do
    echo -e "${GRAY}  Installing $p...${NC}"
    if claude plugin install "$p" &> /dev/null; then
        echo -e "${GREEN}  OK: $p${NC}"
    else
        echo -e "${DARKYELLOW}  WARN: $p (deja installe ou erreur, on continue)${NC}"
    fi
done

# --- Magic API key ---
echo ""
echo -e "${YELLOW}[2/3] Configuration MCP Magic (21st.dev)...${NC}"
echo -e "${GRAY}  Obtenir la cle sur: https://21st.dev/magic/console${NC}"
echo ""
read -rp "  Entrer ta Magic API key (laisser vide pour ignorer): " magic_key

# --- Add MCP servers ---
echo ""
echo -e "${YELLOW}[3/3] Ajout des MCP servers...${NC}"

if [ -n "$magic_key" ]; then
    echo -e "${GRAY}  Adding magic...${NC}"
    if claude mcp add magic --scope user --env "API_KEY=$magic_key" -- npx -y @21st-dev/magic@latest &> /dev/null; then
        echo -e "${GREEN}  OK: magic${NC}"
    else
        echo -e "${DARKYELLOW}  WARN: magic (erreur lors de l'ajout, verifier la cle)${NC}"
    fi
else
    echo -e "${DARKYELLOW}  SKIP: magic (pas de cle fournie)${NC}"
fi

echo -e "${GRAY}  Adding playwright...${NC}"
if claude mcp add playwright --scope user -- npx @playwright/mcp@latest &> /dev/null; then
    echo -e "${GREEN}  OK: playwright${NC}"
else
    echo -e "${DARKYELLOW}  WARN: playwright (deja configure ou erreur)${NC}"
fi

echo -e "${GRAY}  Adding context7...${NC}"
if claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp &> /dev/null; then
    echo -e "${GREEN}  OK: context7${NC}"
else
    echo -e "${DARKYELLOW}  WARN: context7 (deja configure ou erreur)${NC}"
fi

# --- Summary ---
echo ""
echo -e "${GREEN}=== Setup termine ===${NC}"
echo ""
echo "Prochaines etapes:"
echo -e "  1. Bootstrapper un projet :  ${CYAN}./new-project.sh MonProjet${NC}"
echo "  2. Ouvrir Claude Code dans le projet -> tout fonctionne"
echo ""
