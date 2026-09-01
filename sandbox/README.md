# n8n Code Sandbox Service

Isolated Docker-in-Docker execution environment for n8n AI Assistant and Agents on Ubuntu Server.

---

## 1. Overview

The **n8n Sandbox Service** allows n8n to execute AI-generated JavaScript and Python code inside unprivileged `sysbox-runc` micro-containers rather than inside the main production `n8n` or `n8n-worker` instances.

---

## 2. Architecture & Components

- **`sandbox-api`**: Receives execution requests from n8n over `gateway_net` on port `3200` (`http://sandbox-api:3200`), authenticated by `SANDBOX_API_KEY`.
- **`sandbox-runner`**: Runs under `runtime: sysbox-runc` to safely spawn isolated micro-containers.
- **`registry`**: Local Docker registry on `127.0.0.1:5050` caching runner environment images.

---

## 3. Host Systemd Unit (`local-n8n-sandbox.service`)

Create `/etc/systemd/system/local-n8n-sandbox.service`:

```ini
[Unit]
Description=Local n8n Sandbox Service with Doppler Secrets
Requires=docker.service local-n8n.service
After=docker.service network-online.target local-n8n.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/silver-worker/Local-N8n/sandbox
User=silver-worker
Group=docker

ExecStartPre=/usr/bin/docker compose down
ExecStart=/usr/bin/doppler run -- /usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
```
