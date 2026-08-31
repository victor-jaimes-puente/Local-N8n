# File Manifest & Code Index — Local-N8n

> **Scope**: Complete inventory of every file in the repository, verified line counts, roles, internal blocks, dependencies, and configuration parameters.

---

## 1. Complete File Inventory

| Path | Type | Lines | Role & Description |
| :--- | :--- | :---: | :--- |
| [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml) | YAML | 108 | Primary Docker Compose definition for the scalable n8n queue stack (`postgres`, `redis`, `n8n`, `n8n-worker`). |
| [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh) | Shell | 15 | PostgreSQL entrypoint initialization script creating non-root application user and granting database schema rights. |
| [`.env`](file:///Users/victor/Dev/Local-N8n/.env) | Env | 29 | Local offline development environment fallback file. |
| [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample) | Env | 29 | Doppler secrets schema reference and sanitized template for production variables. |
| [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml) | YAML | 28 | Standalone Caddy reverse proxy Compose file bound strictly to Meshnet IP adapters on `gateway_net`. |
| [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile) | Caddy | 14 | Ingress routing rules for `n8n.local-n8n.com` (with WebSocket flush interval) and `lingua.local-n8n.com`. |
| [`caddy/n8n-docker-caddy/caddy_config/Caddyfile`](file:///Users/victor/Dev/Local-N8n/caddy/n8n-docker-caddy/caddy_config/Caddyfile) | Caddy | 15 | Legacy standalone Caddy configuration mapping `n8n.local.test` to `n8n:5678`. |
| [`README.md`](file:///Users/victor/Dev/Local-N8n/README.md) | Markdown | 130 | Production deployment manual covering NordVPN Meshnet, Doppler injection, systemd boot persistence, and troubleshooting. |
| [`DOCKER-WSL.md`](file:///Users/victor/Dev/Local-N8n/DOCKER-WSL.md) | Markdown | 95 | Detailed integration manual for Docker Desktop and WSL 2 on Windows 11. |
| [`WSL.md`](file:///Users/victor/Dev/Local-N8n/WSL.md) | Markdown | 197 | Comprehensive Ubuntu WSL 2 installation, systemd enablement, networking, and performance tuning guide. |
| [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md) | Markdown | 22 | 4-Phase Infrastructure Roadmap (Central proxy, n8n queue stack, Lingua CI/CD over Meshnet, guardrails). |
| [`planning/n8n-mcp-antigrvity-roadmap.md`](file:///Users/victor/Dev/Local-N8n/planning/n8n-mcp-antigrvity-roadmap.md) | Markdown | 114 | 5-Phase implementation roadmap connecting Antigravity IDE to Meshnet n8n via Model Context Protocol (MCP). |
| [`.agents/sample_mcp_config.json`](file:///Users/victor/Dev/Local-N8n/.agents/sample_mcp_config.json) | JSON | 23 | Sanitized template for Model Context Protocol (MCP) server configuration. |
| [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md) | Markdown | 9 | Root agent guidelines and guardrails for Meshnet n8n workflow management. |
| [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md) | Markdown | 7 | Antigravity workspace customization rules for n8n MCP tool usage. |
| [`mcp_config.json`](file:///Users/victor/Dev/Local-N8n/mcp_config.json) *(Gitignored)* | JSON | 23 | Active MCP server configuration containing credentials (ignored by VCS). |
| `/etc/systemd/system/local-n8n.service` | Systemd | 24 | Host systemd unit managing boot persistence with Doppler runtime secret injection. |
| [`planning/repo-map/README.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/README.md) | Markdown | 75 | Agent entry point, repository architecture summary, and quick reference index. |
| [`planning/repo-map/ARCHITECTURE.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ARCHITECTURE.md) | Markdown | 169 | System topology, Mermaid diagrams, Zero-Trust adapter bindings, systemd boot sequence, and queue lifecycle. |
| [`planning/repo-map/ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md) | Markdown | 78 | Environment variable dictionary, Doppler runtime injection guide, and directory token binding. |
| [`planning/repo-map/FILE_MANIFEST.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/FILE_MANIFEST.md) | Markdown | 108 | Complete file index, line counts, and deep component analysis (This file). |
| [`planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md) | Markdown | 187 | Step-by-step commands, Doppler launch runbook, systemd unit setup, client DNS setup, and roadmap status. |

---

## 2. Deep Component & File Analysis

### A. [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml)
- **Shared Anchor Block (`x-shared`, L10–L46)**:
  - Base Image: `docker.n8n.io/n8nio/n8n` with `restart: always`.
  - Database Configuration: Sets `DB_TYPE=postgresdb`, host `postgres:5432`, referencing database `${POSTGRES_DB}` with non-root credentials `${POSTGRES_NON_ROOT_USER}` and `${POSTGRES_NON_ROOT_PASSWORD}`.
  - Queue Mode: Configures `EXECUTIONS_MODE=queue`, `QUEUE_BULL_REDIS_HOST=redis`, and `QUEUE_HEALTH_CHECK_ACTIVE=true`.
  - Ingress & Security: Injects `N8N_ENCRYPTION_KEY`, public `WEBHOOK_URL`, `N8N_HOST`, `N8N_PORT=5678`, and `N8N_PROTOCOL=https`.
  - Execution Pruning Guardrails: Enforces `EXECUTIONS_DATA_PRUNE=true`, `EXECUTIONS_DATA_MAX_AGE=168` (7 days), and `EXECUTIONS_DATA_PRUNE_MAX_COUNT=50000`.
  - Volumes: Mounts `n8n_storage:/home/node/.n8n` and `n8n_local_files:/files`.
  - Logging Policy: Restricts container logs using `json-file` driver with `max-size: "10m"` and `max-file: "3"`.
  - Health Dependency: Awaits healthy status on both `redis` and `postgres`.
- **Services**:
  - `postgres` (L49–L71): Uses `postgres:16`, mounts `db_storage` and `./init-data.sh`, runs healthcheck `pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}`.
  - `redis` (L73–L88): Uses `redis:6-alpine`, mounts `redis_storage`, runs healthcheck `redis-cli ping`.
  - `n8n` (L90–L97): Main UI & API service, maps host port `5678:5678`, connects to both `default` and external `gateway_net`.
  - `n8n-worker` (L99–L104): Executes `command: worker`, depends on `n8n` main service.
- **Networks (L106–L108)**: Declares `gateway_net` as `external: true`.

### B. [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml)
- Implements the standalone reverse proxy using `caddy:latest` with `restart: unless-stopped`.
- **Zero-Trust Port Bindings (L8–L13)**:
  - `100.116.224.88:80:80`, `100.116.224.88:443:443` (TCP) & `100.116.224.88:443:443/udp` (HTTP/3).
  - `100.64.153.30:80:80`, `100.64.153.30:443:443` (TCP) & `100.64.153.30:443:443/udp` (HTTP/3).
- **Volumes**: Mounts persistent state `caddy_data:/data`, `caddy_config:/config`, and `./Caddyfile:/etc/caddy/Caddyfile`.
- **Network**: Connects to external bridge `gateway_net`.

### C. [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile)
- Global Block: `local_certs` enables Caddy's internal automated TLS certificate authority.
- `n8n.local-n8n.com`: Proxies traffic to `n8n:5678` with `flush_interval -1` (critical for real-time WebSocket communication in n8n's visual workflow canvas).
- `lingua.local-n8n.com`: Proxies traffic to companion service `lingua:3000`.

### D. [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh)
- Executed automatically by PostgreSQL during initial database bootstrap.
- Verifies existence of `${POSTGRES_NON_ROOT_USER}` and `${POSTGRES_NON_ROOT_PASSWORD}`.
- Issues SQL commands via `psql` to create the application user, assign passwords, and grant all privileges on `${POSTGRES_DB}` and schema `public`.

### E. [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample)
- Formal schema reference for Doppler runtime secrets injection.
- Lists variable placeholders for domain routing, timezones, Bull queue host, encryption keys, and database credentials.

### F. [`README.md`](file:///Users/victor/Dev/Local-N8n/README.md)
- Primary deployment and operations runbook for the production server (Ubuntu on Dell Precision 5480).
- Documents Doppler secrets injection (`doppler setup` / `doppler run`), systemd host boot persistence (`local-n8n.service`), client hosts file DNS configuration, NordVPN firewall adjustments (`nordvpn set firewall off`), and database troubleshooting.

### G. [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md)
- 4-Phase strategic plan:
  - **Phase 1 (Completed)**: Standalone Caddy gateway and shared `gateway_net` network.
  - **Phase 2 (Completed)**: Database network isolation, Doppler runtime secrets injection, execution data pruning, and systemd boot persistence.
  - **Phase 3 (Active / Next)**: Headless SSH over Meshnet, GitHub Actions CI/CD for Lingua, and container isolation.
  - **Phase 4 (Planned)**: LibreTranslate memory limits (2GB cap), automated container healthchecks, and host cron backups (`pg_dump`).

### H. Host Service Unit: `/etc/systemd/system/local-n8n.service`
- Systemd oneshot unit operating under user `silver-worker`.
- Awaits `docker.service` and `network-online.target`.
- `ExecStartPre`: Executes `/usr/bin/docker compose down` to clear stale un-injected containers.
- `ExecStart`: Executes `/usr/bin/doppler run -- /usr/bin/docker compose up -d` using directory-scoped token binding.
- `ExecStop`: Executes `/usr/bin/docker compose down` with 60-second shutdown timeout.

### I. [`planning/n8n-mcp-antigrvity-roadmap.md`](file:///Users/victor/Dev/Local-N8n/planning/n8n-mcp-antigrvity-roadmap.md)
- 5-Phase strategic plan for Model Context Protocol (MCP) integration with Antigravity IDE:
  - **Phase 1**: Ingress verification over NordVPN Meshnet adapter (`100.116.224.88`).
  - **Phase 2**: Doppler API key provisioning (`N8N_MCP_API_KEY`).
  - **Phase 3**: Antigravity IDE MCP server configuration (`mcp_config.json`) using Doppler runtime wrapper.
  - **Phase 4**: Agent rules and system guardrails for schema validation, queue awareness, and execution pruning.
  - **Phase 5**: Full-cycle validation and workflow scaffolding verification.

### J. [`mcp_config.json`](file:///Users/victor/Dev/Local-N8n/mcp_config.json)
- MCP server declaration registering `meshnet-n8n` to run `n8n-mcp` via Doppler CLI runtime wrapper (`doppler run --project local-n8n --config prd -- npx -y n8n-mcp`).
- Configures `N8N_HOST=https://n8n.local-n8n.com` and `NODE_TLS_REJECT_UNAUTHORIZED=0` for Caddy internal TLS.

### K. [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md) & [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md)
- Antigravity agent operational guidelines enforcing schema pre-fetching (`get_node_schema`), Queue Mode execution awareness, credential vault separation, inactive staging states (`active: false`), and retention thresholds.
