# Operations & Deployment Manual — Local-N8n

> **Scope**: CLI commands, Doppler production workflows, Zero-Trust network administration, client DNS configuration, scaling, and implementation roadmap tracking.

---

## 1. Core Operational Commands

All commands should be executed from within the project directory on the **Ubuntu host server** (or within a WSL 2 Ubuntu shell for local development).

### Stack Deployment & Lifecycle (Doppler Mode)
```bash
# 1. Ensure external gateway network exists
docker network create gateway_net || true

# 2. Start standalone Caddy reverse proxy
cd gateway
docker compose up -d
cd ..

# 3. Configure Doppler project scope (first time or when switching environments)
doppler setup --project silver-worker --config prd

# 4. Start main n8n stack with runtime secret injection
doppler run -- docker compose up -d

# 5. Check container statuses and healthchecks
docker compose ps

# 6. Stream logs across all services
docker compose logs -f

# 7. Stream logs for specific services
docker compose logs -f n8n-worker
docker compose logs -f n8n
docker compose logs -f postgres
```

### Worker Horizontal Scaling
To increase asynchronous workflow execution capacity:
```bash
doppler run -- docker compose up -d --scale n8n-worker=3
```

### Stopping Services
```bash
# Stop n8n application stack
docker compose down

# Stop gateway reverse proxy
cd gateway && docker compose down && cd ..
```

### Database Initialization Reset & Recovery
If PostgreSQL volume state becomes corrupt or requires fresh initialization with updated credentials:
```bash
# WARNING: Deletes all workflow history and credentials from the local database
docker compose down -v
doppler run -- docker compose up -d
```

---

## 2. Host Boot Persistence & Service Management

### Problem & Failure Mode of Native Docker Restart
When the Ubuntu host restarts, the Docker daemon automatically brings up containers based on container restart policies (`restart: always` or `unless-stopped`). However, this daemon boot mechanism **completely bypasses the `doppler run --` runtime injection wrapper**. 

Consequently, containers launch with unpopulated environment variables, causing database authentication failures (`POSTGRES_PASSWORD` missing) and crashing dependent services.

### Systemd Integration Solution (`local-n8n.service`)
To ensure persistent boot recovery with full secret injection, a dedicated host-level `systemd` unit manages the Docker Compose lifecycle on system startup.

The Doppler CLI relies on the pre-configured directory-level token binding scoped to `/home/silver-worker/Local-N8n`, allowing systemd to inject secrets headlessly and non-interactively.

#### Unit File Specification (`/etc/systemd/system/local-n8n.service`)
```ini
[Unit]
Description=Local n8n Stack with Doppler Secrets
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/silver-worker/Local-N8n
User=silver-worker
Group=docker

# Clean up stale containers before starting
ExecStartPre=/usr/bin/docker compose down
# Inject secrets from Doppler directly into Docker Compose at boot
ExecStart=/usr/bin/doppler run -- /usr/bin/docker compose up -d
# Graceful shutdown on host stop/reboot
ExecStop=/usr/bin/docker compose down
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
```

#### Service Registration & Management Commands
```bash
# 1. Reload systemd manager configuration
sudo systemctl daemon-reload

# 2. Enable service to start automatically on system boot
sudo systemctl enable local-n8n.service

# 3. Start service immediately
sudo systemctl start local-n8n.service

# 4. Verify service status and boot logs
sudo systemctl status local-n8n.service
```

---

## 3. Zero-Trust Networking & Firewall Administration

### NordVPN Firewall Conflict Resolution
NordVPN's internal firewall can drop return packets destined for internal Docker bridge networks. If containers cannot reach external APIs:
```bash
# 1. Disable NordVPN internal packet filtering
nordvpn set firewall off

# 2. Restart NordVPN daemon
sudo systemctl restart nordvpnd

# 3. Reconnect NordVPN / Meshnet
nordvpn c
```

### Host UFW Firewall Safeguards
Ubuntu's native UFW must be used as the primary host firewall:
```bash
# Ensure SSH port 22 is explicitly permitted before enabling UFW
sudo ufw allow 22/tcp

# Enable firewall
sudo ufw enable

# Check firewall status
sudo ufw status verbose
```

---

## 4. Client DNS Resolution Runbook

To access services hosted on the server from client laptops/desktops over NordVPN Meshnet:

### A. Host File Configuration
Add the following line to the client machine's hosts file:
- **macOS / Linux**: `/etc/hosts`
- **Windows**: `C:\Windows\System32\drivers\etc\hosts`

```text
100.116.224.88 n8n.local-n8n.com lingua.local-n8n.com
```
*(Replace `100.116.224.88` with your server's static Meshnet IP if altered).*

### B. Flush DNS Cache
- **macOS**:
  ```bash
  sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
  ```
- **Windows (Command Prompt / PowerShell as Admin)**:
  ```cmd
  ipconfig /flushdns
  ```
- **Linux**:
  ```bash
  sudo systemd-resolve --flush-caches
  ```

---

## 5. Implementation Roadmap Tracking (`planning/roadmmap-1.md`)

| Phase | Milestone | Scope / Highlights | Status |
| :---: | :--- | :--- | :---: |
| **Phase 1** | **Central Proxy & Network Backbone** | Standalone Caddy container on `gateway_net`, zero-trust Meshnet IP bindings (`100.116.224.88`, `100.64.153.30`), HTTP/3 UDP 443 support, persistent certificates in `caddy_data`/`caddy_config`. | **Completed** |
| **Phase 2** | **Private n8n Stack Deployment** | Queue mode with Redis Bull queue, PostgreSQL isolation, Doppler CLI runtime secret injection (`doppler run`), execution data pruning (`EXECUTIONS_DATA_PRUNE=true`, 168h retention), log rotation policies. | **Completed** |
| **Phase 3** | **CI/CD Pipeline for Lingua Dev** | Automated deployment via GitHub Actions (`.github/workflows/deploy.yml`) over Meshnet static IP (100.x.x.x), internal network isolation (`lingua_backend`). | **Planned / Next** |
| **Phase 4** | **Resource Management & Guardrails** | Machine learning container memory limits (LibreTranslate 2GB RAM cap), MariaDB/Postgres healthchecks, automated host backup cron (`pg_dump`, `mariadb-dump`). | **Planned** |

---

## 6. Workflows & Code Sandbox Operations

### Exporting & Versioning Workflows
Workflows exported from n8n should be saved in `workflows/<workflow-slug>/` following repository standards:
```bash
# Workflow directory structure:
# workflows/<workflow-slug>/workflow.json (Pretty-printed JSON definition)
# workflows/<workflow-slug>/README.md     (Topology, triggers, credential IDs, test instructions)
```

### Code Sandbox Service Deployment (`sysbox-runc`)
To run the isolated Docker-in-Docker code sandbox alongside the stack:
```bash
# 1. Install sysbox-runc runtime on Ubuntu host (one-time setup)
curl -fsSL -o setup-sysbox.sh https://raw.githubusercontent.com/n8n-io/n8n-sandbox-service/refs/heads/main/scripts/setup-sysbox.sh
chmod +x setup-sysbox.sh && sudo ./setup-sysbox.sh

# 2. Inject SANDBOX_API_KEY into Doppler
doppler secrets set SANDBOX_API_KEY="$(openssl rand -hex 24)" --project silver-worker --config prd

# 3. Start Sandbox Stack
cd sandbox && doppler run -- docker compose up -d
```
