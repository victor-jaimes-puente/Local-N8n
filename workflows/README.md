# Local-N8n Workflows

This directory contains version-controlled exports of all active, testing, and sub-workflow automations deployed on the **Local-N8n** server.

---

## 1. Workflow Inventory & Repository Map

| Directory | Workflow Name | Remote ID | Status | Primary Trigger | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [`ai-testing/`](./ai-testing/) | `AI-TESTING` | `5rRB16PM6Tx07ZB0` | `active: false` | Chat / Manual Test | Interactive chat and manual prompt evaluation flow for local LLMs on Hulk (`http://100.64.153.30:1234/v1`) with SearXNG web search. |
| [`meshnet-health-check/`](./meshnet-health-check/) | `Meshnet-Health-Check` | `XRDcHq3GIEZQKprT` | `active: false` | Webhook (`GET /meshnet-health-check`) | End-to-end health probe validating Meshnet HTTP ingress, Redis Bull queue scheduling, and PostgreSQL recording. |
| [`slack/`](./slack/) | `Slack` | `8irpSdMtOgDVxsSb` | `active: true` | Webhook (`POST /webhook/slack-events`) | Public Slack ingress router with immediate 200 OK acknowledgment, bot echo loop filtering, and dispatch to `slack-ai-agent`. |
| [`slack-ai-agent/`](./slack-ai-agent/) | `slack-ai-agent` | `Fq6gdZ5X10eOiCQA` | `active: true` | Execute Workflow Trigger | Conversational AI sub-workflow powered by Hulk LM Studio, Window Buffer Memory (thread-scoped), SearXNG search tool, and Slack reply posting. |
| [`tool-searxng-search/`](./tool-searxng-search/) | `Tool-SearXNG-Search` | `hk8OViFZWBnveSCF` | `active: true` | Execute Workflow Trigger | Reusable AI Agent Web Search Tool sub-workflow executing live queries against local SearXNG (`http://searxng:8080`). |

---

## 2. Directory Structure & Standards

```
workflows/
├── README.md                          # Workflow inventory & architecture map
├── ai-testing/
│   ├── README.md                      # Local LLM chat & prompt testing docs
│   └── workflow.json                  # Workflow JSON export
├── meshnet-health-check/
│   ├── README.md                      # Meshnet endpoint probe documentation
│   └── workflow.json                  # Workflow JSON export
├── slack/
│   ├── README.md                      # Ingress router & Cloudflare webhook docs
│   └── workflow.json                  # Workflow JSON export
├── slack-ai-agent/
│   ├── README.md                      # Threaded conversational AI bot docs
│   └── workflow.json                  # Workflow JSON export
└── tool-searxng-search/
    ├── README.md                      # Standalone SearXNG tool docs
    └── workflow.json                  # Workflow JSON export
```

---

## 3. Import & Export Standards

1. **Exporting Workflows**: Every exported flow resides in its own kebab-case subdirectory containing:
   - `workflow.json`: The complete exportable JSON definition.
   - `README.md`: Architectural documentation, trigger endpoints, node details, and sample payloads.
2. **Credential Safety**: Workflows strictly connect by Credential ID stored in the server's PostgreSQL vault. No tokens, passwords, or secrets are written to disk.
3. **Queue Mode Compliance**: All workflows operate under asynchronous execution (`EXECUTIONS_MODE=queue` backed by Redis and `n8n-worker`).
