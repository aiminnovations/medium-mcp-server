import express, { Request, Response } from 'express';
import { SSEServerTransport } from '@modelcontextprotocol/sdk/server/sse.js';
import { Server } from '@modelcontextprotocol/sdk/server/index.js';

const transports: { [sessionId: string]: SSEServerTransport } = {};

export function createHttpServer(mcpServer: Server, port: number) {
  const app = express();
  app.use(express.json());

  // Health check endpoint
  app.get('/health', (_req: Request, res: Response) => {
    res.json({
      status: 'healthy',
      service: 'medium-mcp-server',
      timestamp: new Date().toISOString()
    });
  });

  // Info endpoint
  app.get('/', (_req: Request, res: Response) => {
    res.json({
      name: 'medium-mcp-server',
      version: '1.0.0',
      description: 'MCP Server for Medium API Integration',
      endpoints: {
        sse: '/sse',
        messages: '/messages',
        health: '/health'
      }
    });
  });

  // SSE endpoint for establishing connection
  app.get('/sse', async (req: Request, res: Response) => {
    console.log('SSE connection established');

    const transport = new SSEServerTransport('/messages', res);
    const sessionId = transport.sessionId;
    transports[sessionId] = transport;

    res.on('close', () => {
      console.log(`SSE connection closed: ${sessionId}`);
      delete transports[sessionId];
    });

    await mcpServer.connect(transport);
  });

  // Messages endpoint for receiving client messages
  app.post('/messages', async (req: Request, res: Response) => {
    const sessionId = req.query.sessionId as string;

    if (!sessionId) {
      res.status(400).json({ error: 'Missing sessionId query parameter' });
      return;
    }

    const transport = transports[sessionId];
    if (!transport) {
      res.status(404).json({ error: 'Session not found' });
      return;
    }

    try {
      await transport.handlePostMessage(req, res, req.body);
    } catch (error: any) {
      console.error('Error handling message:', error);
      res.status(500).json({ error: error.message });
    }
  });

  const server = app.listen(port, () => {
    console.log(`🚀 Medium MCP Server running on port ${port}`);
    console.log(`   Health: http://localhost:${port}/health`);
    console.log(`   SSE: http://localhost:${port}/sse`);
  });

  return server;
}
