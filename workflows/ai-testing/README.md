# Workflow: AI-TESTING

A local AI testing and evaluation workflow connecting **n8n** to **LM Studio on Hulk (`100.64.153.30:1234`)** over private NordVPN Meshnet, augmented with real-time web search capabilities via our self-hosted **SearXNG** engine.

---

## 1. Overview & Specifications

| Property | Value |
| :--- | :--- |
| **Workflow Name** | `AI-TESTING` |
| **Remote ID** | `5rRB16PM6Tx07ZB0` |
| **Default State** | `active: false` (Manual & Interactive Chat Testing Workflow) |
| **Input Methods** | 1. **Interactive Chat UI** (`When chat message received`)<br/>2. **Canvas Prompt Input** (`When clicking 'Test workflow'` + Set Node) |
| **Direct Canvas Link** | [https://n8n.local-n8n.com/workflow/5rRB16PM6Tx07ZB0](https://n8n.local-n8n.com/workflow/5rRB16PM6Tx07ZB0) |
| **Search Engine** | **SearXNG** (`http://searxng:8080/search?q={query}&format=json`) |
| **Timeout Allowance** | **6 Minutes** (`timeout: 360000ms`, `executionTimeout: 600s`) for model cold loading into GPU memory (RTX 4070) |

---

## 2. Architecture & Inference Topology

```mermaid
graph TD
    ChatTrigger["When chat message received (Interactive Chat Trigger)"] --> AgentNode["AI Agent (LangChain Agent)"]
    ManualTrigger["When clicking 'Test workflow' (Manual Trigger)"] --> InputNode["Test Prompt Input (Set Node)"]
    InputNode --> AgentNode
    
    LocalModel["Hulk LM Studio Model (Chat Model)<br/>Base URL: http://100.64.153.30:1234/v1<br/>Model: qwen/qwen3.6-35b-a3b / google/gemma-4-26b-a4b-qat<br/>Timeout: 360,000 ms"] -.->|ai_languageModel| AgentNode
    
    SearXNGTool["SearXNG Web Search (HTTP Tool)<br/>URL: http://searxng:8080/search<br/>Params: q={{$fromAI('query')}}, format=json"] -.->|ai_tool| AgentNode
    
    AgentNode --> FormatNode["Format Test Results (Code Node)"]
```

---

## 3. How to Input Text & Test the AI Connection

You can test custom prompts using either of two built-in methods:

### Method 1: Interactive Chat UI (Recommended)
1. Open the workflow canvas: [https://n8n.local-n8n.com/workflow/5rRB16PM6Tx07ZB0](https://n8n.local-n8n.com/workflow/5rRB16PM6Tx07ZB0).
2. Click the **"Chat"** tab/button located in the bottom-right corner of the canvas (or double-click the **When chat message received** node and click *Open Chat*).
3. Type a web search prompt (e.g., `Search the web for the latest developments in AI today`).
4. The AI agent will call `SearXNG Web Search`, retrieve live search results, and synthesize a response.

### Method 2: In-Canvas Test Workflow Button
1. Open the **Test Prompt Input** Set node.
2. Edit the `prompt` field value with whatever question or prompt you want to send.
3. Click **"Test workflow"** at the bottom of the canvas.
4. The **Format Test Results** node will display structured execution output with metadata and timestamps.

---

## 4. Hardware & Cold Load Specifications

- **Compute Host**: Hulk (`100.64.153.30:1234`) running LM Studio local server on Nvidia GeForce RTX 4070.
- **Search Backend**: Local SearXNG container (`http://searxng:8080`) on Docker `gateway_net`.
- **Cold Load Buffer**: When switching models or executing after an idle state, LM Studio may take up to 2-5 minutes to load weights into VRAM. The workflow is configured with:
  - Node HTTP Request Timeout: `360,000 ms` (6 minutes)
  - Workflow Execution Timeout ceiling: `600 seconds` (10 minutes)
  - Max Retries: `2`
- **Active Model**: `qwen/qwen3.6-35b-a3b` (or `google/gemma-4-26b-a4b-qat`).
