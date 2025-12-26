import { config } from 'dotenv';
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import MediumAuth from './auth';
import MediumClient from './client';
import { createHttpServer } from './transports/sse';

// Load environment variables
config();

class MediumMcpServer {
  private server: McpServer;
  private mediumClient: MediumClient;
  private auth: MediumAuth;

  constructor() {
    // Initialize authentication
    this.auth = new MediumAuth();

    // Initialize Medium client
    this.mediumClient = new MediumClient(this.auth);

    // Create MCP server instance
    this.server = new McpServer({
      name: "medium-mcp-server",
      version: "1.0.0"
    });

    this.registerTools();
  }

  private registerTools() {
    // Tool for publishing articles
    this.server.tool(
      "publish-article",
      "Publish a new article on Medium",
      {
        title: z.string().min(1, "Title is required"),
        content: z.string().min(10, "Content must be at least 10 characters"),
        tags: z.array(z.string()).optional(),
        publicationId: z.string().optional()
      },
      async (args) => {
        try {
          const publishResult = await this.mediumClient.publishArticle({
            title: args.title,
            content: args.content,
            tags: args.tags,
            publicationId: args.publicationId
          });

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(publishResult, null, 2)
              }
            ]
          };
        } catch (error: any) {
          return {
            isError: true,
            content: [
              {
                type: "text",
                text: `Error publishing article: ${error.message}`
              }
            ]
          };
        }
      }
    );

    // Tool for retrieving user publications
    this.server.tool(
      "get-publications",
      "Retrieve user's publications",
      {},
      async () => {
        try {
          const publications = await this.mediumClient.getUserPublications();

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(publications, null, 2)
              }
            ]
          };
        } catch (error: any) {
          return {
            isError: true,
            content: [
              {
                type: "text",
                text: `Error retrieving publications: ${error.message}`
              }
            ]
          };
        }
      }
    );

    // Tool for searching articles
    this.server.tool(
      "search-articles",
      "Search and filter Medium articles",
      {
        keywords: z.array(z.string()).optional(),
        publicationId: z.string().optional(),
        tags: z.array(z.string()).optional()
      },
      async (args) => {
        try {
          const articles = await this.mediumClient.searchArticles({
            keywords: args.keywords,
            publicationId: args.publicationId,
            tags: args.tags
          });

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(articles, null, 2)
              }
            ]
          };
        } catch (error: any) {
          return {
            isError: true,
            content: [
              {
                type: "text",
                text: `Error searching articles: ${error.message}`
              }
            ]
          };
        }
      }
    );
  }

  // Get the underlying server for transport connection
  getServer() {
    return this.server;
  }

  // Authenticate with Medium
  async authenticate() {
    await this.auth.authenticate();
  }

  // Start with stdio transport (local development)
  async startStdio() {
    await this.authenticate();
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("🚀 MediumMCP Server Initialized (stdio transport)");
  }

  // Start with HTTP/SSE transport (remote/Render deployment)
  async startHttp(port: number) {
    await this.authenticate();
    createHttpServer(this.server as any, port);
  }
}

// Main execution
async function main() {
  const server = new MediumMcpServer();

  const port = process.env.PORT;

  if (port) {
    // HTTP/SSE transport for remote deployment (Render)
    console.log(`Starting in HTTP mode on port ${port}`);
    await server.startHttp(parseInt(port, 10));
  } else {
    // Stdio transport for local development
    console.error("Starting in stdio mode");
    await server.startStdio();
  }
}

main().catch(error => {
  console.error("Fatal error:", error);
  process.exit(1);
});
