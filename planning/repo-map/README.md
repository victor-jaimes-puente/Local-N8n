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
- **Scalable Queue Mode**: Separates UI/API handling (`n8n`) from asynchronous execution processing (`n8n-worker`) via RedisV Bull queue, supporting horizontal worker scaling.
- **Automated Data Pruning & Log Rotation**: Protects storage volumes via built-in n8n execution pruning (`EXECUTIONS_DATA_PRUNE=true`, 168-hour retention, 50k max count) and Docker daemon JSON log rotation (`max-size: 10m`, `max-file: 3`).
- **Multi-Tenant Gateway Network**: Central external bridge (`gateway_net`) enabling unified reverse proxying for both n8n and companion microservices (such as **Lingua**), plus outbound Cloudflare Tunnel (`cloudflared`) for Slack webhooks.
- **Hardened Host & Network Isolation**: Host UFW firewall defaults to `deny incoming`, SSH port 22 is allowed strictly over the Meshnet interface (`nordlynx`) with password auth disabled, n8n UI binds strictly to loopback (`127.0.0.1:5678`), and public Slack webhook ingress is path-restricted with a 403 Forbidden fallback.

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
├── sandbox/                                 # Isolated n8n Code Sandbox service
│   ├── docker-compose.yaml                  # Sandbox API & Runner compose stack
│   └── README.md                            # Sandbox architecture & systemd service guide
├── searxng/                                 # Self-hosted SearXNG Search Engine
│   ├── docker-compose.yaml                  # SearXNG Compose definition on gateway_net
│   ├── settings.yml                         # SearXNG config (JSON format enabled)
│   └── README.md                            # Service lifecycle & systemd unit guide
├── workflows/                               # Exported n8n workflow JSONs & documentation
│   ├── README.md                            # Workflows directory index
│   ├── meshnet-health-check/                # Meshnet HTTP ingress health probe
│   │   ├── workflow.json                    # Formatted workflow JSON
│   │   └── README.md                        # Flow topology & test instructions
│   └── ai-testing/                          # Local AI testing flow with SearXNG web search
│       ├── workflow.json                    # Formatted workflow JSON (LM Studio + SearXNG tool)
│       └── README.md                        # Flow topology, search integration & cold load docs
├── n8n-mcp/                                 # n8n MCP Server Implementation
│   ├── src/mcp/server.ts                    # MCP Server initialization & resource handlers
│   ├── src/mcp/handlers-n8n-manager.ts      # MCP tool execution logic & security rails
│   └── src/mcp/tools-n8n-manager.ts         # MCP tool definitions
├── .agents/                                 # Antigravity IDE customizations & MCP config
│   ├── mcp_config.json                      # Workspace MCP server configuration
│   ├── sample_mcp_config.json               # Sanitized MCP configuration template
│   ├── skills/
│   │   └── n8n-architect/                   # n8n Workflow Engineering Skill package
│   │       ├── SKILL.md                     # Skill operational execution protocol
│   │       └── resources/                   # Expressions, schemas & workflow patterns
│   └── rules/
│       └── n8n-mcp.md                       # Antigravity workspace rules for n8n MCP
├── AGENTS.md                                # Root agent guidelines & Meshnet n8n guardrails
├── planning/                                # Planning & architecture documentation
│   ├── roadmmap-1.md                        # 4-Phase Meshnet Infrastructure Roadmap
│   ├── n8n-mcp-antigrvity-roadmap.md        # 5-Phase Antigravity MCP integration plan
│   ├── Deploying Self-Hosted n8n Code Sandbox/
│   │   └── plan.md                          # Implementation plan for isolated code sandbox
│   ├── Deploying Self-Hosted SearXNG Search Engine/
│   │   └── plan.md                          # Implementation plan for SearXNG metasearch engine
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

## 3. Remote Host & Agent Connection Model

### Host Specifications
- **Automation Server (`silver-worker`)**: Dell Precision 5480, Ubuntu Server (`7.0.0-30-generic` x86_64) — Meshnet IP `100.116.224.88` (Hosts n8n, Caddy, Postgres, Redis, Sandbox, SearXNG).
- **AI Inference Server (`hulk`)**: High-Performance Compute Host (Windows) — Meshnet IP `100.64.153.30` (Hosts LM Studio OpenAI-compatible local LLM server on port `1234`).
- **Application Root**: `/home/silver-worker/Local-N8n`
- **Sandbox Root**: `/home/silver-worker/Local-N8n/sandbox`
- **SearXNG Root**: `/home/silver-worker/Local-N8n/searxng`

### Connection Method
- **SSH Transport**: Authenticated via Ed25519 public key cryptography (`ssh -i ~/.ssh/id_ed25519 silver-worker@100.116.224.88` or shell alias `silverworker`). Password authentication is disabled on the host (`/etc/ssh/sshd_config.d/99-hardened.conf`), and UFW restricts incoming port 22 strictly to the `nordlynx` interface.
- **Zero-Trust Network**: Remote shell access and cross-node LLM inference traffic are routed exclusively over the private NordVPN Meshnet tunnel, inaccessible from public IP ranges or unauthenticated local Wi-Fi.

### Agent Safeguards & Guardrails
1. **Zero-Disk Secret Policy**: Agents must never commit, output, or write plaintext tokens to `.env` files. Secrets must strictly be managed through Doppler (`silver-worker/prd`).
2. **Execution Quarantining**: Untrusted AI-generated code from the Assistant or Agents is restricted to the `sandbox-api` / `sandbox-runner` containers on `gateway_net` and never executed on the host OS or production database containers.
3. **Safe Workflow Staging**: All newly created workflows must be scaffolded with `active: false` until validation succeeds.
4. **Non-Interactive Deployments**: Container operations must run with `doppler run -- docker compose up -d` non-interactively. Commands requiring interactive `sudo` passwords must be clearly documented for manual execution.

---

## 4. Quick Reference for Agents

| Task / Domain | Key Files to Read / Edit |
| :--- | :--- |
| **Main n8n Stack** | [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml), Doppler project `silver-worker/prd` |
| **Local AI Inference (Hulk)** | `http://100.64.153.30:1234/v1`, [`workflows/ai-testing/`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/), [`ARCHITECTURE.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ARCHITECTURE.md) |
| **Host Boot Persistence** | `/etc/systemd/system/local-n8n.service`, `/etc/systemd/system/local-n8n-sandbox.service`, `/etc/systemd/system/local-n8n-searxng.service` |
| **Database Initialization** | [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh), [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml) |
| **Reverse Proxy & Ingress** | [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml), [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile) |
| **Environment & Secrets** | [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample), [`ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md) |
| **Code Sandbox Stack** | [`sandbox/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/sandbox/docker-compose.yaml), [`sandbox/README.md`](file:///Users/victor/Dev/Local-N8n/sandbox/README.md) |
| **SearXNG Search Engine** | [`searxng/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/searxng/docker-compose.yaml), [`searxng/settings.yml`](file:///Users/victor/Dev/Local-N8n/searxng/settings.yml), [`searxng/README.md`](file:///Users/victor/Dev/Local-N8n/searxng/README.md) |
| **Operations & Runbooks** | [`README.md`](file:///Users/victor/Dev/Local-N8n/README.md), [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md) |
| **Exported Workflows** | [`workflows/README.md`](file:///Users/victor/Dev/Local-N8n/workflows/README.md), [`workflows/meshnet-health-check/`](file:///Users/victor/Dev/Local-N8n/workflows/meshnet-health-check/), [`workflows/ai-testing/`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/) |
| **MCP Server Config** | [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml) (`n8n-mcp`), [`.mcp-sample.json`](file:///Users/victor/Dev/Local-N8n/.mcp-sample.json), `~/.gemini/config/mcp_config.json`, [`call_mcp.js`](file:///Users/victor/Dev/Local-N8n/call_mcp.js) |
| **Agent Rules & Guardrails** | [`AGENTS.md`](file:///Users/victor/Dev/Local-N8n/AGENTS.md), [`.agents/rules/n8n-mcp.md`](file:///Users/victor/Dev/Local-N8n/.agents/rules/n8n-mcp.md) |
| **n8n Architect Skill** | [`.agents/skills/n8n-architect/SKILL.md`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/SKILL.md), [`.agents/skills/n8n-architect/resources/`](file:///Users/victor/Dev/Local-N8n/.agents/skills/n8n-architect/resources/) |
| **Roadmap & Expansion** | [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md), [`planning/n8n-mcp-antigrvity-roadmap.md`](file:///Users/victor/Dev/Local-N8n/planning/n8n-mcp-antigrvity-roadmap.md) |
| **WSL 2 & System Tuning** | [`WSL.md`](file:///Users/victor/Dev/Local-N8n/WSL.md), [`DOCKER-WSL.md`](file:///Users/victor/Dev/Local-N8n/DOCKER-WSL.md) |

---

## 5. Map Navigation

- For **Topology & Architecture**: See [`ARCHITECTURE.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ARCHITECTURE.md).
- For **File Inventory & Purpose**: See [`FILE_MANIFEST.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/FILE_MANIFEST.md).
- For **Environment Variables & Secrets**: See [`ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md).
- For **Operational Workflows & Runbooks**: See [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md).

