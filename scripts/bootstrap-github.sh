#!/usr/bin/env bash
# One-time setup: create the 3 GitHub repos, push FE/BE, wire them as submodules of the umbrella.
# Usage (from meeting-manager/, after `gh auth login`): scripts/bootstrap-github.sh
set -euo pipefail
OWNER=${OWNER:-Mrdiamond096}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=$(dirname "$ROOT")

for repo in meeting-manager-backend meeting-manager-frontend; do
  (
    cd "$SRC/$repo"
    if [ ! -d .git ]; then
      git init -b main
      git add .
      git commit -m "chore: initial scaffold"
    fi
    gh repo view "$OWNER/$repo" >/dev/null 2>&1 || gh repo create "$OWNER/$repo" --public --source . --push
  )
done

cd "$ROOT"
[ -d .git ] || git init -b main
[ -e backend/.git ] || git submodule add "https://github.com/$OWNER/meeting-manager-backend.git" backend
[ -e frontend/.git ] || git submodule add "https://github.com/$OWNER/meeting-manager-frontend.git" frontend
git add .
git commit -m "chore: umbrella repo with frontend/backend submodules" || true
gh repo view "$OWNER/meeting-manager" >/dev/null 2>&1 || gh repo create "$OWNER/meeting-manager" --public --source . --push
