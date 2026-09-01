#!/usr/bin/env bash
# ==============================================================================
# Stop All Local-N8n Stacks Cleanly
# ==============================================================================
set -euo pipefail

echo "=== Stopping All Local-N8n Services ==="

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo." >&2
   exit 1
fi

echo "1. Stopping Sandbox..."
systemctl stop local-n8n-sandbox.service || true

echo "2. Stopping SearXNG..."
systemctl stop local-n8n-searxng.service || true

echo "3. Stopping Core Stack..."
systemctl stop local-n8n.service || true

echo "4. Stopping Gateway..."
systemctl stop local-n8n-gateway.service || true

echo "=== All services stopped ==="
