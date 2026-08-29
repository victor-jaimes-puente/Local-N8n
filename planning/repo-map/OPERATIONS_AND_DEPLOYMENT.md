# Operations & Deployment Manual — Local-N8n

> **Scope**: CLI commands, operational lifecycle, scaling, WSL 2 integration, and implementation roadmap.

---

## 1. Core Operational Commands

All commands should be executed from within the project directory inside the **WSL 2 Ubuntu shell**.

### Stack Management
```bash
# 1. Ensure external gateway network exists
docker network create gateway_net || true

# 2. Start gateway reverse proxy (optional if running multi-tenant)
docker compose -f gateway/docker-compose.yaml up -d

# 3. Start main n8n stack in background
docker compose up -d

# 4. View container status
docker compose ps

# 5. Stream logs for all services
docker compose logs -f

# 6. Stream logs for a specific service (e.g. worker or n8n)
docker compose logs -f n8n-worker
docker compose logs -f postgres

# 7. Stop stack
docker compose down
```

### Worker Horizontal Scaling
To increase background execution throughput in Queue Mode:
```bash
docker compose up -d --scale n8n-worker=3
```

### Database Initialization Reset
To trigger `init-data.sh` execution again (WARNING: Destroys PostgreSQL database data):
```bash
docker compose down -v
docker volume rm Local-N8n_db_storage
docker compose up -d
```

---

## 2. WSL 2 & Windows 11 Integration Rules

1. **Filesystem Location**:
   - Store code inside the native Linux filesystem (e.g., `/Users/...` or `~/Dev/Local-N8n`).
   - Avoid keeping active code on Windows mounts (`/mnt/c/...`) to prevent slow I/O performance.

2. **Domain Resolution (Windows Hosts File)**:
   - To access n8n via browser on Windows (`https://n8n.local-n8n.com` or `https://n8n.local.test`), add mapping to `C:\Windows\System32\drivers\etc\hosts`:
     ```text
     127.0.0.1 n8n.local-n8n.com
     127.0.0.1 n8n.local.test
     ```

3. **Caddy Local TLS**:
   - `gateway/Caddyfile` uses `local_certs` mode. On first access, accept the auto-generated TLS certificate in your browser.

---

## 3. Implementation Roadmap Summary (`planning/roadmmap-1.md`)

- **Phase 1: Central Proxy & Network Backbone**
  - Create external network `gateway_net`.
  - Deploy global Caddy container with volume mounts (`caddy_data`, `caddy_config`).
  - Configure subdomain reverse proxying (`n8n.local-n8n.com` & `lingua.local-n8n.com`).

- **Phase 2: Private n8n Stack Deployment**
  - Segregate PostgreSQL on internal backend network (`n8n_backend`).
  - Integrate Doppler CLI runtime secret injection (`doppler run -- docker compose up -d`).
  - Enable n8n data pruning (`EXECUTIONS_DATA_PRUNE=true`, `EXECUTIONS_DATA_MAX_AGE=168`).

- **Phase 3: CI/CD Pipeline for Lingua Dev via GitHub Actions**
  - SSH deployment over Tailscale/Meshnet static IP (`100.x.x.x`).
  - GitHub Actions workflow (`.github/workflows/deploy.yml`) executing `docker compose up -d --build`.
  - Dedicated internal network for Lingua backend services (`lingua_backend`).

- **Phase 4: Resource Management & Guardrails**
  - Resource limits on heavy containers (e.g., LibreTranslate capped at 2GB RAM).
  - Healthcheck directives (`pg_isready`, `mysqladmin ping`).
  - Host cron job for automated database dumps (`pg_dump`).
