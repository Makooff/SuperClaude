#!/usr/bin/env bash
# SuperClaude — build the desktop app (Mac/Linux)
set -e
cd "$(dirname "$0")/installer-app"
echo "==> npm install"
npm install
echo "==> build macOS app"
npm run build-mac
echo "==> Done. Artefact dans installer-app/dist/"
