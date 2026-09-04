# Local-N8n Native Agents

This directory contains version-controlled definitions and documentation for native **n8n Agents** (introduced in n8n 2.35+ with `N8N_ENABLED_MODULES=agents,instance-ai`).

Native agents decouple assistant identity, model configuration, persistent memory, channel integrations (such as Slack), and attached tools/skills from individual workflow canvases.

---

## 1. Agent Inventory & Manifest

| Directory | Agent Name | Remote ID | Model | Integrations | Attached Tools |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [`tirano/`](./tirano/) | `Tirano` | `OeEDzKbhvVK7aqeT` | `google/gemma-4-e4b` (Hulk) | Slack (`messagingExperience: agent`) | [`Tool-SearXNG-Search`](../workflows/tool-searxng-search/) |
| [`tirano-gemini/`](./tirano-gemini/) | `tirano-gemini` | `dEeAUYYsM5pxxKH9` | `google/gemini-3.6-flash` (Gemini API) | Slack (`messagingExperience: agent`) | [`Tool-SearXNG-Search`](../workflows/tool-searxng-search/) |

---

## 2. Directory Structure & Standards

```
agents/
├── README.md                      # Agent inventory & architecture map
├── tirano-gemini/
│   ├── README.md                  # tirano-gemini operational documentation & specs
│   └── agent.json                 # Native agent JSON definition & schema
└── tirano/
    ├── README.md                  # Tirano operational documentation & specs
    └── agent.json                 # Native agent JSON definition & schema
```

---

## 3. Standards & Guardrails

1. **Zero-Disk Credential Vault Separation**: Agent definitions connect to model credentials and Slack integration credentials by ID (`credential: "hvK9eAePdrKHSgMD"`). No tokens or API keys are stored in plaintext.
2. **Channel Integration**: Native agents bind directly to communication platforms (such as Slack) via n8n's internal channel adapter, receiving events and dispatching threaded replies autonomously.
3. **Sub-Workflow Interoperability**: Workflows can invoke native agents dynamically using the `n8n-nodes-base.messageAnAgent` node (see [`workflows/slack-ai-agent/`](../workflows/slack-ai-agent/)).
