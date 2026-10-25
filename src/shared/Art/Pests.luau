--!strict
-- Pest models, following design/preview3d/scene.js PESTS: big eyes, round bodies,
-- thin legs. Each builder draws in preview units, feet on the context origin, facing
-- +Z. Legs are tagged "leg" (with the hip as pivot) so the client can wiggle them;
-- caterpillar segments are tagged "trail" (pivot = the segment's centre, phase = its
-- place in the line) so the client can lay them along the path behind the head.

local Kit = require(script.Parent:WaitForChild("Kit")) :: any

local Pests = {}

local hex = Kit.hex
local V = Vector3.new

export type Info = { top: number, trailGap: number? }

local builders: { [string]: (any) -> Info } = {}

local function leg(ctx: any, hip: Vector3, knee: Vector3?, foot: Vector3, r: number, color: Color3, phase: number)
	local l = Kit.tagged(ctx, "leg", hip.X, hip.Y, hip.Z, phase)
	if knee then
		Kit.stick(l, hip, knee, r, color)
		Kit.stick(l, knee, foot, r * 0.9, color)
	else
		Kit.stick(l, hip, foot, r, color)
	end
end

builders.aphid = function(ctx)
	local body = hex(0xb4e46a)
	Kit.ball(ctx, 0.26, 0, 0.27, -0.05, body, { 0.9, 0.85, 1.15 })
	Kit.ball(ctx, 0.15, 0, 0.32, 0.22, body)
	Kit.eyes(ctx, 0.38, 0.33, 0.08, 0.07)
	local dark = hex(0x5f8a2a)
	for _, s in { -1, 1 } do
		for i, z in { -0.15, 0, 0.15 } do
			leg(ctx, V(s * 0.15, 0.15, z), nil, V(s * 0.3, 0, z * 1.3), 0.02, dark, i + (if s > 0 then 1 else 0))
		end
	end
	return { top = 0.6 }
end

builders.ant = function(ctx)
	local m, dark = hex(0xc4472c), hex(0x5a1d12)
	Kit.ball(ctx, 0.26, 0, 0.32, -0.38, m, { 0.9, 0.85, 1.2 })
	Kit.ball(ctx, 0.15, 0, 0.32, -0.02, m)
	Kit.ball(ctx, 0.22, 0, 0.4, 0.28, m)
	Kit.eyes(ctx, 0.48, 0.44, 0.1, 0.075)
	for _, s in { -1, 1 } do
		for i, z in { -0.15, 0, 0.15 } do
			leg(ctx, V(s * 0.08, 0.3, z), V(s * 0.38, 0.38, z * 1.6), V(s * 0.48, 0, z * 2), 0.025, dark, i + (if s > 0 then 1 else 0))
		end
		Kit.stick(ctx, V(s * 0.06, 0.58, 0.32), V(s * 0.2, 0.8, 0.45), 0.018, dark)
		Kit.ball(ctx, 0.035, s * 0.2, 0.8, 0.45, dark)
	end
	return { top = 0.85 }
end

builders.snail = function(ctx)
	local body = hex(0xc9e09a)
	Kit.ball(ctx, 0.3, 0, 0.2, 0.05, body, { 1.2, 0.75, 2.6 })
	Kit.ball(ctx, 0.26, 0, 0.36, 0.48, body)
	-- Shell: an orange ball with darker spiral rings on each side.
	local shellM, shellD = hex(0xd9772b), hex(0x9c4b1b)
	Kit.ball(ctx, 0.46, 0, 0.62, -0.15, shellM, { 0.8, 1, 1 })
	for _, s in { -1, 1 } do
		for i, ring in { { 0.42, 0 }, { 0.3, 0.07 }, { 0.18, 0.12 } } do
			local col = if i % 2 == 1 then shellD else shellM
			Kit.cyl(ctx, ring[1], 0.03, s * (0.355 + i * 0.012), 0.62 + ring[2] * 0.4, -0.15 + ring[2] * 0.3, col, { 0, 0, math.pi / 2 })
		end
	end
	local stalk = hex(0xb9d38a)
	for _, s in { -1, 1 } do
		Kit.stick(ctx, V(s * 0.08, 0.5, 0.55), V(s * 0.17, 0.92, 0.66), 0.035, stalk)
	end
	Kit.eyes(ctx, 0.97, 0.68, 0.17, 0.11)
	Kit.smile(ctx, 0.33, 0.73, 0.07, 0.02, hex(0x3b2a1a))
	return { top = 1.15 }
end

builders.beetle = function(ctx)
	local shellA, shellB, black = hex(0x4b3fb3), hex(0x6f63e0), hex(0x1d1a28)
	Kit.ball(ctx, 0.5, -0.2, 0.36, -0.08, shellA, { 0.42, 0.7, 1.4 }, nil, { Reflectance = 0.12 })
	Kit.ball(ctx, 0.5, 0.2, 0.36, -0.08, shellB, { 0.42, 0.7, 1.4 }, nil, { Reflectance = 0.12 })
	Kit.box(ctx, 0.04, 0.42, 1.2, 0, 0.45, -0.08, black)
	for _, sp in { { -0.25, -0.2 }, { 0.27, 0.05 }, { -0.18, 0.25 }, { 0.2, -0.4 } } do
		Kit.ball(ctx, 0.07, sp[1], 0.62, sp[2], hex(0xa9a2ff), { 1, 0.4, 1 })
	end
	Kit.ball(ctx, 0.48, 0, 0.28, -0.08, black, { 0.95, 0.35, 1.35 })
	Kit.ball(ctx, 0.27, 0, 0.36, 0.62, black, { 1.1, 0.9, 0.9 })
	Kit.eyes(ctx, 0.48, 0.78, 0.13, 0.1)
	for _, s in { -1, 1 } do
		Kit.stick(ctx, V(s * 0.08, 0.25, 0.82), V(s * 0.16, 0.25, 0.98), 0.03, black)
		for i, z in { -0.45, -0.05, 0.35 } do
			leg(ctx, V(s * 0.35, 0.25, z), V(s * 0.65, 0.3, z + 0.05), V(s * 0.75, 0, z + 0.12), 0.04, black, i + (if s > 0 then 1 else 0))
		end
		Kit.stick(ctx, V(s * 0.1, 0.5, 0.75), V(s * 0.3, 0.8, 1.0), 0.02, black)
	end
	return { top = 0.9 }
end

builders.caterpillar = function(ctx)
	local greens = { hex(0x8fd84a), hex(0x7cc93a) }
	local spot = hex(0xffd23a)
	local gap = 0.28
	for i = 5, 1, -1 do
		local r = 0.36 - i * 0.015
		local z = -i * gap
		local seg = Kit.tagged(ctx, "trail", 0, 0, z, i)
		Kit.ball(seg, r, 0, r, z, greens[i % 2 + 1])
		Kit.ball(seg, 0.06, 0, r * 2 - 0.02, z, spot)
	end
	local hr = 0.42
	Kit.ball(ctx, hr, 0, hr, 0, greens[1])
	local head = Kit.sub(ctx, 0, hr, 0, 0, 0, 0, 1.3)
	Kit.eyes(head, 0.08, 0.24, 0.12, 0.1)
	Kit.smile(head, -0.1, 0.3, 0.07, 0.02, hex(0x2e4a12))
	for _, s in { -1, 1 } do
		Kit.stick(head, V(s * 0.08, 0.25, 0.05), V(s * 0.22, 0.55, 0.12), 0.02, hex(0x4f8a22))
		Kit.ball(head, 0.055, s * 0.22, 0.55, 0.12, hex(0xff6f91))
	end
	return { top = 1.25, trailGap = gap }
end

-- The pests below are not in the preview; same style, simpler.

builders.moth = function(ctx)
	local fur, wing = hex(0xd8cdb4), hex(0xefe6d0)
	Kit.ball(ctx, 0.22, 0, 0.3, -0.05, fur, { 0.9, 0.9, 1.4 })
	Kit.ball(ctx, 0.16, 0, 0.36, 0.25, fur)
	Kit.eyes(ctx, 0.42, 0.34, 0.08, 0.07)
	for i, s in { -1, 1 } do
		local w = Kit.tagged(ctx, "leg", s * 0.1, 0.35, 0, i * 2)
		Kit.ball(w, 0.4, s * 0.42, 0.38, -0.05, wing, { 1, 0.12, 0.8 }, { 0, 0, s * 0.3 })
		Kit.ball(w, 0.1, s * 0.5, 0.42, -0.05, hex(0xa08870), { 1, 0.3, 1 })
	end
	return { top = 0.7 }
end

builders.wasp = function(ctx)
	local yellow, black = hex(0xf2c62a), hex(0x2a2430)
	Kit.ball(ctx, 0.24, 0, 0.32, -0.3, yellow, { 0.85, 0.85, 1.3 })
	Kit.cyl(ctx, 0.2, 0.06, 0, 0.32, -0.25, black, { math.pi / 2, 0, 0 })
	Kit.cyl(ctx, 0.17, 0.06, 0, 0.32, -0.42, black, { math.pi / 2, 0, 0 })
	Kit.ball(ctx, 0.12, 0, 0.32, -0.02, black)
	Kit.ball(ctx, 0.18, 0, 0.38, 0.2, yellow)
	Kit.eyes(ctx, 0.44, 0.32, 0.08, 0.07)
	for i, s in { -1, 1 } do
		local w = Kit.tagged(ctx, "leg", s * 0.08, 0.45, -0.05, i * 2)
		Kit.ball(w, 0.26, s * 0.25, 0.55, -0.1, Color3.new(1, 1, 1), { 1, 0.1, 0.6 }, { 0, 0, s * 0.4 }, { Transparency = 0.35 })
	end
	return { top = 0.75 }
end

builders.mole = function(ctx)
	local fur = hex(0x5a4638)
	Kit.ball(ctx, 0.42, 0, 0.36, -0.05, fur, { 1, 0.85, 1.25 })
	Kit.ball(ctx, 0.12, 0, 0.36, 0.5, hex(0xf29aa0), { 1, 0.8, 1 })
	Kit.eyes(ctx, 0.52, 0.36, 0.12, 0.07)
	for i, s in { -1, 1 } do
		local paw = Kit.tagged(ctx, "leg", s * 0.3, 0.2, 0.25, i * 2)
		Kit.ball(paw, 0.14, s * 0.38, 0.12, 0.32, hex(0xf2c0a0), { 1.2, 0.5, 1 })
	end
	return { top = 0.85 }
end

builders.slugmum = function(ctx)
	local body = hex(0xb58ab0)
	Kit.ball(ctx, 0.4, 0, 0.28, 0, body, { 1.1, 0.75, 2.2 })
	Kit.ball(ctx, 0.3, 0, 0.5, 0.55, body)
	Kit.ball(ctx, 0.2, 0, 0.62, -0.35, hex(0xd8b0d0))
	local stalk = hex(0x9a7096)
	for _, s in { -1, 1 } do
		Kit.stick(ctx, V(s * 0.08, 0.7, 0.6), V(s * 0.2, 1.05, 0.72), 0.035, stalk)
	end
	Kit.eyes(ctx, 1.08, 0.74, 0.19, 0.11)
	Kit.smile(ctx, 0.42, 0.84, 0.08, 0.02, hex(0x3b2a3a))
	return { top = 1.25 }
end

builders.possum = function(ctx)
	local grey, pale, pink = hex(0x7d7d8a), hex(0xd8d6dc), hex(0xf2a0b0)
	Kit.ball(ctx, 0.55, 0, 0.6, -0.1, grey, { 1, 0.9, 1.3 })
	Kit.ball(ctx, 0.36, 0, 0.85, 0.6, grey)
	Kit.ball(ctx, 0.16, 0, 0.78, 0.95, pale, { 1, 0.8, 1.2 })
	Kit.ball(ctx, 0.06, 0, 0.82, 1.12, hex(0x1a1418))
	Kit.eyes(ctx, 0.98, 0.86, 0.15, 0.11)
	for _, s in { -1, 1 } do
		Kit.ball(ctx, 0.16, s * 0.28, 1.18, 0.5, grey, { 1, 1, 0.4 })
		Kit.ball(ctx, 0.1, s * 0.28, 1.18, 0.53, pink, { 1, 1, 0.4 })
		for i, z in { -0.4, 0.3 } do
			leg(ctx, V(s * 0.35, 0.35, z), nil, V(s * 0.4, 0, z), 0.1, grey, i + (if s > 0 then 1 else 0))
		end
	end
	Kit.stick(ctx, V(0, 0.5, -0.7), V(0, 0.9, -1.3), 0.06, pink)
	return { top = 1.45 }
end

local function generic(ctx: any): Info
	Kit.ball(ctx, 0.3, 0, 0.3, 0, hex(0x9acd60))
	Kit.eyes(ctx, 0.4, 0.25, 0.1, 0.08)
	return { top = 0.7 }
end

-- Builds `typeId` into ctx. Returns { top (units, for the health bar), trailGap? }.
function Pests.build(typeId: string, ctx: any): Info
	local b = builders[typeId] or generic
	return b(ctx)
end

return Pests
