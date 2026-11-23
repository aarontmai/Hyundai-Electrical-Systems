# Hyundai Electrical Systems Handbook

An interactive, single-file engineering handbook on Hyundai/Kia/Genesis body electrical, telematics, in-vehicle networking, EV systems and diagnostics. Open `index.html` in a browser, or view it on GitHub Pages if enabled.

Module names, bus layouts and procedures vary by platform, model year and market. Always follow the official service information for the exact vehicle. This is an independent study reference and is not affiliated with Hyundai Motor Company.

## Running the daily updater on another Mac (e.g. a Mac mini)

Everything needed is in [`mac-mini/`](mac-mini/):

| File | Purpose |
|---|---|
| `setup-mac-mini.sh` | One-time setup: clones this repo, seeds `~/Applications/Hyundai-Engineering-Handbook/hyundai-engineering-handbook.html` from `index.html`, installs the push script and schedules an hourly GitHub push with launchd |
| `github-push.sh` | Pulls, copies the handbook to `index.html`, commits and pushes if anything changed |
| `ROUTINE_PROMPT.md` | The daily prompt for the Claude scheduled task that writes new chapters, news and glossary terms |

Steps on the new Mac:

1. Install the GitHub CLI (`brew install gh`), then run:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/aarontmai/Hyundai-Electrical-Systems/main/mac-mini/setup-mac-mini.sh | bash
   ```
   Sign in to GitHub in the browser when asked.
2. Open the Claude desktop app on that Mac, start a Cowork task, connect the `~/Applications` folder, and ask:
   > Create a daily scheduled task at 8:00 AM Pacific named "Hyundai handbook daily updater" that requires this computer, using the prompt in ~/Applications/Hyundai-Engineering-Handbook/ROUTINE_PROMPT.md.
3. Retire the old machine so two Macs never push different copies: on the old Mac run
   `launchctl unload ~/Library/LaunchAgents/com.aaronmai.handbook-push.plist`, and delete its old scheduled task.
