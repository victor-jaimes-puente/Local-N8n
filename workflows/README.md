# Local-N8n Workflows

This directory contains version-controlled exports of all active and staging n8n automation workflows deployed on the **Local-N8n** server.

---

## Workflow Inventory

| Directory | Workflow Name | Remote ID | Primary Trigger | Description |
| :--- | :--- | :--- | :--- | :--- |
| [`ai-testing/`](file:///Users/victor/Dev/Local-N8n/workflows/ai-testing/) | `AI-TESTING` | `5rRB16PM6Tx07ZB0` | Manual (`Test workflow`) | Side-by-side inference benchmark comparing Local LLM (Ollama/vLLM) and Google Gemini via OpenAI-compatible connectors. |
| [`meshnet-health-check/`](file:///Users/victor/Dev/Local-N8n/workflows/meshnet-health-check/) | `Meshnet-Health-Check` | `XRDcHq3GIEZQKprT` | Webhook (`GET /meshnet-health-check`) | End-to-end health probe validating Meshnet HTTP ingress, Redis Bull queue scheduling, and PostgreSQL recording. |

---

## Import & Export Standards

1. **Exporting Workflows**: Every exported flow resides in its own kebab-case subdirectory containing:
   - `workflow.json`: The complete exportable JSON definition (without raw credentials).
   - `README.md`: Architectural documentation, trigger endpoints, node details, and sample payloads.
2. **Credential Safety**: Workflows must never contain embedded secrets in node parameters. Credentials are tied dynamically via n8n Credential IDs stored in the PostgreSQL vault.
3. **Queue Mode Compliance**: All workflows are verified for asynchronous execution under `EXECUTIONS_MODE=queue`.
