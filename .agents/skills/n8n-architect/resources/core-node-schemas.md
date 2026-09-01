# Core Node Schemas & JSON Skeletons — n8n

> **Authoritative Source**: Verified against n8n node source definitions (`n8n-nodes-base`, `@n8n/n8n-nodes-langchain`).

---

## 1. Flow Control & Logic Nodes

### A. `n8n-nodes-base.if` (v2.3)
Routes items between two output branches based on evaluation conditions.

* **Outputs**:
  * Output `0`: **True** (Condition Met)
  * Output `1`: **False** (Condition Unmet)

```json
{
  "id": "10101010-0001-4000-8000-000000000010",
  "name": "Check Status",
  "type": "n8n-nodes-base.if",
  "typeVersion": 2.3,
  "position": [480, 300],
  "parameters": {
    "conditions": {
      "options": {
        "caseSensitive": true,
        "leftValue": "",
        "typeValidation": "strict",
        "version": 2
      },
      "conditions": [
        {
          "id": "cond-1",
          "leftValue": "={{ $json.status }}",
          "rightValue": "completed",
          "operator": {
            "type": "string",
            "operation": "equals"
          }
        },
        {
          "id": "cond-2",
          "leftValue": "={{ $json.retryCount }}",
          "rightValue": 3,
          "operator": {
            "type": "number",
            "operation": "lt"
          }
        }
      ],
      "combinator": "and"
    }
  }
}
```

*Supported Operator Types*: `string` (`equals`, `notEquals`, `contains`, `regex`, `empty`), `number` (`equals`, `lt`, `gt`, `lte`, `gte`), `boolean` (`true`, `false`), `dateTime` (`before`, `after`), `array` (`contains`, `empty`).

---

### B. `n8n-nodes-base.switch` (v3.4)
Routes items dynamically across multiple output branches using rule sets.

```json
{
  "id": "10101010-0001-4000-8000-000000000020",
  "name": "Route Event Type",
  "type": "n8n-nodes-base.switch",
  "typeVersion": 3.4,
  "position": [480, 300],
  "parameters": {
    "mode": "rules",
    "rules": {
      "rules": [
        {
          "outputKey": "order_created",
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict",
              "version": 2
            },
            "conditions": [
              {
                "id": "rule-1",
                "leftValue": "={{ $json.event }}",
                "rightValue": "order.created",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ],
            "combinator": "and"
          }
        },
        {
          "outputKey": "order_cancelled",
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict",
              "version": 2
            },
            "conditions": [
              {
                "id": "rule-2",
                "leftValue": "={{ $json.event }}",
                "rightValue": "order.cancelled",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ],
            "combinator": "and"
          }
        }
      ]
    },
    "options": {
      "fallbackOutput": "extra"
    }
  }
}
```

---

### C. `n8n-nodes-base.merge` (v3.2)
Merges data streams from two input branches (`input 1` and `input 2`).

```json
{
  "id": "10101010-0001-4000-8000-000000000030",
  "name": "Merge Records",
  "type": "n8n-nodes-base.merge",
  "typeVersion": 3.2,
  "position": [780, 300],
  "parameters": {
    "mode": "combine",
    "combinationMode": "mergeByFields",
    "mergeByFields": {
      "values": [
        {
          "field1": "userId",
          "field2": "id"
        }
      ]
    },
    "options": {
      "clashHandling": {
        "values": {
          "resolveClash": "overrideWithInput2"
        }
      }
    }
  }
}
```

*Modes*: `combine` (`mergeByFields`, `multiplex`), `append` (concatenate streams), `chooseBranch` (pass through single input), `passThrough`.

---

### D. `n8n-nodes-base.splitInBatches` / Loop Over Items (v3.0)
Iterates through items in chunks of size `batchSize`.

* **Outputs**:
  * Output `0`: **Loop** (Current batch of items to process)
  * Output `1`: **Done** (Triggers once all items/batches have finished)

```json
{
  "id": "10101010-0001-4000-8000-000000000040",
  "name": "Loop Over Batches",
  "type": "n8n-nodes-base.splitInBatches",
  "typeVersion": 3,
  "position": [480, 300],
  "parameters": {
    "batchSize": 50,
    "options": {
      "reset": false
    }
  }
}
```

---

## 2. Transformation & Scripting Nodes

### A. `n8n-nodes-base.code` (v2.0) — JavaScript Mode
Executes isolated JavaScript against `$input.all()` or `$input.item`.

```json
{
  "id": "10101010-0001-4000-8000-000000000050",
  "name": "Transform Data JS",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [640, 300],
  "parameters": {
    "language": "javaScript",
    "mode": "runOnceForAllItems",
    "jsCode": "const items = $input.all();\nconst results = [];\n\nfor (const item of items) {\n  results.push({\n    json: {\n      id: item.json.id,\n      fullName: `${item.json.firstName} ${item.json.lastName}`.trim(),\n      processedAt: new Date().toISOString(),\n      isActive: item.json.status === 'ACTIVE'\n    }\n  });\n}\n\nreturn results;"
  }
}
```

### B. `n8n-nodes-base.code` (v2.0) — Python Mode
Executes Python code against `_input.all()`.

```json
{
  "id": "10101010-0001-4000-8000-000000000051",
  "name": "Transform Data Python",
  "type": "n8n-nodes-base.code",
  "typeVersion": 2,
  "position": [640, 300],
  "parameters": {
    "language": "python",
    "mode": "runOnceForAllItems",
    "pythonCode": "items = _input.all()\nresults = []\n\nfor item in items:\n    raw = item.get('json', {})\n    results.append({\n        'json': {\n            'id': raw.get('id'),\n            'email': str(raw.get('email', '')).lower(),\n            'score': float(raw.get('score', 0.0)) * 1.1\n        }\n    })\n\nreturn results"
  }
}
```

---

## 3. Protocol & Integration Nodes

### A. `n8n-nodes-base.httpRequest` (v4.5)
Performs robust HTTP calls with body serialization, headers, and authentication.

```json
{
  "id": "10101010-0001-4000-8000-000000000060",
  "name": "API Request",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.5,
  "position": [640, 300],
  "parameters": {
    "method": "POST",
    "url": "https://api.example.com/v1/orders",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {
          "name": "Content-Type",
          "value": "application/json"
        }
      ]
    },
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={\n  \"orderId\": \"{{ $json.orderId }}\",\n  \"amount\": {{ $json.amount }},\n  \"currency\": \"USD\"\n}",
    "options": {
      "timeout": 30000,
      "response": {
        "response": {
          "neverError": false,
          "fullResponse": false
        }
      }
    }
  },
  "credentials": {
    "httpHeaderAuth": {
      "id": "existing-cred-id",
      "name": "API Header Token"
    }
  }
}
```

---

### B. `n8n-nodes-base.executeWorkflow` (v1.3)
Dispatches input payloads to a designated sub-workflow.

```json
{
  "id": "10101010-0001-4000-8000-000000000070",
  "name": "Call Processing Subworkflow",
  "type": "n8n-nodes-base.executeWorkflow",
  "typeVersion": 1.3,
  "position": [780, 300],
  "parameters": {
    "source": "database",
    "workflowId": {
      "__rl": true,
      "value": "subworkflow-id-123",
      "mode": "id"
    },
    "mode": "all",
    "options": {
      "waitForSubWorkflow": true
    }
  }
}
```

---

### C. `n8n-nodes-base.errorTrigger` (v1.0)
Specialized trigger capturing unhandled workflow failures.

```json
{
  "id": "10101010-0001-4000-8000-000000000080",
  "name": "Error Trigger",
  "type": "n8n-nodes-base.errorTrigger",
  "typeVersion": 1,
  "position": [240, 300],
  "parameters": {}
}
```
*Emitted Payload Structure*:
```json
{
  "execution": {
    "id": "24819",
    "url": "https://n8n.local-n8n.com/execution/24819",
    "error": {
      "message": "HTTP Request failed with status 500",
      "stack": "NodeOperationError: ..."
    },
    "lastNodeExecuted": "API Request",
    "mode": "webhook"
  },
  "workflow": {
    "id": "5rRB16PM6Tx07ZB0",
    "name": "AI-TESTING"
  }
}
```

---

## 4. Advanced AI & LangChain Nodes

### A. `@n8n/n8n-nodes-langchain.agent` (v3.1) & `@n8n/n8n-nodes-langchain.lmChatOpenAi` (v1.3)

```json
{
  "id": "ffe9d70f-e9c2-48e8-863b-baa0be2a66f4",
  "name": "AI Agent",
  "type": "@n8n/n8n-nodes-langchain.agent",
  "typeVersion": 3.1,
  "position": [760, 240],
  "parameters": {
    "promptType": "define",
    "text": "={{ $json.chatInput || $json.prompt }}",
    "options": {
      "systemMessage": "You are a helpful AI assistant."
    }
  }
},
{
  "id": "70b302be-c910-4703-a97a-8a2c91e94ce5",
  "name": "OpenAI-Compatible Model",
  "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
  "typeVersion": 1.3,
  "position": [760, 480],
  "parameters": {
    "model": {
      "__rl": true,
      "value": "google/gemma-4-26b-a4b-qat",
      "mode": "list"
    },
    "builtInTools": {},
    "options": {
      "baseURL": "http://100.64.153.30:1234/v1",
      "timeout": 360000,
      "maxRetries": 2,
      "temperature": 0.7
    }
  },
  "credentials": {
    "openAiApi": {
      "id": "hvK9eAePdrKHSgMD",
      "name": "OpenAI account"
    }
  }
}
```
