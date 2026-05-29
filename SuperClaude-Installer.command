#!/usr/bin/env bash
# SuperClaude Installer — Mac
# Rendre exécutable avant le premier lancement :
#   chmod +x SuperClaude-Installer.command
# Puis double-cliquer depuis le Finder, ou lancer :
#   ./SuperClaude-Installer.command

# ── Couleurs ANSI ─────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
WHITE='\033[97m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
CYAN='\033[96m'
PURPLE='\033[35m'
DIM='\033[2m'

# ── Helpers ───────────────────────────────────────────────────
clear

TOTAL_STEPS=10
CURRENT_STEP=0

print_header() {
    echo ""
    echo -e "${PURPLE}${BOLD}  ╔═══════════════════════════════════════╗${RESET}"
    echo -e "${PURPLE}${BOLD}  ║        ⚡  SuperClaude Installer       ║${RESET}"
    echo -e "${PURPLE}${BOLD}  ║   Config Claude Code — prête en 30s   ║${RESET}"
    echo -e "${PURPLE}${BOLD}  ╚═══════════════════════════════════════╝${RESET}"
    echo ""
}

# Barre de progression ASCII : [████████░░░░░░░] 60%
print_progress() {
    local step=$1
    local total=$2
    local width=30
    local filled=$(( step * width / total ))
    local empty=$(( width - filled ))
    local pct=$(( step * 100 / total ))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    printf "\r  ${CYAN}[${bar}]${RESET} ${WHITE}%3d%%${RESET}  " "$pct"
}

# Spinner animé pendant une commande
spin_run() {
    local label="$1"
    shift
    local cmd=("$@")
    local spinners=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0

    # Lance la commande en arrière-plan
    "${cmd[@]}" >/tmp/sc_out 2>&1 &
    local pid=$!

    printf "  "
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${PURPLE}%s${RESET}  ${WHITE}%s${RESET}   " "${spinners[$i]}" "$label"
        i=$(( (i + 1) % ${#spinners[@]} ))
        sleep 0.1
    done

    wait "$pid"
    return $?
}

log_ok()   { printf "\r  ${GREEN}✅${RESET}  ${WHITE}%s${RESET}%40s\n" "$1" ""; }
log_warn() { printf "\r  ${YELLOW}⚠️ ${RESET}  ${YELLOW}%s${RESET}%40s\n" "$1" ""; }
log_info() { printf "  ${DIM}→${RESET}  ${DIM}%s${RESET}\n" "$1"; }

step() {
    CURRENT_STEP=$(( CURRENT_STEP + 1 ))
    local label="$1"
    shift
    local cmd=("$@")

    echo ""
    print_progress "$CURRENT_STEP" "$TOTAL_STEPS"
    echo ""

    spin_run "$label" "${cmd[@]}"
    local rc=$?

    if [ $rc -eq 0 ]; then
        log_ok "$label"
    else
        log_warn "$label — ignoré (continuer)"
    fi

    sleep 0.3
}

# ── Installation ───────────────────────────────────────────────
print_header

echo -e "  ${DIM}Appuie sur Ctrl+C pour annuler à tout moment.${RESET}"
echo ""
sleep 1

# Étape 1 — Node.js
step "Vérification Node.js" node --version

# Log version si dispo
if command -v node &>/dev/null; then
    log_info "Node.js $(node --version) détecté"
fi

# Étape 2 — Claude Code
step "Vérification Claude Code" claude --version

if command -v claude &>/dev/null; then
    log_info "Claude Code $(claude --version 2>/dev/null | head -1) détecté"
fi

# Étape 3 — Plugin code-review
step "Installation plugin code-review" claude plugin install code-review

# Étape 4 — Plugin superpowers
step "Installation plugin superpowers" claude plugin install superpowers

# Étape 5 — Plugin impeccable
step "Installation plugin impeccable" claude plugin install impeccable

# Étape 6 — Plugin taste-skill
step "Installation plugin taste-skill" claude plugin install taste-skill

# Étape 7 — Plugin playwright
step "Installation plugin playwright" claude plugin install playwright

# Étape 8 — MCP context7
step "Ajout MCP context7" claude mcp add context7

# Étape 9 — MCP playwright
step "Ajout MCP playwright" claude mcp add playwright

# Étape 10 — Terminé
CURRENT_STEP=10
echo ""
print_progress 10 10
echo ""
echo ""

echo -e "  ${GREEN}${BOLD}✅  Installation terminée avec succès !${RESET}"
echo ""
echo -e "  ${WHITE}Skills actifs :${RESET} ${DIM}code-review · superpowers · impeccable · taste-skill · playwright${RESET}"
echo -e "  ${WHITE}MCPs actifs   :${RESET} ${DIM}context7 · playwright${RESET}"
echo ""

# Tenter d'ouvrir Claude Code
if open -Ra "Claude" 2>/dev/null; then
    echo -e "  ${CYAN}→ Ouverture de Claude Code...${RESET}"
    open -a "Claude" 2>/dev/null || true
else
    echo -e "  ${CYAN}→ Lance Claude Code avec :${RESET} ${WHITE}claude${RESET}"
fi

echo ""
echo -e "  ${DIM}Ferme cette fenêtre ou appuie sur Entrée pour quitter.${RESET}"
read -r
