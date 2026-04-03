#!/usr/bin/env bash
#
# Stop the Paperclip dev service for this repo (registry-based), then start `pnpm dev`.
# Use after changing PATH-related server code (e.g. ~/.local/bin for claude).
#
# Usage:
#   ./scripts/restart-dev.sh                    # foreground (same terminal, Ctrl+C stops)
#   ./scripts/restart-dev.sh --background|-b    # nohup + log under $TMPDIR or /tmp
#   ./scripts/restart-dev.sh --hard            # kill-dev.sh first if soft stop is not enough
#   ./scripts/restart-dev.sh --reset-db        # after stop, remove embedded Postgres data dir
#   ./scripts/restart-dev.sh --reset-db -y     # same, no prompt (CI / database_unreachable recovery)
#
# Embedded DB path: ${PAPERCLIP_HOME:-~/.paperclip}/instances/${PAPERCLIP_INSTANCE_ID:-default}/db
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

BACKGROUND=false
HARD=false
RESET_DB=false
ASSUME_YES=false

for arg in "$@"; do
  case "$arg" in
    --background|-b) BACKGROUND=true ;;
    --hard) HARD=true ;;
    --reset-db) RESET_DB=true ;;
    -y|--yes) ASSUME_YES=true ;;
  esac
done

resolve_embedded_db_dir() {
  local root="${PAPERCLIP_HOME:-$HOME/.paperclip}"
  if [[ "$root" == "~" ]]; then root="$HOME"; elif [[ "$root" == "~/"* ]]; then root="$HOME/${root#~/}"; fi
  local inst="${PAPERCLIP_INSTANCE_ID:-default}"
  printf '%s\n' "$root/instances/$inst/db"
}

reset_embedded_db() {
  local db_dir
  db_dir="$(resolve_embedded_db_dir)"
  if [[ ! -e "$db_dir" ]]; then
    echo "[restart-dev] --reset-db: nothing to remove ($db_dir missing)"
    return 0
  fi
  if [[ "$ASSUME_YES" != true ]]; then
    read -r -p "[restart-dev] Remove embedded Postgres data at ${db_dir} ? [y/N] " ans || true
    if [[ ! "${ans:-}" =~ ^[Yy]$ ]]; then
      echo "[restart-dev] aborted."
      exit 1
    fi
  fi
  echo "[restart-dev] removing embedded DB dir: $db_dir"
  rm -rf "$db_dir"
}

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
  echo "[restart-dev] hint: if health returns database_unreachable afterward, run: pnpm dev:restart:db"
fi

echo "[restart-dev] stopping (pnpm dev:stop) ..."
"${PNPM[@]}" dev:stop 2>/dev/null || true
sleep 1

if [[ "$RESET_DB" == true ]]; then
  reset_embedded_db
fi

echo "[restart-dev] starting pnpm dev ..."
print_dev_urls() {
  echo "[restart-dev] URLs (default port 3100, see log if port changed):"
  echo "  UI/API   http://127.0.0.1:3100/"
  echo "  health   http://127.0.0.1:3100/api/health"
  echo "  bookmark doc/URLS.md"
  if [[ "$RESET_DB" == true ]]; then
    echo "[restart-dev] embedded DB was reset; first boot will re-init Postgres + migrations."
  fi
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
