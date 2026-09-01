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
| [`README.md`](file:///Users/victor/Dev/Local-N8n/README.md) | Markdown | 139 | Production deployment manual covering NordVPN Meshnet, Doppler injection, systemd boot persistence, LM Studio inference, and troubleshooting. |
| [`DOCKER-WSL.md`](file:///Users/victor/Dev/Local-N8n/DOCKER-WSL.md) | Markdown | 95 | Detailed integration manual for Docker Desktop and WSL 2 on Windows 11. |
| [`WSL.md`](file:///Users/victor/Dev/Local-N8n/WSL.md) | Markdown | 197 | Comprehensive Ubuntu WSL 2 installation, systemd enablement, networking, and performance tuning guide. |
| [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md) | Markdown | 22 | 4-Phase Infrastructure Roadmap (Central proxy, n8n queue stack, Lingua CI/CD over Meshnet, guardrails). |
| [`planning/n8n-mcp-antigrvity-roadmap.md`](file:///Users/victor/Dev/Local-N8n/planning/n8n-mcp-antigrvity-roadmap.md) | Markdown | 114 | 5-Phase implementation roadmap connecting Antigravity IDE to Meshnet n8n via Model Context Protocol (MCP). |
| [`planning/Deploying Self-Hosted n8n Code Sandbox/plan.md`](file:///Users/victor/Dev/Local-N8n/planning/Deploying%20Self-Hosted%20n8n%20Code%20Sandbox/plan.md) | Markdown | 139 | Implementation plan and operational guide for isolated `sysbox-runc` Docker code sandbox service (`n8n-sandbox-service`). |
| [`workflows/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/README.md) | Markdown | 22 | Workflows directory index and export standards. |
| [`workflows/meshnet-health-check/workflow.json`](file:///Users/victor/Dev/Local-N8n/workflows/meshnet-health-check/workflow.json) | JSON | 77 | Exported JSON definition for Meshnet-Health-Check workflow. |
| [`workflows/meshnet-health-check/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/meshnet-health-check/README.md) | Markdown | 67 | Documentation and test guide for Meshnet-Health-Check. |
| [`workflows/ai-testing/workflow.json`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/workflow.json) | JSON | 181 | Exported JSON definition for AI-TESTING workflow configured with Hulk LM Studio (`http://100.64.153.30:1234/v1`). |
| [`workflows/ai-testing/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/README.md) | Markdown | 61 | Documentation and architecture for AI-TESTING flow (Interactive Chat & Test Prompt with 6-min cold load tolerance). |
| [`sandbox/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/sandbox/docker-compose.yaml) | YAML | 103 | Isolated n8n Code Sandbox service Compose stack (`sandbox-api`, `sandbox-runner`, `registry`). |
| [`sandbox/README.md`](file:///Users/victor/Dev/Local-N8n/sandbox/README.md) | Markdown | 45 | Code sandbox architecture, systemd service guide, and Doppler secrets integration. |
| [`searxng/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/searxng/docker-compose.yaml) | YAML | 22 | SearXNG metasearch engine Compose definition attached to `gateway_net`. |
| [`searxng/settings.yml`](file:///Users/victor/Dev/Local-N8n/searxng/settings.yml) | YAML | 15 | SearXNG configuration with JSON API format and disabled rate limiting. |
| [`searxng/README.md`](file:///Users/victor/Dev/Local-N8n/searxng/README.md) | Markdown | 66 | SearXNG service guide, JSON verification curl, and systemd persistence. |
| [`planning/Deploying Self-Hosted SearXNG Search Engine/plan.md`](file:///Users/victor/Dev/Local-N8n/planning/Deploying%20Self-Hosted%20SearXNG%20Search%20Engine/plan.md) | Markdown | 150 | Implementation plan and architecture runbook for SearXNG deployment. |
| [`.agents/skills/n8n-architect/SKILL.md`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/SKILL.md) | Markdown | 169 | n8n Architect skill definition, MCP First protocol, tool hierarchy, and node quick reference. |
| [`.agents/skills/n8n-architect/resources/expressions-reference.md`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/resources/expressions-reference.md) | Markdown | 142 | Modern n8n v1+ expression syntax guide (Luxon dates, `$json`, `$item`, JMESPath, binary handling). |
| [`.agents/skills/n8n-architect/resources/core-node-schemas.md`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/resources/core-node-schemas.md) | Markdown | 391 | Production JSON skeletons for If, Switch, Code, HTTP Request, Merge, Aggregate, and ExecuteWorkflow. |
| [`.agents/skills/n8n-architect/resources/workflow-patterns.md`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/resources/workflow-patterns.md) | Markdown | 195 | Production architectural patterns (Webhook ingest/response, API pagination, Sub-workflows, Local AI). |
| [`.agents/mcp_config.json`](file:///Users/victor/Dev/Local-N8n/.agents/mcp_config.json) | JSON | 23 | Workspace MCP server configuration targeting Meshnet n8n instance via Doppler runtime wrapper. |
| [`.agents/sample_mcp_config.json`](file:///Users/victor/Dev/Local-N8n/.agents/sample_mcp_config.json) | JSON | 23 | Sanitized template for Model Context Protocol (MCP) server configuration. |
| [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md) | Markdown | 11 | Root agent guidelines enforcing MCP Server First and Meshnet n8n guardrails. |
| [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md) | Markdown | 9 | Antigravity workspace customization rules for strict n8n MCP tool usage. |
| [`mcp_config.json`](file:///Users/victor/Dev/Local-N8n/mcp_config.json) *(Gitignored)* | JSON | 23 | Active MCP server configuration containing credentials (ignored by VCS). |
| `/etc/systemd/system/local-n8n.service` | Systemd | 24 | Host systemd unit managing n8n core stack boot persistence with Doppler secrets injection. |
| `/etc/systemd/system/local-n8n-sandbox.service` | Systemd | 24 | Host systemd unit managing sandbox service boot persistence with Doppler secrets injection. |
| `/etc/systemd/system/local-n8n-searxng.service` | Systemd | 24 | Host systemd unit managing SearXNG service boot persistence with Doppler secrets injection. |
| [`planning/repo-map/README.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/README.md) | Markdown | 131 | Agent entry point, dual-host architecture summary (Automation & AI Compute), and quick reference index. |
| [`planning/repo-map/ARCHITECTURE.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ARCHITECTURE.md) | Markdown | 257 | System topology, Mermaid diagrams, Meshnet AI inference layer, systemd boot sequence, and agent safeguards. |
| [`planning/repo-map/ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md) | Markdown | 84 | Environment variable dictionary, LM Studio endpoint reference, and Doppler runtime injection guide. |
| [`planning/repo-map/FILE_MANIFEST.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/FILE_MANIFEST.md) | Markdown | 162 | Complete file index, line counts, and deep component analysis (This file). |
| [`planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md) | Markdown | 274 | Step-by-step commands, SSH access, LM Studio operations & port forwarding, systemd unit setup, and roadmap status. |

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

### J. [`planning/Deploying Self-Hosted n8n Code Sandbox/plan.md`](file:///Users/victor/Dev/Local-N8n/planning/Deploying%20Self-Hosted%20n8n%20Code%20Sandbox/plan.md)
- Architecture design and runbook for running `n8n-sandbox-service` on the Ubuntu host:
  - Utilizes `sysbox-runc` for unprivileged micro-container execution.
  - Deploys `sandbox-api` (port 3200), `sandbox-runner`, and `sandbox-registry`.
  - Manages `SANDBOX_API_KEY` via Doppler for secure authenticated n8n code execution.

### K. [`.agents/mcp_config.json`](file:///Users/victor/Dev/Local-N8n/.agents/mcp_config.json) & [`mcp_config.json`](file:///Users/victor/Dev/Local-N8n/mcp_config.json)
- MCP server declaration registering `meshnet-n8n` to run `n8n-mcp` via Doppler CLI runtime wrapper (`doppler run --project silver-worker --config prd -- npx -y n8n-mcp`).
- Configures `N8N_HOST=https://n8n.local-n8n.com` and `NODE_TLS_REJECT_UNAUTHORIZED=0` for Caddy internal TLS.

### L. [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md) & [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md)
- Antigravity agent operational guidelines enforcing schema pre-fetching (`get_node_schema`), Queue Mode execution awareness, credential vault separation, inactive staging states (`active: false`), and retention thresholds.

### M. [`workflows/`](file:///Users/victor/Dev/Local-N8n/workflows/) (Exported Automations)
- **`meshnet-health-check/`**: Webhook probe returning server timestamp, health status, and execution mode over Meshnet tunnel.
- **`ai-testing/`**: Side-by-side comparative inference flow between Local LLM on Hulk (`http://100.64.153.30:1234/v1`) and Google Gemini using OpenAI-compatible connectors.

### N. [`sandbox/`](file:///Users/victor/Dev/Local-N8n/sandbox/) (Code Sandbox Service)
- **`docker-compose.yaml`**: Official companion stack running `sandbox-api` (port 3200), `sandbox-runner`, and `registry` (port 5050), integrated with `gateway_net` and Doppler secrets (`SANDBOX_API_KEY`).
- **`README.md`**: Sandbox service architecture, endpoint health verification, and `/etc/systemd/system/local-n8n-sandbox.service` unit setup.

### O. [`searxng/`](file:///Users/victor/Dev/Local-N8n/searxng/) (Metasearch Engine Service)
- **`docker-compose.yaml`**: Standalone SearXNG service attached to `gateway_net` with aliases `searxng` and `searxng.internal` on port 8080.
- **`settings.yml`**: Metasearch engine configuration with `search.formats: [html, json]` and `server.limiter: false` for n8n AI Assistant search parsing.
- **`README.md`**: Operational manual, JSON output test curl commands, and `/etc/systemd/system/local-n8n-searxng.service` systemd unit setup.

### P. [`planning/Deploying Self-Hosted SearXNG Search Engine/plan.md`](file:///Users/victor/Dev/Local-N8n/planning/Deploying%20Self-Hosted%20SearXNG%20Search%20Engine/plan.md)
- Complete architecture plan, network topology diagram, Doppler secret provisioning, and step-by-step verification runbook for SearXNG.

### Q. Local AI Inference Node (Hulk Compute Host `100.64.153.30`)
- Dedicated compute node running LM Studio with OpenAI-compatible REST server on port `1234`.
- Proxied over Meshnet via Windows `netsh portproxy` for zero-latency local inference from n8n workflows (`http://100.64.153.30:1234/v1`).
- Serves quantized local models (Qwen 3, Gemma 4, Nomic text embeddings) with full privacy and zero egress cost.

### R. [`.agents/skills/n8n-architect/`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/) (n8n Workflow Engineering Skill)
- **`SKILL.md`**: Master Antigravity skill definition, 4-step execution protocol (Introspection &rarr; Topology &rarr; Error Handling &rarr; Diff/Test), and node quick reference table.
- **`resources/expressions-reference.md`**: Authoritative modern v1+ expression syntax guide covering `$json`, `$item`, `$now`, Luxon datetime formatting, JMESPath querying, and binary data handling.
- **`resources/core-node-schemas.md`**: Valid JSON skeletons and parameter dictionaries for core routing and integration nodes (If v2.3, Switch v3.4, Code v2, HTTP Request v4.5, Merge v3.2, Aggregate v1, ExecuteWorkflow v1.3, ErrorTrigger v1).
- **`resources/workflow-patterns.md`**: Standardized production blueprints for Webhook Ingest/Validation/Response, API Pagination, Sub-Workflow Callers, and Local AI Meshnet Inference.


