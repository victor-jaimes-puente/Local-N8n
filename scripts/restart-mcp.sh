#!/bin/bash
echo "Killing any running n8n-mcp node processes to force Antigravity IDE to restart the MCP server..."
pkill -f "n8n-mcp"
if [ $? -eq 0 ]; then
    echo "Successfully killed the MCP server process. The IDE will restart it automatically on the next tool call."
else
    echo "No running MCP server process found. The IDE will start it automatically on the next tool call."
fi
