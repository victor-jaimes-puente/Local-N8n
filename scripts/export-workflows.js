#!/usr/bin/env node

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const fs = require('fs');
const path = require('path');

const N8N_API_URL = process.env.N8N_API_URL || 'https://n8n.local-n8n.com/api/v1';
const N8N_API_KEY = process.env.N8N_API_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NGQ4MTcxOC0xZjVkLTQxNTQtYWMxOC0xMzc2NTk1MzVmZGIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiMmIzZDdjMDMtODZlNi00MGYwLTlhOWMtZjZiYjM2NGI4NzhlIiwiaWF0IjoxNzg4MjE1NzUxfQ.aT_eCBS-0dPfsPLO97o1kJIhXVTIHVpn418gGIx_9LU';

async function exportWorkflows() {
  console.log(`Fetching workflows from ${N8N_API_URL}...`);
  
  const response = await fetch(`${N8N_API_URL}/workflows`, {
    headers: {
      'X-N8N-API-KEY': N8N_API_KEY,
      'Accept': 'application/json'
    }
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch workflows: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  const workflows = data.data;

  console.log(`Found ${workflows.length} workflows.`);

  const workflowsDir = path.join(__dirname, '..', 'workflows');
  if (!fs.existsSync(workflowsDir)) {
    fs.mkdirSync(workflowsDir, { recursive: true });
  }

  for (const wf of workflows) {
    const folderName = wf.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    const wfDir = path.join(workflowsDir, folderName);
    
    if (!fs.existsSync(wfDir)) {
      fs.mkdirSync(wfDir, { recursive: true });
      console.log(`Created directory: ${wfDir}`);
    }

    const filePath = path.join(wfDir, 'workflow.json');
    
    const workflowJson = JSON.stringify(wf, null, 2);
    fs.writeFileSync(filePath, workflowJson);
    console.log(`Exported: ${wf.name} -> workflows/${folderName}/workflow.json`);
    
    const readmePath = path.join(wfDir, 'README.md');
    if (!fs.existsSync(readmePath)) {
      const readmeContent = `# Workflow: ${wf.name}\n\nID: \`${wf.id}\`\n\n*(Add documentation here)*\n`;
      fs.writeFileSync(readmePath, readmeContent);
    }
  }
  
  console.log('Export complete!');
}

exportWorkflows().catch(err => {
  console.error("Error exporting workflows:", err.message);
  process.exit(1);
});
