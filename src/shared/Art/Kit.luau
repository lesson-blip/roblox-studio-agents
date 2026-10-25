--!strict
-- Tiny builder for models made only of Parts (no meshes, no uploaded assets).
-- Coordinates and sizes are given in "preview units" (design/preview3d/scene.js),
-- and a Kit context turns them into studs with its own CFrame and scale. Every
-- part made through one context (and its sub contexts) is recorded in `rec`, so a
-- client can animate a model by moving its parts with workspace:BulkMoveTo.

local Kit = {}
Kit.__index = Kit

export type Record = {
	part: BasePart,
	tag: string?, -- "leg", "jaw", "head", "static" (does not sway) or nil
	pivot: Vector3?, -- studs, model space, for "leg" and "jaw"
	phase: number?,
}

export type Ctx = {
	cf: CFrame,
	s: number,
	parent: Instance,
	rec: { Record },
	tag: string?,
	pivot: Vector3?,
	phase: number?,
	shadows: boolean,
	material: Enum.Material?,
}

-- Colour from a 0xRRGGBB number, as written in scene.js.
function Kit.hex(n: number): Color3
	local r = bit32.band(bit32.rshift(n, 16), 255)
	local g = bit32.band(bit32.rshift(n, 8), 255)
	local b = bit32.band(n, 255)
	return Color3.fromRGB(r, g, b)
end

-- Deterministic random numbers (the same Park and Miller generator scene.js uses),
-- so every server builds the same garden.
function Kit.rng(seed: number): (() -> number, (number, number) -> number)
	local s = seed
	local function rnd(): number
		s = (s * 16807) % 2147483647
		return (s - 1) / 2147483646
	end
	local function rr(a: number, b: number): number
		return a + (b - a) * rnd()
	end
	return rnd, rr
end

function Kit.new(parent: Instance, cf: CFrame, scale: number): Ctx
	return {
		cf = cf,
		s = scale,
		parent = parent,
		rec = {},
		tag = nil,
		pivot = nil,
		phase = nil,
		shadows = true,
		material = nil,
	}
end

-- A child context: offset (in units) and rotation relative to `ctx`, optional
-- extra scale. Shares the record list and parent.
function Kit.sub(ctx: Ctx, x: number, y: number, z: number, rx: number?, ry: number?, rz: number?, k: number?): Ctx
	local s = ctx.s
	return {
		cf = ctx.cf * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(rx or 0, ry or 0, rz or 0),
		s = s * (k or 1),
		parent = ctx.parent,
		rec = ctx.rec,
		tag = ctx.tag,
		pivot = ctx.pivot,
		phase = ctx.phase,
		shadows = ctx.shadows,
		material = ctx.material,
	}
end

-- Same context with a tag (and optional pivot in units, relative to this context).
function Kit.tagged(ctx: Ctx, tag: string?, px: number?, py: number?, pz: number?, phase: number?): Ctx
	local c = Kit.sub(ctx, 0, 0, 0)
	c.tag = tag
	if px and py and pz then
		c.pivot = (ctx.cf * CFrame.new(px * ctx.s, py * ctx.s, pz * ctx.s)).Position
	end
	c.phase = phase
	return c
end

-- World point of a local point (units).
function Kit.point(ctx: Ctx, x: number, y: number, z: number): Vector3
	return (ctx.cf * CFrame.new(x * ctx.s, y * ctx.s, z * ctx.s)).Position
end

local function finish(ctx: Ctx, p: BasePart, color: Color3, opts: { [string]: any }?): BasePart
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = ctx.material or Enum.Material.SmoothPlastic
	p.Color = color
	p.CastShadow = ctx.shadows
	if opts then
		for k, v in opts do
			(p :: any)[k] = v
		end
	end
	p.Parent = ctx.parent
	table.insert(ctx.rec, { part = p, tag = ctx.tag, pivot = ctx.pivot, phase = ctx.phase })
	return p
end

local function place(ctx: Ctx, x: number, y: number, z: number, rx: number?, ry: number?, rz: number?): CFrame
	local s = ctx.s
	return ctx.cf * CFrame.new(x * s, y * s, z * s) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
end

-- Box w by h by d (units) centred at x, y, z.
function Kit.box(ctx: Ctx, w: number, h: number, d: number, x: number, y: number, z: number, color: Color3, rot: { number }?, opts: { [string]: any }?): BasePart
	local p = Instance.new("Part")
	p.Size = Vector3.new(w * ctx.s, h * ctx.s, d * ctx.s)
	p.CFrame = place(ctx, x, y, z, rot and rot[1], rot and rot[2], rot and rot[3])
	return finish(ctx, p, color, opts)
end

-- Ellipsoid of radius r scaled by sx, sy, sz. A round one is a Ball part; a squashed
-- one is a block with a sphere SpecialMesh (which fills the part's size).
function Kit.ball(ctx: Ctx, r: number, x: number, y: number, z: number, color: Color3, scale: { number }?, rot: { number }?, opts: { [string]: any }?): BasePart
	local p = Instance.new("Part")
	local sx, sy, sz = 1, 1, 1
	if scale then
		sx, sy, sz = scale[1], scale[2], scale[3]
	end
	local d = 2 * r * ctx.s
	if sx == sy and sy == sz then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(d * sx, d * sx, d * sx)
	else
		p.Size = Vector3.new(d * sx, d * sy, d * sz)
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType.Sphere
		m.Parent = p
	end
	p.CFrame = place(ctx, x, y, z, rot and rot[1], rot and rot[2], rot and rot[3])
	return finish(ctx, p, color, opts)
end

-- Upright cylinder of radius r and height h centred at x, y, z (then rotated by rot).
function Kit.cyl(ctx: Ctx, r: number, h: number, x: number, y: number, z: number, color: Color3, rot: { number }?, opts: { [string]: any }?): BasePart
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Cylinder
	p.Size = Vector3.new(h * ctx.s, 2 * r * ctx.s, 2 * r * ctx.s)
	p.CFrame = place(ctx, x, y, z, rot and rot[1], rot and rot[2], rot and rot[3]) * CFrame.Angles(0, 0, math.pi / 2)
	return finish(ctx, p, color, opts)
end

-- Cylinder (or a square rod with `square`) from point a to point b (units, local).
function Kit.stick(ctx: Ctx, a: Vector3, b: Vector3, r: number, color: Color3, square: boolean?, opts: { [string]: any }?): BasePart?
	local s = ctx.s
	local wa = (ctx.cf * CFrame.new(a * s)).Position
	local wb = (ctx.cf * CFrame.new(b * s)).Position
	local len = (wb - wa).Magnitude
	if len < 1e-4 then
		return nil
	end
	local p = Instance.new("Part")
	if not square then
		p.Shape = Enum.PartType.Cylinder
	end
	p.Size = Vector3.new(len, 2 * r * s, 2 * r * s)
	local mid = (wa + wb) / 2
	local up = if math.abs((wb - wa).Unit.Y) > 0.99 then Vector3.xAxis else Vector3.yAxis
	-- lookAt points -Z at b; turning 90 degrees about Y puts the part's X axis there.
	p.CFrame = CFrame.lookAt(mid, wb, up) * CFrame.Angles(0, math.pi / 2, 0)
	return finish(ctx, p, color, opts)
end

-- WedgePart w by h by d. Roblox wedges are full height at their back (+Z) face and
-- slope down to the bottom of their front (-Z) face.
function Kit.wedge(ctx: Ctx, w: number, h: number, d: number, x: number, y: number, z: number, color: Color3, rot: { number }?, opts: { [string]: any }?): BasePart
	local p = Instance.new("WedgePart")
	p.Size = Vector3.new(w * ctx.s, h * ctx.s, d * ctx.s)
	p.CFrame = place(ctx, x, y, z, rot and rot[1], rot and rot[2], rot and rot[3])
	return finish(ctx, p, color, opts)
end

-- A stepped cone (no cone primitive): `tiers` cylinders, each narrower, base radius r,
-- height h, base centred at x, y, z, then rotated by rot about the base.
function Kit.cone(ctx: Ctx, r: number, h: number, x: number, y: number, z: number, color: Color3, tiers: number?, rot: { number }?)
	local n = tiers or 3
	local c = Kit.sub(ctx, x, y, z, rot and rot[1], rot and rot[2], rot and rot[3])
	local th = h / (n + 0.6)
	for i = 0, n - 1 do
		local rad = r * (1 - i / n)
		Kit.cyl(c, rad, th, 0, th * (i + 0.5), 0, color)
	end
	Kit.ball(c, r / n * 0.9, 0, th * n + r / n * 0.4, 0, color)
end

-- Cartoon eyes (white, pupil, highlight) facing +Z, as scene.js `eyes`.
function Kit.eyes(ctx: Ctx, y: number, z: number, spread: number, size: number, look: number?)
	local white = Color3.fromRGB(255, 255, 255)
	local black = Kit.hex(0x15121c)
	local lk = look or 0
	for _, side in { -1, 1 } do
		Kit.ball(ctx, size, side * spread, y, z, white, { 1, 1.15, 0.8 })
		Kit.ball(ctx, size * 0.55, side * spread + lk * size * 0.3, y - size * 0.05, z + size * 0.62, black)
		Kit.ball(ctx, size * 0.18, side * spread + size * 0.2, y + size * 0.25, z + size * 0.95, white)
	end
end

-- A small curved smile from three dark beads (no torus primitive in Roblox).
function Kit.smile(ctx: Ctx, y: number, z: number, r: number, thick: number, color: Color3)
	for i = -1, 1 do
		local a = i * 0.7
		Kit.ball(ctx, thick, math.sin(a) * r, y - math.cos(a) * r * 0.45 + r * 0.3, z, color)
	end
end

-- Sets transparency on every part (ghost previews) and turns off their shadows.
function Kit.ghost(model: Instance, transparency: number)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.Transparency = math.max(d.Transparency, transparency)
			d.CastShadow = false
		elseif d:IsA("Light") then
			d.Enabled = false
		end
	end
end

return Kit
