#!/usr/bin/env bash
# ==============================================================================
# Helper to Update Cloudflare Tunnel Token in Doppler & Restart Gateway
# ==============================================================================
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <CLOUDFLARE_TUNNEL_TOKEN>"
  exit 1
fi

TOKEN="$1"

echo "Updating CLOUDFLARE_TUNNEL_TOKEN in Doppler (silver-worker/prd)..."
doppler secrets set CLOUDFLARE_TUNNEL_TOKEN="${TOKEN}" --project silver-worker --config prd

echo "Restarting Gateway service..."
sudo systemctl restart local-n8n-gateway.service || {
  cd /home/silver-worker/Local-N8n/gateway && doppler run -- docker compose up -d --force-recreate cloudflared
}

echo "Done. Checking cloudflared logs:"
docker logs --tail 10 gateway-cloudflared-1 2>&1
