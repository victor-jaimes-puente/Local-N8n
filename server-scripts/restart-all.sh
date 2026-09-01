#!/usr/bin/env bash
# ==============================================================================
# Restart All Local-N8n Stacks Cleanly
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo." >&2
   exit 1
fi

"${SCRIPT_DIR}/stop-all.sh"
echo "Waiting 3 seconds..."
sleep 3
"${SCRIPT_DIR}/start-all.sh"
echo ""
"${SCRIPT_DIR}/status-all.sh"
