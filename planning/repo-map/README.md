# Repository Map for AI Agents — Local-N8n

> **Target Audience**: Autonomous Coding & Operations AI Agents
> **Repository Path**: `/Users/victor/Dev/Local-N8n`
> **Primary Stack**: Docker Compose, n8n (Queue Mode), PostgreSQL 16, Redis 6, Caddy (Reverse Proxy), NordVPN Meshnet (Zero-Trust Ingress), Doppler Secret Injection, Ubuntu Server (Dell Precision 5480) / WSL 2.

---

## 1. Executive Summary & Purpose

`Local-N8n` is a production-grade, containerized automation infrastructure running **n8n** in **Queue Mode** with dedicated PostgreSQL 16 and Redis 6 backends, fronted by a **Caddy** reverse proxy. The system is deployed under a **Zero-Trust architecture** on an Ubuntu server (Dell Precision 5480), exposed securely over private **NordVPN Meshnet** tunnels, and fully decoupled from plaintext disk secrets using **Doppler runtime injection**.

Key Architectural Capabilities:
- **Zero-Trust Ingress**: Caddy is bound exclusively to private Meshnet IP interfaces (`100.116.224.88`, `100.64.153.30`) with HTTP/3 UDP 443 support, rendering the server completely invisible to local LAN networks.
- **Dynamic Secret Injection**: Zero disk secrets in production. All environment variables, database passwords, and encryption keys are injected at runtime via Doppler (`doppler run -- docker compose up -d`).
- **Host Boot Persistence (`systemd`)**: A host-level unit (`/etc/systemd/system/local-n8n.service`) automatically launches the stack with Doppler runtime injection upon machine reboots, preventing un-injected credential failures.
- **Scalable Queue Mode**: Separates UI/API handling (`n8n`) from asynchronous execution processing (`n8n-worker`) via Redis Bull queue, supporting horizontal worker scaling.
- **Automated Data Pruning & Log Rotation**: Protects storage volumes via built-in n8n execution pruning (`EXECUTIONS_DATA_PRUNE=true`, 168-hour retention, 50k max count) and Docker daemon JSON log rotation (`max-size: 10m`, `max-file: 3`).
- **Multi-Tenant Gateway Network**: Central external bridge (`gateway_net`) enabling unified reverse proxying for both n8n and companion microservices (such as **Lingua**).

---

## 2. Directory & Component Structure

```
Local-N8n/
├── compose.yaml                             # Main n8n queue stack (Postgres, Redis, n8n, n8n-worker)
├── init-data.sh                             # Postgres non-root DB & user setup script
├── .env / .env-sample                       # Local dev template & Doppler schema reference
├── gateway/                                 # Central reverse proxy stack
│   ├── docker-compose.yaml                  # Standalone Caddy service bound to Meshnet IPs
│   └── Caddyfile                            # Subdomain routing (n8n.local-n8n.com, lingua...)
├── caddy/                                   # Legacy / standalone Caddy configs
│   └── n8n-docker-caddy/
│       └── caddy_config/
│           └── Caddyfile                    # Alternate Caddy configuration (n8n.local.test)
├── workflows/                               # Exported n8n workflow JSONs & documentation
│   ├── README.md                            # Workflows directory index
│   ├── meshnet-health-check/                # Meshnet HTTP ingress health probe
│   │   ├── workflow.json                    # Formatted workflow JSON
│   │   └── README.md                        # Flow topology & test instructions
│   └── ai-testing/                          # Multi-provider AI inference testing flow
│       ├── workflow.json                    # Formatted workflow JSON
│       └── README.md                        # OpenAI-compatible local vs Gemini docs
├── .agents/                                 # Antigravity IDE customizations & MCP config
│   ├── mcp_config.json                      # Workspace MCP server configuration
│   ├── sample_mcp_config.json               # Sanitized MCP configuration template
│   └── rules/
│       └── n8n-mcp.md                       # Antigravity workspace rules for n8n MCP
├── AGENTS.md                                # Root agent guidelines & Meshnet n8n guardrails
├── planning/                                # Planning & architecture documentation
│   ├── roadmmap-1.md                        # 4-Phase Meshnet Infrastructure Roadmap
│   ├── n8n-mcp-antigrvity-roadmap.md        # 5-Phase Antigravity MCP integration plan
│   ├── Deploying Self-Hosted n8n Code Sandbox/
│   │   └── plan.md                          # Implementation plan for isolated code sandbox (sysbox)
│   └── repo-map/                            # Agent Repository Map (This directory)
│       ├── README.md                        # Main navigation & summary index
│       ├── ARCHITECTURE.md                  # Network topology, services & scaling specs
│       ├── FILE_MANIFEST.md                 # Detailed file inventory & line-by-line purpose
│       ├── ENVIRONMENT_AND_SECRETS.md       # Env variables, Doppler integration, credentials
│       └── OPERATIONS_AND_DEPLOYMENT.md     # Commands, lifecycle, WSL2 guide & roadmap summary
├── README.md                                # Deployment guide, Meshnet setup & troubleshooting
├── DOCKER-WSL.md                            # WSL2 & Docker Desktop configuration guide
└── WSL.md                                   # Comprehensive Ubuntu WSL2 setup & tuning guide
```

---

## 3. Quick Reference for Agents

| Task / Domain | Key Files to Read / Edit |
| :--- | :--- |
| **Main n8n Stack** | [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml), Doppler project `silver-worker/prd` |
| **Host Boot Persistence** | `/etc/systemd/system/local-n8n.service`, [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md) |
| **Database Initialization** | [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh), [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml) |
| **Reverse Proxy & Ingress** | [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml), [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile) |
| **Environment & Secrets** | [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample), [`ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md) |
| **Operations & Troubleshooting** | [`README.md`](file:///Users/victor/Dev/Local-N8n/README.md), [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md) |
| **Exported Workflows** | [`workflows/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/README.md), [`workflows/meshnet-health-check/`](file:///Users/victor/Dev/Local-N8n/workflows/meshnet-health-check/), [`workflows/ai-testing/`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/) |
| **Code Sandbox Integration** | [`planning/Deploying Self-Hosted n8n Code Sandbox/plan.md`](file:///Users/victor/Dev/Local-N8n/planning/Deploying%20Self-Hosted%20n8n%20Code%20Sandbox/plan.md) |
| **MCP Server Config** | [`mcp_config.json`](file:///Users/victor/Dev/Local-N8n/mcp_config.json), [`.agents/mcp_config.json`](file:///Users/victor/Dev/Local-N8n/.agents/mcp_config.json) |
| **Agent Rules & Guardrails** | [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md), [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md) |
| **Roadmap & Expansion** | [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md), [`planning/n8n-mcp-antigrvity-roadmap.md`](file:///Users/victor/Dev/Local-N8n/planning/n8n-mcp-antigrvity-roadmap.md) |
| **WSL 2 & System Tuning** | [`WSL.md`](file:///Users/victor/Dev/Local-N8n/WSL.md), [`DOCKER-WSL.md`](file:///Users/victor/Dev/Local-N8n/DOCKER-WSL.md) |

---

## 4. Map Navigation

- For **Topology & Architecture**: See [`ARCHITECTURE.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ARCHITECTURE.md).
- For **File Inventory & Purpose**: See [`FILE_MANIFEST.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/FILE_MANIFEST.md).
- For **Environment Variables & Secrets**: See [`ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md).
- For **Operational Workflows & Runbooks**: See [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md).
