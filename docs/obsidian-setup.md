# Setup mémoire Obsidian

## Prérequis

1. **Obsidian** installé avec le plugin **Local REST API**
   - Dans Obsidian: Settings → Community Plugins → Local REST API
   - Activer le plugin
   - Copier l'API key générée

2. Le plugin tourne sur `http://127.0.0.1:27124` par défaut.

## Configuration

Dans `~/.claude/settings.json`, ajouter dans `env`:
```json
{
  "OBSIDIAN_API_KEY": "VOTRE_KEY_ICI",
  "OBSIDIAN_API_HOST": "127.0.0.1",
  "OBSIDIAN_API_PORT": "27124"
}
```

## Structure vault recommandée

```
Qwillio/
├── Taches.md           # Tâches actives (Claude lit en début de session)
├── 04 - Decisions.md   # Décisions architecturales
├── 03 - Pages.md       # Pages et composants créés
└── Sessions/
    ├── 2026-05-28.md   # Journal du jour (Claude écrit ici)
    └── 2026-05-27.md
```

## Commandes disponibles

```powershell
# Lire une note
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" read "Qwillio/Taches.md"

# Ajouter du contenu (append)
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" append "Qwillio/Sessions/2026-05-28.md" "## 14:30 — Fix auth\nDescription du fix"

# Écrire une note complète (overwrite)
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" write "Qwillio/Taches.md" "# Taches\n- [ ] Feature X\n- [x] Feature Y"

# Lister un dossier
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" list "Qwillio/"

# Injecter le contexte dans Claude (appelé automatiquement par le hook)
node --no-warnings "C:/Users/matpo/.claude/scripts/obsidian.js" inject-context
```

## Hook automatique

Le hook `UserPromptSubmit` dans `settings.json` appelle `inject-context` à chaque message.
Claude reçoit automatiquement les tâches ouvertes et la session du jour.

## Après chaque action majeure

Claude doit logger automatiquement dans Obsidian. Structure:
```markdown
## HH:MM — [type d'action]
- Fichier créé/modifié: path/to/file
- Ce qui a changé: description
- Décision prise: si applicable
```
