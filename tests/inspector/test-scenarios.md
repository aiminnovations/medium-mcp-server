# MCP Inspector Test Scenarios

Manual test scenarios for the medium-mcp-server using MCP Inspector.

## Prerequisites

1. Build the project: `npm run build`
2. Set up environment variables in `.env`:
   ```
   MEDIUM_CLIENT_ID=your_client_id
   MEDIUM_CLIENT_SECRET=your_client_secret
   ```

## Running the Inspector

### Interactive UI Mode
```bash
# Windows
tests\inspector\run-inspector.cmd

# Linux/Mac
./tests/inspector/run-inspector.sh

# With config file
./tests/inspector/run-inspector.sh --config
```

### CLI Mode (Automated)
```bash
# Run basic tests
./tests/inspector/run-cli-tests.sh

# Run with verbose output
./tests/inspector/run-cli-tests.sh --verbose
```

---

## Tool Test Scenarios

### 1. publish-article

**Purpose**: Publish a new article to Medium

#### Valid Cases

| Test Case | Parameters | Expected Result |
|-----------|------------|-----------------|
| Basic publish | `title`: "Test Article", `content`: "# Hello\n\nThis is content" | Success with article URL |
| With tags | `title`: "Tagged Post", `content`: "Content here", `tags`: ["tech", "programming"] | Success with tags applied |
| With publication | `title`: "Pub Post", `content`: "Content", `publicationId`: "valid-pub-id" | Published to specific publication |

#### Edge Cases

| Test Case | Parameters | Expected Result |
|-----------|------------|-----------------|
| Empty title | `title`: "", `content`: "Some content" | Error: title required |
| Empty content | `title`: "Title", `content`: "" | Error: content required |
| Long title (>100 chars) | `title`: "Very long title...", `content`: "Content" | Verify handling |
| Special chars in title | `title`: "Test <script> & \"quotes\"", `content`: "Content" | Proper escaping |
| Invalid publicationId | `title`: "Title", `content`: "Content", `publicationId`: "invalid" | Error handling |

#### CLI Commands
```bash
# Basic publish
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name publish-article \
  --tool-arg 'title=Test Article' \
  --tool-arg 'content=# Hello World\n\nThis is a test article.'

# With tags
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name publish-article \
  --tool-arg 'title=Tagged Article' \
  --tool-arg 'content=Article content here' \
  --tool-arg 'tags=["tech", "testing"]'
```

---

### 2. get-publications

**Purpose**: Retrieve user's Medium publications

#### Valid Cases

| Test Case | Parameters | Expected Result |
|-----------|------------|-----------------|
| List publications | (none) | Array of publication objects |

#### Edge Cases

| Test Case | Parameters | Expected Result |
|-----------|------------|-----------------|
| No publications | (none) | Empty array |
| Invalid auth | (bad token) | Authentication error |

#### CLI Commands
```bash
# List publications
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get-publications
```

---

### 3. search-articles

**Purpose**: Search and filter Medium articles

#### Valid Cases

| Test Case | Parameters | Expected Result |
|-----------|------------|-----------------|
| By keywords | `keywords`: ["javascript", "react"] | Matching articles |
| By tags | `tags`: ["programming"] | Articles with tag |
| By publication | `publicationId`: "pub-id" | Publication articles |
| Combined | `keywords`: ["api"], `tags`: ["tech"] | Filtered results |

#### Edge Cases

| Test Case | Parameters | Expected Result |
|-----------|------------|-----------------|
| No parameters | (none) | All/recent articles |
| No matches | `keywords`: ["xyznonexistent123"] | Empty array |
| Invalid publication | `publicationId`: "invalid" | Error or empty |

#### CLI Commands
```bash
# Search by keywords
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name search-articles \
  --tool-arg 'keywords=["javascript"]'

# Search by tags
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name search-articles \
  --tool-arg 'tags=["programming"]'

# Combined search
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name search-articles \
  --tool-arg 'keywords=["api"]' \
  --tool-arg 'publicationId=your-pub-id'
```

---

## Transport Testing

### STDIO Transport (Default)
```bash
npx @modelcontextprotocol/inspector node dist/index.js
```

### SSE Transport
```bash
# Start server with SSE transport
PORT=3000 node dist/index.js

# Connect inspector to SSE endpoint
npx @modelcontextprotocol/inspector --cli http://localhost:3000/sse --method tools/list
```

---

## Debugging Scenarios

### 1. Connection Issues
- Check server process is running
- Verify environment variables loaded
- Check for error messages in console

### 2. Authentication Errors
- Verify MEDIUM_CLIENT_ID set
- Verify MEDIUM_CLIENT_SECRET set
- Check token expiration

### 3. Tool Errors
- Use `--verbose` mode for detailed output
- Check request/response in Inspector UI
- Review server logs for errors

---

## Quick Reference

```bash
# List available tools
npx @modelcontextprotocol/inspector --cli node dist/index.js --method tools/list

# List resources (if any)
npx @modelcontextprotocol/inspector --cli node dist/index.js --method resources/list

# List prompts (if any)
npx @modelcontextprotocol/inspector --cli node dist/index.js --method prompts/list

# Get server capabilities
npx @modelcontextprotocol/inspector --cli node dist/index.js --method initialize
```
