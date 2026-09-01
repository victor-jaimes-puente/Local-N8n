#!/usr/bin/env bash
# ==============================================================================
# Quick Docker Compose Logs Shortcut (logs.sh)
#
# Usage:
#   ./logs.sh [service]                     # View logs for a core service (n8n, redis, postgres, worker)
#   ./logs.sh [stack] [service]             # View logs for specific stack and service
#   ./logs.sh [stack] -f                    # Follow logs for an entire stack
#   ./logs.sh cloudflared -f                # Follow cloudflared logs in gateway
#   ./logs.sh n8n -f                        # Follow n8n logs in core
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DC="${SCRIPT_DIR}/dc.sh"

if [ $# -eq 0 ]; then
  echo "Usage: $0 [core|gateway|searxng|sandbox] [service] [-f]"
  echo ""
  echo "Common Examples:"
  echo "  $0 n8n -f                 # Follow core n8n logs"
  echo "  $0 worker -f              # Follow n8n worker logs"
  echo "  $0 cloudflared -f         # Follow Cloudflare Tunnel logs"
  echo "  $0 caddy -f               # Follow Caddy reverse proxy logs"
  echo "  $0 searxng -f             # Follow SearXNG logs"
  echo "  $0 sandbox -f             # Follow Sandbox logs"
  exit 1
fi

case "$1" in
  cloudflared|caddy)
    exec "$DC" gateway logs "$@"
    ;;
  searxng)
    exec "$DC" searxng logs "$@"
    ;;
  api|runner|tls-init)
    exec "$DC" sandbox logs "$@"
    ;;
  gateway|sandbox)
    stack="$1"
    shift
    exec "$DC" "$stack" logs "$@"
    ;;
  core)
    shift
    exec "$DC" core logs "$@"
    ;;
  worker|n8n-worker)
    shift
    exec "$DC" core logs n8n-worker "$@"
    ;;
  *)
    exec "$DC" core logs "$@"
    ;;
esac
