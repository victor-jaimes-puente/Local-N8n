# File Manifest & Code Index — Local-N8n

> **Scope**: Complete inventory of every file in the repository, verified line counts, roles, internal blocks, dependencies, and configuration parameters.

---

## 1. Complete File Inventory

| Path | Type | Lines | Role & Description |
| :--- | :--- | :---: | :--- |
| [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml) | YAML | 127 | Primary Docker Compose definition for the n8n stack (`postgres`, `redis`, `n8n`, `n8n-mcp`) configured with native Agents (`N8N_ENABLED_MODULES=agents,instance-ai`) and loopback UI binding. |
| [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh) | Shell | 15 | PostgreSQL entrypoint initialization script creating non-root application user and granting database schema rights. |
| [`.env`](file:///Users/victor/Dev/Local-N8n/.env) | Env | 29 | Local offline development environment fallback file. |
| [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample) | Env | 29 | Doppler secrets schema reference and sanitized template for production variables. |
| [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml) | YAML | 32 | Gateway Compose stack running Caddy (Meshnet IP bound) and `cloudflared` tunnel for public Slack ingress on `gateway_net`. |
| [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile) | Caddy | 32 | Hardened ingress routing rules with path-restricted Slack webhooks (403 fallback) and Meshnet internal routing (`n8n.local-n8n.com`, `lingua...`). |
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
| [`workflows/ai-testing/workflow.json`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/workflow.json) | JSON | 215 | Exported JSON definition for AI-TESTING workflow configured with Hulk LM Studio (`http://100.64.153.30:1234/v1`), multi-agent comparison, and SearXNG Web Search tool (`toolWorkflow`). |
| [`workflows/ai-testing/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/README.md) | Markdown | 58 | Documentation and architecture for AI-TESTING flow (Interactive Chat & Test Prompt with SearXNG sub-workflow tool & 6-min cold load tolerance). |
| [`workflows/tool-searxng-search/workflow.json`](file:///Users/victor/Dev/Local-N8n/workflows/tool-searxng-search/workflow.json) | JSON | 55 | Exported JSON definition for Tool-SearXNG-Search sub-workflow (`executeWorkflowTrigger` + `httpRequest` to SearXNG). |
| [`workflows/tool-searxng-search/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/tool-searxng-search/README.md) | Markdown | 35 | Documentation for Tool-SearXNG-Search sub-workflow tool. |
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
| [`.mcp-sample.json`](file:///Users/victor/Dev/Local-N8n/.mcp-sample.json) | JSON | 33 | Sanitized template for Model Context Protocol (MCP) configuration (Remote SSE on port 3001 & local stdio). |
| [`call_mcp.js`](file:///Users/victor/Dev/Local-N8n/call_mcp.js) *(Gitignored)* | JavaScript | 80 | Headless CLI test harness running JSON-RPC handshake and `n8n_list_workflows` against live n8n instance via `.env`. |
| [`scripts/restart-mcp.sh`](file:///Users/victor/Dev/Local-N8n/scripts/restart-mcp.sh) | Shell | 9 | Process utility terminating stale `n8n-mcp` instances to trigger fresh Antigravity IDE connection. |
| [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md) | Markdown | 11 | Root agent guidelines enforcing MCP Server First and Meshnet n8n guardrails. |
| [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md) | Markdown | 9 | Antigravity workspace customization rules for strict n8n MCP tool usage. |
| [`mcp_config.json`](file:///Users/victor/Dev/Local-N8n/mcp_config.json) *(Gitignored)* | JSON | 18 | Local active MCP server configuration (ignored by VCS). |
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
  - Base Image: `docker.n8n.io/n8nio/n8n:latest` with `restart: always`.
  - Database Configuration: Sets `DB_TYPE=postgresdb`, host `postgres:5432`, referencing database `${POSTGRES_DB}` with non-root credentials `${POSTGRES_NON_ROOT_USER}` and `${POSTGRES_NON_ROOT_PASSWORD}`.
  - Execution Architecture & Modules: Configures `EXECUTIONS_MODE=regular` and `N8N_ENABLED_MODULES=agents,instance-ai` to activate the standalone Agents tab, chat connections, episodic memory, RAG, and sub-agent engine during preview.
  - Ingress & Security: Injects `N8N_ENCRYPTION_KEY`, public `WEBHOOK_URL`, `N8N_WEBHOOK_URL`, `N8N_HOST`, `N8N_PORT=5678`, and `N8N_PROTOCOL=https`.
  - Execution Pruning Guardrails: Enforces `EXECUTIONS_DATA_PRUNE=true`, `EXECUTIONS_DATA_MAX_AGE=168` (7 days), and `EXECUTIONS_DATA_PRUNE_MAX_COUNT=50000`.
  - Volumes: Mounts `n8n_storage:/home/node/.n8n` and `n8n_local_files:/files`.
  - Logging Policy: Restricts container logs using `json-file` driver with `max-size: "10m"` and `max-file: "3"`.
  - Health Dependency: Awaits healthy status on both `redis` and `postgres`.
- **Services**:
  - `postgres` (L49–L71): Uses `postgres:16`, mounts `db_storage` and `./init-data.sh`, runs healthcheck `pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}`.
  - `redis` (L73–L88): Uses `redis:6-alpine`, mounts `redis_storage`, runs healthcheck `redis-cli ping`.
  - `n8n` (L90–L97): Main UI, API & Agent service, maps host port `127.0.0.1:5678:5678` (loopback only to protect LAN), connects to both `default` and external `gateway_net`.
  - `n8n-worker` (L99–L105): Paused (commented out) while running regular mode for the Agents preview.
  - `n8n-mcp` (L107–L123): Community MCP server bound to `${MESHNET_IP}:3001:3001`.
- **Networks (L125–L127)**: Declares `gateway_net` as `external: true`.

### B. [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml)
- Implements the standalone reverse proxy using `caddy:latest` and the outbound Cloudflare Tunnel using `cloudflare/cloudflared:latest`.
- **Zero-Trust Port Bindings (L5–L8)**:
  - `100.116.224.88:80:80`, `100.116.224.88:443:443` (TCP) & `100.116.224.88:443:443/udp` (HTTP/3).
- **Public Tunnel**: `cloudflared` runs `tunnel --no-autoupdate run` using `CLOUDFLARE_TUNNEL_TOKEN` on `gateway_net` with zero open router ports.
- **Volumes**: Mounts persistent state `caddy_data:/data`, `caddy_config:/config`, and `./Caddyfile:/etc/caddy/Caddyfile`.
- **Network**: Connects to external bridge `gateway_net`.

### C. [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile)
- Global Block: `local_certs` enables Caddy's internal automated TLS certificate authority.
- `webhook.tiranotech.com`: Hardened public webhook proxy routing `/webhook/*` and `/webhook-test/*` to `n8n:5678`, dropping all other routes with HTTP 403 Forbidden.
- `n8n.local-n8n.com`: Proxies traffic to `n8n:5678` over Meshnet with `flush_interval -1` (critical for real-time WebSocket communication in n8n's visual workflow canvas).
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

### K. [`.mcp-sample.json`](file:///Users/victor/Dev/Local-N8n/.mcp-sample.json) & [`call_mcp.js`](file:///Users/victor/Dev/Local-N8n/call_mcp.js)
- **`.mcp-sample.json`**: Standardized MCP template defining both remote SSE (`http://100.x.x.x:3001/mcp`) and local stdio integration using `npx -y n8n-mcp@latest`.
- **`call_mcp.js`**: Diagnostic JSON-RPC test client that runs the MCP initialization handshake and executes tool calls against live n8n using `.env` credentials with `WEBHOOK_SECURITY_MODE=permissive`.
- **`mcp_config.json`** *(Gitignored)*: Local client configuration loaded by Antigravity IDE (`~/.gemini/config/mcp_config.json`).

### L. [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md) & [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md)
- Antigravity agent operational guidelines enforcing schema pre-fetching (`get_node`), Queue Mode execution awareness, credential vault separation, inactive staging states (`active: false`), and retention thresholds.

### M. [`workflows/`](file:///Users/victor/Dev/Local-N8n/workflows/) (Exported Automations)
- **`meshnet-health-check/`**: Webhook probe returning server timestamp, health status, and execution mode over Meshnet tunnel.
- **`ai-testing/`**: Interactive chat and manual prompt evaluation workflow connecting local LLMs on Hulk (`http://100.64.153.30:1234/v1`) with our self-hosted SearXNG metasearch engine (`http://searxng:8080`) for real-time web search capabilities.
- **`tool-searxng-search/`**: Dedicated sub-workflow (`Tool-SearXNG-Search` / `hk8OViFZWBnveSCF`) serving as a reusable AI Agent Web Search Tool via SearXNG JSON API.

### N. [`sandbox/`](file:///Users/victor/Dev/Local-N8n/sandbox/) (Code Sandbox Service)
- **`docker-compose.yaml`**: Official companion stack running `sandbox-api` (port 3200), `sandbox-runner`, and `registry` (port 5050), integrated with `gateway_net` and Doppler secrets (`SANDBOX_API_KEY`).
- **`README.md`**: Sandbox service architecture, endpoint health verification, and `/etc/systemd/system/local-n8n-sandbox.service` unit setup.

### G. Community n8n-mcp Server (`compose.yaml`)
- **Container**: `local-n8n-n8n-mcp-1` (`ghcr.io/czlonkowski/n8n-mcp:latest`).
- **Interface Binding**: Exclusively bound to the NordVPN Meshnet adapter (`100.116.224.88:3001:3001`) with internal `PORT=3001` and `MCP_MODE=http`.
- **Runtime Secret Injection**: Pulls `N8N_API_URL`, `N8N_API_KEY`, and `MCP_AUTH_TOKEN` from Doppler at boot.
- **SSRF Compatibility**: Requires `WEBHOOK_SECURITY_MODE=permissive` on clients connecting to `100.x.x.x` Meshnet addresses.

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


