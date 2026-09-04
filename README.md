# Local n8n over NordVPN Meshnet (Docker Compose)

This repository contains the deployment configuration and workflow definitions for running a private n8n stack and Lingua application on an Ubuntu server (Dell Precision 5480), securely accessible over a NordVPN Meshnet tunnel using a Zero-Trust architecture.

---

## Repository Map

```
Local-N8n/
├── README.md                          # Main deployment & architectural documentation
├── compose.yaml                       # Core Docker Compose definition (n8n, worker, postgres, redis)
├── mcp_config.json                    # Antigravity / Claude MCP server connection profile
├── caddy/                             # Caddy reverse proxy configurations
├── docs/                              # Disaster Recovery runbooks and host rebuild guides
├── gateway/                           # Standalone Meshnet Caddy gateway Docker Compose stack
├── planning/                          # Architectural roadmaps and implementation designs
├── sandbox/                           # Execution sandbox configurations
├── scripts/                           # Local helpers, backup orchestrators & host state gathering
├── searxng/                           # Self-hosted SearXNG search engine settings
├── server-scripts/                    # Operational control scripts (start-all, stop-all, status-all)
├── systemd/                           # Systemd service unit files for boot persistence
└── workflows/                         # Version-controlled n8n workflow definitions
    ├── README.md                      # Comprehensive workflow catalog & map
    ├── ai-testing/                    # Local LLM prompt & chat evaluation workflow
    ├── meshnet-health-check/          # Zero-trust health probe endpoint
    ├── slack/                         # Slack ingress router & webhook dispatcher
    ├── slack-ai-agent/                # Threaded conversational Slack AI sub-workflow
    └── tool-searxng-search/           # Reusable SearXNG web search tool workflow
```

---

## Architecture & Networking Overview

The infrastructure operates with the following core configurations:

### 1. Secret Management & Container Initialization
- **Doppler Runtime Injection:** Environment variables are not stored in a local `.env` file on disk. Instead, secrets are injected directly into memory at runtime using the `doppler run -- docker compose ...` wrapper.
- **Zero-Disk Secret Policy:** Workflow definitions reference secure Credential IDs within the PostgreSQL vault without embedding plaintext tokens or keys on disk.

### 2. Client DNS & Host File Overrides
- **Custom Subdomains:** Local hosts files on client machines map the custom subdomains (`n8n.local-n8n.com` and `lingua.local-n8n.com`) directly to the server's static Meshnet IP (`100.116.224.88`).

### 3. Network Security & Firewall Adjustments
- **NordVPN Firewall:** NordVPN's internal firewall is disabled (`nordvpn set firewall off`) to permit return packets across Docker's internal subnet.
- **UFW Native Firewall:** Ubuntu's native UFW acts as the primary firewall, strictly allowing SSH and Meshnet traffic.

### 4. Zero-Trust Gateway Binding
- **Meshnet Exclusivity:** The Caddy reverse proxy (`gateway/docker-compose.yaml`) binds exclusively to the Meshnet interface (`100.116.224.88:443:443`), making the server invisible on the local LAN.

---

## Workflow Catalog

| Directory | Workflow | Remote ID | Primary Trigger | Description |
| :--- | :--- | :--- | :--- | :--- |
| [`workflows/slack/`](./workflows/slack/) | `Slack` | `8irpSdMtOgDVxsSb` | Webhook (`POST /slack-events`) | Public Slack ingress router with immediate 200 OK acknowledgment and bot loop filtering. |
| [`workflows/slack-ai-agent/`](./workflows/slack-ai-agent/) | `slack-ai-agent` | `Fq6gdZ5X10eOiCQA` | Sub-Workflow Trigger | Conversational AI sub-workflow powered by Hulk LM Studio, Window Buffer Memory, and SearXNG. |
| [`workflows/ai-testing/`](./workflows/ai-testing/) | `AI-TESTING` | `5rRB16PM6Tx07ZB0` | Chat / Manual Test | Local LLM chat and manual prompt evaluation playground on Hulk. |
| [`workflows/tool-searxng-search/`](./workflows/tool-searxng-search/) | `Tool-SearXNG-Search` | `hk8OViFZWBnveSCF` | Sub-Workflow Trigger | Reusable AI Agent Web Search Tool executing live queries against local SearXNG (`http://searxng:8080`). |
| [`workflows/meshnet-health-check/`](./workflows/meshnet-health-check/) | `Meshnet-Health-Check` | `XRDcHq3GIEZQKprT` | Webhook (`GET /meshnet-health-check`) | Health probe validating HTTP ingress, Redis Bull queue scheduling, and PostgreSQL recording. |

---

## Local AI Inference & Web Search over Meshnet

### 1. LM Studio Local LLM Server (Hulk `100.64.153.30`)
- **Compute Host (`hulk`)**: `100.64.153.30` running LM Studio on port `1234` (RTX 4070).
- **OpenAI-Compatible Base URL**: `http://100.64.153.30:1234/v1`
- **Workflow Integration**: Connected via `@n8n/n8n-nodes-langchain.lmChatOpenAi` with `timeout: 360000` (6 minutes) to tolerate cold loads.

### 2. Self-Hosted SearXNG Search Engine
- **Service**: Standalone SearXNG container on `gateway_net` (`http://searxng:8080`).
- **AI Agent Tool**: Connected to LangChain `AI Agent` via `@n8n/n8n-nodes-langchain.toolCode` to fetch real-time web results with zero external API fees.

---

## Model Context Protocol (MCP) Integration

Antigravity IDE and external AI agents interface directly with the private n8n instance using the community [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp) server.

```
┌───────────────────────────┐         NordVPN Meshnet         ┌────────────────────────────────────────────────────────┐
│      Developer Mac        │        (100.116.224.88)         │              Ubuntu Host (silver-worker)               │
│                           │                                 │                                                        │
│  Antigravity IDE / CLI    │                                 │  Docker Stack (compose.yaml)                           │
│  ~/.gemini/config/        │                                 │                                                        │
│    mcp_config.json        │ ──(HTTP/SSE :3001 or stdio)───> │  ┌──────────────────────────────────────────────────┐  │
│                           │                                 │  │ local-n8n-n8n-mcp-1 (czlonkowski/n8n-mcp:latest) │  │
│  call_mcp.js (test harness│                                 │  │ - PORT: 3001                                     │  │
│    using .env secrets)    │                                 │  │ - Bound to: 100.116.224.88:3001                  │  │
│                           │                                 │  └───────────────┬──────────────────────────────────┘  │
│                           │                                 │                  │ Internal Gateway / Caddy            │
│                           │                                 │                  ▼                                     │
│                           │                                 │  ┌──────────────────────────────────────────────────┐  │
│                           │                                 │  │ n8n Core API (https://n8n.local-n8n.com)         │  │
│                           │                                 │  └──────────────────────────────────────────────────┘  │
└───────────────────────────┘                                 └────────────────────────────────────────────────────────┘
```

### 1. Server Deployment (`compose.yaml`)
The MCP container is deployed on the `silver-worker` host and bound strictly to the private Meshnet IP:
```yaml
  n8n-mcp:
    image: ghcr.io/czlonkowski/n8n-mcp:latest
    restart: always
    environment:
      - N8N_API_URL=${N8N_API_URL}
      - N8N_API_KEY=${N8N_API_KEY}
      - MCP_AUTH_TOKEN=${MCP_AUTH_TOKEN}
      - AUTH_TOKEN=${MCP_AUTH_TOKEN}
      - MCP_MODE=http
      - PORT=3001
    ports:
      # Docker Interface Bind Trick: Exclusively bind to the Meshnet adapter
      - "${MESHNET_IP}:3001:3001"
    networks:
      - default
      - gateway_net
```

### 2. Doppler Secret Configuration
All required MCP secrets are managed centrally in Doppler (`silver-worker/prd`):
- `MESHNET_IP`: Host Meshnet address (`100.116.224.88`).
- `N8N_API_URL`: n8n ingress endpoint (`https://n8n.local-n8n.com`).
- `N8N_API_KEY`: n8n Public API key generated under **Settings > n8n API**.
- `MCP_AUTH_TOKEN`: Shared bearer token protecting the MCP HTTP/SSE endpoints.

### 3. Client IDE Setup (`mcp_config.json`)
Client configurations use the sanitized template [`.mcp-sample.json`](./.mcp-sample.json).

* **Global Antigravity IDE**: Place in `/Users/victor/.gemini/config/mcp_config.json`:
```json
{
  "mcpServers": {
    "meshnet-n8n": {
      "command": "npx",
      "args": ["-y", "n8n-mcp@latest"],
      "env": {
        "N8N_API_URL": "https://n8n.local-n8n.com",
        "N8N_HOST": "https://n8n.local-n8n.com",
        "N8N_API_KEY": "<YOUR_N8N_API_KEY>",
        "WEBHOOK_SECURITY_MODE": "permissive",
        "NODE_TLS_REJECT_UNAUTHORIZED": "0"
      }
    }
  }
}
```
> **Critical Setting**: `"WEBHOOK_SECURITY_MODE": "permissive"` is required to prevent `n8n-mcp` SSRF protection from blocking Meshnet/CGNAT (`100.x.x.x`) IP ranges.

### 4. Operational Commands & Testing
- **Test Server Health**:
  ```bash
  curl -s http://100.116.224.88:3001/health
  ```
- **Run Standalone JSON-RPC Test Harness**:
  ```bash
  node call_mcp.js
  ```
- **Restart MCP Server**:
  ```bash
  bash scripts/restart-mcp.sh
  ```
  *(Then in Antigravity IDE press `Cmd + Shift + P` -> `Developer: Reload Window`).*
- **View Container Logs**:
  ```bash
  ssh silverworker "docker logs -f local-n8n-n8n-mcp-1"
  ```

---

## Deployment & Service Control

### Host Boot Persistence (Systemd Service)
Managed by `/etc/systemd/system/local-n8n.service`:

```bash
sudo systemctl status local-n8n.service
```

### Operational Scripts
Located in `server-scripts/`:
- `./server-scripts/status-all.sh`: Check health of all containers and services.
- `./server-scripts/restart-all.sh`: Clean restart of the entire Docker stack with Doppler injection.
- `./server-scripts/logs.sh`: View real-time logs for n8n, worker, redis, or postgres.
- `node scripts/export-workflows.js`: Pull all latest workflow definitions from n8n API into version control.

### Automated Backup Strategy
- **Zero-Trust Mac Pull**: A macOS orchestrator script (`scripts/backup-pull.sh`) connects via Meshnet SSH to pull live PostgreSQL dumps, compressed Docker volumes, and server configuration files.
- **Host Configuration State (Phase 2)**: Uses `scripts/gather-host-state.sh` (executed via passwordless sudo) to snapshot the Ubuntu environment (APT packages, `/etc`, user dotfiles) for lightweight bare-metal disaster recovery.
- **Disaster Recovery**: Detailed bare-metal recovery steps are documented in `docs/DR-HOST-REBUILD.md`.
