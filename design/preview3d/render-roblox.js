// Renders roblox.html (the parts the Roblox code builds) to PNGs.
// Usage: lune run tools/export-parts [w h]; then node render-roblox.js [outDir]
// (default ../../media/3d). Needs Playwright with Chromium.
const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const ROOT = __dirname;
const OUT = path.resolve(process.argv[2] || path.join(ROOT, '..', '..', 'media', '3d'));
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json' };
const data = JSON.parse(fs.readFileSync(path.join(ROOT, 'export', 'parts.json'), 'utf8'));

const server = http.createServer((req, res) => {
  const p = path.join(ROOT, decodeURIComponent(req.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { res.writeHead(404); return res.end(); }
  res.writeHead(200, { 'Content-Type': TYPES[path.extname(p)] || 'application/octet-stream' });
  fs.createReadStream(p).pipe(res);
});

(async () => {
  await new Promise(r => server.listen(0, '127.0.0.1', r));
  const port = server.address().port;
  fs.mkdirSync(OUT, { recursive: true });
  const args = ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'];
  let browser;
  try { browser = await chromium.launch({ args }); }
  catch (e) { browser = await chromium.launch({ args, executablePath: '/opt/pw-browsers/chromium' }); }
  const tag = `${data.width}x${data.height}`;
  for (const view of ['game', 'overview']) {
    const page = await browser.newPage({ viewport: { width: data.width, height: data.height }, deviceScaleFactor: 1 });
    page.on('console', m => { if (m.type() === 'error') console.log(`[${view}] ${m.text()}`); });
    page.on('pageerror', e => console.log(`[${view}] pageerror: ${e.message}`));
    await page.goto(`http://127.0.0.1:${port}/roblox.html?view=${view}`);
    await page.waitForFunction(() => window.READY === true, null, { timeout: 180000 });
    const file = path.join(OUT, `roblox-parts-${view}-${tag}.png`);
    await page.screenshot({ path: file });
    console.log('wrote', file);
    await page.close();
  }
  await browser.close();
  server.close();
})().catch(e => { console.error(e); process.exit(1); });
