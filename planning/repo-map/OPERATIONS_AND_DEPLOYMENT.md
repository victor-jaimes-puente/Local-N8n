# Operations & Deployment Manual — Local-N8n

> **Scope**: CLI commands, Doppler production workflows, Zero-Trust network administration, client DNS configuration, scaling, and implementation roadmap tracking.

---

## 1. Core Operational Commands

All commands should be executed on the **Ubuntu host server** (`silver-worker` on Dell Precision 5480).

### Remote Host SSH Access
From the developer workstation:
```bash
# Direct SSH over private NordVPN Meshnet tunnel:
ssh -i ~/.ssh/id_ed25519 silver-worker@100.116.224.88

# Or using the local shell alias:
silverworker
```

### Stack Deployment & Lifecycle (Doppler Mode)
```bash
# 1. Navigate to project root
cd /home/silver-worker/Local-N8n

# 2. Ensure external gateway network exists
docker network create gateway_net || true

# 3. Start standalone Caddy reverse proxy
cd gateway && docker compose up -d && cd ..

# 4. Configure Doppler project scope (first time or when switching environments)
doppler setup --project silver-worker --config prd

# 5. Start main n8n stack with runtime secret injection
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

### Host UFW Firewall Safeguards (Hardened Meshnet Ingress)
Ubuntu's native UFW must be used as the primary host firewall, scoped strictly to the Meshnet adapter (`nordlynx`):
```bash
# 1. Ensure default deny on incoming traffic, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 2. Allow SSH strictly on the Meshnet interface (nordlynx)
sudo ufw allow in on nordlynx to any port 22 proto tcp

# 3. If port 22 was previously open to 0.0.0.0, remove the open rule
sudo ufw delete allow 22/tcp || true

# 4. Enable firewall & reload
sudo ufw enable
sudo ufw reload

# 5. Check firewall status
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

### Code Sandbox Service Deployment
To run the isolated Docker-in-Docker code sandbox alongside the stack:
```bash
# 1. Inject SANDBOX_API_KEY into Doppler
doppler secrets set SANDBOX_API_KEY="$(openssl rand -hex 24)" --project silver-worker --config prd

# 2. Start Sandbox Stack
cd sandbox && doppler run -- docker compose up -d
```

### SearXNG Search Engine Service Deployment
To run the self-hosted SearXNG metasearch engine for n8n AI Assistant:
```bash
# 1. Provision secret in Doppler
doppler secrets set SEARXNG_SECRET_KEY="$(openssl rand -hex 32)" --project silver-worker --config prd

# 2. Start SearXNG Stack
cd searxng && doppler run -- docker compose up -d

# 3. Test JSON Search Output
curl "http://100.116.224.88:8088/search?q=n8n&format=json"
```

---

## 7. Local AI Inference & LM Studio Operations (Hulk `100.64.153.30`)

### A. LM Studio Local Server Setup on Hulk
1. Open **LM Studio** on the `hulk` machine (`100.64.153.30`).
2. Navigate to the **Developer / Local Server** tab (`<->` icon).
3. Under Server Settings:
   - Ensure **Port** is set to `1234`.
   - Ensure **CORS** is enabled.
   - Load desired LLM or embedding models into GPU/RAM (or enable JIT / auto-loading).

### B. Windows Port Forwarding & Firewall Setup
If LM Studio is bound to `127.0.0.1`, bridge incoming Meshnet traffic directly to the local server:
```powershell
# Run in Administrator PowerShell / Command Prompt on Hulk:

# 1. Add port forwarding from all interfaces to local LM Studio
netsh interface portproxy add v4tov4 listenport=1234 listenaddress=0.0.0.0 connectport=1234 connectaddress=127.0.0.1

# 2. Allow inbound TCP traffic on port 1234 in Windows Firewall
New-NetFirewallRule -DisplayName "LM Studio Meshnet" -Direction Inbound -LocalPort 1234 -Protocol TCP -Action Allow
```

### C. Verify Connectivity from Automation Host (`silver-worker`)
From `silver-worker` or any Meshnet client, query the OpenAI-compatible `/v1/models` endpoint:
```bash
curl http://100.64.153.30:1234/v1/models
```
*Expected output: JSON array containing active models (`qwen/qwen3-14b`, `google/gemma-4-26b-a4b-qat`, etc.).*

### D. Workflow Configuration in n8n
1. In n8n (`https://n8n.local-n8n.com`), create an **OpenAI API** credential:
   - **Credential Name**: `OpenAI account` (or `Hulk LM Studio`)
   - **API Key**: `lm-studio` (or valid token)
2. Add an **OpenAI Chat Model** (`@n8n/n8n-nodes-langchain.lmChatOpenAi`) node:
   - **Credential**: `OpenAI account`
   - **Model**: Model name (e.g. `qwen/qwen3.6-35b-a3b` or `google/gemma-4-26b-a4b-qat`)
   - **Options -> Base URL**: `http://100.64.153.30:1234/v1`
   - **Timeout**: `360000` (6 minutes for cold model loading)

### E. SearXNG AI Agent Web Search Integration
To grant local AI agents real-time web search capabilities:
1. Connect a **Custom Code Tool** (`@n8n/n8n-nodes-langchain.toolCode` v1.1) to the `ai_tool` input of the `AI Agent` node.
2. Enable explicit input schema (`specifyInputSchema: true`) with JSON Schema:
   ```json
   {
     "type": "object",
     "properties": {
       "query": {
         "type": "string",
         "description": "The search query string to look up on the web"
       }
     },
     "required": ["query"]
   }
   ```
3. Provide JavaScript execution logic using native async `fetch`:
   ```javascript
   const searchTarget = (typeof query !== "undefined" && query) ? query : ((typeof input !== "undefined" && input) ? input : "news");
   const q = encodeURIComponent(searchTarget);

   try {
     const response = await fetch(`http://searxng:8080/search?q=${q}&format=json`);
     const data = await response.json();
     const results = (data.results || []).slice(0, 5).map((r, i) => `${i+1}. [${r.title}](${r.url})\n${r.content}`).join("\n\n");
     return results || "No results found.";
   } catch (err) {
     return `Error querying SearXNG: ${err.message}`;
   }
   ```

### F. Critical LangChain Tool Debugging Rules
- **Do not use `$fromAI()` inside JavaScript `jsCode`**: `$fromAI()` is an n8n expression macro for UI property fields (e.g. `{{ $fromAI(...) }}`). It does not exist in the JavaScript VM scope. Calling it will throw an unhandled reference exception and cause `NodeOperationError: No execution data available`.
- **Prefer `toolCode` over `toolHttpRequest` in n8n v2.36.x**: In current n8n 2.x releases, `toolHttpRequest` may throw `The node has a supplyData method but no execute method` when invoked at runtime. `toolCode` with `specifyInputSchema: true` executes reliably and allows clean formatting of search snippets.

---

## 8. Model Context Protocol (MCP) Server Operations

The stack runs the community `czlonkowski/n8n-mcp` service on the `silver-worker` host, bound exclusively to the NordVPN Meshnet IP (`100.116.224.88:3001`).

### A. Lifecycle Commands (Host Server)
```bash
# 1. Deploy/restart n8n-mcp with Doppler secrets
cd /home/silver-worker/Local-N8n
doppler run -- docker compose up -d n8n-mcp

# 2. Check container status & health
docker compose ps n8n-mcp

# 3. Stream container logs
docker compose logs -f n8n-mcp

# 4. Stop service
docker compose stop n8n-mcp
```

### B. Health Verification
From any authorized Meshnet client:
```bash
curl -s http://100.116.224.88:3001/health
# Expected: {"status":"ok","version":"2.82.1","uptime":...,"timestamp":"..."}
```

### C. Client Configuration & Management
1. **Config Template**: Copy [`.mcp-sample.json`](file:///Users/victor/Dev/Local-N8n/.mcp-sample.json) into `~/.gemini/config/mcp_config.json`.
2. **SSRF Permissive Mode**: Always ensure `"WEBHOOK_SECURITY_MODE": "permissive"` is present in the client environment to permit requests against the `100.116.224.88` Meshnet IP.
3. **Local CLI Verification Harness**:
   ```bash
   node call_mcp.js
   ```
4. **Force Restart MCP Process in IDE**:
   ```bash
   bash scripts/restart-mcp.sh
   ```
   *(Then press `Cmd + Shift + P` -> `Developer: Reload Window` in Antigravity IDE).*



