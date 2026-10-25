// Seed Siege: three.js mock-up of the planned Roblox look (Backyard Patch).
// Views: index.html?view=hero | close | overview
import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/geometries/RoundedBoxGeometry.js';

await document.fonts.load('700 84px Fredoka');
const params = new URLSearchParams(location.search);
const VIEW = params.get('view') || 'hero';
const W = 1600, H = 900;
const T = 2; // world units per tile

// ---------- field data (design/prototype/fields.py, Backyard Patch) ----------
const COLS = 12, ROWS = 8;
const WAYPOINTS = [[0,1],[9,1],[9,4],[2,4],[2,6],[11,6]];
const pathSet = new Set();
for (let i = 0; i < WAYPOINTS.length - 1; i++) {
  const [ax, ay] = WAYPOINTS[i], [bx, by] = WAYPOINTS[i + 1];
  const n = Math.max(Math.abs(bx - ax), Math.abs(by - ay));
  for (let k = 0; k <= n; k++) pathSet.add((ax + Math.sign(bx - ax) * k) + ',' + (ay + Math.sign(by - ay) * k));
}
const isPath = (x, y) => pathSet.has(x + ',' + y);
const tw = (x, y) => new THREE.Vector3((x - 5.5) * T, 0, (y - 3.5) * T);
const ROUTE_LEN = 30;
function routeAt(d) {
  let left = d;
  for (let i = 0; i < WAYPOINTS.length - 1; i++) {
    const [ax, ay] = WAYPOINTS[i], [bx, by] = WAYPOINTS[i + 1];
    const len = Math.abs(bx - ax) + Math.abs(by - ay);
    if (left <= len || i === WAYPOINTS.length - 2) {
      const t = Math.min(1, Math.max(0, left / len));
      const x = ax + (bx - ax) * t, y = ay + (by - ay) * t;
      return { pos: tw(x, y), dir: new THREE.Vector3(Math.sign(bx - ax), 0, Math.sign(by - ay)) };
    }
    left -= len;
  }
}

// ---------- renderer ----------
const canvas = document.getElementById('c');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(2);
renderer.setSize(W, H, false);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.05;
renderer.outputColorSpace = THREE.SRGBColorSpace;

const scene = new THREE.Scene();
scene.fog = new THREE.Fog(0xbfe3f5, 60, 150);

// ---------- helpers ----------
const matCache = new Map();
function mat(color, o = {}) {
  const key = color + JSON.stringify(o);
  if (matCache.has(key)) return matCache.get(key);
  const m = new THREE.MeshStandardMaterial(Object.assign({ color, roughness: 0.55, metalness: 0.02 }, o));
  matCache.set(key, m);
  return m;
}
function mesh(geo, m, x = 0, y = 0, z = 0, parent) {
  const me = new THREE.Mesh(geo, m);
  me.position.set(x, y, z);
  if (parent) parent.add(me);
  return me;
}
const rbox = (w, h, d, r = 0.08, s = 3) => new RoundedBoxGeometry(w, h, d, s, Math.min(r, w / 2, h / 2, d / 2) - 0.001);
const sph = (r, ws = 20, hs = 14) => new THREE.SphereGeometry(r, ws, hs);
const cyl = (rt, rb, h, s = 16) => new THREE.CylinderGeometry(rt, rb, h, s);
let seed = 7;
const rnd = () => { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; };
const rr = (a, b) => a + (b - a) * rnd();

function stick(a, b, r, m, parent) { // cylinder between two points
  const dir = new THREE.Vector3().subVectors(b, a);
  const len = dir.length();
  const me = new THREE.Mesh(cyl(r, r, len, 8), m);
  me.position.copy(a).addScaledVector(dir, 0.5);
  me.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir.normalize());
  parent.add(me);
  return me;
}
function tube(points, r, m, parent, seg = 24) {
  const curve = new THREE.CatmullRomCurve3(points);
  const me = new THREE.Mesh(new THREE.TubeGeometry(curve, seg, r, 8, false), m);
  parent.add(me);
  return me;
}
function eyes(parent, y, z, spread, size, look = 0) {
  const white = mat(0xffffff, { roughness: 0.3 }), black = mat(0x15121c, { roughness: 0.2 });
  for (const s of [-1, 1]) {
    const e = mesh(sph(size, 16, 12), white, s * spread, y, z, parent);
    e.scale.set(1, 1.15, 0.8);
    mesh(sph(size * 0.55, 12, 10), black, s * spread + look * size * 0.3, y - size * 0.05, z + size * 0.62, parent);
    mesh(sph(size * 0.18, 8, 6), white, s * spread + size * 0.2, y + size * 0.25, z + size * 0.95, parent);
  }
}
function canvasTex(w, h, draw, repeat) {
  const c = document.createElement('canvas'); c.width = w; c.height = h;
  draw(c.getContext('2d'), w, h);
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  if (repeat) t.repeat.set(repeat[0], repeat[1]);
  t.anisotropy = 8;
  return t;
}
function corrugated(w, h, light, dark, n = 32) {
  return canvasTex(256, 64, (g, cw, ch) => {
    for (let i = 0; i < cw; i++) {
      const v = 0.5 + 0.5 * Math.sin(i / cw * Math.PI * 2 * n);
      g.fillStyle = `rgb(${dark.map((d, k) => Math.round(d + (light[k] - d) * v)).join(',')})`;
      g.fillRect(i, 0, 1, ch);
    }
  }, [w, h]);
}
function glowSprite(color, size, opacity = 1) {
  const tex = canvasTex(128, 128, (g) => {
    const gr = g.createRadialGradient(64, 64, 0, 64, 64, 64);
    gr.addColorStop(0, 'rgba(255,255,255,1)');
    gr.addColorStop(0.25, 'rgba(255,255,255,0.6)');
    gr.addColorStop(1, 'rgba(255,255,255,0)');
    g.fillStyle = gr; g.fillRect(0, 0, 128, 128);
  });
  const s = new THREE.Sprite(new THREE.SpriteMaterial({ map: tex, color, transparent: true, opacity, blending: THREE.AdditiveBlending, depthWrite: false, fog: false }));
  s.scale.set(size, size, 1);
  s.userData.noShadow = true;
  return s;
}

// ---------- sky ----------
{
  const g = new THREE.SphereGeometry(400, 32, 16);
  const m = new THREE.ShaderMaterial({
    side: THREE.BackSide, depthWrite: false, fog: false,
    uniforms: { top: { value: new THREE.Color(0x4aa8ec) }, mid: { value: new THREE.Color(0xa9dbf7) }, bot: { value: new THREE.Color(0xe9f6ff) } },
    vertexShader: 'varying vec3 vp; void main(){ vp = normalize(position); gl_Position = projectionMatrix*modelViewMatrix*vec4(position,1.0); }',
    fragmentShader: 'uniform vec3 top; uniform vec3 mid; uniform vec3 bot; varying vec3 vp; void main(){ float h = vp.y; vec3 c = h > 0.15 ? mix(mid, top, smoothstep(0.15, 0.7, h)) : mix(bot, mid, smoothstep(-0.1, 0.15, h)); gl_FragColor = vec4(c, 1.0); }'
  });
  const sky = new THREE.Mesh(g, m); sky.userData.noShadow = true; scene.add(sky);
}

// ---------- lights ----------
scene.add(new THREE.HemisphereLight(0xcfeaff, 0x6a8f3a, 1.15));
const sun = new THREE.DirectionalLight(0xfff0d6, 2.6);
sun.position.set(-22, 34, 20);
sun.castShadow = true;
sun.shadow.mapSize.set(4096, 4096);
Object.assign(sun.shadow.camera, { left: -34, right: 34, top: 30, bottom: -30, near: 1, far: 120 });
sun.shadow.bias = -0.0004;
sun.shadow.normalBias = 0.03;
sun.shadow.radius = 3;
scene.add(sun);
const fill = new THREE.DirectionalLight(0xbcd8ff, 0.45);
fill.position.set(20, 14, -18);
scene.add(fill);

// ---------- ground and tiles ----------
const YARD = { x0: -17, x1: 19, z0: -15.5, z1: 11.5 };
{
  const outer = mesh(new THREE.PlaneGeometry(400, 400), mat(0x5c9f3c, { roughness: 0.95 }), 0, -0.02, 0, scene);
  outer.rotation.x = -Math.PI / 2;
  const yard = mesh(rbox(YARD.x1 - YARD.x0, 0.3, YARD.z1 - YARD.z0, 0.1), mat(0x6fbf47, { roughness: 0.9 }),
    (YARD.x0 + YARD.x1) / 2, 0.0, (YARD.z0 + YARD.z1) / 2, scene);
  yard.position.y = -0.1;
}
const TILE_TOP = 0.42;
const grassA = mat(0x7dd14f, { roughness: 0.85 }), grassB = mat(0x6cc244, { roughness: 0.85 });
const soilM = mat(0x5b3a24, { roughness: 1 }), soilDark = mat(0x4a2e1b, { roughness: 1 });
const timber = mat(0xc28a52, { roughness: 0.75 });
const dirtM = mat(0x9a7350, { roughness: 1 });
const paverCols = [0xe6cfa3, 0xdcc395, 0xeed9b0, 0xd6b98a];
const paverMs = paverCols.map(c => mat(c, { roughness: 0.8 }));
const tileGeo = rbox(T - 0.06, 0.4, T - 0.06, 0.1);
const grassVar = [0x7dd14f, 0x78cc4b, 0x83d655, 0x6cc244, 0x67bd40, 0x72c849].map(c => mat(c, { roughness: 0.85 }));
const paverGeo = rbox(T / 2 - 0.12, 0.16, T / 2 - 0.12, 0.05, 2);
const PLOTS = new Set(['3,3','1,2','6,5','10,3','3,5','7,2','2,0','6,0','10,0','6,3','8,2','1,5','5,7','9,7','10,5','4,2'].map(String));
const adjacent = (x, y) => { for (let dx = -1; dx <= 1; dx++) for (let dy = -1; dy <= 1; dy++) if (isPath(x + dx, y + dy)) return true; return false; };
const plotTiles = [];
for (let y = 0; y < ROWS; y++) for (let x = 0; x < COLS; x++) {
  const p = tw(x, y);
  if (isPath(x, y)) {
    mesh(new THREE.BoxGeometry(T, 0.2, T), dirtM, p.x, 0.1, p.z, scene);
    for (const [ox, oz] of [[-0.5, -0.5], [0.5, -0.5], [-0.5, 0.5], [0.5, 0.5]]) {
      const pv = mesh(paverGeo, paverMs[Math.floor(rnd() * 4)], p.x + ox * T / 2, 0.24 + rr(-0.01, 0.01), p.z + oz * T / 2, scene);
      pv.rotation.y = rr(-0.04, 0.04);
    }
  } else {
    mesh(tileGeo, grassVar[((x + y) % 2) * 3 + Math.floor(rnd() * 3)], p.x, TILE_TOP - 0.2, p.z, scene);
    if (PLOTS.has(x + ',' + y)) plotTiles.push([x, y]);
  }
}
// path runs off the grid to the gate and into the shed
for (let i = 1; i <= 3; i++) {
  const p = tw(-i, 1);
  mesh(new THREE.BoxGeometry(T, 0.2, T), dirtM, p.x, 0.1, p.z, scene);
  for (const [ox, oz] of [[-0.5, -0.5], [0.5, -0.5], [-0.5, 0.5], [0.5, 0.5]])
    mesh(paverGeo, paverMs[Math.floor(rnd() * 4)], p.x + ox * T / 2, 0.24, p.z + oz * T / 2, scene);
}
{
  const p = tw(12, 6);
  mesh(new THREE.BoxGeometry(T, 0.2, T), dirtM, p.x, 0.1, p.z, scene);
  for (const [ox, oz] of [[-0.5, -0.5], [0.5, -0.5], [-0.5, 0.5], [0.5, 0.5]])
    mesh(paverGeo, paverMs[1], p.x + ox * T / 2, 0.24, p.z + oz * T / 2, scene);
}
// soil plots with timber edging
const plotGeo = rbox(1.5, 0.14, 1.5, 0.05, 2);
const edgeA = rbox(1.72, 0.16, 0.14, 0.04, 2), edgeB = rbox(0.14, 0.16, 1.72, 0.04, 2);
for (const [x, y] of plotTiles) {
  const p = tw(x, y);
  mesh(plotGeo, soilM, p.x, TILE_TOP + 0.03, p.z, scene);
  mesh(edgeA, timber, p.x, TILE_TOP + 0.06, p.z - 0.79, scene);
  mesh(edgeA, timber, p.x, TILE_TOP + 0.06, p.z + 0.79, scene);
  mesh(edgeB, timber, p.x - 0.79, TILE_TOP + 0.06, p.z, scene);
  mesh(edgeB, timber, p.x + 0.79, TILE_TOP + 0.06, p.z, scene);
  for (let k = 0; k < 3; k++) mesh(sph(0.09, 8, 6), soilDark, p.x + rr(-0.5, 0.5), TILE_TOP + 0.1, p.z + rr(-0.5, 0.5), scene).scale.y = 0.5;
}
const PLOT_TOP = TILE_TOP + 0.1;

// grass tufts and little flowers on plain lawn
const tuftM = [mat(0x5fb03a, { roughness: 0.9 }), mat(0x8ad85a, { roughness: 0.9 })];
function tuft(x, y, z) {
  const g = new THREE.Group();
  for (let i = 0; i < 4; i++) {
    const c = mesh(new THREE.ConeGeometry(0.06, rr(0.25, 0.4), 4), tuftM[i % 2], rr(-0.1, 0.1), 0.12, rr(-0.1, 0.1), g);
    c.rotation.set(rr(-0.4, 0.4), 0, rr(-0.4, 0.4));
  }
  g.position.set(x, y, z); scene.add(g);
}
function flower(x, y, z, color) {
  mesh(cyl(0.02, 0.02, 0.25, 5), tuftM[0], x, y + 0.12, z, scene);
  for (let i = 0; i < 5; i++) {
    const a = i / 5 * Math.PI * 2;
    mesh(sph(0.06, 8, 6), mat(color, { roughness: 0.6 }), x + Math.cos(a) * 0.07, y + 0.26, z + Math.sin(a) * 0.07, scene).scale.y = 0.5;
  }
  mesh(sph(0.045, 8, 6), mat(0xffc531), x, y + 0.28, z, scene);
}
for (let y = 0; y < ROWS; y++) for (let x = 0; x < COLS; x++) {
  if (isPath(x, y) || PLOTS.has(x + ',' + y)) continue;
  const p = tw(x, y);
  for (let k = 0; k < 1 + Math.floor(rnd() * 2); k++) tuft(p.x + rr(-0.7, 0.7), TILE_TOP, p.z + rr(-0.7, 0.7));
  if (rnd() < 0.5) flower(p.x + rr(-0.6, 0.6), TILE_TOP, p.z + rr(-0.6, 0.6), rnd() < 0.5 ? 0xffffff : 0xffe066);
}
for (let i = 0; i < 90; i++) {
  const x = rr(YARD.x0 + 0.5, YARD.x1 - 0.5), z = rr(YARD.z0 + 0.5, YARD.z1 - 0.5);
  if (x > -13 && x < 13 && z > -9 && z < 9) continue;
  tuft(x, 0.05, z);
  if (rnd() < 0.3) flower(x + 0.3, 0.05, z, [0xffffff, 0xffe066, 0xff8fb1][Math.floor(rnd() * 3)]);
}

// ---------- seeds (towers) ----------
const SEEDS = {};
SEEDS.thorn = function () {
  const g = new THREE.Group();
  const leaf = mat(0x3fa63c, { roughness: 0.6, flatShading: true });
  const leaf2 = mat(0x52bf45, { roughness: 0.6, flatShading: true });
  const b = mesh(new THREE.IcosahedronGeometry(0.62, 1), leaf, 0, 0.62, 0, g); b.scale.set(1, 0.85, 1);
  mesh(new THREE.IcosahedronGeometry(0.38, 1), leaf2, -0.42, 0.42, 0.1, g);
  mesh(new THREE.IcosahedronGeometry(0.34, 1), leaf2, 0.45, 0.4, -0.05, g);
  const spikeM = mat(0xe9f27a, { roughness: 0.4 });
  const N = 26;
  for (let i = 0; i < N; i++) {
    const yv = 1 - (i / (N - 1)) * 1.3; const r = Math.sqrt(Math.max(0, 1 - yv * yv)); const a = i * 2.39996;
    const n = new THREE.Vector3(Math.cos(a) * r, Math.max(yv, -0.2), Math.sin(a) * r).normalize();
    if (n.z > 0.75 && n.y < 0.5 && n.y > -0.1) continue; // keep the face clear
    const c = mesh(new THREE.ConeGeometry(0.07, 0.36, 6), spikeM, 0, 0, 0, g);
    c.position.set(n.x * 0.6, 0.62 + n.y * 0.52, n.z * 0.6);
    c.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), n);
  }
  eyes(g, 0.66, 0.5, 0.17, 0.12);
  // angry little brows
  for (const s of [-1, 1]) { const br = mesh(rbox(0.2, 0.05, 0.05, 0.02), mat(0x1d4a1c), s * 0.17, 0.84, 0.55, g); br.rotation.z = s * -0.35; }
  g.userData.muzzle = new THREE.Vector3(0, 0.9, 0.4);
  return g;
};
SEEDS.dandelion = function () {
  const g = new THREE.Group();
  const stem = mat(0x5aa83a, { roughness: 0.6 });
  tube([new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.08, 0.8, 0), new THREE.Vector3(-0.06, 1.6, 0.05), new THREE.Vector3(0, 2.25, 0)], 0.07, stem, g);
  const leafM = mat(0x4c9e33, { roughness: 0.6, flatShading: true });
  for (let i = 0; i < 5; i++) {
    const a = i / 5 * Math.PI * 2 + 0.3;
    const l = mesh(new THREE.IcosahedronGeometry(0.3, 0), leafM, Math.cos(a) * 0.38, 0.12, Math.sin(a) * 0.38, g);
    l.scale.set(1.7, 0.25, 0.6); l.rotation.y = -a; l.rotation.z = 0.25;
  }
  const core = mesh(sph(0.16), mat(0xc9a35a), 0, 2.3, 0, g);
  const puff = mesh(sph(0.62, 28, 20), mat(0xffffff, { roughness: 0.9, transparent: true, opacity: 0.55, depthWrite: false }), 0, 2.3, 0, g);
  puff.castShadow = false; puff.userData.noShadow = true;
  const fluff = mat(0xffffff, { roughness: 0.8, emissive: 0x333333 });
  const strand = mat(0xeee8d8, { roughness: 0.8 });
  const N = 70;
  for (let i = 0; i < N; i++) {
    const yv = 1 - (i / (N - 1)) * 2; const r = Math.sqrt(1 - yv * yv); const a = i * 2.39996;
    const n = new THREE.Vector3(Math.cos(a) * r, yv, Math.sin(a) * r);
    const tip = new THREE.Vector3(0, 2.3, 0).addScaledVector(n, 0.6);
    stick(new THREE.Vector3(0, 2.3, 0).addScaledVector(n, 0.14), tip, 0.012, strand, g);
    mesh(sph(0.07, 8, 6), fluff, tip.x, tip.y, tip.z, g);
  }
  g.userData.muzzle = new THREE.Vector3(0, 2.4, 0.4);
  return g;
};
SEEDS.pumpkin = function () {
  const g = new THREE.Group();
  const orange = mat(0xf5862a, { roughness: 0.45 }), orange2 = mat(0xe8751c, { roughness: 0.45 });
  for (let i = 0; i < 9; i++) {
    const a = i / 9 * Math.PI * 2;
    const r = mesh(sph(0.5, 20, 14), i % 2 ? orange : orange2, Math.cos(a) * 0.28, 0.58, Math.sin(a) * 0.28, g);
    r.scale.set(0.62, 1, 1); r.rotation.y = -a;
  }
  mesh(sph(0.55), orange, 0, 0.6, 0, g).scale.set(1, 0.9, 1);
  // barrel: a gourd neck pointing up and forward
  const barrel = new THREE.Group(); barrel.position.set(0, 1.0, -0.05); barrel.rotation.x = 0.75; g.add(barrel);
  mesh(cyl(0.2, 0.26, 0.8, 18), mat(0x6f9a32, { roughness: 0.5 }), 0, 0.4, 0, barrel);
  mesh(new THREE.TorusGeometry(0.22, 0.07, 10, 20), mat(0x8bb840, { roughness: 0.5 }), 0, 0.8, 0, barrel).rotation.x = Math.PI / 2;
  mesh(cyl(0.16, 0.16, 0.05, 16), mat(0x1c140c, { roughness: 1 }), 0, 0.83, 0, barrel);
  mesh(new THREE.TorusGeometry(0.27, 0.06, 10, 20), mat(0x55762a, { roughness: 0.5 }), 0, 0.05, 0, barrel).rotation.x = Math.PI / 2;
  // leaves and curly vine
  const leafM = mat(0x47a03a, { roughness: 0.6, flatShading: true });
  for (const [a, s] of [[2.3, 1], [3.9, -1]]) {
    const l = mesh(new THREE.IcosahedronGeometry(0.3, 0), leafM, Math.cos(a) * 0.55, 0.12, Math.sin(a) * 0.55, g);
    l.scale.set(1.5, 0.2, 1.1); l.rotation.y = -a;
  }
  const vine = mesh(new THREE.TorusGeometry(0.16, 0.03, 6, 20, Math.PI * 1.6), mat(0x5d8f2c), -0.35, 1.05, -0.2, g); vine.rotation.y = 1;
  eyes(g, 0.72, 0.5, 0.2, 0.13);
  const smile = mesh(new THREE.TorusGeometry(0.13, 0.03, 6, 16, Math.PI), mat(0x3a1a08), 0, 0.5, 0.53, g); smile.rotation.z = Math.PI;
  g.userData.muzzle = new THREE.Vector3(0, 1.75, 0.55);
  return g;
};
SEEDS.snapjaw = function () {
  const g = new THREE.Group();
  const stem = mat(0x4f9a35, { roughness: 0.6 });
  tube([new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.05, 0.4, -0.05), new THREE.Vector3(-0.05, 0.8, 0.05), new THREE.Vector3(0, 1.0, 0.15)], 0.09, stem, g);
  const leafM = mat(0x5bb341, { roughness: 0.55, flatShading: true });
  for (let i = 0; i < 4; i++) {
    const a = i / 4 * Math.PI * 2 + 0.6;
    const l = mesh(new THREE.IcosahedronGeometry(0.25, 0), leafM, Math.cos(a) * 0.4, 0.12, Math.sin(a) * 0.4, g);
    l.scale.set(1.8, 0.3, 0.9); l.rotation.y = -a;
  }
  const head = new THREE.Group(); head.position.set(0, 1.1, 0.15); head.scale.setScalar(1.25); g.add(head);
  const outer = mat(0x7cc443, { roughness: 0.45 }), inner = mat(0xe8414f, { roughness: 0.45 });
  const toothM = mat(0xfffbe8, { roughness: 0.35 });
  function jaw(up) {
    const j = new THREE.Group();
    const shell = mesh(new THREE.SphereGeometry(0.5, 24, 12, 0, Math.PI * 2, 0, Math.PI / 2), outer, 0, 0, 0, j);
    shell.scale.set(1, 0.55, 0.85);
    const cap = mesh(new THREE.CircleGeometry(0.49, 24), inner, 0, 0.005, 0, j); cap.rotation.x = -Math.PI / 2; cap.scale.set(1, 0.85, 1);
    const cap2 = mesh(new THREE.CircleGeometry(0.49, 24), inner, 0, 0.004, 0, j); cap2.rotation.x = Math.PI / 2; cap2.scale.set(1, 0.85, 1);
    for (let i = 0; i < 11; i++) {
      const a = Math.PI * (0.08 + 0.84 * i / 10);
      const t = mesh(new THREE.ConeGeometry(0.045, 0.2, 5), toothM, Math.cos(a) * 0.48, -0.08, Math.sin(a) * 0.41, j);
      t.rotation.x = Math.PI;
    }
    if (up) { j.rotation.x = Math.PI; }
    return j;
  }
  // jaws hinge at the back (-z), open towards the front
  const lower = new THREE.Group(); lower.position.z = -0.1; head.add(lower);
  const lj = jaw(true); lj.position.z = 0.35; lower.add(lj); lower.rotation.x = 0.3;
  const upper = new THREE.Group(); upper.position.z = -0.1; head.add(upper);
  const uj = jaw(false); uj.position.z = 0.35; upper.add(uj); upper.rotation.x = -1.0;
  g.userData.upper = upper;
  g.userData.muzzle = new THREE.Vector3(0, 1.1, 0.6);
  return g;
};
SEEDS.sunpetal = function () {
  const g = new THREE.Group();
  const stem = mat(0x4f9a35, { roughness: 0.6 });
  tube([new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.05, 0.6, 0), new THREE.Vector3(0, 1.2, 0.05), new THREE.Vector3(0, 1.55, 0.12)], 0.08, stem, g);
  const leafM = mat(0x56ad3b, { roughness: 0.55, flatShading: true });
  for (const [s, y] of [[1, 0.55], [-1, 0.85]]) {
    const l = mesh(new THREE.IcosahedronGeometry(0.28, 0), leafM, s * 0.3, y, 0, g); l.scale.set(1.6, 0.25, 0.8); l.rotation.z = s * 0.4;
  }
  const head = new THREE.Group(); head.position.set(0, 1.65, 0.18); head.rotation.x = -0.35; g.add(head);
  const petal = mat(0xffcf2e, { roughness: 0.4, emissive: 0xff9a00, emissiveIntensity: 0.35 });
  const petal2 = mat(0xffb51a, { roughness: 0.4, emissive: 0xff8a00, emissiveIntensity: 0.3 });
  for (let i = 0; i < 14; i++) {
    const a = i / 14 * Math.PI * 2;
    const p = mesh(sph(0.2, 12, 8), i % 2 ? petal : petal2, Math.cos(a) * 0.55, Math.sin(a) * 0.55, -0.02, head);
    p.scale.set(1.5, 0.6, 0.25); p.rotation.z = a;
  }
  const disc = mesh(cyl(0.42, 0.42, 0.14, 28), mat(0x7a4618, { roughness: 0.8 }), 0, 0, 0.02, head); disc.rotation.x = Math.PI / 2;
  const faceG = new THREE.Group(); faceG.position.z = 0.1; head.add(faceG);
  eyes(faceG, 0.1, 0.02, 0.14, 0.09);
  const smile = mesh(new THREE.TorusGeometry(0.12, 0.025, 6, 16, Math.PI), mat(0x2a1606), 0, -0.08, 0.05, faceG); smile.rotation.z = Math.PI;
  for (const s of [-1, 1]) mesh(sph(0.05, 8, 6), mat(0xff7b6b), s * 0.25, -0.05, 0.03, faceG).scale.z = 0.4;
  const glow = glowSprite(0xffc04a, 3.2, 0.55); glow.position.set(0, 1.65, 0.1); g.add(glow);
  const light = new THREE.PointLight(0xffc35a, 6, 6, 1.6); light.position.set(0, 1.7, 0.6); g.add(light);
  g.userData.glow = true;
  return g;
};

// ---------- pests ----------
const PESTS = {};
PESTS.snail = function () {
  const g = new THREE.Group();
  const body = mat(0xc9e09a, { roughness: 0.35 });
  const b = mesh(new THREE.CapsuleGeometry(0.22, 0.75, 8, 16), body, 0, 0.2, 0.05, g); b.rotation.x = Math.PI / 2; b.scale.set(1.2, 1, 0.75);
  mesh(sph(0.26), body, 0, 0.36, 0.48, g);
  const shellM = mat(0xd9772b, { roughness: 0.4 }), shellD = mat(0x9c4b1b, { roughness: 0.4 });
  const shell = mesh(sph(0.46, 24, 18), shellM, 0, 0.62, -0.15, g); shell.scale.set(0.8, 1, 1);
  for (const [r, off] of [[0.42, 0], [0.28, 0.07], [0.15, 0.12]]) {
    for (const s of [-1, 1]) {
      const t = mesh(new THREE.TorusGeometry(r, 0.035, 8, 28), shellD, s * (0.36 + off * 0.15), 0.62 + off * 0.4, -0.15 + off * 0.3, g);
      t.rotation.y = Math.PI / 2;
    }
  }
  const stalk = mat(0xb9d38a, { roughness: 0.4 });
  for (const s of [-1, 1]) {
    stick(new THREE.Vector3(s * 0.08, 0.5, 0.55), new THREE.Vector3(s * 0.17, 0.92, 0.66), 0.035, stalk, g);
  }
  eyes(g, 0.97, 0.68, 0.17, 0.11);
  const smile = mesh(new THREE.TorusGeometry(0.07, 0.02, 6, 12, Math.PI), mat(0x3b2a1a), 0, 0.33, 0.73, g); smile.rotation.z = Math.PI;
  return g;
};
PESTS.beetle = function () {
  const g = new THREE.Group();
  const shellM = mat(0x4b3fb3, { roughness: 0.25, metalness: 0.35 });
  const shellHi = mat(0x6f63e0, { roughness: 0.25, metalness: 0.35 });
  const blackM = mat(0x1d1a28, { roughness: 0.4 });
  for (const s of [-1, 1]) {
    const half = mesh(new THREE.SphereGeometry(0.5, 24, 14, 0, Math.PI, 0, Math.PI / 2), s < 0 ? shellM : shellHi, s * 0.015, 0.3, -0.08, g);
    half.scale.set(1.0, 0.85, 1.4); half.rotation.y = s < 0 ? Math.PI : 0; half.rotation.y += Math.PI / 2 * 0; // halves split along x
    half.rotation.set(0, s < 0 ? Math.PI / 2 : -Math.PI / 2, 0);
  }
  mesh(rbox(0.04, 0.42, 1.36, 0.02), blackM, 0, 0.5, -0.08, g);
  for (const [x, z] of [[-0.25, -0.2], [0.27, 0.05], [-0.18, 0.25], [0.2, -0.4]]) mesh(sph(0.07, 10, 8), mat(0xa9a2ff, { roughness: 0.3 }), x, 0.67, z, g).scale.y = 0.4;
  mesh(sph(0.48, 20, 12), blackM, 0, 0.28, -0.08, g).scale.set(0.95, 0.35, 1.35);
  const head = mesh(sph(0.27), blackM, 0, 0.36, 0.62, g); head.scale.set(1.1, 0.9, 0.9);
  eyes(g, 0.48, 0.78, 0.13, 0.1);
  for (const s of [-1, 1]) {
    const m1 = mesh(new THREE.TorusGeometry(0.1, 0.03, 6, 10, Math.PI * 0.8), blackM, s * 0.1, 0.25, 0.88, g);
    m1.rotation.set(Math.PI / 2, 0, s > 0 ? -0.3 : Math.PI + 0.3);
    for (const z of [-0.45, -0.05, 0.35]) {
      const a = new THREE.Vector3(s * 0.35, 0.25, z), k = new THREE.Vector3(s * 0.65, 0.3, z + 0.05), f = new THREE.Vector3(s * 0.75, 0.0, z + 0.12);
      stick(a, k, 0.04, blackM, g); stick(k, f, 0.035, blackM, g);
    }
    stick(new THREE.Vector3(s * 0.1, 0.5, 0.75), new THREE.Vector3(s * 0.3, 0.8, 1.0), 0.02, blackM, g);
  }
  return g;
};
PESTS.ant = function () {
  const g = new THREE.Group();
  const m = mat(0xc4472c, { roughness: 0.35 }), dark = mat(0x5a1d12, { roughness: 0.4 });
  mesh(sph(0.26), m, 0, 0.32, -0.38, g).scale.set(0.9, 0.85, 1.2);
  mesh(sph(0.15), m, 0, 0.32, -0.02, g);
  mesh(sph(0.22), m, 0, 0.4, 0.28, g);
  eyes(g, 0.48, 0.44, 0.1, 0.075);
  for (const s of [-1, 1]) {
    for (const z of [-0.15, 0, 0.15]) {
      const a = new THREE.Vector3(s * 0.08, 0.3, z), k = new THREE.Vector3(s * 0.38, 0.38, z * 1.6), f = new THREE.Vector3(s * 0.48, 0.0, z * 2.0);
      stick(a, k, 0.025, dark, g); stick(k, f, 0.022, dark, g);
    }
    stick(new THREE.Vector3(s * 0.06, 0.58, 0.32), new THREE.Vector3(s * 0.2, 0.8, 0.45), 0.018, dark, g);
    mesh(sph(0.035, 8, 6), dark, s * 0.2, 0.8, 0.45, g);
  }
  return g;
};
PESTS.aphid = function () {
  const g = new THREE.Group();
  const m = mat(0xb4e46a, { roughness: 0.35 });
  mesh(sph(0.26), m, 0, 0.27, -0.05, g).scale.set(0.9, 0.85, 1.15);
  mesh(sph(0.15), m, 0, 0.32, 0.22, g);
  eyes(g, 0.38, 0.33, 0.08, 0.07);
  const dark = mat(0x5f8a2a);
  for (const s of [-1, 1]) for (const z of [-0.15, 0.0, 0.15]) stick(new THREE.Vector3(s * 0.15, 0.15, z), new THREE.Vector3(s * 0.3, 0, z * 1.3), 0.02, dark, g);
  return g;
};
function caterpillar(dHead) {
  const g = new THREE.Group();
  const greens = [mat(0x8fd84a, { roughness: 0.35 }), mat(0x7cc93a, { roughness: 0.35 })];
  const spot = mat(0xffd23a, { roughness: 0.4 });
  const foot = mat(0x4f8a22);
  const N = 6;
  for (let i = N - 1; i >= 0; i--) {
    const { pos } = routeAt(dHead - i * 0.28);
    const r = i === 0 ? 0.42 : 0.36 - i * 0.015;
    const bob = Math.sin(i * 1.4) * 0.06;
    const s = mesh(sph(r), greens[i % 2], pos.x, PATH_Y + r + bob, pos.z, g);
    if (i > 0) {
      mesh(sph(0.06, 8, 6), spot, pos.x, PATH_Y + r * 2 + bob - 0.02, pos.z, g);
      for (const k of [-1, 1]) mesh(sph(0.05, 8, 6), foot, pos.x + k * 0.12, PATH_Y + 0.04, pos.z, g);
    }
  }
  const head = routeAt(dHead);
  const hg = new THREE.Group(); hg.position.set(head.pos.x, PATH_Y + 0.42, head.pos.z); hg.scale.setScalar(1.3);
  hg.rotation.y = Math.atan2(head.dir.x, head.dir.z); g.add(hg);
  eyes(hg, 0.08, 0.24, 0.12, 0.1);
  const smile = mesh(new THREE.TorusGeometry(0.07, 0.02, 6, 12, Math.PI), mat(0x2e4a12), 0, -0.1, 0.3, hg); smile.rotation.z = Math.PI;
  const ant = mat(0x4f8a22);
  for (const s of [-1, 1]) {
    stick(new THREE.Vector3(s * 0.08, 0.25, 0.05), new THREE.Vector3(s * 0.22, 0.55, 0.12), 0.02, ant, hg);
    mesh(sph(0.055, 8, 6), mat(0xff6f91), s * 0.22, 0.55, 0.12, hg);
  }
  return g;
}
const PATH_Y = 0.32;

function healthBar(frac, w = 1.1) {
  const tex = canvasTex(256, 48, (g) => {
    g.fillStyle = '#1b1822'; roundRect(g, 2, 2, 252, 44, 18); g.fill();
    g.fillStyle = '#3a3546'; roundRect(g, 10, 10, 236, 28, 12); g.fill();
    const col = frac > 0.5 ? '#5ee05a' : frac > 0.25 ? '#ffc93a' : '#ff5b5b';
    g.fillStyle = col; roundRect(g, 10, 10, Math.max(20, 236 * frac), 28, 12); g.fill();
    g.fillStyle = 'rgba(255,255,255,0.35)'; roundRect(g, 14, 13, Math.max(12, 236 * frac - 8), 9, 5); g.fill();
  });
  const s = new THREE.Sprite(new THREE.SpriteMaterial({ map: tex, transparent: true, depthWrite: false }));
  s.scale.set(w, w * 48 / 256, 1);
  s.userData.noShadow = true;
  return s;
}
function roundRect(g, x, y, w, h, r) {
  g.beginPath(); g.moveTo(x + r, y); g.arcTo(x + w, y, x + w, y + h, r); g.arcTo(x + w, y + h, x, y + h, r);
  g.arcTo(x, y + h, x, y, r); g.arcTo(x, y, x + w, y, r); g.closePath();
}

// ---------- place towers ----------
const towers = {};
function placeSeed(kind, x, y, faceTo, scale = 1.4) {
  const g = SEEDS[kind]();
  const p = tw(x, y);
  g.position.set(p.x, PLOT_TOP, p.z);
  g.scale.setScalar(scale);
  if (faceTo) g.rotation.y = Math.atan2(faceTo.x - p.x, faceTo.z - p.z);
  scene.add(g);
  // little mound under each plant
  mesh(sph(0.62, 16, 8), soilDark, p.x, PLOT_TOP - 0.05, p.z, scene).scale.set(1, 0.18, 1);
  towers[kind + '@' + x + ',' + y] = g;
  return g;
}
function worldOf(g, local) { g.updateMatrixWorld(true); return g.localToWorld(local.clone()); }

// pests along the route (d in tiles from entry)
const pestSpots = [
  ['aphid', 1.3, 0.9], ['aphid', 2.6, 1.0], ['ant', 5.2, 0.75], ['snail', 9.6, 0.55],
  ['snail', 16.0, 0.35], ['beetle', 20.3, 0.62], ['ant', 23.2, 0.85],
];
const pestWorld = {};
for (const [kind, d, hp] of pestSpots) {
  const { pos, dir } = routeAt(d);
  const g = PESTS[kind]();
  const sc = { aphid: 1.7, ant: 1.7, snail: 1.75, beetle: 1.7 }[kind];
  g.scale.setScalar(sc);
  g.position.set(pos.x, PATH_Y, pos.z);
  g.rotation.y = Math.atan2(dir.x, dir.z);
  scene.add(g);
  const hb = healthBar(hp, kind === 'beetle' || kind === 'snail' ? 1.6 : 1.25);
  const bb = new THREE.Box3().setFromObject(g); hb.position.set(pos.x, bb.max.y + 0.35, pos.z);
  scene.add(hb);
  pestWorld[kind + d] = pos.clone().setY(PATH_Y + 0.8);
}
const CAT_D = 13.6;
scene.add(caterpillar(CAT_D));
{ const p = routeAt(CAT_D - 0.5).pos; const hb = healthBar(0.8, 1.6); hb.position.set(p.x, PATH_Y + 1.5, p.z); scene.add(hb); pestWorld.cat = p.clone().setY(PATH_Y + 0.4); }

const snailA = pestWorld['snail16'], beetle = pestWorld['beetle20.3'], snailB = pestWorld['snail9.6'], cat = pestWorld.cat;
const thorn = placeSeed('thorn', 3, 3, snailA);
const thorn2 = placeSeed('thorn', 1, 2, pestWorld['ant5.2']);
const dand = placeSeed('dandelion', 6, 5, snailA);
const pump = placeSeed('pumpkin', 10, 3, cat);
const snap = placeSeed('snapjaw', 3, 5, beetle);
const sunp = placeSeed('sunpetal', 7, 2, new THREE.Vector3(6, 0, 30));

// ---------- projectiles and effects ----------
const fx = new THREE.Group(); scene.add(fx);
function noShadow(o) { o.traverse(c => { c.userData.noShadow = true; }); return o; }
// thorn darts
function darts(tower, target, n, startT = 0.25) {
  const a = worldOf(tower, tower.userData.muzzle), b = target.clone();
  const dir = new THREE.Vector3().subVectors(b, a).normalize();
  for (let i = 0; i < n; i++) {
    const t = startT + i * 0.28; if (t > 0.95) break;
    const p = a.clone().lerp(b, t);
    const c = mesh(new THREE.ConeGeometry(0.11, 0.6, 6), mat(0xf2ff8a, { emissive: 0xc8ff3a, emissiveIntensity: 1.2 }), p.x, p.y, p.z, fx);
    c.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir);
    const tr = mesh(cyl(0.01, 0.09, 1.3, 8), new THREE.MeshBasicMaterial({ color: 0xeaffb0, transparent: true, opacity: 0.55, depthWrite: false }), 0, 0, 0, fx);
    tr.position.copy(p).addScaledVector(dir, -0.85);
    tr.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir);
    noShadow(tr);
    const gl = glowSprite(0xd6ff6a, 1.3, 0.75); gl.position.copy(p); fx.add(gl);
  }
}
function arcPoint(a, b, t, h) { const p = a.clone().lerp(b, t); p.y += Math.sin(t * Math.PI) * h; return p; }
function puffs(tower, target, ts) {
  const a = worldOf(tower, tower.userData.muzzle), b = target.clone();
  for (const t of ts) {
    const p = arcPoint(a, b, t, 1.2);
    const s = mesh(sph(0.17, 10, 8), mat(0xffffff, { emissive: 0xffffff, emissiveIntensity: 0.5, roughness: 0.9 }), p.x, p.y, p.z, fx);
    const gl = glowSprite(0xffffff, 1.3, 0.6); gl.position.copy(p); fx.add(gl);
    for (let k = 0; k < 6; k++) {
      const q = new THREE.Vector3(rr(-1, 1), rr(-0.2, 1), rr(-1, 1)).normalize();
      stick(p, p.clone().addScaledVector(q, 0.32), 0.014, mat(0xffffff), fx);
    }
  }
}
function mortar(tower, target, t) {
  const a = worldOf(tower, tower.userData.muzzle), b = target.clone();
  for (let i = 1; i <= 7; i++) {
    const tt = t - i * 0.05; if (tt < 0.02) break;
    const p = arcPoint(a, b, tt, 3.2);
    const s = mesh(sph(0.11 * (1 - i / 9), 8, 6), new THREE.MeshBasicMaterial({ color: 0xffd08a, transparent: true, opacity: 0.6 - i * 0.07, depthWrite: false }), p.x, p.y, p.z, fx);
    noShadow(s);
  }
  const p = arcPoint(a, b, t, 3.2);
  const ball = mesh(sph(0.26, 18, 14), mat(0xff8a1f, { emissive: 0xff5a00, emissiveIntensity: 0.55, roughness: 0.4 }), p.x, p.y, p.z, fx);
  mesh(cyl(0.03, 0.03, 0.12, 6), mat(0x4f7a22), p.x, p.y + 0.3, p.z, fx);
  const gl = glowSprite(0xffa040, 1.6, 0.6); gl.position.copy(p); fx.add(gl);
}
function impact(p, color = 0xffef8a, size = 1.6) {
  const gl = glowSprite(color, size, 0.9); gl.position.copy(p); fx.add(gl);
  const starM = mat(0xfff6b0, { emissive: 0xffe066, emissiveIntensity: 1 });
  for (let i = 0; i < 6; i++) {
    const a = i / 6 * Math.PI * 2;
    const s = mesh(new THREE.OctahedronGeometry(0.07), starM, p.x + Math.cos(a) * 0.4, p.y + Math.sin(a) * 0.35, p.z + 0.1, fx);
    noShadow(s);
  }
}
function leafPuff(p) {
  const leafM = [mat(0x6fc84a, { roughness: 0.5 }), mat(0xa6e05a, { roughness: 0.5 }), mat(0xffd25a)];
  for (let i = 0; i < 14; i++) {
    const q = new THREE.Vector3(rr(-1, 1), rr(0.1, 1), rr(-1, 1)).normalize().multiplyScalar(rr(0.3, 0.9));
    const l = mesh(new THREE.IcosahedronGeometry(0.11, 0), leafM[i % 3], p.x + q.x, p.y + q.y, p.z + q.z, fx);
    l.scale.set(1.6, 0.3, 0.8); l.rotation.set(rr(0, 3), rr(0, 3), rr(0, 3));
  }
  const ring = mesh(new THREE.RingGeometry(0.6, 0.85, 40), new THREE.MeshBasicMaterial({ color: 0xffe9a8, transparent: true, opacity: 0.55, depthWrite: false, side: THREE.DoubleSide }), p.x, PATH_Y + 0.08, p.z, fx);
  ring.rotation.x = -Math.PI / 2; noShadow(ring);
  const puff = glowSprite(0xffffff, 1.4, 0.45); puff.position.set(p.x, p.y + 0.3, p.z); fx.add(puff);
}
darts(thorn, snailA, 3);
darts(thorn2, pestWorld['ant5.2'], 2, 0.35);
puffs(dand, snailA, [0.3, 0.55, 0.8]);
mortar(pump, cat, 0.55);
impact(snailA.clone().add(new THREE.Vector3(0.1, 0.25, 0.1)));
impact(beetle.clone().add(new THREE.Vector3(0, 0.15, 0.2)), 0xff9a8a, 1.3);
const popAt = routeAt(11.2).pos.setY(PATH_Y + 0.4);
leafPuff(popAt);
// range ring on the selected Pumpkin Mortar (hero only)
let rangeRing = null;
{
  const p = tw(10, 3);
  rangeRing = new THREE.Group();
  const disc = mesh(new THREE.CircleGeometry(3.5 * T, 64), new THREE.MeshBasicMaterial({ color: 0xfff0b8, transparent: true, opacity: 0.12, depthWrite: false }), 0, 0, 0, rangeRing);
  disc.rotation.x = -Math.PI / 2;
  const edge = mesh(new THREE.RingGeometry(3.5 * T - 0.12, 3.5 * T, 96), new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.7, depthWrite: false }), 0, 0.01, 0, rangeRing);
  edge.rotation.x = -Math.PI / 2;
  rangeRing.position.set(p.x, TILE_TOP + 0.16, p.z);
  noShadow(rangeRing);
  rangeRing.visible = false;
  scene.add(rangeRing);
}

// ---------- props: fence, gate, shed, tank, Hills Hoist, gum trees, gnome, Nan, garden bed ----------
const colorbond = mat(0x7d8670, { roughness: 0.5, metalness: 0.15, map: null });
function colorbondPanel(len, h) {
  const tex = corrugated(len * 2.2, 1, [156, 166, 140], [96, 106, 84], 16);
  return mat(0xffffff, { map: tex, roughness: 0.45, metalness: 0.15 });
}
function fenceRun(x0, z0, x1, z1, h = 1.9) {
  const len = Math.hypot(x1 - x0, z1 - z0); const ang = Math.atan2(z1 - z0, x1 - x0);
  const g = new THREE.Group(); g.position.set((x0 + x1) / 2, 0, (z0 + z1) / 2); g.rotation.y = -ang; scene.add(g);
  mesh(new THREE.BoxGeometry(len, h, 0.08), colorbondPanel(len, h), 0, h / 2, 0, g);
  mesh(rbox(len + 0.1, 0.12, 0.2, 0.04), mat(0x5d6553, { roughness: 0.45, metalness: 0.2 }), 0, h + 0.04, 0, g);
  mesh(rbox(len, 0.1, 0.16, 0.03), mat(0x5d6553, { roughness: 0.45, metalness: 0.2 }), 0, 0.08, 0, g);
  const n = Math.max(1, Math.round(len / 2.4));
  for (let i = 0; i <= n; i++) mesh(rbox(0.16, h + 0.15, 0.16, 0.04), mat(0x5d6553, { roughness: 0.45, metalness: 0.2 }), -len / 2 + i * len / n, (h + 0.15) / 2, 0, g);
}
function picketRun(x0, z0, x1, z1) {
  const len = Math.hypot(x1 - x0, z1 - z0); const ang = Math.atan2(z1 - z0, x1 - x0);
  const g = new THREE.Group(); g.position.set((x0 + x1) / 2, 0, (z0 + z1) / 2); g.rotation.y = -ang; scene.add(g);
  const white = mat(0xfbf7ee, { roughness: 0.5 });
  for (const y of [0.35, 0.75]) mesh(rbox(len, 0.1, 0.07, 0.03), white, 0, y, -0.06, g);
  const n = Math.floor(len / 0.32);
  for (let i = 0; i <= n; i++) {
    const x = -len / 2 + i * len / n;
    mesh(rbox(0.16, 0.95, 0.06, 0.03), white, x, 0.48, 0, g);
    const tip = mesh(new THREE.ConeGeometry(0.11, 0.16, 4), white, x, 1.03, 0, g); tip.rotation.y = Math.PI / 4;
  }
}
const GATE_Z = tw(0, 1).z;
fenceRun(YARD.x0, YARD.z0, YARD.x1, YARD.z0);             // back
fenceRun(YARD.x1, YARD.z0, YARD.x1, YARD.z1);             // right
fenceRun(YARD.x0, YARD.z0, YARD.x0, GATE_Z - 1.2);        // left, above gate
fenceRun(YARD.x0, GATE_Z + 1.2, YARD.x0, YARD.z1);        // left, below gate
picketRun(YARD.x0, YARD.z1, YARD.x1, YARD.z1);            // front: low white pickets
// open timber gate
{
  const g = new THREE.Group(); g.position.set(YARD.x0, 0, GATE_Z - 1.2); g.rotation.y = -1.1; scene.add(g);
  const wood = mat(0xb07a46, { roughness: 0.7 });
  for (let i = 0; i < 6; i++) mesh(rbox(0.36, 1.7, 0.08, 0.03), wood, 0.2 + i * 0.4, 0.95, 0, g);
  for (const y of [0.45, 1.45]) mesh(rbox(2.4, 0.12, 0.1, 0.03), mat(0x8c5e33, { roughness: 0.7 }), 1.2, y, 0.06, g);
}
// pest burrow / spawn marker just outside the gate
{
  const p = new THREE.Vector3(YARD.x0 - 1.4, 0, GATE_Z);
  mesh(sph(1.0, 20, 10), mat(0x7a5434, { roughness: 1 }), p.x, -0.1, p.z, scene).scale.set(1.2, 0.35, 1.2);
  mesh(cyl(0.6, 0.6, 0.06, 20), mat(0x24160c, { roughness: 1 }), p.x, 0.22, p.z, scene);
}

// shed (Nan's shed, the goal)
{
  const g = new THREE.Group(); const c = tw(12, 6); g.position.set(c.x + 2.6, 0, c.z); scene.add(g);
  const wallTex = corrugated(3, 1, [176, 214, 168], [128, 172, 124], 22);
  const wall = mat(0xffffff, { map: wallTex, roughness: 0.45, metalness: 0.15 });
  mesh(rbox(4.6, 0.2, 4.4, 0.05), mat(0xb8b2a6, { roughness: 0.9 }), 0, 0.1, 0, g);
  mesh(new THREE.BoxGeometry(4.2, 2.6, 4.0), wall, 0, 1.5, 0, g);
  // gable ends
  const gableShape = new THREE.Shape(); gableShape.moveTo(-2.1, 0); gableShape.lineTo(2.1, 0); gableShape.lineTo(0, 1.0); gableShape.closePath();
  const gable = new THREE.ExtrudeGeometry(gableShape, { depth: 4.0, bevelEnabled: false });
  const gm = mesh(gable, wall, 0, 2.8, -2.0, g);
  // roof
  const roofTex = corrugated(1, 3, [214, 84, 70], [156, 52, 44], 26); roofTex.rotation = Math.PI / 2;
  const roofM = mat(0xffffff, { map: roofTex, roughness: 0.4, metalness: 0.2 });
  const slope = Math.atan2(1.0, 2.1), rl = Math.hypot(2.1, 1.0) + 0.35;
  for (const s of [-1, 1]) {
    const r = mesh(new THREE.BoxGeometry(rl, 0.1, 4.6), roofM, s * 1.05, 3.33, 0, g);
    r.rotation.z = -s * slope;
  }
  mesh(cyl(0.1, 0.1, 4.7, 10), mat(0xd9dcde, { metalness: 0.5, roughness: 0.3 }), 0, 3.83, 0, g).rotation.x = Math.PI / 2;
  // trim
  const trim = mat(0xf4f1ea, { roughness: 0.5 });
  for (const [x, z] of [[-2.1, -2.0], [2.1, -2.0], [-2.1, 2.0], [2.1, 2.0]]) mesh(rbox(0.16, 2.7, 0.16, 0.04), trim, x, 1.5, z, g);
  // double doors on the path side (-x)
  const doorM = mat(0x2f6b45, { roughness: 0.45, metalness: 0.15 });
  for (const s of [-1, 1]) {
    mesh(rbox(0.1, 1.95, 0.92, 0.03), doorM, -2.13, 1.18, s * 0.48, g);
    mesh(sph(0.06, 8, 6), mat(0xe6c35a, { metalness: 0.6, roughness: 0.3 }), -2.2, 1.25, s * 0.12, g);
  }
  
  // sign
  const signTex = canvasTex(512, 160, (ctx, w, h) => {
    ctx.fillStyle = '#f6e7c8'; roundRect(ctx, 6, 6, w - 12, h - 12, 30); ctx.fill();
    ctx.lineWidth = 10; ctx.strokeStyle = '#7a4a22'; roundRect(ctx, 6, 6, w - 12, h - 12, 30); ctx.stroke();
    ctx.fillStyle = '#7a3a12'; ctx.font = '700 84px Fredoka, sans-serif'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillText("NAN'S SHED", w / 2, h / 2 + 4);
  });
  const sign = mesh(new THREE.PlaneGeometry(1.9, 0.6), mat(0xffffff, { map: signTex, roughness: 0.7 }), -2.17, 2.62, 0, g); sign.rotation.y = -Math.PI / 2;
  // window on the front (+z) with flower box
  mesh(rbox(1.2, 0.9, 0.08, 0.04), mat(0x9fd8f0, { roughness: 0.1, metalness: 0.3, emissive: 0x204050, emissiveIntensity: 0.2 }), 0.9, 1.75, 2.03, g);
  mesh(rbox(1.36, 1.06, 0.06, 0.03), trim, 0.9, 1.75, 2.01, g);
  mesh(rbox(1.4, 0.3, 0.35, 0.05), mat(0xb07a46), 0.9, 1.15, 2.2, g);
  for (let i = 0; i < 5; i++) mesh(sph(0.12, 10, 8), mat([0xff6f91, 0xffd25a, 0xff8a3a][i % 3]), 0.4 + i * 0.25, 1.38, 2.25, g);
  // heart badge above the shed (hearts are the shed's health)
  const heart = new THREE.Shape();
  heart.moveTo(0, -0.5); heart.bezierCurveTo(-0.9, 0.05, -0.55, 0.65, 0, 0.3); heart.bezierCurveTo(0.55, 0.65, 0.9, 0.05, 0, -0.5);
  const hm = mesh(new THREE.ExtrudeGeometry(heart, { depth: 0.18, bevelEnabled: true, bevelSize: 0.06, bevelThickness: 0.06, bevelSegments: 3 }),
    mat(0xff4d5e, { roughness: 0.3, emissive: 0xff2030, emissiveIntensity: 0.25 }), 0, 5.25, 0, g);
  hm.scale.setScalar(0.95); g.userData.heart = hm;
  g.userData.heartPos = new THREE.Vector3(c.x + 2.6, 4.75, c.z);
  scene.userData.shed = g;
}
// rainwater tank next to the shed
{
  const c = tw(12, 6); const x = c.x + 3.0, z = c.z - 3.9;
  const tex = corrugated(1, 6, [222, 226, 228], [160, 166, 170], 24); tex.rotation = Math.PI / 2;
  const m = mat(0xffffff, { map: tex, roughness: 0.35, metalness: 0.45 });
  mesh(cyl(1.25, 1.25, 2.4, 40), m, x, 1.3, z, scene);
  mesh(new THREE.SphereGeometry(1.25, 40, 10, 0, Math.PI * 2, 0, Math.PI / 2), mat(0xd9dcde, { roughness: 0.35, metalness: 0.45 }), x, 2.5, z, scene).scale.y = 0.25;
  mesh(cyl(1.35, 1.35, 0.2, 40), mat(0xb8b2a6, { roughness: 0.9 }), x, 0.1, z, scene);
  mesh(cyl(0.06, 0.06, 0.3, 8), mat(0xc9a040, { metalness: 0.6, roughness: 0.3 }), x - 1.3, 0.5, z, scene).rotation.z = Math.PI / 2;
}
// Hills Hoist with washing
{
  const g = new THREE.Group(); g.position.set(5.5, 0, -12.2); g.rotation.y = 0.35; scene.add(g);
  const steel = mat(0xc7cbd0, { metalness: 0.6, roughness: 0.3 });
  mesh(cyl(0.09, 0.11, 2.9, 12), steel, 0, 1.45, 0, g);
  mesh(cyl(0.16, 0.16, 0.35, 12), steel, 0, 1.75, 0, g);
  mesh(rbox(0.22, 0.12, 0.35, 0.03), mat(0x2f2f36), 0.15, 1.1, 0, g);
  const R = 3.1;
  const tips = [];
  for (let i = 0; i < 4; i++) {
    const a = i / 4 * Math.PI * 2 + Math.PI / 4;
    const tip = new THREE.Vector3(Math.cos(a) * R, 2.75, Math.sin(a) * R);
    stick(new THREE.Vector3(0, 1.75, 0), tip, 0.045, steel, g);
    stick(new THREE.Vector3(0, 2.85, 0), new THREE.Vector3(Math.cos(a) * 1.2, 2.3, Math.sin(a) * 1.2), 0.025, steel, g);
    tips.push(a);
  }
  const line = mat(0xf0f0f0, { roughness: 0.6 });
  for (const f of [0.4, 0.6, 0.8, 1.0]) {
    for (let i = 0; i < 4; i++) {
      const a0 = tips[i], a1 = tips[(i + 1) % 4];
      const y = 1.75 + (2.75 - 1.75) * f;
      stick(new THREE.Vector3(Math.cos(a0) * R * f, y, Math.sin(a0) * R * f), new THREE.Vector3(Math.cos(a1) * R * f, y, Math.sin(a1) * R * f), 0.012, line, g);
    }
  }
  // washing on the outer lines
  const towelTex = canvasTex(64, 128, (ctx) => { const c = ['#ff6b6b', '#ffd25a', '#4fb6ff', '#ffffff']; for (let i = 0; i < 8; i++) { ctx.fillStyle = c[i % 4]; ctx.fillRect(0, i * 16, 64, 16); } });
  const clothes = [
    [0, 0.25, mat(0xffffff, { map: towelTex, roughness: 0.8, side: THREE.DoubleSide }), 0.9, 1.3],
    [0, 0.65, mat(0xff8fb1, { roughness: 0.8, side: THREE.DoubleSide }), 0.7, 0.8],
    [1, 0.4, mat(0x4f8fe0, { roughness: 0.8, side: THREE.DoubleSide }), 1.4, 1.1],
    [2, 0.5, mat(0xfff4d6, { roughness: 0.8, side: THREE.DoubleSide }), 0.6, 0.7],
    [3, 0.35, mat(0x7fd36a, { roughness: 0.8, side: THREE.DoubleSide }), 0.8, 0.9],
  ];
  for (const [side, t, m, w, h] of clothes) {
    const a0 = tips[side], a1 = tips[(side + 1) % 4];
    const p0 = new THREE.Vector3(Math.cos(a0) * R, 2.75, Math.sin(a0) * R), p1 = new THREE.Vector3(Math.cos(a1) * R, 2.75, Math.sin(a1) * R);
    const p = p0.clone().lerp(p1, t);
    const cloth = mesh(new THREE.PlaneGeometry(w, h, 4, 4), m, p.x, p.y - h / 2, p.z, g);
    cloth.rotation.y = -Math.atan2(p1.z - p0.z, p1.x - p0.x);
    const pos = cloth.geometry.attributes.position; for (let k = 0; k < pos.count; k++) pos.setZ(k, Math.sin(pos.getX(k) * 4) * 0.06);
    cloth.geometry.computeVertexNormals();
    for (const s of [-1, 1]) { const pg = mesh(rbox(0.06, 0.16, 0.06, 0.02), mat(0xffd25a), 0, 0, 0, g); pg.position.copy(p0.clone().lerp(p1, t + s * w / (2 * p0.distanceTo(p1)) * 0.8)); pg.position.y = 2.72; }
  }
  // washing basket
  mesh(cyl(0.45, 0.38, 0.4, 16), mat(0x5ab8e8, { roughness: 0.5 }), 1.4, 0.22, 1.2, g);
  mesh(sph(0.3, 10, 8), mat(0xfff4d6, { roughness: 0.9 }), 1.4, 0.42, 1.2, g).scale.y = 0.4;
}
// gum trees
function gumTree(x, z, h, s = 1) {
  const g = new THREE.Group(); g.position.set(x, 0, z); g.scale.setScalar(s); scene.add(g);
  const barkTex = canvasTex(128, 256, (ctx, w, hh) => {
    ctx.fillStyle = '#efe7d8'; ctx.fillRect(0, 0, w, hh);
    const cols = ['#d9cdb8', '#c8b9a0', '#e8c9b0', '#f7f2e8', '#bfb6a6'];
    for (let i = 0; i < 70; i++) { ctx.fillStyle = cols[i % 5]; ctx.beginPath(); ctx.ellipse(rr(0, w), rr(0, hh), rr(4, 14), rr(10, 34), 0, 0, 7); ctx.fill(); }
  });
  const bark = mat(0xffffff, { map: barkTex, roughness: 0.7 });
  const trunk = [new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.3, h * 0.35, 0.1), new THREE.Vector3(-0.1, h * 0.6, 0), new THREE.Vector3(0.2, h * 0.8, -0.1)];
  const tg = new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3(trunk), 20, 0.42, 10), bark); g.add(tg);
  mesh(cyl(0.5, 0.75, 0.6, 10), bark, 0, 0.3, 0, g);
  const leafCols = [0x6e9a5a, 0x7fa86a, 0x5a8550, 0x8db07a];
  const ends = [];
  for (let i = 0; i < 5; i++) {
    const a = i / 5 * Math.PI * 2 + rr(-0.3, 0.3);
    const start = trunk[2].clone().lerp(trunk[3], rr(0, 1));
    const end = new THREE.Vector3(Math.cos(a) * rr(2.0, 3.0), h * rr(0.82, 1.0), Math.sin(a) * rr(2.0, 3.0));
    const mid = start.clone().lerp(end, 0.5); mid.y += 0.5;
    g.add(new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3([start, mid, end]), 10, 0.16, 8), bark));
    ends.push(end);
  }
  ends.push(trunk[3].clone().setY(h * 1.02));
  for (const e of ends) {
    for (let k = 0; k < 4; k++) {
      const c = mesh(new THREE.IcosahedronGeometry(rr(0.8, 1.2), 0), mat(leafCols[Math.floor(rnd() * 4)], { roughness: 0.75, flatShading: true }),
        e.x + rr(-0.8, 0.8), e.y + rr(-0.2, 0.7), e.z + rr(-0.8, 0.8), g);
      c.scale.set(1.2, 0.6, 1.1); c.rotation.set(rr(0, 3), rr(0, 3), rr(0, 3));
    }
  }
  return g;
}
gumTree(-14.5, -18.5, 9.5, 1.0);
gumTree(-4, -19.5, 10.5, 1.1);
gumTree(14.5, -19, 9, 1.0);
gumTree(23, 2, 9, 1.0);
gumTree(-21.5, 6, 8.5, 0.95);
// background shrubs beyond the fence
for (let i = 0; i < 26; i++) {
  const x = rr(-30, 32), z = rr(-24, -17.5);
  const b = mesh(new THREE.IcosahedronGeometry(rr(1.0, 1.8), 0), mat([0x4f8a3a, 0x5c9a44, 0x6aa84e][i % 3], { roughness: 0.8, flatShading: true }), x, 0.8, z, scene);
  b.scale.y = 0.8;
}
// garden gnome
function gnome() {
  const g = new THREE.Group();
  mesh(cyl(0.32, 0.38, 0.6, 16), mat(0x3d74c9, { roughness: 0.45 }), 0, 0.35, 0, g);
  mesh(rbox(0.66, 0.08, 0.1, 0.03), mat(0x3a2414), 0, 0.42, 0.33, g);
  mesh(sph(0.27), mat(0xf5c9a0, { roughness: 0.5 }), 0, 0.85, 0, g);
  const beard = mesh(new THREE.ConeGeometry(0.3, 0.55, 16), mat(0xffffff, { roughness: 0.8 }), 0, 0.62, 0.12, g); beard.rotation.x = Math.PI + 0.25;
  mesh(sph(0.08, 10, 8), mat(0xf29a8a), 0, 0.85, 0.27, g);
  for (const s of [-1, 1]) mesh(sph(0.04, 8, 6), mat(0x15121c), s * 0.1, 0.94, 0.23, g);
  const hat = mesh(new THREE.ConeGeometry(0.32, 0.8, 16), mat(0xe33a3a, { roughness: 0.45 }), 0, 1.38, -0.04, g); hat.rotation.x = -0.15;
  mesh(new THREE.TorusGeometry(0.28, 0.06, 8, 20), mat(0xd12f2f, { roughness: 0.45 }), 0, 1.0, 0, g).rotation.x = Math.PI / 2;
  for (const s of [-1, 1]) mesh(sph(0.12, 10, 8), mat(0x3a2414), s * 0.16, 0.06, 0.1, g).scale.set(1, 0.6, 1.4);
  // little shovel
  stick(new THREE.Vector3(0.38, 0.1, 0.15), new THREE.Vector3(0.45, 0.9, 0.2), 0.03, mat(0xb07a46), g);
  mesh(rbox(0.2, 0.26, 0.04, 0.03), mat(0xb9bec4, { metalness: 0.6, roughness: 0.3 }), 0.37, 0.05, 0.14, g);
  return g;
}
{ const c = tw(11, 7); const gn = gnome(); gn.position.set(c.x + 0.4, TILE_TOP, c.z + 0.1); gn.rotation.y = -0.4; gn.scale.setScalar(1.15); scene.add(gn); }
{ const gn = gnome(); gn.position.set(-14.5, 0.05, 9.5); gn.rotation.y = 0.6; scene.add(gn); }
// Nan (blocky avatar), waving by the shed
function nan() {
  const g = new THREE.Group();
  const skin = mat(0xf2c9a0, { roughness: 0.5 });
  const pants = mat(0x4a4d6e, { roughness: 0.55 });
  const cardi = mat(0xb48ad6, { roughness: 0.55 });
  const blouse = mat(0xfff4e0, { roughness: 0.6 });
  for (const s of [-1, 1]) {
    mesh(rbox(0.44, 0.95, 0.44, 0.08), pants, s * 0.23, 0.55, 0, g);
    mesh(rbox(0.46, 0.18, 0.56, 0.07), mat(0x6b4a2e), s * 0.23, 0.09, 0.05, g);
  }
  mesh(rbox(0.96, 1.0, 0.5, 0.1), cardi, 0, 1.5, 0, g);
  mesh(rbox(0.36, 0.94, 0.04, 0.03), blouse, 0, 1.52, 0.25, g);
  for (const y of [1.25, 1.5, 1.75]) mesh(sph(0.04, 8, 6), mat(0xffffff), 0.22, y, 0.27, g);
  // arms: left down holding watering can, right waving
  mesh(rbox(0.42, 0.95, 0.42, 0.08), cardi, -0.7, 1.5, 0, g);
  mesh(rbox(0.36, 0.22, 0.36, 0.06), skin, -0.7, 0.98, 0, g);
  const armR = new THREE.Group(); armR.position.set(0.7, 1.95, 0); armR.rotation.z = 2.5; g.add(armR);
  mesh(rbox(0.42, 0.95, 0.42, 0.08), cardi, 0, -0.45, 0, armR);
  mesh(rbox(0.36, 0.22, 0.36, 0.06), skin, 0, -1.0, 0, armR);
  // head
  const head = new THREE.Group(); head.position.y = 2.42; g.add(head);
  mesh(rbox(0.82, 0.78, 0.78, 0.3, 4), skin, 0, 0, 0, head);
  const hair = mat(0xdfe0e6, { roughness: 0.75 });
  mesh(sph(0.46, 20, 14), hair, 0, 0.18, -0.06, head).scale.set(1.0, 0.75, 1.0);
  mesh(sph(0.24, 16, 12), hair, 0, 0.42, -0.32, head);
  for (const s of [-1, 1]) { mesh(sph(0.16, 12, 10), hair, s * 0.38, 0.06, -0.05, head); }
  for (const s of [-1, 1]) {
    mesh(sph(0.065, 10, 8), mat(0x15121c), s * 0.16, 0.0, 0.4, head);
    mesh(new THREE.TorusGeometry(0.12, 0.022, 8, 20), mat(0x8a3f7a, { roughness: 0.3 }), s * 0.16, 0.0, 0.42, head);
    mesh(sph(0.07, 8, 6), mat(0xff9b8a), s * 0.27, -0.13, 0.38, head).scale.z = 0.3;
  }
  mesh(rbox(0.1, 0.03, 0.03, 0.01), mat(0x8a3f7a), 0, 0.02, 0.43, head);
  const smile = mesh(new THREE.TorusGeometry(0.11, 0.025, 6, 14, Math.PI), mat(0x6b2a1a), 0, -0.16, 0.4, head); smile.rotation.z = Math.PI;
  // watering can
  const can = new THREE.Group(); can.position.set(-0.75, 0.7, 0.15); g.add(can);
  mesh(cyl(0.22, 0.25, 0.42, 16), mat(0x4fb06a, { roughness: 0.4, metalness: 0.2 }), 0, 0, 0, can);
  stick(new THREE.Vector3(0, 0, 0.15), new THREE.Vector3(0, 0.25, 0.6), 0.04, mat(0x4fb06a, { metalness: 0.2 }), can);
  mesh(new THREE.TorusGeometry(0.17, 0.035, 8, 16, Math.PI), mat(0x3f9a58), 0, 0.2, 0, can);
  g.userData.head = head;
  return g;
}
const NAN = nan();
{ const c = tw(12, 6); NAN.position.set(c.x + 0.2, 0.02, c.z - 2.4); NAN.rotation.y = -0.55; NAN.scale.setScalar(1.05); scene.add(NAN); }
// raised veggie bed at the back left, flower bed along the front
{
  const g = new THREE.Group(); g.position.set(-8, 0, -12.6); scene.add(g);
  const wood = mat(0xb5824f, { roughness: 0.7 });
  mesh(rbox(7, 0.7, 0.2, 0.05), wood, 0, 0.35, -1.1, g); mesh(rbox(7, 0.7, 0.2, 0.05), wood, 0, 0.35, 1.1, g);
  mesh(rbox(0.2, 0.7, 2.4, 0.05), wood, -3.4, 0.35, 0, g); mesh(rbox(0.2, 0.7, 2.4, 0.05), wood, 3.4, 0.35, 0, g);
  mesh(new THREE.BoxGeometry(6.6, 0.55, 2.0), soilM, 0, 0.3, 0, g);
  for (let i = 0; i < 6; i++) {
    const lg = new THREE.Group(); lg.position.set(-2.8 + i * 1.1, 0.6, -0.45); g.add(lg);
    for (let k = 0; k < 5; k++) mesh(sph(0.22, 10, 8), mat(k % 2 ? 0x8fd45a : 0x6fbf47, { roughness: 0.6 }), rr(-0.15, 0.15), rr(0.05, 0.2), rr(-0.15, 0.15), lg).scale.y = 0.7;
  }
  for (let i = 0; i < 4; i++) {
    const x = -2.6 + i * 1.75; stick(new THREE.Vector3(x, 0.5, 0.5), new THREE.Vector3(x, 1.9, 0.5), 0.035, mat(0xc89a62), g);
    mesh(new THREE.IcosahedronGeometry(0.35, 0), mat(0x4f9a35, { flatShading: true }), x, 1.3, 0.5, g);
    for (let k = 0; k < 3; k++) mesh(sph(0.1, 10, 8), mat(0xff4b3a, { roughness: 0.35 }), x + rr(-0.25, 0.25), rr(0.9, 1.6), 0.5 + rr(-0.2, 0.25), g);
  }
}
for (let i = 0; i < 18; i++) {
  const x = -15 + i * 1.9, z = 10.4;
  if (x > -13.2 && x < -12) continue;
  mesh(new THREE.IcosahedronGeometry(0.5, 1), mat([0x4f9a35, 0x5aab3d][i % 2], { roughness: 0.7, flatShading: true }), x, 0.4, z, scene).scale.set(1, 0.75, 0.8);
  if (i % 2 === 0) for (let k = 0; k < 3; k++) mesh(sph(0.1, 8, 6), mat([0xff6f91, 0xffd25a, 0xffffff][(i + k) % 3]), x + rr(-0.3, 0.3), 0.75, z + rr(-0.2, 0.25), scene);
}

// back deck with a barbie, just past the front pickets
{
  const g = new THREE.Group(); g.position.set(-4, 0, 15.2); scene.add(g);
  const boards = [mat(0xb98250, { roughness: 0.7 }), mat(0xa9733f, { roughness: 0.7 })];
  for (let i = 0; i < 14; i++) mesh(rbox(16, 0.22, 0.5, 0.04, 2), boards[i % 2], 0, 0.25, -3.2 + i * 0.5, g);
  // barbie
  const bbq = new THREE.Group(); bbq.position.set(-4.5, 0.36, -1.6); g.add(bbq);
  const black = mat(0x2a2a30, { roughness: 0.4, metalness: 0.4 }), steel = mat(0xc7cbd0, { metalness: 0.6, roughness: 0.3 });
  for (const [x, z] of [[-0.7, -0.35], [0.7, -0.35], [-0.7, 0.35], [0.7, 0.35]]) mesh(cyl(0.05, 0.05, 1.0, 8), steel, x, 0.5, z, bbq);
  mesh(rbox(1.7, 0.4, 0.95, 0.08), black, 0, 1.15, 0, bbq);
  const lid = mesh(new THREE.CylinderGeometry(0.47, 0.47, 1.7, 20, 1, false, 0, Math.PI), black, 0, 1.35, -0.05, bbq); lid.rotation.z = Math.PI / 2; lid.rotation.x = -0.9;
  for (let i = 0; i < 4; i++) mesh(rbox(0.36, 0.08, 0.2, 0.04), mat(0xb5532f, { roughness: 0.5 }), -0.55 + i * 0.37, 1.39, 0.15, bbq);
  mesh(rbox(0.6, 0.06, 0.95, 0.03), steel, 1.15, 1.1, 0, bbq);
  // two outdoor chairs and a table
  const chairM = mat(0x3fa7d8, { roughness: 0.45 }), chairM2 = mat(0xff8a5c, { roughness: 0.45 });
  [[1.6, chairM, 0.3], [4.6, chairM2, -0.3]].forEach(([x, m, r]) => {
    const c = new THREE.Group(); c.position.set(x, 0.36, -1.4); c.rotation.y = r; g.add(c);
    mesh(rbox(0.9, 0.12, 0.9, 0.05), m, 0, 0.55, 0, c);
    mesh(rbox(0.9, 0.9, 0.12, 0.05), m, 0, 1.0, -0.42, c).rotation.x = -0.15;
    for (const [lx, lz] of [[-0.38, -0.38], [0.38, -0.38], [-0.38, 0.38], [0.38, 0.38]]) mesh(cyl(0.04, 0.04, 0.55, 6), m, lx, 0.27, lz, c);
  });
  mesh(cyl(0.55, 0.55, 0.08, 24), mat(0xf4f1ea), 3.1, 1.05, -1.6, g);
  mesh(cyl(0.06, 0.06, 0.7, 8), steel, 3.1, 0.7, -1.6, g);
  mesh(cyl(0.12, 0.1, 0.25, 12), mat(0xfff4d6), 3.0, 1.22, -1.5, g);
  // pot plants
  for (const [x, z] of [[-7.3, -2.6], [7.3, -2.6]]) {
    mesh(cyl(0.45, 0.35, 0.7, 16), mat(0xc96a3a, { roughness: 0.7 }), x, 0.7, z, g);
    mesh(new THREE.IcosahedronGeometry(0.6, 1), mat(0x4f9a35, { flatShading: true, roughness: 0.7 }), x, 1.35, z, g);
  }
}
// neighbours' yards beyond the side fences
{
  const nb = (x0, z0, x1, z1) => fenceRun(x0, z0, x1, z1, 1.9);
  nb(YARD.x0 - 22, YARD.z0 + 4, YARD.x0 - 0.2, YARD.z0 + 4);
  nb(YARD.x1 + 0.2, YARD.z0 + 6, YARD.x1 + 24, YARD.z0 + 6);
  nb(YARD.x0 - 0.2, YARD.z1 + 8, YARD.x0 - 22, YARD.z1 + 8);
  for (let i = 0; i < 24; i++) {
    const side = i % 2 ? 1 : -1;
    const x = side > 0 ? rr(YARD.x1 + 3, YARD.x1 + 20) : rr(YARD.x0 - 20, YARD.x0 - 3);
    const z = rr(YARD.z0 - 4, YARD.z1 + 10);
    const b = mesh(new THREE.IcosahedronGeometry(rr(0.8, 1.5), 0), mat([0x4f8a3a, 0x5c9a44, 0x6aa84e][i % 3], { roughness: 0.8, flatShading: true }), x, 0.6, z, scene);
    b.scale.y = 0.8;
  }
  const shed2 = mesh(rbox(4, 2.4, 3, 0.05), mat(0xc96a4a, { roughness: 0.6 }), YARD.x0 - 9, 1.2, YARD.z0 + 9, scene);
  const roof2 = mesh(rbox(4.6, 0.2, 3.6, 0.05), mat(0xdfe2e4, { metalness: 0.4, roughness: 0.35 }), YARD.x0 - 9, 2.5, YARD.z0 + 9, scene); roof2.rotation.x = 0.12;
  const tramp = new THREE.Group(); tramp.position.set(YARD.x1 + 9, 0, YARD.z0 + 14); scene.add(tramp);
  mesh(cyl(2.4, 2.4, 0.1, 36), mat(0x2a2a30, { roughness: 0.6 }), 0, 0.9, 0, tramp);
  mesh(new THREE.TorusGeometry(2.45, 0.14, 8, 40), mat(0x3fa7d8, { roughness: 0.45 }), 0, 0.92, 0, tramp).rotation.x = Math.PI / 2;
  for (let i = 0; i < 6; i++) { const a = i / 6 * Math.PI * 2; mesh(cyl(0.05, 0.05, 0.9, 6), mat(0xc7cbd0, { metalness: 0.5 }), Math.cos(a) * 2.3, 0.45, Math.sin(a) * 2.3, tramp); }
}
// ---------- shadows on everything solid ----------
scene.traverse(o => {
  if (o.isMesh && !o.userData.noShadow) { o.castShadow = true; o.receiveShadow = true; }
  if (o.isMesh && o.material && o.material.transparent) o.castShadow = false;
});

// ---------- cameras ----------
const camera = new THREE.PerspectiveCamera(34, W / H, 0.3, 500);
const views = {
  hero: { pos: [10.5, 24, 26.5], look: [3.0, 0, 2.4], fov: 36 },
  close: { pos: [2.6, 8.6, 14.4], look: [-1.8, 1.0, 0.4], fov: 42 },
  overview: { pos: [1.5, 40, 21], look: [1.5, 0, -1.6], fov: 40 },
};
const v = views[VIEW] || views.hero;
camera.fov = v.fov; camera.position.set(...v.pos); camera.lookAt(...v.look); camera.updateProjectionMatrix();
if (VIEW === 'hero') rangeRing.visible = true;
{ const hm = scene.userData.shed.userData.heart; const wp = new THREE.Vector3(); hm.getWorldPosition(wp); const to = camera.position.clone(); to.y = wp.y; hm.lookAt(to); hm.position.x -= 0; }


// ---------- HUD ----------
const hud = document.getElementById('hud');
if (VIEW === 'overview') hud.classList.add('hidden');
if (VIEW === 'close') { for (const id of ['tip']) document.getElementById(id).classList.add('hidden'); }

function thumbnail(builder, opts = {}) {
  const c = document.createElement('canvas'); c.width = 256; c.height = 224;
  const r = new THREE.WebGLRenderer({ canvas: c, alpha: true, antialias: true, preserveDrawingBuffer: true });
  r.toneMapping = THREE.ACESFilmicToneMapping; r.outputColorSpace = THREE.SRGBColorSpace; r.setClearColor(0x000000, 0);
  const s = new THREE.Scene();
  s.add(new THREE.HemisphereLight(0xffffff, 0x88aa66, 1.4));
  const d = new THREE.DirectionalLight(0xfff2dd, 2.4); d.position.set(-3, 5, 6); s.add(d);
  const obj = builder(); s.add(obj);
  obj.traverse(o => { if (o.isPointLight) o.intensity = 0; if (o.isSprite) o.visible = false; });
  const box = new THREE.Box3().setFromObject(obj); const ctr = box.getCenter(new THREE.Vector3()); const size = box.getSize(new THREE.Vector3());
  const cam = new THREE.PerspectiveCamera(28, 256 / 224, 0.1, 100);
  const dist = Math.max(size.y, size.x * 0.9) * (opts.zoom || 2.3);
  cam.position.set(ctr.x + dist * 0.35, ctr.y + dist * (opts.up ?? 0.35), ctr.z + dist); cam.lookAt(ctr.x, ctr.y + (opts.dy || 0), ctr.z);
  r.render(s, cam);
  const url = c.toDataURL('image/png'); r.dispose();
  return url;
}
const CARDS = [
  ['thorn', 'Thorn Sprout', 60, 'linear-gradient(#9be36a, #4fae3c)', {}],
  ['sunpetal', 'Sunpetal', 75, 'linear-gradient(#ffe27a, #f2b01e)', {}],
  ['dandelion', 'Dandelion', 100, 'linear-gradient(#bfe6ff, #6fb5ea)', { zoom: 1.9 }],
  ['pumpkin', 'Pumpkin', 130, 'linear-gradient(#ffbb72, #ee7a2a)', {}],
  ['snapjaw', 'Snapjaw', 170, 'linear-gradient(#ff9aa8, #de4a63)', {}],
];
const sapIcon = '<svg viewBox="0 0 48 48"><path d="M24 4 C24 4 9 22 9 31 C9 39 16 45 24 45 C32 45 39 39 39 31 C39 22 24 4 24 4 Z" fill="#ffc23a" stroke="#14121a" stroke-width="4"/></svg>';
const bar = document.getElementById('seedbar');
CARDS.forEach(([id, name, cost, bg, o], i) => {
  const el = document.createElement('div'); el.className = 'card' + (id === 'pumpkin' ? ' sel' : ''); el.style.background = bg;
  el.innerHTML = `<span class="key stroke">${i + 1}</span><img src="${thumbnail(SEEDS[id], o)}" alt=""><span class="name stroke">${name}</span><span class="cost stroke">${sapIcon}${cost}</span>`;
  bar.appendChild(el);
});
document.getElementById('nanface').src = thumbnail(() => { const n = nan(); return n.userData.head; }, { zoom: 2.4, up: 0.05 });

// floating reward numbers and labels (projected from 3D)
function floatAt(p3, text, cls = '', dy = 0) {
  const p = p3.clone().project(camera);
  const el = document.createElement('div'); el.className = 'float stroke ' + cls; el.textContent = text;
  el.style.left = ((p.x + 1) / 2 * W) + 'px'; el.style.top = ((1 - p.y) / 2 * H + dy) + 'px';
  document.getElementById('floats').appendChild(el);
}
if (VIEW !== 'overview') {
  floatAt(popAt.clone().add(new THREE.Vector3(0, 1.6, 0)), '+10');
}

await document.fonts.ready;
renderer.render(scene, camera);
window.READY = true;
