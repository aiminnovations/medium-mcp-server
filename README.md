# <img src="https://cdn-static-1.medium.com/_/fp/icons/Medium-Avatar-500x500.svg" alt="Medium Logo" width="32" height="32"> Medium MCP Server

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-22%2B-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.2-blue.svg)](https://www.typescriptlang.org/)
[![MCP](https://img.shields.io/badge/MCP-1.0-purple.svg)](https://modelcontextprotocol.io/)

> Model Context Protocol (MCP) server for programmatic Medium API integration, enabling AI-powered content publishing and retrieval.

## Overview

Medium MCP Server is an innovative solution for programmatically interacting with Medium's content ecosystem. It implements the [Model Context Protocol](https://modelcontextprotocol.io/) to enable intelligent, context-aware content operations through AI assistants like Claude.

**[Read the Full Story: From Thought to Published](https://dishantraghav27.medium.com/from-thought-to-published-how-mediummcp-streamlines-the-ai-to-medium-platform-workflow-9e436159d1a2)**

## Key Features

- **Publish Articles** - Create and publish articles to Medium directly from AI assistants
- **Manage Publications** - Retrieve and manage your Medium publications
- **Search Content** - Search and filter articles by keywords, tags, and publications
- **Dual Transport** - Supports both stdio (local) and SSE (remote) transports
- **Type-Safe** - Full TypeScript support with Zod validation

## Quick Start

### Prerequisites

- Node.js 22+
- npm or yarn
- Medium API credentials ([Get yours here](https://medium.com/me/settings))

### Installation

```bash
# Clone the repository
git clone https://github.com/Dishant27/medium-mcp-server.git
cd medium-mcp-server

# Install dependencies
npm install

# Build the project
npm run build
```

### Configuration

Create a `.env` file in the project root:

```env
MEDIUM_CLIENT_ID=your_client_id
MEDIUM_CLIENT_SECRET=your_client_secret
```

### Running the Server

```bash
# Development mode (with hot reload)
npm run dev

# Production mode
npm run build
npm start

# With SSE transport (for remote deployment)
PORT=3000 npm start
```

## MCP Tools

The server exposes three tools for AI assistants:

| Tool | Description |
|------|-------------|
| `publish-article` | Publish a new article to Medium |
| `get-publications` | Retrieve user's Medium publications |
| `search-articles` | Search and filter Medium articles |

See [API Documentation](docs/api/README.md) for detailed tool specifications.

## Client Configuration

### Claude Desktop

Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "medium": {
      "command": "node",
      "args": ["/path/to/medium-mcp-server/dist/index.js"],
      "env": {
        "MEDIUM_CLIENT_ID": "your_client_id",
        "MEDIUM_CLIENT_SECRET": "your_client_secret"
      }
    }
  }
}
```

### Claude Code / Cursor

Add to your `mcp.json`:

```json
{
  "mcpServers": {
    "medium": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "/path/to/medium-mcp-server",
      "env": {
        "MEDIUM_CLIENT_ID": "your_client_id",
        "MEDIUM_CLIENT_SECRET": "your_client_secret"
      }
    }
  }
}
```

### SSE Transport (Remote)

For remote deployment or SSE connections:

```json
{
  "mcpServers": {
    "medium": {
      "type": "sse",
      "url": "http://localhost:3000/sse"
    }
  }
}
```

## Testing with MCP Inspector

Interactive testing using the MCP Inspector:

```bash
# Launch Inspector UI
npm run test:inspector

# CLI mode - list tools
npm run test:inspector:cli

# With config file
npm run test:inspector:config
```

See [Test Documentation](tests/inspector/test-scenarios.md) for detailed test scenarios.

## Project Structure

```
medium-mcp-server/
├── src/
│   ├── index.ts          # Main server entry point
│   ├── auth.ts           # Authentication logic
│   ├── client.ts         # Medium API client
│   └── transports/
│       └── sse.ts        # SSE transport implementation
├── dist/                 # Compiled JavaScript
├── tests/
│   └── inspector/        # MCP Inspector test scripts
├── docs/                 # Documentation
└── examples/             # Configuration examples
```

## API Endpoints (SSE Mode)

When running with SSE transport (`PORT=3000`):

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Server info |
| `/health` | GET | Health check |
| `/sse` | GET | Establish SSE connection |
| `/messages` | POST | Send MCP messages |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `MEDIUM_CLIENT_ID` | Yes | Medium OAuth client ID |
| `MEDIUM_CLIENT_SECRET` | Yes | Medium OAuth client secret |
| `PORT` | No | HTTP port for SSE mode (uses stdio if not set) |
| `LOG_LEVEL` | No | Logging level (debug, info, warn, error) |

## Development

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build

# Run tests
npm test

# Test with MCP Inspector
npm run test:inspector
```

## Documentation

- [API Reference](docs/api/README.md) - Detailed tool specifications
- [Architecture](docs/architecture/README.md) - System design overview
- [Test Scenarios](tests/inspector/test-scenarios.md) - Manual test cases

## Technology Stack

- **Runtime**: Node.js 22+
- **Language**: TypeScript 5.2
- **Protocol**: Model Context Protocol (MCP) SDK
- **HTTP**: Express.js
- **Validation**: Zod
- **API Client**: Axios

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Dishant Kumar** - [Medium](https://dishantraghav27.medium.com/)

## Acknowledgments

- [Model Context Protocol](https://modelcontextprotocol.io/) - The protocol specification
- [Anthropic](https://www.anthropic.com/) - MCP SDK development
- [Medium](https://medium.com/) - Content platform API
