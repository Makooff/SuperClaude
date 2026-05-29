#!/usr/bin/env bash
# SuperClaude — Bootstrap Nouveau Projet (Mac / Linux)
# Usage: ./new-project.sh MonProjet [/chemin/optionnel]

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DARKYELLOW='\033[0;33m'
GRAY='\033[0;90m'
NC='\033[0m'

SUPERCLAUDE_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Args ---
if [ $# -lt 1 ]; then
    echo -e "${YELLOW}Usage: ./new-project.sh NomProjet [/chemin/optionnel]${NC}"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_PATH="${2:-$(pwd)}"

echo ""
echo -e "${CYAN}=== SuperClaude — Nouveau Projet ===${NC}"
echo -e "${GRAY}  Vault Obsidian : $PROJECT_NAME${NC}"
echo -e "${GRAY}  Chemin projet  : $PROJECT_PATH${NC}"
echo ""

# --- Create project directory ---
echo -e "${YELLOW}[1/4] Creation du dossier projet...${NC}"
mkdir -p "$PROJECT_PATH"
echo -e "${GREEN}  OK: $PROJECT_PATH${NC}"

# --- Copy SuperClaude config ---
echo ""
echo -e "${YELLOW}[2/4] Copie de la config SuperClaude...${NC}"

if [ -d "$SUPERCLAUDE_DIR/.claude" ]; then
    cp -r "$SUPERCLAUDE_DIR/.claude" "$PROJECT_PATH/.claude"
    echo -e "${GREEN}  OK: .claude/${NC}"
else
    echo -e "${DARKYELLOW}  WARN: .claude/ non trouve dans SuperClaude${NC}"
fi

if [ -f "$SUPERCLAUDE_DIR/CLAUDE.md" ]; then
    cp "$SUPERCLAUDE_DIR/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
    echo -e "${GREEN}  OK: CLAUDE.md${NC}"
fi

if [ -f "$SUPERCLAUDE_DIR/.mcp.json" ]; then
    cp "$SUPERCLAUDE_DIR/.mcp.json" "$PROJECT_PATH/.mcp.json"
    echo -e "${GREEN}  OK: .mcp.json${NC}"
fi

if [ -f "$SUPERCLAUDE_DIR/.env.example" ]; then
    cp "$SUPERCLAUDE_DIR/.env.example" "$PROJECT_PATH/.env.local"
    echo -e "${GREEN}  OK: .env.example -> .env.local${NC}"
else
    echo -e "${DARKYELLOW}  WARN: .env.example non trouve${NC}"
fi

# --- Interactive secrets ---
echo ""
echo -e "${YELLOW}[3/4] Configuration des secrets...${NC}"
echo -e "${GRAY}  (Obsidian -> Settings -> Local REST API -> copier la cle)${NC}"
echo ""
read -rp "  OBSIDIAN_API_KEY: " obsidian_key
read -rp "  MAGIC_API_KEY (21st.dev, laisser vide si pas encore): " magic_key

# Write .env.local with filled values
cat > "$PROJECT_PATH/.env.local" << EOF
# SuperClaude — Secrets projet
# NE JAMAIS commiter ce fichier

# Obsidian Local REST API
OBSIDIAN_API_KEY=$obsidian_key
OBSIDIAN_API_HOST=127.0.0.1
OBSIDIAN_API_PORT=27124

# Nom du vault Obsidian pour ce projet
OBSIDIAN_VAULT=$PROJECT_NAME

# 21st.dev Magic MCP
MAGIC_API_KEY=$magic_key
EOF

echo ""
echo -e "${GREEN}  OK: .env.local rempli${NC}"

# --- .gitignore ---
echo ""
echo -e "${YELLOW}[4/4] Mise a jour .gitignore...${NC}"
GITIGNORE="$PROJECT_PATH/.gitignore"

if [ -f "$GITIGNORE" ]; then
    if ! grep -qF ".env.local" "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo ".env.local" >> "$GITIGNORE"
        echo -e "${GREEN}  OK: .env.local ajoute au .gitignore existant${NC}"
    else
        echo -e "${GREEN}  OK: .env.local deja dans .gitignore${NC}"
    fi
else
    echo ".env.local" > "$GITIGNORE"
    echo -e "${GREEN}  OK: .gitignore cree avec .env.local${NC}"
fi

# --- Summary ---
echo ""
echo -e "${GREEN}=== Projet pret ===${NC}"
echo ""
echo "Prochaines etapes:"
echo -e "  1. Dans Obsidian, creer le dossier : ${CYAN}$PROJECT_NAME/${NC}"
echo -e "${GRAY}     avec Taches.md, Decisions.md, PRODUCT.md, Sessions/${NC}"
echo -e "  2. Ouvrir le projet dans VS Code : ${CYAN}$PROJECT_PATH${NC}"
echo -e "  3. Claude Code -> nouveau chat -> premier message"
echo ""
echo -e "${GRAY}  Obsidian doit etre ouvert pour la memoire cross-session.${NC}"
echo ""
