# Local-N8n Workspace Rules

## Meshnet n8n MCP Agent Guardrails

1. **MCP Server First & Exclusively**: Always use the connected `n8n-mcp` server tools (`meshnet-n8n`) as the primary and exclusive interface for all n8n operations (node discovery, schema introspection, validation, mutation, credential retrieval, and execution diagnostics). Never bypass the MCP server with direct database edits, raw curl requests, or ad-hoc scripts. If an operation is unsupported by the MCP protocol, STOP and ask the user for clarification. Do not fall back to shell scripts or curl.
2. **Schema Retrieval Before Scaffolding**: Always call `get_node` (with `mode="info"`) prior to generating or updating node JSON to avoid schema mismatch errors.
3. **Deterministic Pre-Flight Validation**: Always run `validate_workflow_schema` prior to creating or modifying workflows.
4. **Credential Vault Separation**: Never embed raw API tokens, passwords, or secrets into node JSON. Connect workflows to existing Credential IDs retrieved via `list_credentials` (if available in the MCP server; otherwise, ask the user for the ID).
5. **Staging / Safe State**: Set `active: false` on all newly scaffolded workflows until validation tests and executions succeed.
6. **Asynchronous Execution Model**: The production stack operates with `EXECUTIONS_MODE=queue` backed by Redis 6 and `n8n-worker` instances. Do not assume synchronous in-memory execution loops.
7. **Retention Awareness**: Do not retain high-volume binary payloads inside execution data, adhering to the 168-hour / 50,000-execution pruning threshold (`EXECUTIONS_DATA_PRUNE=true`).
