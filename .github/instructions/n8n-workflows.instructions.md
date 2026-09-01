---
applyTo: "workflows/**"
---

# n8n Workflow File Editing Guidelines

When creating, reading, or modifying workflow JSON files inside `workflows/`:

1. **Schema Compliance**:
   - Ensure all node parameters match the exact schema returned by `get_node` from the `meshnet-n8n` MCP server.
   - Every node must have `id`, `name`, `type`, `typeVersion`, `position` (`[x, y]`), and `parameters`.
2. **Expression Standard**:
   - Use only modern v1+ expression syntax (`{{ $json.field }}`, `{{ $('Node Name').item.json.field }}`). Never use legacy `{{ $node[...] }}` syntax.
3. **Credentials & Secrets**:
   - Do NOT store plaintext passwords, API keys, or bearer tokens in `parameters`. Always specify the credential in `credentials: { "<credentialType>": { "id": "<credentialId>" } }`.
4. **Staging State**:
   - Set `"active": false` for newly created workflow files by default.
