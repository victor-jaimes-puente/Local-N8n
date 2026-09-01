#!/usr/bin/env bash
# ==============================================================================
# Install & Enable Systemd Units for Local-N8n Stacks
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SYSTEMD_DIR="${REPO_DIR}/systemd"

echo "=== Installing Local-N8n Systemd Units ==="

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo or as root." >&2
   exit 1
fi

echo "Copying unit files from ${SYSTEMD_DIR} to /etc/systemd/system/..."
cp "${SYSTEMD_DIR}"/*.service /etc/systemd/system/

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling services for host boot persistence..."
systemctl enable \
  local-n8n-gateway.service \
  local-n8n.service \
  local-n8n-searxng.service \
  local-n8n-sandbox.service

echo "=== Systemd services installed and enabled successfully ==="
echo "You can check status with: ${SCRIPT_DIR}/status-all.sh"
