# n8n Modern Expression Reference (v1+)

> **Authoritative Source**: Verified against [n8n Expressions Documentation](https://docs.n8n.io/data/expressions/) and n8n core runtime engine.

---

## 1. Core Data Access Expressions

n8n uses double-curly-brace syntax `{{ ... }}` for dynamic JavaScript expressions evaluated within node parameters.

### A. Current Node Input (`$json`)
| Expression | Description |
| :--- | :--- |
| `{{ $json.fieldName }}` | Value of `fieldName` from the current incoming item. |
| `{{ $json["field-with-hyphens"] }}` | Bracket notation for keys containing hyphens, spaces, or special characters. |
| `{{ $json.user.address.city }}` | Safe nested property traversal. |
| `{{ $json.items[0].id }}` | Array element access from current item JSON. |

### B. Referencing Other Nodes (`$('Node Name')`)
| Expression | Description |
| :--- | :--- |
| `{{ $('Node Name').item.json.fieldName }}` | Value of `fieldName` from the **paired item** in `Node Name` (preserves 1:1 item matching). |
| `{{ $('Node Name').first().json.fieldName }}` | Value from the **first item** emitted by `Node Name`. |
| `{{ $('Node Name').last().json.fieldName }}` | Value from the **last item** emitted by `Node Name`. |
| `{{ $('Node Name').all() }}` | Returns the complete array of all items emitted by `Node Name` (`[ { json: ... } ]`). |
| `{{ $('Node Name').all()[2].json.id }}` | Direct item indexing across the predecessor's output stream. |

---

## 2. Loop & Execution Indexing Variables

| Variable | Type | Description |
| :--- | :---: | :--- |
| `$itemIndex` | `number` | Index (0-based) of the current item within the active batch being processed. |
| `$runIndex` | `number` | Execution iteration count (0-based) for nodes executing inside loops (`SplitInBatches` / `LoopOverItems`). |
| `$position` | `number` | Sequential position (0-based) of the item across all processed batches. |
| `$maxRunIndex` | `number` | Total number of iterations executed by the node in the current loop. |

---

## 3. Workflow & System Metadata

| Variable | Example Output | Description |
| :--- | :--- | :--- |
| `{{ $execution.id }}` | `"24819"` | Unique execution run ID. |
| `{{ $execution.mode }}` | `"manual"`, `"webhook"`, `"trigger"` | Trigger invocation mode. |
| `{{ $workflow.id }}` | `"5rRB16PM6Tx07ZB0"` | Unique n8n workflow ID. |
| `{{ $workflow.name }}` | `"Meshnet-Health-Check"` | Name of the active workflow. |
| `{{ $workflow.active }}` | `true` / `false` | Staging / active status. |
| `{{ $env.GENERIC_TIMEZONE }}` | `"America/Chicago"` | Host environment variable (when `$env` access is enabled). |

---

## 4. Date & Time Expressions (Luxon Integration)

n8n natively bundles **Luxon** for all date and time operations.

### Standard Timestamps
* Current DateTime: `{{ $now }}` (Luxon `DateTime` instance)
* Start of Today: `{{ $today }}`
* ISO 8601 String: `{{ $now.toISO() }}` &rarr; `2026-09-01T01:47:00.000Z`
* Epoch Milliseconds: `{{ $now.toMillis() }}`

### Formatting & Manipulation
```javascript
// Format to standard human-readable date
{{ $now.toFormat('yyyy-MM-dd HH:mm:ss') }}

// Date arithmetic (Add / Subtract)
{{ $now.plus({ days: 7, hours: 2 }).toISO() }}
{{ $now.minus({ minutes: 30 }).toFormat('HH:mm') }}

// Timezone conversion
{{ $now.setZone('America/Chicago').toFormat('yyyy-MM-dd HH:mm:ss ZZZZ') }}

// Date difference calculation
{{ $now.diff(DateTime.fromISO($json.createdAt), 'hours').hours }}
```

---

## 5. Built-in Transformation Methods

### A. JMESPath Querying (`$jmespath`)
Query and transform deeply nested JSON structures concisely:
```javascript
{{ $jmespath($json, "users[?age > `21`].email") }}
{{ $jmespath($('Fetch API').all(), "[*].json.id") }}
```

### B. Native Array & String Operations
```javascript
// Extract and comma-join IDs from an array of objects
{{ $json.users.map(u => u.id).join(', ') }}

// Safe fallback for nullish properties
{{ $json.description ?? 'No description provided' }}

// URL parameter encoding
{{ encodeURIComponent($json.searchQuery) }}

// String hashing & encoding
{{ $json.rawPayload.trim().toLowerCase() }}
```

---

## 6. Binary Data Handling

Binary files (documents, images, audio) are stored in `$binary` alongside JSON payloads:

### Inspecting Binary Properties
```javascript
{{ $binary.data.fileName }}      // e.g. "invoice.pdf"
{{ $binary.data.mimeType }}      // e.g. "application/pdf"
{{ $binary.data.fileExtension }} // e.g. "pdf"
{{ $binary.data.fileSize }}      // e.g. 1048576 (bytes)
```

### Accessing Binary in Code Node (JavaScript)
```javascript
// Reading binary stream metadata in Code node
for (const item of $input.all()) {
  if (item.binary && item.binary.data) {
    item.json.fileName = item.binary.data.fileName;
    item.json.fileSizeKb = Math.round(item.binary.data.fileSize / 1024);
  }
}
return $input.all();
```

---

## 7. Deprecated vs. Modern Syntax Reference

| Deprecated Syntax (Forbidden ❌) | Modern Canonical Syntax (Required ✅) | Reason / Behavior |
| :--- | :--- | :--- |
| `{{ $node["NodeName"].data["key"] }}` | `{{ $('NodeName').item.json.key }}` | Deprecated in v1; breaks paired item resolution. |
| `{{ $node["NodeName"].json["key"] }}` | `{{ $('NodeName').item.json.key }}` | Replaced by direct `$()` node selector function. |
| `{{ $items("NodeName") }}` | `{{ $('NodeName').all() }}` | Standardized on `.all()` collection method. |
| `{{ $item(0).$node["NodeName"]... }}` | `{{ $('NodeName').item.json.key }}` | Item pairing is automatically handled natively. |
| `{{ items[0].json }}` (in Code node) | `{{ $input.first().json }}` or `$input.all()` | Modern `$input` context object replaces raw `items`. |
