# File Manifest & Code Index — Local-N8n

> **Scope**: Complete inventory of every file in the repository, line counts, purpose, dependencies, and configuration parameters.

---

## 1. Complete File Inventory

| Path | Type | Lines | Role & Description |
| :--- | :--- | :---: | :--- |
| [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml) | YAML | 89 | Primary Docker Compose definition for n8n queue stack (`postgres`, `redis`, `n8n`, `n8n-worker`). |
| [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh) | Shell | 15 | Postgres entrypoint initialization script creating non-root DB user and permissions. |
| [`.env`](file:///Users/victor/Dev/Local-N8n/.env) | Env | 29 | Active local environment variables file containing domain, database passwords, and secrets. |
| [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample) | Env | 28 | Template environment variable file used as a baseline for `.env` / `.env.local`. |
| [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml) | YAML | 24 | Docker Compose specification for the standalone central Caddy reverse proxy on `gateway_net`. |
| [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile) | Caddy | 14 | Ingress proxy routing rules for `n8n.local-n8n.com` and `lingua.local-n8n.com`. |
| [`caddy/n8n-docker-caddy/caddy_config/Caddyfile`](file:///Users/victor/Dev/Local-N8n/caddy/n8n-docker-caddy/caddy_config/Caddyfile) | Caddy | 15 | Alternative local Caddy proxy configuration pointing `n8n.local.test` to `n8n:5678`. |
| [`README.md`](file:///Users/victor/Dev/Local-N8n/README.md) | Markdown | 95 | Developer quickstart guide, prerequisites, Compose commands, and troubleshooting pointers. |
| [`DOCKER-WSL.md`](file:///Users/victor/Dev/Local-N8n/DOCKER-WSL.md) | Markdown | 95 | Detailed integration manual for Docker Desktop and WSL 2 on Windows 11. |
| [`WSL.md`](file:///Users/victor/Dev/Local-N8n/WSL.md) | Markdown | 197 | Complete Ubuntu WSL 2 installation, systemd enablement, networking, and performance tuning guide. |
| [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md) | Markdown | 22 | 4-Phase Meshnet Infrastructure Roadmap (Proxy backbone, n8n stack, Lingua CI/CD, guardrails). |

---

## 2. Deep File Details

### A. [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml)
- **Anchor Block (`x-shared`)**: Lines 9–37 define shared environment variables (`DB_TYPE`, `EXECUTIONS_MODE=queue`, `QUEUE_BULL_REDIS_HOST=redis`, `N8N_ENCRYPTION_KEY`, etc.), volume mounts (`n8n_storage`, `/files`), and healthcheck dependencies (`redis`, `postgres`).
- **Services**:
  - `postgres` (L40–L56): Uses `postgres:16`, mounts `./init-data.sh` to `/docker-entrypoint-initdb.d/init-data.sh`.
  - `redis` (L59–L68): Uses `redis:6-alpine`, mounts `redis_storage`.
  - `n8n` (L71–L78): Main UI service, maps port `5678:5678`, connects to external network `gateway_net`.
  - `n8n-worker` (L80–L85): Worker execution service running `command: worker`.

### B. [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh)
- Executed automatically by PostgreSQL container entrypoint during initial database cluster creation.
- Checks if `${POSTGRES_NON_ROOT_USER}` and `${POSTGRES_NON_ROOT_PASSWORD}` are provided.
- Runs `psql` SQL commands:
  - `CREATE USER ... WITH PASSWORD ...`
  - `GRANT ALL PRIVILEGES ON DATABASE ... TO ...`
  - `GRANT CREATE ON SCHEMA public TO ...`

### C. [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml)
- Runs `caddy:latest` service.
- Binds ports `80` and `443` to the host.
- Connects to external Docker network `gateway_net`.
- Persists state in volumes `caddy_data` and `caddy_config`.

### D. [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile)
- Global option: `local_certs` (generates internal TLS certificates for local domain names).
- Reverse proxy rule 1: `n8n.local-n8n.com` -> `reverse_proxy n8n:5678` with `flush_interval -1` (required for real-time WebSocket communication in n8n UI).
- Reverse proxy rule 2: `lingua.local-n8n.com` -> `reverse_proxy lingua:3000`.

### E. [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md)
- Strategic plan divided into 4 key phases:
  - **Phase 1**: Gateway network setup & standalone Caddy proxy.
  - **Phase 2**: Database network isolation, dynamic Doppler secret injection, execution data pruning (`EXECUTIONS_DATA_PRUNE=true`).
  - **Phase 3**: CI/CD for Lingua over Tailscale/Meshnet IP (100.x.x.x) via GitHub Actions SSH step.
  - **Phase 4**: Machine Learning resource limits (LibreTranslate 2GB cap), container healthchecks, auto database backups (`pg_dump`).
