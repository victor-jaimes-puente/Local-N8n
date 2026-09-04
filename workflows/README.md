# Local-N8n Workflows

This directory contains version-controlled exports of all active, testing, and sub-workflow automations deployed on the **Local-N8n** server.

For standalone native AI agents (n8n 2.35+), see [`../agents/`](../agents/).

---

## 1. Active Workflow Inventory & Repository Map

| Directory | Workflow Name | Remote ID | Status | Primary Trigger | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [`ai-testing/`](./ai-testing/) | `AI-TESTING` | `5rRB16PM6Tx07ZB0` | `active: false` | Chat / Manual Test | Interactive chat and manual prompt evaluation flow for local LLMs on Hulk (`http://100.64.153.30:1234/v1`) with SearXNG web search. |
| [`meshnet-health-check/`](./meshnet-health-check/) | `Meshnet-Health-Check` | `XRDcHq3GIEZQKprT` | `active: false` | Webhook (`GET /meshnet-health-check`) | End-to-end health probe validating Meshnet HTTP ingress, Redis Bull queue scheduling, and PostgreSQL recording. |
| [`slack/`](./slack/) | `Slack` | `8irpSdMtOgDVxsSb` | `active: true` | Webhook (`POST /webhook/slack-events`) | Public Slack ingress router with immediate 200 OK acknowledgment, bot echo loop filtering, and dispatch to `slack-ai-agent`. |
| [`slack-ai-agent/`](./slack-ai-agent/) | `slack-ai-agent` | `Fq6gdZ5X10eOiCQA` | `active: true` | Execute Workflow Trigger | Conversational AI bridge sub-workflow forwarding Slack messages to native agent **Tirano** via `messageAnAgent`. |
| [`tool-searxng-search/`](./tool-searxng-search/) | `Tool-SearXNG-Search` | `hk8OViFZWBnveSCF` | `active: true` | Execute Workflow Trigger | Reusable AI Agent Web Search Tool sub-workflow executing live queries against local SearXNG (`http://searxng:8080`). |
| [`tool-calendar-batch-insert/`](./tool-calendar-batch-insert/) | `tool-calendar-batch-insert` | `xvcby8WREF4cxTCr` | `active: true` | Execute Workflow Trigger | Batch reminder insertion tool accepting an array of reminder records and inserting into `reminders` Data Table. |
| [`sub-agent-calendar-manager/`](./sub-agent-calendar-manager/) | `sub-agent-calendar-manager` | `TNsAnwkOeLrnbk24` | `active: true` | Execute Workflow Trigger | Autonomous task & calendar AI sub-agent powered by `google/gemma-4-e4b` on Hulk, anchoring time calculations to incoming reference_time. |
| [`reminder-poller/`](./reminder-poller/) | `reminder-poller` | `aHpvAYW4Jnbf9rte` | `active: true` | Schedule Trigger (1 min) | Automated cron poller with Double-Delivery Guard (status claims: pending -> processing -> completed) dispatching alerts to Slack. |

---

## 2. Standalone & Legacy Prototypes

| Directory | Workflow Name | Remote ID | Status | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| [`calendar-native-agent/`](./calendar-native-agent/) | `Calendar Native Agent` | `ahZnfDnp0564f7YS` | `active: false (archived)` | Superseded native canvas prototype. |

---

## 3. n8n Data Tables

Persistent tables hosted within n8n:

| Table Name | Remote Table ID | Purpose | Columns |
| :--- | :--- | :--- | :--- |
| `reminders` | `UfEmiO0qytgmsjE4` | Private persistent task & alert store | `task` (string), `target_time` (date), `notify_time` (date), `offset_label` (string), `status` (string), `slack_channel` (string) |

---

## 4. Directory Structure & Standards

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
├── tool-searxng-search/
│   ├── README.md                      # Standalone SearXNG tool docs
│   └── workflow.json                  # Workflow JSON export
├── sub-agent-calendar-manager/
│   ├── README.md                      # Sub-agent calendar manager docs
│   └── workflow.json                  # Staged/archived workflow JSON
├── reminder-poller/
│   ├── README.md                      # Reminder cron poller docs
│   └── workflow.json                  # Staged/archived workflow JSON
└── calendar-native-agent/
    ├── README.md                      # Canvas prototype docs
    └── workflow.json                  # Staged/archived workflow JSON
```

---

## 5. Import & Export Standards

1. **Exporting Workflows**: Run `node scripts/export-workflows.js` to refresh all workflow JSONs directly from n8n's REST API.
2. **Credential Safety**: Workflows strictly connect by Credential ID stored in the server's PostgreSQL vault. No tokens, passwords, or secrets are written to disk.
3. **Queue / Regular Mode Compliance**: Sub-workflows and tools are callable synchronously or asynchronously under the active execution mode.
