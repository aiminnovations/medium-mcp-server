#!/bin/bash
# MCP Inspector - Interactive Testing for medium-mcp-server
# This script launches the MCP Inspector UI for interactive testing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi

# Build the project first
echo "Building the project..."
cd "$PROJECT_ROOT"
npm run build

# Launch MCP Inspector with our server
echo "Launching MCP Inspector..."
echo "UI will be available at http://localhost:6274"
echo ""

# Use config file if available, otherwise use direct command
if [ "$1" == "--config" ]; then
    npx @modelcontextprotocol/inspector --config "$SCRIPT_DIR/mcp-config.json" --server medium-mcp-server
else
    npx @modelcontextprotocol/inspector \
        -e MEDIUM_CLIENT_ID="${MEDIUM_CLIENT_ID}" \
        -e MEDIUM_CLIENT_SECRET="${MEDIUM_CLIENT_SECRET}" \
        node dist/index.js
fi
