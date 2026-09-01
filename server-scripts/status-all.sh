#!/usr/bin/env bash
# ==============================================================================
# Inspect Status of All Local-N8n Systemd Units & Docker Containers
# ==============================================================================
set -euo pipefail

echo "=============================================================================="
echo "                  LOCAL-N8N SYSTEMD SERVICES STATUS"
echo "=============================================================================="
systemctl is-active --quiet local-n8n-gateway.service && echo "  [ACTIVE]  local-n8n-gateway.service" || echo "  [INACTIVE] local-n8n-gateway.service"
systemctl is-active --quiet local-n8n.service         && echo "  [ACTIVE]  local-n8n.service"         || echo "  [INACTIVE] local-n8n.service"
systemctl is-active --quiet local-n8n-searxng.service && echo "  [ACTIVE]  local-n8n-searxng.service" || echo "  [INACTIVE] local-n8n-searxng.service"
systemctl is-active --quiet local-n8n-sandbox.service && echo "  [ACTIVE]  local-n8n-sandbox.service" || echo "  [INACTIVE] local-n8n-sandbox.service"

echo ""
echo "=============================================================================="
echo "                      DOCKER CONTAINERS STATUS"
echo "=============================================================================="
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=============================================================================="
echo "                   CLOUDFLARE TUNNEL INGRESS LOGS (LAST 5 LINES)"
echo "=============================================================================="
docker logs --tail 5 gateway-cloudflared-1 2>&1 || echo "Gateway container not running."
