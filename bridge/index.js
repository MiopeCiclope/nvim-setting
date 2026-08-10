import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { execSync } from 'child_process';
import { existsSync, readdirSync } from 'fs';

function findSocket() {
  const name = process.env.REPO_NAME;
  if (name) {
    const path = `/tmp/nvim-${name}.pipe`;
    if (existsSync(path)) return path;
  }
  const sockets = readdirSync('/tmp').filter(f => f.startsWith('nvim-') && f.endsWith('.pipe'));
  if (sockets.length === 1) return `/tmp/${sockets[0]}`;
  if (sockets.length === 0) throw new Error('No nvim socket found. Is nvim running via orchestra?');
  throw new Error(`Multiple nvim sockets: ${sockets.join(', ')}. Set REPO_NAME to disambiguate.`);
}

function nvimExec(socket, cmd) {
  const escaped = cmd.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
  execSync(`nvim --server "${socket}" --remote-expr "execute('${escaped}')"`, { stdio: 'pipe' });
}

const TOOLS = [
  {
    name: 'nvim_open',
    description: 'Open a file in nvim, optionally at a specific line. Path can be absolute or relative to REPO_PATH.',
    inputSchema: {
      type: 'object',
      properties: {
        path: { type: 'string', description: 'File path (absolute or relative to repo root)' },
        line: { type: 'number', description: 'Line number to jump to' },
      },
      required: ['path'],
    },
  },
  {
    name: 'nvim_load_review',
    description: 'Load Claude review concerns into nvim quickfix list and open it.',
    inputSchema: {
      type: 'object',
      properties: {
        concerns: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              file: { type: 'string' },
              line: { type: 'number' },
              message: { type: 'string' },
            },
            required: ['file', 'line', 'message'],
          },
        },
      },
      required: ['concerns'],
    },
  },
  {
    name: 'nvim_git',
    description: 'Run a fugitive git command in nvim (e.g. "diff origin/main...HEAD", "blame").',
    inputSchema: {
      type: 'object',
      properties: {
        command: { type: 'string', description: 'Fugitive command without the :G prefix' },
      },
      required: ['command'],
    },
  },
  {
    name: 'nvim_exec',
    description: 'Execute any nvim command directly.',
    inputSchema: {
      type: 'object',
      properties: {
        command: { type: 'string', description: 'Vim command (without leading colon)' },
      },
      required: ['command'],
    },
  },
];

const server = new Server(
  { name: 'nvim-bridge', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools: TOOLS }));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  return { content: [{ type: 'text', text: 'not implemented' }] };
});

const transport = new StdioServerTransport();
await server.connect(transport);
