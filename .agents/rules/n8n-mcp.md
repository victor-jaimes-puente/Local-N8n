# Rules for Meshnet n8n MCP Agent

1. **Schema Retrieval Before Scaffolding**: Always call `get_node_schema` prior to generating third-party or custom node JSON to avoid schema mismatch errors.
2. **Asynchronous Execution Model**: The production stack operates with `EXECUTIONS_MODE=queue` backed by Redis 6 and `n8n-worker` instances. Do not assume synchronous in-memory execution loops.
3. **Credential Vault Separation**: Never embed raw API tokens, passwords, or secrets into node JSON. Connect workflows to existing Credential IDs stored in n8n.
4. **Staging / Safe State**: Set `active: false` on all newly scaffolded workflows until validation tests succeed via `execute_workflow`.
5. **Retention Awareness**: Do not retain high-volume binary payloads inside execution data, adhering to the 168-hour / 50,000-execution pruning threshold (`EXECUTIONS_DATA_PRUNE=true`).
