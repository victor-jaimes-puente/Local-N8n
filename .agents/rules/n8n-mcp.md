# Rules for Meshnet n8n MCP Agent

1. **MCP Server First & Exclusively**: Always use the connected `n8n-mcp` server tools (`meshnet-n8n`) as the primary and exclusive interface for all n8n operations (node discovery, schema introspection, validation, mutation, credential retrieval, and execution diagnostics). Never bypass the MCP server with direct database edits, raw curl requests, or ad-hoc scripts unless an action is strictly unsupported by the MCP protocol.
2. **Schema Retrieval Before Scaffolding**: Always call `get_node_schema` prior to generating or updating node JSON to avoid schema mismatch errors.
3. **Deterministic Pre-Flight Validation**: Always run `validate_workflow_schema` prior to creating or modifying workflows.
4. **Credential Vault Separation**: Never embed raw API tokens, passwords, or secrets into node JSON. Connect workflows to existing Credential IDs retrieved via `list_credentials`.
5. **Staging / Safe State**: Set `active: false` on all newly scaffolded workflows until validation tests and executions succeed.
6. **Execution Model**: The production stack operates with `EXECUTIONS_MODE=regular` to support native Agents in preview (`N8N_ENABLED_MODULES=agents,instance-ai`, with `n8n-worker` paused). When queue mode supports standalone agents in future releases, Redis 6 and `n8n-worker` can be resumed.
7. **Retention Awareness**: Do not retain high-volume binary payloads inside execution data, adhering to the 168-hour / 50,000-execution pruning threshold (`EXECUTIONS_DATA_PRUNE=true`).
