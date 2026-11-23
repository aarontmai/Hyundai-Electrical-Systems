#!/bin/bash
# One-time setup for running the Hyundai handbook on a new Mac (e.g. the Mac mini).
#   curl -fsSL https://raw.githubusercontent.com/aarontmai/Hyundai-Electrical-Systems/main/mac-mini/setup-mac-mini.sh | bash
# It clones this repo, seeds ~/Applications/Hyundai-Engineering-Handbook with the latest handbook,
# installs the push script and the daily routine prompt, and schedules an hourly GitHub push.
set -e
DIR="$HOME/Applications/Hyundai-Engineering-Handbook"
REPO="https://github.com/aarontmai/Hyundai-Electrical-Systems.git"

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Run: xcode-select --install   then re-run this script."; exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI not found. Install it first:  brew install gh   (or https://cli.github.com)"; exit 1
fi
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git

mkdir -p "$DIR"
if [ -d "$DIR/github-upload/.git" ]; then
  git -C "$DIR/github-upload" pull -q --rebase origin main
else
  git clone -q "$REPO" "$DIR/github-upload"
fi
cd "$DIR/github-upload"
git config user.name "aarontmai"
git config user.email "aarontmai@users.noreply.github.com"

# Seed the working handbook from the published copy (never overwrite an existing one).
if [ ! -f "$DIR/hyundai-engineering-handbook.html" ]; then
  cp index.html "$DIR/hyundai-engineering-handbook.html"
  echo "Seeded $DIR/hyundai-engineering-handbook.html"
else
  echo "Existing handbook kept: $DIR/hyundai-engineering-handbook.html"
fi
cp mac-mini/github-push.sh "$DIR/github-push.sh"; chmod +x "$DIR/github-push.sh"
cp mac-mini/ROUTINE_PROMPT.md "$DIR/ROUTINE_PROMPT.md"

PLIST="$HOME/Library/LaunchAgents/com.aaronmai.handbook-push.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.aaronmai.handbook-push</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$DIR/github-push.sh</string></array>
  <key>EnvironmentVariables</key><dict><key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string></dict>
  <key>StartInterval</key><integer>3600</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$DIR/github-push.log</string>
  <key>StandardErrorPath</key><string>$DIR/github-push.log</string>
</dict></plist>
P
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo ""
echo "Done. Hourly auto-push is scheduled (log: $DIR/github-push.log)."
echo "Next: open the Claude desktop app on this Mac, start a Cowork task with your Applications folder connected,"
echo "and ask Claude to create a daily scheduled task from $DIR/ROUTINE_PROMPT.md (see README)."
