// Draws export/parts.json (written by `lune run tools/export-parts`): every Part the
// Roblox code builds, as Roblox shapes, with the camera the game would use.
// This approximates Roblox's look (no Roblox lighting or materials); it is a check of
// shapes, sizes and placement. Open roblox.html?view=game|overview.
import * as THREE from 'three';

const params = new URLSearchParams(location.search);
const VIEW = params.get('view') || 'game';
const data = await (await fetch('export/parts.json')).json();
const W = data.width, H = data.height;

const canvas = document.getElementById('c');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(1);
renderer.setSize(W, H, false);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.outputColorSpace = THREE.SRGBColorSpace;

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x9fd3f2);
scene.add(new THREE.HemisphereLight(0xcfeaff, 0x6a8f3a, 1.15));
const sun = new THREE.DirectionalLight(0xfff0d6, 2.6);
sun.position.set(-44, 68, 40 + 16).add(new THREE.Vector3(24, 0, 16));
sun.target.position.set(24, 0, 16);
sun.castShadow = true;
sun.shadow.mapSize.set(4096, 4096);
Object.assign(sun.shadow.camera, { left: -80, right: 80, top: 70, bottom: -70, near: 1, far: 300 });
sun.shadow.bias = -0.0004;
scene.add(sun); scene.add(sun.target);

// Roblox WedgePart: full height at +Z, sloping to the bottom of -Z (unit size, centred).
function wedgeGeo() {
  const g = new THREE.BufferGeometry();
  const v = [
    [-0.5, -0.5, -0.5], [0.5, -0.5, -0.5], [0.5, -0.5, 0.5], [-0.5, -0.5, 0.5],
    [-0.5, 0.5, 0.5], [0.5, 0.5, 0.5],
  ];
  const f = [[0, 1, 2], [0, 2, 3], [3, 2, 5], [3, 5, 4], [0, 4, 5], [0, 5, 1], [0, 3, 4], [1, 5, 2]];
  const pos = [];
  for (const t of f) for (const i of t) pos.push(...v[i]);
  g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
  g.computeVertexNormals();
  return g;
}
const geos = {
  Block: new THREE.BoxGeometry(1, 1, 1),
  Ball: new THREE.SphereGeometry(0.5, 20, 14),
  Sphere: new THREE.SphereGeometry(0.5, 20, 14),
  Cylinder: new THREE.CylinderGeometry(0.5, 0.5, 1, 20).rotateZ(Math.PI / 2), // Roblox cylinders run along X
  Wedge: wedgeGeo(),
};
const mats = new Map();
function mat(col, t, r) {
  const key = col.join(',') + t + r;
  if (!mats.has(key)) {
    const c = new THREE.Color().setRGB(col[0], col[1], col[2], THREE.SRGBColorSpace);
    mats.set(key, new THREE.MeshStandardMaterial({ color: c, roughness: 0.6 - r, metalness: r, transparent: t > 0, opacity: 1 - t, depthWrite: t < 0.5 }));
  }
  return mats.get(key);
}
for (const p of data.parts) {
  let geo = geos[p.sh] || geos.Block;
  if (p.c === 'WedgePart') geo = geos.Wedge;
  if (p.sh === 'Ball') geo = geos.Ball;
  const m = new THREE.Mesh(geo, mat(p.col, p.t, p.r || 0));
  const [x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22] = p.cf;
  const mx = new THREE.Matrix4().set(r00, r01, r02, x, r10, r11, r12, y, r20, r21, r22, z, 0, 0, 0, 1);
  mx.multiply(new THREE.Matrix4().makeScale(p.s[0], p.s[1], p.s[2]));
  m.matrixAutoUpdate = false;
  m.matrix.copy(mx);
  m.castShadow = p.cs && p.t < 0.5;
  m.receiveShadow = true;
  scene.add(m);
}

const camera = new THREE.PerspectiveCamera(data.camera.fov, W / H, 0.5, 2000);
if (VIEW === 'overview') {
  camera.fov = 40; camera.position.set(27, 82, 58); camera.lookAt(27, 0, 12);
} else {
  const [x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22] = data.camera.cf;
  const mx = new THREE.Matrix4().set(r00, r01, r02, x, r10, r11, r12, y, r20, r21, r22, z, 0, 0, 0, 1);
  camera.matrixAutoUpdate = false;
  camera.matrix.copy(mx);
  camera.matrixWorld.copy(mx);
  camera.matrixWorldInverse.copy(mx).invert();
}
camera.updateProjectionMatrix();
if (VIEW !== 'overview') {
  // Outline the HUD's safe box so the framing can be judged.
  document.getElementById('safe').style.display = 'block';
}
renderer.render(scene, camera);
window.READY = true;
