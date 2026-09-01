#!/usr/bin/env bash
# ==============================================================================
# Start All Local-N8n Stacks via Systemd (with Doppler secrets injection)
# ==============================================================================
set -euo pipefail

echo "=== Starting All Local-N8n Services ==="

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo." >&2
   exit 1
fi

echo "1. Starting Gateway (Caddy & Cloudflare Tunnel)..."
systemctl start local-n8n-gateway.service

echo "2. Starting Core Stack (Postgres, Redis, n8n, Worker)..."
systemctl start local-n8n.service

echo "3. Starting SearXNG Metasearch Service..."
systemctl start local-n8n-searxng.service

echo "4. Starting Code Execution Sandbox..."
systemctl start local-n8n-sandbox.service

echo "=== All services started successfully ==="
