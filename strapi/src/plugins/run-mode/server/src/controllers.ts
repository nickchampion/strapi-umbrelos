import fs from 'node:fs';
import path from 'node:path';

// Persisted to the mounted src/ volume so it survives container restarts
const MODE_FILE = path.join(process.cwd(), 'src', '.strapi-run-mode');

export default ({ strapi }: { strapi: any }) => ({
  async find(ctx: any) {
    let mode = 'development';
    try {
      if (fs.existsSync(MODE_FILE)) {
        const raw = fs.readFileSync(MODE_FILE, 'utf8').trim();
        if (raw === 'production' || raw === 'development') mode = raw;
      }
    } catch {}
    ctx.body = { data: { mode } };
  },

  async update(ctx: any) {
    const body = ctx.request.body?.data ?? ctx.request.body ?? {};
    const { mode } = body;

    if (mode !== 'development' && mode !== 'production') {
      ctx.status = 400;
      ctx.body = { error: 'mode must be "development" or "production"' };
      return;
    }

    try {
      fs.mkdirSync(path.dirname(MODE_FILE), { recursive: true });
      fs.writeFileSync(MODE_FILE, mode, 'utf8');
    } catch (err: any) {
      ctx.status = 500;
      ctx.body = { error: `Failed to write mode file: ${err.message}` };
      return;
    }

    ctx.body = { data: { mode, restarting: true } };

    // Give the response time to flush before the process exits
    setTimeout(() => process.exit(0), 500);
  },
});
