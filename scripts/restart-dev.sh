#!/usr/bin/env bash
#
# Stop the Paperclip dev service for this repo (registry-based), then start `pnpm dev`.
# Use after changing PATH-related server code (e.g. ~/.local/bin for claude).
#
# Usage:
#   ./scripts/restart-dev.sh              # foreground (same terminal, Ctrl+C stops)
#   ./scripts/restart-dev.sh --background # nohup + log to /tmp/paperclip-dev.log
#   ./scripts/restart-dev.sh --hard       # kill-dev.sh first if soft stop is not enough
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

BACKGROUND=false
HARD=false
for arg in "$@"; do
  case "$arg" in
    --background|-b) BACKGROUND=true ;;
    --hard) HARD=true ;;
  esac
done

if [[ -d "${HOME}/.local/bin" ]]; then
  case ":${PATH:-}:" in *":${HOME}/.local/bin:"*) ;; *)
    export PATH="${HOME}/.local/bin:${PATH:-}"
    ;;
  esac
fi

if command -v pnpm >/dev/null 2>&1; then
  PNPM=(pnpm)
else
  PNPM=(npx --yes pnpm@9.15.4)
fi

if [[ "$HARD" == true ]]; then
  echo "[restart-dev] --hard: running kill-dev.sh ..."
  "$SCRIPT_DIR/kill-dev.sh" || true
  sleep 2
fi

echo "[restart-dev] stopping (pnpm dev:stop) ..."
"${PNPM[@]}" dev:stop 2>/dev/null || true
sleep 1

echo "[restart-dev] starting pnpm dev ..."
print_dev_urls() {
  echo "[restart-dev] URLs (default port 3100, see log if port changed):"
  echo "  UI/API   http://127.0.0.1:3100/"
  echo "  health   http://127.0.0.1:3100/api/health"
  echo "  bookmark doc/URLS.md"
}
if [[ "$BACKGROUND" == true ]]; then
  LOG_FILE="${TMPDIR:-/tmp}/paperclip-dev.log"
  nohup "${PNPM[@]}" dev >"$LOG_FILE" 2>&1 &
  echo "[restart-dev] background pid $!  log: $LOG_FILE"
  echo "[restart-dev] tail: tail -f $LOG_FILE"
  print_dev_urls
else
  print_dev_urls
  exec "${PNPM[@]}" dev
fi
