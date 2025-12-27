#!/bin/bash
# MCP Inspector CLI Tests for medium-mcp-server
# Automated testing using MCP Inspector CLI mode

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi

# Build the project first
echo -e "${YELLOW}Building the project...${NC}"
cd "$PROJECT_ROOT"
npm run build

echo ""
echo "========================================"
echo "  MCP Inspector CLI Tests"
echo "========================================"
echo ""

PASS=0
FAIL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local method="$2"
    shift 2
    local extra_args="$@"

    echo -n "Testing: $test_name... "

    if npx @modelcontextprotocol/inspector --cli node dist/index.js --method "$method" $extra_args > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
    else
        echo -e "${RED}FAIL${NC}"
        ((FAIL++))
    fi
}

# Function to run a test and show output
run_test_verbose() {
    local test_name="$1"
    local method="$2"
    shift 2
    local extra_args="$@"

    echo ""
    echo -e "${YELLOW}Testing: $test_name${NC}"
    echo "Command: npx @modelcontextprotocol/inspector --cli node dist/index.js --method $method $extra_args"
    echo ""

    npx @modelcontextprotocol/inspector --cli \
        -e MEDIUM_CLIENT_ID="${MEDIUM_CLIENT_ID}" \
        -e MEDIUM_CLIENT_SECRET="${MEDIUM_CLIENT_SECRET}" \
        node dist/index.js --method "$method" $extra_args

    echo ""
}

# ========================================
# Tool Discovery Tests
# ========================================
echo "--- Tool Discovery Tests ---"

run_test "List all tools" "tools/list"

# ========================================
# Tool Call Tests (with verbose output)
# ========================================
if [ "$1" == "--verbose" ]; then
    echo ""
    echo "--- Verbose Tool Tests ---"

    run_test_verbose "List tools (verbose)" "tools/list"

    run_test_verbose "Get publications" "tools/call" \
        --tool-name "get-publications"

    run_test_verbose "Search articles" "tools/call" \
        --tool-name "search-articles" \
        --tool-arg 'keywords=["programming"]'
fi

# ========================================
# Summary
# ========================================
echo ""
echo "========================================"
echo "  Test Summary"
echo "========================================"
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    exit 1
fi
