#!/usr/bin/env bash
# ==============================================================================
# Doppler Docker Compose Wrapper (dc.sh)
# Executes docker compose commands with Doppler runtime secrets injection.
#
# Usage:
#   ./dc.sh [stack] <compose-subcommand> [args...]
#
# Stacks:
#   core (default)  -> /home/silver-worker/Local-N8n (n8n, postgres, redis, worker)
#   gateway         -> /home/silver-worker/Local-N8n/gateway (caddy, cloudflared)
#   searxng         -> /home/silver-worker/Local-N8n/searxng (searxng)
#   sandbox         -> /home/silver-worker/Local-N8n/sandbox (tls-init, api, runner)
#   all             -> executes command across all stacks in sequence
#
# Examples:
#   ./dc.sh ps
#   ./dc.sh logs -f n8n
#   ./dc.sh gateway logs -f cloudflared
#   ./dc.sh searxng config
#   ./dc.sh sandbox logs -f api
#   ./dc.sh all ps
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

STACK="core"
STACK_DIR="${ROOT_DIR}"

if [ $# -eq 0 ]; then
  echo "Usage: $0 [core|gateway|searxng|sandbox|all] <docker-compose-command> [options...]"
  echo ""
  echo "Examples:"
  echo "  $0 ps"
  echo "  $0 logs -f n8n"
  echo "  $0 gateway logs -f cloudflared"
  echo "  $0 searxng logs -f"
  echo "  $0 sandbox logs -f api"
  echo "  $0 all ps"
  exit 1
fi

case "$1" in
  core)
    STACK="core"
    STACK_DIR="${ROOT_DIR}"
    shift
    ;;
  gateway)
    STACK="gateway"
    STACK_DIR="${ROOT_DIR}/gateway"
    shift
    ;;
  searxng)
    STACK="searxng"
    STACK_DIR="${ROOT_DIR}/searxng"
    shift
    ;;
  sandbox)
    STACK="sandbox"
    STACK_DIR="${ROOT_DIR}/sandbox"
    shift
    ;;
  all)
    STACK="all"
    shift
    ;;
  *)
    # Default stack is core, arguments remain unchanged
    STACK="core"
    STACK_DIR="${ROOT_DIR}"
    ;;
esac

if [ "$STACK" = "all" ]; then
  for s in gateway core searxng sandbox; do
    echo ""
    echo "=============================================================================="
    echo "  STACK: [${s^^}]"
    echo "=============================================================================="
    case "$s" in
      core) d="${ROOT_DIR}" ;;
      gateway) d="${ROOT_DIR}/gateway" ;;
      searxng) d="${ROOT_DIR}/searxng" ;;
      sandbox) d="${ROOT_DIR}/sandbox" ;;
    esac
    (cd "$d" && doppler run -- docker compose "$@") || true
  done
else
  echo "[dc.sh] Executing in stack '${STACK}' (${STACK_DIR}): doppler run -- docker compose $*"
  cd "${STACK_DIR}" && doppler run -- docker compose "$@"
fi
