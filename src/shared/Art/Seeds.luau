--!strict
-- Plant models, one builder per seed, following design/preview3d/scene.js SEEDS.
-- Each builder draws in preview units with its base at the context origin, facing +Z
-- (the face looks at the camera until the plant turns to a pest). Parts tagged "jaw"
-- or "head" can be animated by the client; the rest sway together.
-- Shared so the client can draw plants on the board and in the seed card portraits.

local Kit = require(script.Parent:WaitForChild("Kit")) :: any

local Seeds = {}

local hex = Kit.hex
local V = Vector3.new
local WHITE = Color3.new(1, 1, 1)

-- A curved stem as a few straight segments with ball joints.
local function stem(ctx: any, pts: { Vector3 }, r: number, color: Color3)
	for i = 1, #pts - 1 do
		Kit.stick(ctx, pts[i], pts[i + 1], r, color)
		if i < #pts - 1 then
			Kit.ball(ctx, r, pts[i + 1].X, pts[i + 1].Y, pts[i + 1].Z, color)
		end
	end
end

-- A flat leaf (a squashed turned ball) at angle a around the stem.
local function leaf(ctx: any, a: number, dist: number, y: number, len: number, color: Color3, tilt: number?)
	Kit.ball(ctx, len, math.cos(a) * dist, y, math.sin(a) * dist, color, { 1.7, 0.25, 0.6 }, { 0, -a, tilt or 0.25 })
end

local builders: { [string]: (any) -> { muzzle: Vector3 } } = {}

builders.thorn = function(ctx)
	local leaf1, leaf2 = hex(0x3fa63c), hex(0x52bf45)
	Kit.ball(ctx, 0.62, 0, 0.62, 0, leaf1, { 1, 0.85, 1 })
	Kit.ball(ctx, 0.38, -0.42, 0.42, 0.1, leaf2)
	Kit.ball(ctx, 0.34, 0.45, 0.4, -0.05, leaf2)
	-- Spikes: thin pale rods standing out from the bush (fewer than the preview's 26).
	local spike = hex(0xe9f27a)
	local n = 18
	for i = 0, n - 1 do
		local yv = 1 - (i / (n - 1)) * 1.3
		local r = math.sqrt(math.max(0, 1 - yv * yv))
		local a = i * 2.39996
		local nv = V(math.cos(a) * r, math.max(yv, -0.2), math.sin(a) * r).Unit
		if not (nv.Z > 0.6 and nv.Y < 0.55 and nv.Y > -0.15) then -- keep the face clear
			local base = V(nv.X * 0.55, 0.62 + nv.Y * 0.46, nv.Z * 0.55)
			Kit.stick(ctx, base, base + nv * 0.3, 0.035, spike, true)
		end
	end
	Kit.eyes(ctx, 0.66, 0.5, 0.17, 0.12)
	-- Angry little brows.
	for _, s in { -1, 1 } do
		Kit.box(ctx, 0.2, 0.05, 0.05, s * 0.17, 0.84, 0.56, hex(0x1d4a1c), { 0, 0, s * -0.35 })
	end
	return { muzzle = V(0, 0.9, 0.4) }
end

builders.sunpetal = function(ctx)
	local green = hex(0x4f9a35)
	stem(ctx, { V(0, 0, 0), V(0.05, 0.6, 0), V(0, 1.2, 0.05), V(0, 1.55, 0.12) }, 0.08, green)
	for _, l in { { 1, 0.55 }, { -1, 0.85 } } do
		Kit.ball(ctx, 0.28, l[1] * 0.3, l[2], 0, hex(0x56ad3b), { 1.6, 0.25, 0.8 }, { 0, 0, l[1] * 0.4 })
	end
	local head = Kit.tagged(Kit.sub(ctx, 0, 1.65, 0.18, -0.35, 0, 0), "head", 0, 0, 0)
	local p1, p2 = hex(0xffcf2e), hex(0xffb51a)
	for i = 0, 11 do
		local a = i / 12 * math.pi * 2
		Kit.ball(head, 0.2, math.cos(a) * 0.55, math.sin(a) * 0.55, -0.02, if i % 2 == 0 then p1 else p2, { 1.5, 0.6, 0.25 }, { 0, 0, a })
	end
	Kit.cyl(head, 0.42, 0.14, 0, 0, 0.02, hex(0x7a4618), { math.pi / 2, 0, 0 })
	local face = Kit.sub(head, 0, 0, 0.1)
	Kit.eyes(face, 0.1, 0.02, 0.14, 0.09)
	Kit.smile(face, -0.08, 0.06, 0.11, 0.025, hex(0x2a1606))
	for _, s in { -1, 1 } do
		Kit.ball(face, 0.05, s * 0.25, -0.05, 0.03, hex(0xff7b6b), { 1, 1, 0.4 })
	end
	-- The warm glow: a point light in the flower (client and server alike).
	local disc = head.rec[#head.rec].part
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 195, 90)
	light.Brightness = 1.6
	light.Range = 9
	light.Shadows = false
	light.Parent = disc
	return { muzzle = V(0, 1.7, 0.3) }
end

builders.burr = function(ctx)
	-- Burr Vine: a low tangle of vines carrying spiky burrs (not in the preview; same style).
	local vine = hex(0x5a8f2f)
	local burr = hex(0x9a6a38)
	local spike = hex(0xe2c890)
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2 + 0.4
		stem(ctx, { V(0, 0.05, 0), V(math.cos(a) * 0.35, 0.35, math.sin(a) * 0.35), V(math.cos(a + 0.6) * 0.6, 0.2, math.sin(a + 0.6) * 0.6) }, 0.06, vine)
		leaf(ctx, a + 0.3, 0.45, 0.12, 0.22, hex(0x6fae3e))
	end
	local function burrBall(x: number, y: number, z: number, r: number)
		Kit.ball(ctx, r, x, y, z, burr)
		for k = 0, 7 do
			local a = k / 8 * math.pi * 2
			local yy = if k % 2 == 0 then 0.35 else -0.25
			local nv = V(math.cos(a), yy, math.sin(a)).Unit
			local b = V(x, y, z) + nv * r * 0.8
			Kit.stick(ctx, b, b + nv * r * 0.55, 0.025, spike, true)
		end
	end
	burrBall(0, 0.62, 0, 0.36)
	burrBall(-0.45, 0.32, -0.15, 0.2)
	burrBall(0.42, 0.3, 0.12, 0.18)
	Kit.eyes(ctx, 0.7, 0.3, 0.13, 0.1)
	return { muzzle = V(0, 0.7, 0.35) }
end

builders.dandelion = function(ctx)
	stem(ctx, { V(0, 0, 0), V(0.08, 0.8, 0), V(-0.06, 1.6, 0.05), V(0, 2.25, 0) }, 0.07, hex(0x5aa83a))
	for i = 0, 4 do
		leaf(ctx, i / 5 * math.pi * 2 + 0.3, 0.38, 0.12, 0.3, hex(0x4c9e33))
	end
	local head = Kit.tagged(ctx, "head", 0, 2.3, 0)
	Kit.ball(head, 0.16, 0, 2.3, 0, hex(0xc9a35a))
	Kit.ball(head, 0.62, 0, 2.3, 0, WHITE, nil, nil, { Transparency = 0.55, CastShadow = false })
	-- Seed fluff: tufts on a sphere (the preview's 70 strands, cut to 26).
	local strand = hex(0xeee8d8)
	local n = 26
	for i = 0, n - 1 do
		local yv = 1 - (i / (n - 1)) * 2
		local r = math.sqrt(math.max(0, 1 - yv * yv))
		local a = i * 2.39996
		local nv = V(math.cos(a) * r, yv, math.sin(a) * r)
		local tip = V(0, 2.3, 0) + nv * 0.6
		if i % 2 == 0 then
			Kit.stick(head, V(0, 2.3, 0) + nv * 0.16, tip, 0.014, strand, nil, { CastShadow = false })
		end
		Kit.ball(head, 0.08, tip.X, tip.Y, tip.Z, WHITE)
	end
	return { muzzle = V(0, 2.4, 0.4) }
end

builders.pumpkin = function(ctx)
	local orange, orange2 = hex(0xf5862a), hex(0xe8751c)
	for i = 0, 6 do
		local a = i / 7 * math.pi * 2
		Kit.ball(ctx, 0.5, math.cos(a) * 0.28, 0.58, math.sin(a) * 0.28, if i % 2 == 1 then orange else orange2, { 0.62, 1, 1 }, { 0, -a, 0 })
	end
	Kit.ball(ctx, 0.55, 0, 0.6, 0, orange, { 1, 0.9, 1 })
	-- The barrel: a gourd neck pointing up and forward.
	local barrel = Kit.tagged(Kit.sub(ctx, 0, 1.0, -0.05, 0.75, 0, 0), "head", 0, 0, 0)
	Kit.cyl(barrel, 0.24, 0.8, 0, 0.4, 0, hex(0x6f9a32))
	Kit.cyl(barrel, 0.27, 0.12, 0, 0.8, 0, hex(0x8bb840))
	Kit.cyl(barrel, 0.16, 0.05, 0, 0.865, 0, hex(0x1c140c))
	Kit.cyl(barrel, 0.31, 0.1, 0, 0.05, 0, hex(0x55762a))
	for _, l in { { 2.3 }, { 3.9 } } do
		leaf(ctx, l[1], 0.55, 0.12, 0.3, hex(0x47a03a), 0)
	end
	Kit.eyes(ctx, 0.72, 0.5, 0.2, 0.13)
	Kit.smile(ctx, 0.48, 0.53, 0.12, 0.03, hex(0x3a1a08))
	return { muzzle = V(0, 1.75, 0.55) }
end

builders.snapjaw = function(ctx)
	stem(ctx, { V(0, 0, 0), V(0.05, 0.4, -0.05), V(-0.05, 0.8, 0.05), V(0, 1.0, 0.15) }, 0.09, hex(0x4f9a35))
	for i = 0, 3 do
		leaf(ctx, i / 4 * math.pi * 2 + 0.6, 0.4, 0.12, 0.25, hex(0x5bb341))
	end
	local head = Kit.sub(ctx, 0, 1.1, 0.15, 0, 0, 0, 1.25)
	local outer, inner, tooth = hex(0x7cc443), hex(0xe8414f), hex(0xfffbe8)
	-- One jaw: a squashed half shell (a flattened ball), a red mouth disc and teeth.
	local function jaw(j: any, up: boolean)
		local sgn = if up then 1 else -1
		Kit.ball(j, 0.5, 0, sgn * 0.1, 0, outer, { 1, 0.5, 0.85 })
		Kit.ball(j, 0.47, 0, 0, 0, inner, { 1, 0.06, 0.85 })
		for i = 0, 6 do
			local a = math.pi * (0.1 + 0.8 * i / 6)
			Kit.box(j, 0.06, 0.2, 0.06, math.cos(a) * 0.44, -sgn * 0.08, math.sin(a) * 0.37, tooth, { 0, 0, 0 })
		end
	end
	-- Jaws hinge at the back (-z) and open towards the front.
	local lower = Kit.sub(head, 0, 0, -0.1, 0.3, 0, 0)
	jaw(Kit.sub(lower, 0, 0, 0.35), false)
	local hinge = Kit.tagged(head, "jaw", 0, 0, -0.1)
	local upper = Kit.sub(hinge, 0, 0, -0.1, -1.0, 0, 0)
	jaw(Kit.sub(upper, 0, 0, 0.35), true)
	return { muzzle = V(0, 1.1, 0.6) }
end

builders.nettle = function(ctx)
	-- Nettle Patch: a low clump of jagged leaves (turned thin blocks) with a sting tip.
	local cols = { hex(0x5aa04a), hex(0x78bf5e) }
	for i = 0, 6 do
		local a = i / 7 * math.pi * 2
		local h = 0.5 + (i % 3) * 0.12
		Kit.box(ctx, 0.36, h, 0.06, math.cos(a) * 0.3, h / 2, math.sin(a) * 0.3, cols[i % 2 + 1], { 0.35, -a + math.pi / 2, 0 })
		Kit.box(ctx, 0.25, 0.25, 0.05, math.cos(a) * 0.38, h * 0.9, math.sin(a) * 0.38, cols[(i + 1) % 2 + 1], { 0.35, -a + math.pi / 2, math.pi / 4 })
	end
	Kit.ball(ctx, 0.3, 0, 0.4, 0, hex(0x4c8f3c))
	Kit.eyes(ctx, 0.5, 0.28, 0.11, 0.09)
	return { muzzle = V(0, 0.6, 0.3) }
end

builders.mint = function(ctx)
	-- Mint Mist: round pale leaves in tiers and a misty halo.
	local mint, mintDark = hex(0x9ee8c8), hex(0x56b890)
	stem(ctx, { V(0, 0, 0), V(0, 0.9, 0) }, 0.06, mintDark)
	for t = 0, 2 do
		for i = 0, 3 do
			local a = i / 4 * math.pi * 2 + t * 0.6
			Kit.ball(ctx, 0.22 - t * 0.04, math.cos(a) * (0.3 - t * 0.05), 0.3 + t * 0.28, math.sin(a) * (0.3 - t * 0.05), if (i + t) % 2 == 0 then mint else mintDark, { 1.4, 0.3, 1 }, { 0, -a, 0.2 })
		end
	end
	Kit.ball(ctx, 0.75, 0, 0.6, 0, hex(0xd8fff0), nil, nil, { Transparency = 0.75, CastShadow = false })
	Kit.eyes(ctx, 0.95, 0.12, 0.09, 0.07)
	return { muzzle = V(0, 1.0, 0.2) }
end

builders.chilli = function(ctx)
	-- Chilli Torch: a leafy bush hung with red chillies, one big one on top.
	local leafCol = hex(0x4f9a35)
	stem(ctx, { V(0, 0, 0), V(0, 0.7, 0) }, 0.07, hex(0x3f7a2a))
	Kit.ball(ctx, 0.45, 0, 0.75, 0, leafCol, { 1, 0.8, 1 })
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2
		Kit.ball(ctx, 0.12, math.cos(a) * 0.42, 0.55, math.sin(a) * 0.42, hex(0xd8352f), { 0.8, 2, 0.8 }, { 0, 0, 0.3 })
	end
	Kit.ball(ctx, 0.2, 0, 1.3, 0, hex(0xe8402f), { 0.9, 1.8, 0.9 })
	Kit.ball(ctx, 0.08, 0, 1.68, 0, hex(0x3f7a2a))
	Kit.eyes(ctx, 0.78, 0.38, 0.14, 0.1)
	return { muzzle = V(0, 1.4, 0.2) }
end

builders.oak = function(ctx)
	-- Oak Sentinel: a sturdy sapling with a chunky canopy and an acorn hat.
	local trunk = hex(0x8a5a32)
	Kit.cyl(ctx, 0.22, 1.2, 0, 0.6, 0, trunk)
	Kit.cyl(ctx, 0.32, 0.25, 0, 0.12, 0, trunk)
	local leaves = { hex(0x3f8a3a), hex(0x52a044), hex(0x2f7a32) }
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		Kit.box(ctx, 0.75, 0.55, 0.7, math.cos(a) * 0.42, 1.5 + (i % 2) * 0.2, math.sin(a) * 0.42, leaves[i % 3 + 1], { 0.4, a, 0.3 })
	end
	Kit.box(ctx, 0.8, 0.6, 0.8, 0, 1.95, 0, leaves[2], { 0.3, 0.8, 0.2 })
	Kit.eyes(ctx, 0.85, 0.22, 0.1, 0.08)
	Kit.ball(ctx, 0.14, 0.3, 1.2, 0.45, hex(0xc08a4a), { 1, 1.2, 1 })
	Kit.ball(ctx, 0.15, 0.3, 1.33, 0.45, hex(0x6a4424), { 1, 0.6, 1 })
	return { muzzle = V(0, 1.6, 0.4) }
end

-- Builds `seedId` into ctx. Returns { muzzle } (units, model space) for shot effects.
function Seeds.build(seedId: string, ctx: any): { muzzle: Vector3 }
	local b = builders[seedId] or builders.thorn
	return b(ctx)
end

Seeds.has = function(seedId: string): boolean
	return builders[seedId] ~= nil
end

return Seeds
