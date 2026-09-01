# SearXNG Metasearch Engine Service — Local-N8n

Self-hosted, privacy-respecting **SearXNG** metasearch engine integrated with `Local-N8n` to power web search for n8n AI Assistant and AI Agents.

---

## 1. Service Overview

- **Image**: `searxng/searxng:latest`
- **Internal Network**: `gateway_net` (DNS Aliases: `searxng`, `searxng.internal`)
- **Internal Service URL**: `http://searxng:8080`
- **Host Port Bindings**: `127.0.0.1:8088:8080`, `100.116.224.88:8088:8080`
- **Output Formats**: HTML + JSON (`search.formats: [html, json]`)

---

## 2. Operational Lifecycle

### Manual Start with Doppler Secrets
```bash
cd /home/silver-worker/Local-N8n/searxng
doppler setup --project silver-worker --config prd --no-interactive
doppler run -- docker compose up -d
```

### Health & JSON Output Verification
```bash
# From host or Mac:
curl "http://100.116.224.88:8088/search?q=n8n&format=json"

# From inside n8n container:
docker exec local-n8n-n8n-1 wget -q -O - "http://searxng:8080/search?q=n8n&format=json"
```

---

## 3. Host Boot Persistence (`systemd`)

To start SearXNG automatically upon server reboot:

```bash
sudo bash -c 'cat << "EOF" > /etc/systemd/system/local-n8n-searxng.service
[Unit]
Description=Local n8n SearXNG Search Service with Doppler Secrets
Requires=docker.service local-n8n.service
After=docker.service network-online.target local-n8n.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/silver-worker/Local-N8n/searxng
User=silver-worker
Group=docker

ExecStartPre=/usr/bin/docker compose down
ExecStart=/usr/bin/doppler run -- /usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable local-n8n-searxng.service
'
```
