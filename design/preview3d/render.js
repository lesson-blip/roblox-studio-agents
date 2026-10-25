// Renders the Seed Siege 3D preview to PNGs.
// Usage: node render.js [outDir]   (default ../../media/3d)
const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const ROOT = __dirname;
const OUT = path.resolve(process.argv[2] || path.join(ROOT, '..', '..', 'media', '3d'));
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.ttf': 'font/ttf', '.png': 'image/png', '.json': 'application/json' };

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
  const shots = [['hero', 'preview-hero.png'], ['close', 'preview-close.png'], ['overview', 'preview-overview.png']];
  for (const [view, file] of shots) {
    const page = await browser.newPage({ viewport: { width: 1600, height: 900 }, deviceScaleFactor: 1 });
    page.on('console', m => { if (m.type() === 'error' || m.type() === 'warning') console.log(`[${view}] ${m.type()}: ${m.text()}`); });
    page.on('pageerror', e => console.log(`[${view}] pageerror: ${e.message}`));
    await page.goto(`http://127.0.0.1:${port}/index.html?view=${view}`);
    await page.waitForFunction(() => window.READY === true, null, { timeout: 180000 });
    await page.waitForTimeout(300);
    await page.screenshot({ path: path.join(OUT, file) });
    console.log('wrote', path.join(OUT, file));
    await page.close();
  }
  await browser.close();
  server.close();
})().catch(e => { console.error(e); process.exit(1); });
