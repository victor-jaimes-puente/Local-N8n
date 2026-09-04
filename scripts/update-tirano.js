#!/usr/bin/env node

const { execSync } = require('child_process');
const crypto = require('crypto');

const REMOTE_HOST = process.env.BACKUP_REMOTE_HOST || '100.116.224.88';
const REMOTE_USER = process.env.BACKUP_REMOTE_USER || 'silver-worker';
const REMOTE_DIR = process.env.BACKUP_REMOTE_DIR || '/home/silver-worker/Local-N8n';

const { spawnSync } = require('child_process');

function runPsql(sql) {
  const res = spawnSync('ssh', [
    `${REMOTE_USER}@${REMOTE_HOST}`,
    `${REMOTE_DIR}/server-scripts/dc.sh core exec -T postgres psql -U n8n -d n8n -t -A`
  ], {
    input: sql,
    encoding: 'utf-8',
    maxBuffer: 10 * 1024 * 1024
  });
  if (res.error) throw res.error;
  if (res.status !== 0) throw new Error(`psql failed: ${res.stderr}`);
  return res.stdout;
}

async function updateTirano() {
  console.log('Fetching Tirano agent from PostgreSQL...');
  const stdout = runPsql("SELECT row_to_json(a) FROM agents a WHERE id = 'OeEDzKbhvVK7aqeT';");
  const line = stdout.split('\n').find(l => l.trim().startsWith('{') && l.trim().endsWith('}'));
  if (!line) {
    throw new Error('Could not find Tirano record in PostgreSQL');
  }

  const agent = JSON.parse(line);
  const schema = agent.schema;

  // 1. Add tool if not already added
  if (!schema.tools) schema.tools = [];
  const existingToolIndex = schema.tools.findIndex(t => t.name === 'manage_calendar_and_tasks');
  const toolDef = {
    type: "workflow",
    workflowId: "TNsAnwkOeLrnbk24",
    workflow: "sub-agent-calendar-manager",
    name: "manage_calendar_and_tasks",
    description: "Handles creating, listing, cancelling, and scheduling reminders, appointments, and tasks. Requires user query and current slack_channel.",
    allOutputs: false
  };

  if (existingToolIndex >= 0) {
    schema.tools[existingToolIndex] = toolDef;
  } else {
    schema.tools.push(toolDef);
  }

  // 2. Add routing instructions
  const routingDirective = `
Calendar & Task Delegation Rules:
You have access to a specialized Calendar & Task Sub-Agent via the manage_calendar_and_tasks tool.
When the user asks to schedule a reminder, set an appointment, check upcoming events, or cancel a reminder:
1. Call the manage_calendar_and_tasks tool, passing their exact query and current Slack channel ID.
2. Read the structured JSON response returned by the tool.
3. Respond conversationally to the user summarizing the scheduled times and confirmation details.
4. Never invent or assume scheduling confirmations without receiving confirmation from the sub-agent.
`;

  if (!schema.instructions.includes('Calendar & Task Delegation Rules')) {
    schema.instructions = schema.instructions.trim() + '\n\n' + routingDirective.trim() + '\n';
  }

  // 3. Create new history entry
  const newVersionId = crypto.randomUUID();
  console.log(`Creating new agent version: ${newVersionId}`);

  const schemaJson = JSON.stringify(schema).replace(/'/g, "''");
  const toolsJson = JSON.stringify(agent.tools || {}).replace(/'/g, "''");
  const skillsJson = JSON.stringify(agent.skills || {}).replace(/'/g, "''");

  const insertHistorySql = `INSERT INTO agent_history ("versionId", "agentId", "schema", "tools", "skills", "author", "createdAt", "updatedAt") VALUES ('${newVersionId}', 'OeEDzKbhvVK7aqeT', '${schemaJson}'::json, '${toolsJson}'::json, '${skillsJson}'::json, 'Victor Jaimes-Puente', NOW(), NOW());`;
  runPsql(insertHistorySql);

  // 4. Update agents table
  console.log('Updating agents table...');
  const updateAgentSql = `UPDATE agents SET "schema" = '${schemaJson}'::json, "versionId" = '${newVersionId}', "activeVersionId" = '${newVersionId}', "revision" = "revision" + 1, "updatedAt" = NOW() WHERE "id" = 'OeEDzKbhvVK7aqeT';`;
  runPsql(updateAgentSql);

  console.log('Tirano updated successfully in PostgreSQL!');
}

updateTirano().catch(err => {
  console.error('Error updating Tirano:', err);
  process.exit(1);
});
