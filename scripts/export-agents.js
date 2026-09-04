#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const REMOTE_HOST = process.env.BACKUP_REMOTE_HOST || '100.116.224.88';
const REMOTE_USER = process.env.BACKUP_REMOTE_USER || 'silver-worker';
const REMOTE_DIR = process.env.BACKUP_REMOTE_DIR || '/home/silver-worker/Local-N8n';

async function exportAgents() {
  console.log(`Querying native agents from ${REMOTE_USER}@${REMOTE_HOST}...`);
  
  const cmd = `echo "SELECT row_to_json(a) FROM agents a;" | ssh ${REMOTE_USER}@${REMOTE_HOST} "${REMOTE_DIR}/server-scripts/dc.sh core exec -T postgres psql -U n8n -d n8n -t -A"`;
  
  const stdout = execSync(cmd, { encoding: 'utf-8' });
  const lines = stdout.split('\n').filter(line => {
    const trimmed = line.trim();
    return trimmed.startsWith('{') && trimmed.endsWith('}');
  });

  console.log(`Found ${lines.length} agents.`);

  const agentsDir = path.join(__dirname, '..', 'agents');
  if (!fs.existsSync(agentsDir)) {
    fs.mkdirSync(agentsDir, { recursive: true });
  }

  for (const line of lines) {
    const agent = JSON.parse(line);
    const folderName = agent.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    const agentDir = path.join(agentsDir, folderName);

    if (!fs.existsSync(agentDir)) {
      fs.mkdirSync(agentDir, { recursive: true });
      console.log(`Created directory: ${agentDir}`);
    }

    const filePath = path.join(agentDir, 'agent.json');
    fs.writeFileSync(filePath, JSON.stringify(agent, null, 2) + '\n');
    console.log(`Exported agent: ${agent.name} (${agent.id}) -> agents/${folderName}/agent.json`);
  }

  console.log('Agent export complete!');
}

exportAgents().catch(err => {
  console.error('Error exporting agents:', err.message);
  process.exit(1);
});
