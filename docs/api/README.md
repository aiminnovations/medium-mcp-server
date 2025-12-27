# Medium MCP Server - API Reference

Complete API documentation for all MCP tools exposed by the Medium MCP Server.

## Overview

The Medium MCP Server exposes tools following the [Model Context Protocol](https://modelcontextprotocol.io/) specification. These tools can be invoked by any MCP-compatible client (Claude Desktop, Claude Code, Cursor, etc.).

## Tools

### publish-article

Publish a new article to Medium.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `title` | `string` | Yes | Article title (minimum 1 character) |
| `content` | `string` | Yes | Article content in Markdown format (minimum 10 characters) |
| `tags` | `string[]` | No | Array of tags for the article (max 5 tags) |
| `publicationId` | `string` | No | ID of the publication to publish to |

#### Schema (Zod)

```typescript
{
  title: z.string().min(1, "Title is required"),
  content: z.string().min(10, "Content must be at least 10 characters"),
  tags: z.array(z.string()).optional(),
  publicationId: z.string().optional()
}
```

#### Example Request

```json
{
  "tool": "publish-article",
  "arguments": {
    "title": "Getting Started with MCP",
    "content": "# Introduction\n\nThis is a guide to the Model Context Protocol...",
    "tags": ["programming", "ai", "mcp"]
  }
}
```

#### Success Response

```json
{
  "content": [
    {
      "type": "text",
      "text": "{\n  \"id\": \"abc123\",\n  \"title\": \"Getting Started with MCP\",\n  \"url\": \"https://medium.com/@user/getting-started-with-mcp-abc123\",\n  \"publishStatus\": \"draft\"\n}"
    }
  ]
}
```

#### Error Response

```json
{
  "isError": true,
  "content": [
    {
      "type": "text",
      "text": "Error publishing article: Unauthorized - invalid credentials"
    }
  ]
}
```

---

### get-publications

Retrieve the user's Medium publications.

#### Parameters

This tool takes no parameters.

#### Schema (Zod)

```typescript
{}
```

#### Example Request

```json
{
  "tool": "get-publications",
  "arguments": {}
}
```

#### Success Response

```json
{
  "content": [
    {
      "type": "text",
      "text": "{\n  \"data\": [\n    {\n      \"id\": \"pub123\",\n      \"name\": \"Tech Insights\",\n      \"description\": \"A publication about technology\",\n      \"url\": \"https://medium.com/tech-insights\",\n      \"imageUrl\": \"https://cdn-images-1.medium.com/...\"\n    }\n  ]\n}"
    }
  ]
}
```

#### Error Response

```json
{
  "isError": true,
  "content": [
    {
      "type": "text",
      "text": "Error retrieving publications: Authentication required"
    }
  ]
}
```

---

### search-articles

Search and filter Medium articles.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `keywords` | `string[]` | No | Keywords to search for |
| `publicationId` | `string` | No | Filter by publication ID |
| `tags` | `string[]` | No | Filter by tags |

#### Schema (Zod)

```typescript
{
  keywords: z.array(z.string()).optional(),
  publicationId: z.string().optional(),
  tags: z.array(z.string()).optional()
}
```

#### Example Request

```json
{
  "tool": "search-articles",
  "arguments": {
    "keywords": ["javascript", "react"],
    "tags": ["programming"]
  }
}
```

#### Success Response

```json
{
  "content": [
    {
      "type": "text",
      "text": "{\n  \"data\": [\n    {\n      \"id\": \"art123\",\n      \"title\": \"React Best Practices\",\n      \"author\": \"John Doe\",\n      \"url\": \"https://medium.com/@johndoe/react-best-practices\",\n      \"publishedAt\": \"2024-01-15T10:30:00Z\",\n      \"tags\": [\"react\", \"javascript\", \"programming\"]\n    }\n  ]\n}"
    }
  ]
}
```

#### Error Response

```json
{
  "isError": true,
  "content": [
    {
      "type": "text",
      "text": "Error searching articles: Rate limit exceeded"
    }
  ]
}
```

---

## HTTP Endpoints (SSE Mode)

When running with SSE transport, the following HTTP endpoints are available:

### GET /

Returns server information.

**Response:**
```json
{
  "name": "medium-mcp-server",
  "version": "1.0.0",
  "description": "MCP Server for Medium API Integration",
  "endpoints": {
    "sse": "/sse",
    "messages": "/messages",
    "health": "/health"
  }
}
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "service": "medium-mcp-server",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### GET /sse

Establish an SSE (Server-Sent Events) connection for MCP communication.

**Headers:**
- `Accept: text/event-stream`

**Response:** SSE stream with MCP messages

### POST /messages

Send MCP messages to the server.

**Query Parameters:**
- `sessionId` (required): The session ID from the SSE connection

**Request Body:** MCP JSON-RPC message

**Response:** MCP JSON-RPC response

---

## Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| `UNAUTHORIZED` | Missing or invalid credentials | Check MEDIUM_CLIENT_ID and MEDIUM_CLIENT_SECRET |
| `RATE_LIMITED` | Too many requests | Wait and retry with exponential backoff |
| `VALIDATION_ERROR` | Invalid parameters | Check parameter types and required fields |
| `NOT_FOUND` | Resource not found | Verify the resource ID exists |
| `SERVER_ERROR` | Internal server error | Check server logs for details |

---

## Rate Limits

The Medium API enforces rate limits. The server will return appropriate error messages when limits are exceeded.

| Endpoint | Limit |
|----------|-------|
| Publishing | 10 articles per day |
| Reading | 100 requests per minute |
| Search | 30 requests per minute |

---

## Testing with MCP Inspector

### CLI Commands

```bash
# List all tools
npx @modelcontextprotocol/inspector --cli node dist/index.js --method tools/list

# Call publish-article
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name publish-article \
  --tool-arg 'title=Test Article' \
  --tool-arg 'content=# Hello\n\nThis is test content.'

# Call get-publications
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get-publications

# Call search-articles
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name search-articles \
  --tool-arg 'keywords=["javascript"]'
```

### UI Mode

```bash
# Launch interactive inspector
npx @modelcontextprotocol/inspector node dist/index.js
```

Open http://localhost:6274 to access the Inspector UI.
