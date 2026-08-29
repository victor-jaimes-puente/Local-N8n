# Roadmap: Antigravity IDE to Meshnet n8n via Model Context Protocol (MCP)

This phased implementation plan connects **Antigravity IDE** on your development machine to your self-hosted **Local-N8n** stack running on your Ubuntu server. It routes traffic over the private **NordVPN Meshnet** adapter through **Caddy** with Zero-Trust ingress and secures API credentials using **Doppler** runtime injection.

---

## Phase 1: Client Network Routing & Ingress Verification

Map the development workstation's network path directly to the server's Meshnet IP interfaces.

### 1.1 Configure Static DNS / Hosts File
Add the domain-to-IP mappings in your workstation's host file (`/etc/hosts` on macOS/Linux or `C:\Windows\System32\drivers\etc\hosts` on Windows):

```text
100.116.224.88 n8n.local-n8n.com lingua.local-n8n.com
```

### 1.2 Verify Reverse Proxy Connectivity
Verify that Caddy accepts incoming HTTPS traffic across port 443 on the NordVPN Meshnet adapter:

```bash
curl -k -I https://n8n.local-n8n.com
```

> **Note**: `-k` allows self-signed TLS certificates issued by Caddy's internal `local_certs` engine.

---

## Phase 2: Credential Lifecycle & Doppler Secret Provisioning

Generate n8n administrative tokens and store them within the Doppler production project.

### 2.1 Generate n8n API Key
1. Open `https://n8n.local-n8n.com` in your browser.
2. Navigate to **Settings** > **n8n API** > **Create API Key**.
3. Name the key `antigravity-mcp-bridge` and copy the value.

### 2.2 Inject Token into Doppler Secrets Engine
Store the secret in Doppler under the `local-n8n/prd` configuration rather than writing it to disk in plaintext:

```bash
doppler secrets set N8N_MCP_API_KEY="<YOUR_N8N_API_KEY>" --project local-n8n --config prd
```

---

## Phase 3: Antigravity MCP Server Configuration

Register the local MCP bridge process to run via Doppler injection inside Antigravity IDE.

### 3.1 Define Server in `mcp_config.json`
Open your global (`~/.gemini/antigravity-ide/mcp_config.json` / `~/.antigravity/mcp_config.json`) or workspace configuration file and add the `meshnet-n8n` entry:

```json
{
  "mcpServers": {
    "meshnet-n8n": {
      "command": "doppler",
      "args": [
        "run",
        "--project",
        "local-n8n",
        "--config",
        "prd",
        "--",
        "npx",
        "-y",
        "n8n-mcp"
      ],
      "env": {
        "N8N_HOST": "https://n8n.local-n8n.com",
        "N8N_API_KEY": "${N8N_MCP_API_KEY}",
        "NODE_TLS_REJECT_UNAUTHORIZED": "0"
      }
    }
  }
}
```

> **Note**: `NODE_TLS_REJECT_UNAUTHORIZED=0` permits Node to communicate through Caddy's internal Certificate Authority.

---

## Phase 4: Agent Instructions & System Guardrails

Establish rules for the Antigravity agent in `.agents/rules/n8n-mcp.md` (or workspace rules) to prevent corrupted workflows or memory bloat.

### 4.1 Create Workspace Rules
```markdown
# Rules for Meshnet n8n MCP Agent

1. **Schema Retrieval Before Scaffolding**: Always call `get_node_schema` prior to generating third-party or custom node JSON to avoid schema mismatch errors.
2. **Asynchronous Execution Model**: The production stack operates with `EXECUTIONS_MODE=queue` backed by Redis 6 and `n8n-worker` instances. Do not assume synchronous in-memory execution loops.
3. **Credential Vault Separation**: Never embed raw API tokens, passwords, or secrets into node JSON. Connect workflows to existing Credential IDs stored in n8n.
4. **Staging / Safe State**: Set `active: false` on all newly scaffolded workflows until validation tests succeed via `execute_workflow`.
5. **Retention Awareness**: Do not retain high-volume binary payloads inside execution data, adhering to the 168-hour / 50,000-execution pruning threshold (`EXECUTIONS_DATA_PRUNE=true`).
```

---

## Phase 5: Verification & End-to-End Validation

Run full-cycle tests from Antigravity IDE to ensure the agent can discover, scaffold, and inspect workflows across the Meshnet.

### 5.1 Tool Discovery
Prompt the agent:
> *"Check available MCP tools and list all active workflows on meshnet-n8n."*

### 5.2 Automated Scaffolding
Prompt the agent:
> *"Create an inactive workflow titled `Meshnet-Health-Check` that accepts a GET webhook request, executes a basic JavaScript Code Node returning the server timestamp, and responds with HTTP 200 JSON."*

### 5.3 Canvas & Execution Audit
Open `https://n8n.local-n8n.com` in your browser to inspect the node canvas, verify connection topology, and validate that execution records route properly to Redis and PostgreSQL.