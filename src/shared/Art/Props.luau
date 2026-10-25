--!strict
-- Characters and small props shared by the server (the garden) and the client
-- (HUD portraits): garden gnome and Nan. Built from Parts, following scene.js.

local Kit = require(script.Parent:WaitForChild("Kit")) :: any

local Props = {}

local hex = Kit.hex
local V = Vector3.new

-- Garden gnome, base at the context origin, facing +Z.
function Props.gnome(ctx: any)
	local blue, brown = hex(0x3d74c9), hex(0x3a2414)
	Kit.cyl(ctx, 0.35, 0.6, 0, 0.35, 0, blue)
	Kit.box(ctx, 0.66, 0.08, 0.1, 0, 0.42, 0.33, brown)
	Kit.ball(ctx, 0.27, 0, 0.85, 0, hex(0xf5c9a0))
	-- Beard: a white wedge of balls.
	Kit.ball(ctx, 0.26, 0, 0.66, 0.12, Color3.new(1, 1, 1), { 1, 1.2, 0.7 })
	Kit.ball(ctx, 0.08, 0, 0.85, 0.27, hex(0xf29a8a))
	for _, s in { -1, 1 } do
		Kit.ball(ctx, 0.04, s * 0.1, 0.94, 0.23, hex(0x15121c))
		Kit.ball(ctx, 0.12, s * 0.16, 0.06, 0.1, brown, { 1, 0.6, 1.4 })
	end
	-- Pointy red hat: brim ring then a stepped cone.
	Kit.cyl(ctx, 0.32, 0.1, 0, 1.0, 0, hex(0xd12f2f))
	Kit.cone(ctx, 0.3, 0.85, 0, 1.02, -0.02, hex(0xe33a3a), 3, { -0.15, 0, 0 })
	-- Little shovel.
	Kit.stick(ctx, V(0.38, 0.1, 0.15), V(0.45, 0.9, 0.2), 0.03, hex(0xb07a46))
	Kit.box(ctx, 0.2, 0.26, 0.04, 0.37, 0.05, 0.14, hex(0xb9bec4), nil, { Reflectance = 0.15 })
end

-- Nan's head (also used alone for the HUD portrait), centred at the context origin.
function Props.nanHead(ctx: any)
	local skin = hex(0xf2c9a0)
	local hair = hex(0xdfe0e6)
	local glasses = hex(0x8a3f7a)
	Kit.box(ctx, 0.82, 0.78, 0.78, 0, 0, 0, skin)
	Kit.ball(ctx, 0.46, 0, 0.18, -0.06, hair, { 1, 0.75, 1 })
	Kit.ball(ctx, 0.24, 0, 0.42, -0.32, hair) -- bun
	for _, s in { -1, 1 } do
		Kit.ball(ctx, 0.16, s * 0.38, 0.06, -0.05, hair)
		Kit.ball(ctx, 0.065, s * 0.16, 0, 0.4, hex(0x15121c))
		-- Round glasses: a thin ring is a flat cylinder with a skin coloured middle.
		Kit.cyl(ctx, 0.13, 0.02, s * 0.16, 0, 0.405, glasses, { math.pi / 2, 0, 0 })
		Kit.cyl(ctx, 0.1, 0.03, s * 0.16, 0, 0.41, skin, { math.pi / 2, 0, 0 })
		Kit.ball(ctx, 0.05, s * 0.16, 0, 0.42, hex(0x15121c))
		Kit.ball(ctx, 0.07, s * 0.27, -0.13, 0.38, hex(0xff9b8a), { 1, 1, 0.3 })
	end
	Kit.box(ctx, 0.1, 0.03, 0.03, 0, 0.02, 0.43, glasses)
	Kit.smile(ctx, -0.16, 0.4, 0.1, 0.025, hex(0x6b2a1a))
end

-- Nan, waving, holding a watering can. Feet at the context origin, facing +Z.
function Props.nan(ctx: any)
	local pants = hex(0x4a4d6e)
	local cardi = hex(0xb48ad6)
	local skin = hex(0xf2c9a0)
	for _, s in { -1, 1 } do
		Kit.box(ctx, 0.44, 0.95, 0.44, s * 0.23, 0.55, 0, pants)
		Kit.box(ctx, 0.46, 0.18, 0.56, s * 0.23, 0.09, 0.05, hex(0x6b4a2e))
	end
	Kit.box(ctx, 0.96, 1.0, 0.5, 0, 1.5, 0, cardi)
	Kit.box(ctx, 0.36, 0.94, 0.04, 0, 1.52, 0.25, hex(0xfff4e0))
	for _, y in { 1.25, 1.5, 1.75 } do
		Kit.ball(ctx, 0.04, 0.22, y, 0.27, Color3.new(1, 1, 1))
	end
	-- Left arm down, holding the can.
	Kit.box(ctx, 0.42, 0.95, 0.42, -0.7, 1.5, 0, cardi)
	Kit.box(ctx, 0.36, 0.22, 0.36, -0.7, 0.98, 0, skin)
	-- Right arm up, waving.
	local arm = Kit.sub(ctx, 0.7, 1.95, 0, 0, 0, 2.5)
	Kit.box(arm, 0.42, 0.95, 0.42, 0, -0.45, 0, cardi)
	Kit.box(arm, 0.36, 0.22, 0.36, 0, -1.0, 0, skin)
	Props.nanHead(Kit.sub(ctx, 0, 2.42, 0))
	-- Watering can.
	local can = Kit.sub(ctx, -0.75, 0.7, 0.15)
	local green = hex(0x4fb06a)
	Kit.cyl(can, 0.24, 0.42, 0, 0, 0, green)
	Kit.stick(can, V(0, 0, 0.15), V(0, 0.25, 0.6), 0.04, green)
	Kit.stick(can, V(0, 0.2, -0.17), V(0, 0.36, 0), 0.03, hex(0x3f9a58))
	Kit.stick(can, V(0, 0.36, 0), V(0, 0.2, 0.17), 0.03, hex(0x3f9a58))
end

return Props
