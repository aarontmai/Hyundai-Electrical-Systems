#!/bin/bash
# Copies the latest handbook into the GitHub repo folder and pushes it if anything changed.
# Run hourly by launchd (installed by setup-mac-mini.sh).
set -e
DIR="$HOME/Applications/Hyundai-Engineering-Handbook"
cd "$DIR/github-upload"
git pull -q --rebase origin main || echo "Pull failed, continuing with local copy"
cp "$DIR/hyundai-engineering-handbook.html" index.html
git add -A
if git diff --cached --quiet; then echo "No changes"; exit 0; fi
git commit -q -m "Daily handbook update $(date +%F)"
git push -q origin main
echo "Pushed $(date)"
