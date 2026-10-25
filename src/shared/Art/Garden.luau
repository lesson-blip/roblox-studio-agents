--!strict
-- The static backyard around a field, built from Parts on the server (spec 6.4
-- PlotService calls this). It follows design/preview3d/scene.js unit for unit: the
-- preview's tile is 2 units, ours is 4 studs, so one unit is Visuals.UNIT studs and
-- the preview's origin (the middle of the 12 by 8 grid) is the grid centre here.
--
-- Only `Tiles` matters to the game: 96 parts named T_x_y with X, Y, IsPath (and Bed)
-- attributes, which the client raycasts against. Everything else is in `Decor`
-- and has CanQuery off, so it never blocks a tap.

local Kit = require(script.Parent:WaitForChild("Kit")) :: any
local Props = require(script.Parent:WaitForChild("Props")) :: any

local Garden = {}

local hex = Kit.hex
local V = Vector3.new
local WHITE = Color3.new(1, 1, 1)

local TILE_TOP = 0.42 -- units
local PLOT_TOP = TILE_TOP + 0.1

-- Preview units of a tile centre, relative to the grid centre.
local function tw(x: number, y: number, cols: number, rows: number): (number, number)
	return (x - (cols - 1) / 2) * 2, (y - (rows - 1) / 2) * 2
end

local function grassTuft(ctx: any, rr: (number, number) -> number, x: number, y: number, z: number, cols: { Color3 })
	-- Two thin crossed blades read as a tuft from the game camera.
	for i = 1, 2 do
		local h = rr(0.25, 0.4)
		Kit.box(ctx, 0.05, h, 0.14, x + rr(-0.08, 0.08), y + h / 2, z + rr(-0.08, 0.08), cols[i],
			{ rr(-0.4, 0.4), i * 1.4, rr(-0.4, 0.4) })
	end
end

local function flower(ctx: any, x: number, y: number, z: number, color: Color3)
	Kit.box(ctx, 0.03, 0.25, 0.03, x, y + 0.12, z, hex(0x5fb03a))
	Kit.ball(ctx, 0.12, x, y + 0.26, z, color, { 1, 0.35, 1 })
	Kit.ball(ctx, 0.045, x, y + 0.29, z, hex(0xffc531))
end

-- Sandstone pavers on a dirt base for one path tile. Returns the dirt part.
local function pathTile(ctx: any, rnd: () -> number, rr: (number, number) -> number, px: number, pz: number, pavers: { Color3 }, query: boolean): BasePart
	local dirt = Kit.box(ctx, 2, 0.2, 2, px, 0.1, pz, hex(0x9a7350))
	dirt.CanQuery = query
	dirt.CastShadow = false
	for _, o in { { -0.5, -0.5 }, { 0.5, -0.5 }, { -0.5, 0.5 }, { 0.5, 0.5 } } do
		local c = pavers[math.floor(rnd() * 4) + 1]
		Kit.box(ctx, 0.88, 0.16, 0.88, px + o[1], 0.24 + rr(-0.01, 0.01), pz + o[2], c, { 0, rr(-0.04, 0.04), 0 })
	end
	return dirt
end

-- A run of Colorbond fence from (x0, z0) to (x1, z1), units. Ribs every 0.8 units
-- stand in for the corrugation (no textures).
local function fenceRun(ctx: any, x0: number, z0: number, x1: number, z1: number, ribs: boolean)
	local h = 1.9
	local len = math.sqrt((x1 - x0) ^ 2 + (z1 - z0) ^ 2)
	local ang = math.atan2(z1 - z0, x1 - x0)
	local g = Kit.sub(ctx, (x0 + x1) / 2, 0, (z0 + z1) / 2, 0, -ang, 0)
	local panel = hex(0x7d8670)
	local trim = hex(0x5d6553)
	Kit.box(g, len, h, 0.08, 0, h / 2, 0, panel, nil, { Reflectance = 0.04 })
	Kit.box(g, len + 0.1, 0.12, 0.2, 0, h + 0.04, 0, trim)
	Kit.box(g, len, 0.1, 0.16, 0, 0.08, 0, trim)
	local n = math.max(1, math.floor(len / 2.4 + 0.5))
	for i = 0, n do
		Kit.box(g, 0.16, h + 0.15, 0.16, -len / 2 + i * len / n, (h + 0.15) / 2, 0, trim)
	end
	if ribs then
		local rib = hex(0x96a088)
		local count = math.floor(len / 0.8)
		for i = 1, count - 1 do
			local x = -len / 2 + i * len / count
			if i % 3 ~= 0 then -- posts already sit near every third rib
				Kit.box(g, 0.14, h - 0.12, 0.12, x, h / 2, 0, rib, nil, { CastShadow = false })
			end
		end
	end
end

local function picketRun(ctx: any, x0: number, z0: number, x1: number, z1: number)
	local len = math.sqrt((x1 - x0) ^ 2 + (z1 - z0) ^ 2)
	local ang = math.atan2(z1 - z0, x1 - x0)
	local g = Kit.sub(ctx, (x0 + x1) / 2, 0, (z0 + z1) / 2, 0, -ang, 0)
	local white = hex(0xfbf7ee)
	for _, y in { 0.35, 0.75 } do
		Kit.box(g, len, 0.1, 0.07, 0, y, -0.06, white)
	end
	local n = math.floor(len / 0.42)
	for i = 0, n do
		local x = -len / 2 + i * len / n
		Kit.box(g, 0.16, 0.95, 0.06, x, 0.48, 0, white)
		-- A square turned 45 degrees makes the pointed top.
		Kit.box(g, 0.113, 0.113, 0.06, x, 0.955, 0, white, { 0, 0, math.pi / 4 }, { CastShadow = false })
	end
end

local function gumTree(ctx: any, rnd: () -> number, rr: (number, number) -> number, x: number, z: number, h: number, sc: number)
	local g = Kit.sub(ctx, x, 0, z, 0, rr(0, 6), 0, sc)
	local bark = hex(0xefe7d8)
	local barkPatch = { hex(0xd9cdb8), hex(0xe8c9b0), hex(0xc8b9a0) }
	local trunk = { V(0, 0, 0), V(0.3, h * 0.35, 0.1), V(-0.1, h * 0.6, 0), V(0.2, h * 0.8, -0.1) }
	for i = 1, 3 do
		Kit.stick(g, trunk[i], trunk[i + 1], 0.42 - i * 0.04, bark)
		Kit.ball(g, 0.42 - i * 0.04, trunk[i + 1].X, trunk[i + 1].Y, trunk[i + 1].Z, bark)
	end
	Kit.cyl(g, 0.62, 0.6, 0, 0.3, 0, bark)
	-- A few bark patches give the pale gum its mottled look.
	for i = 1, 3 do
		local t = trunk[i]:Lerp(trunk[i + 1], 0.5)
		Kit.ball(g, 0.18, t.X + 0.36, t.Y, t.Z + 0.12, barkPatch[i], { 0.4, 1.6, 0.9 }, nil, { CastShadow = false })
	end
	local leafCols = { hex(0x6e9a5a), hex(0x7fa86a), hex(0x5a8550), hex(0x8db07a) }
	local ends: { Vector3 } = {}
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2 + rr(-0.3, 0.3)
		local start = trunk[3]:Lerp(trunk[4], rr(0, 1))
		local e = V(math.cos(a) * rr(2.0, 3.0), h * rr(0.82, 1.0), math.sin(a) * rr(2.0, 3.0))
		Kit.stick(g, start, e, 0.16, bark)
		table.insert(ends, e)
	end
	table.insert(ends, V(trunk[4].X, h * 1.02, trunk[4].Z))
	-- Clumped canopy: turned blocks read as low poly leaf clusters.
	for _, e in ends do
		for _ = 1, 3 do
			local r = rr(0.8, 1.2)
			Kit.box(g, r * 2.2, r * 1.1, r * 2.0, e.X + rr(-0.8, 0.8), e.Y + rr(-0.2, 0.7), e.Z + rr(-0.8, 0.8),
				leafCols[math.floor(rnd() * 4) + 1], { rr(-0.5, 0.5), rr(0, 3), rr(-0.5, 0.5) })
		end
	end
end

local function shrub(ctx: any, rr: (number, number) -> number, x: number, z: number, r: number, color: Color3)
	Kit.box(ctx, r * 1.7, r * 1.2, r * 1.6, x, r * 0.55, z, color, { rr(-0.3, 0.3), rr(0, 3), rr(-0.3, 0.3) })
end

local function shed(ctx: any, facing: number)
	-- Nan's shed: sage corrugated walls, red corrugated roof, double doors facing the path.
	local g = Kit.sub(ctx, 0, 0, 0, 0, if facing > 0 then 0 else math.pi, 0)
	local wall = hex(0x9cc496)
	local rib = hex(0xb4d8ac)
	local trim = hex(0xf4f1ea)
	Kit.box(g, 4.6, 0.2, 4.4, 0, 0.1, 0, hex(0xb8b2a6))
	Kit.box(g, 4.2, 2.6, 4.0, 0, 1.5, 0, wall)
	-- Wall corrugation ribs on the front and back.
	for i = 1, 9 do
		local x = -2.1 + i * 0.42
		Kit.box(g, 0.12, 2.5, 4.06, x, 1.5, 0, rib, nil, { CastShadow = false })
	end
	-- Gable ends: a prism of two wedges along the shed's depth.
	Kit.wedge(g, 4.0, 1.0, 2.1, -1.05, 3.3, 0, wall, { 0, math.pi / 2, 0 })
	Kit.wedge(g, 4.0, 1.0, 2.1, 1.05, 3.3, 0, wall, { 0, -math.pi / 2, 0 })
	-- Roof.
	local slope = math.atan2(1.0, 2.1)
	local rl = math.sqrt(2.1 ^ 2 + 1) + 0.35
	local red, redRib = hex(0xd6544a), hex(0x9c342c)
	for _, s in { -1, 1 } do
		local roof = Kit.sub(g, s * 1.05, 3.33, 0, 0, 0, -s * slope)
		Kit.box(roof, rl, 0.1, 4.6, 0, 0, 0, red)
		for i = 0, 10 do
			Kit.box(roof, rl, 0.06, 0.08, 0, 0.07, -2.2 + i * 0.44, redRib, nil, { CastShadow = false })
		end
	end
	Kit.cyl(g, 0.1, 4.7, 0, 3.83, 0, hex(0xd9dcde), { math.pi / 2, 0, 0 }, { Reflectance = 0.2 })
	for _, c in { { -2.1, -2.0 }, { 2.1, -2.0 }, { -2.1, 2.0 }, { 2.1, 2.0 } } do
		Kit.box(g, 0.16, 2.7, 0.16, c[1], 1.5, c[2], trim)
	end
	-- Double doors on the path side (-x) with brass knobs.
	local door = hex(0x2f6b45)
	for _, s in { -1, 1 } do
		Kit.box(g, 0.1, 1.95, 0.92, -2.13, 1.18, s * 0.48, door)
		Kit.ball(g, 0.06, -2.2, 1.25, s * 0.12, hex(0xe6c35a), nil, nil, { Reflectance = 0.3 })
	end
	-- Sign.
	local sign = Kit.box(g, 0.06, 0.6, 1.9, -2.18, 2.62, 0, hex(0xf6e7c8))
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Left
	sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	sg.PixelsPerStud = 40
	sg.LightInfluence = 1
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = "NAN'S SHED"
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = Color3.fromRGB(122, 58, 18)
	t.Parent = sg
	sg.Parent = sign
	-- Window with a flower box on the front.
	Kit.box(g, 1.36, 1.06, 0.06, 0.9, 1.75, 2.01, trim)
	Kit.box(g, 1.2, 0.9, 0.08, 0.9, 1.75, 2.03, hex(0x9fd8f0), nil, { Reflectance = 0.25 })
	Kit.box(g, 1.4, 0.3, 0.35, 0.9, 1.15, 2.2, hex(0xb07a46))
	local blooms = { hex(0xff6f91), hex(0xffd25a), hex(0xff8a3a) }
	for i = 0, 4 do
		Kit.ball(g, 0.12, 0.4 + i * 0.25, 1.38, 2.25, blooms[i % 3 + 1])
	end
	-- Heart above the shed (hearts are the shed's health): two balls and a turned square.
	local heart = Kit.sub(g, 0, 5.0, 0, 0, if facing > 0 then -0.25 else math.pi - 0.25, 0)
	local hred = hex(0xff4d5e)
	Kit.ball(heart, 0.3, -0.24, 0.2, 0, hred, { 1, 1, 0.55 })
	Kit.ball(heart, 0.3, 0.24, 0.2, 0, hred, { 1, 1, 0.55 })
	Kit.box(heart, 0.62, 0.62, 0.33, 0, -0.05, 0, hred, { 0, 0, math.pi / 4 })
end

local function tank(ctx: any)
	local steel = hex(0xd0d4d7)
	Kit.cyl(ctx, 1.35, 0.2, 0, 0.1, 0, hex(0xb8b2a6))
	Kit.cyl(ctx, 1.25, 2.4, 0, 1.3, 0, steel, nil, { Reflectance = 0.1 })
	for i = 1, 5 do
		Kit.cyl(ctx, 1.28, 0.08, 0, 0.3 + i * 0.4, 0, hex(0xa0a6aa), nil, { CastShadow = false })
	end
	Kit.ball(ctx, 1.25, 0, 2.5, 0, hex(0xd9dcde), { 1, 0.25, 1 })
	Kit.cyl(ctx, 0.06, 0.3, -1.3, 0.5, 0, hex(0xc9a040), { 0, 0, math.pi / 2 })
end

local function hillsHoist(ctx: any)
	local steel = hex(0xc7cbd0)
	Kit.cyl(ctx, 0.1, 2.9, 0, 1.45, 0, steel, nil, { Reflectance = 0.2 })
	Kit.cyl(ctx, 0.16, 0.35, 0, 1.75, 0, steel)
	Kit.box(ctx, 0.22, 0.12, 0.35, 0.15, 1.1, 0, hex(0x2f2f36))
	local R = 3.1
	local tips: { number } = {}
	for i = 0, 3 do
		local a = i / 4 * math.pi * 2 + math.pi / 4
		Kit.stick(ctx, V(0, 1.75, 0), V(math.cos(a) * R, 2.75, math.sin(a) * R), 0.045, steel)
		Kit.stick(ctx, V(0, 2.85, 0), V(math.cos(a) * 1.2, 2.3, math.sin(a) * 1.2), 0.025, steel)
		table.insert(tips, a)
	end
	local line = hex(0xf0f0f0)
	for _, f in { 0.4, 0.6, 0.8, 1.0 } do
		for i = 1, 4 do
			local a0, a1 = tips[i], tips[i % 4 + 1]
			local y = 1.75 + 1.0 * f
			Kit.stick(ctx, V(math.cos(a0) * R * f, y, math.sin(a0) * R * f), V(math.cos(a1) * R * f, y, math.sin(a1) * R * f), 0.014, line, nil, { CastShadow = false })
		end
	end
	-- Washing on the outer lines: side, position along it, colours (stripes), width, height.
	local clothes: { { any } } = {
		{ 1, 0.25, { hex(0xff6b6b), hex(0xffd25a), hex(0x4fb6ff), WHITE }, 0.9, 1.3 },
		{ 1, 0.65, { hex(0xff8fb1) }, 0.7, 0.8 },
		{ 2, 0.4, { hex(0x4f8fe0) }, 1.4, 1.1 },
		{ 3, 0.5, { hex(0xfff4d6) }, 0.6, 0.7 },
		{ 4, 0.35, { hex(0x7fd36a) }, 0.8, 0.9 },
	}
	for _, c in clothes do
		local side: number, along: number = c[1], c[2]
		local a0, a1 = tips[side], tips[side % 4 + 1]
		local p0 = V(math.cos(a0) * R, 2.75, math.sin(a0) * R)
		local p1 = V(math.cos(a1) * R, 2.75, math.sin(a1) * R)
		local p = p0:Lerp(p1, along)
		local yaw = -math.atan2(p1.Z - p0.Z, p1.X - p0.X)
		local cloth = Kit.sub(ctx, p.X, p.Y, p.Z, 0, yaw, 0)
		local cols: { Color3 } = c[3]
		local w: number, h: number = c[4], c[5]
		local band = h / #cols
		for i, col in cols do
			Kit.box(cloth, w, band, 0.03, 0, -band * (i - 0.5), 0, col)
		end
		for _, s in { -1, 1 } do
			Kit.box(cloth, 0.06, 0.16, 0.06, s * w * 0.4, 0, 0, hex(0xffd25a), nil, { CastShadow = false })
		end
	end
	Kit.cyl(ctx, 0.42, 0.4, 1.4, 0.22, 1.2, hex(0x5ab8e8))
	Kit.ball(ctx, 0.3, 1.4, 0.42, 1.2, hex(0xfff4d6), { 1, 0.4, 1 })
end

local function veggieBed(ctx: any, rr: (number, number) -> number)
	local wood = hex(0xb5824f)
	Kit.box(ctx, 7, 0.7, 0.2, 0, 0.35, -1.1, wood)
	Kit.box(ctx, 7, 0.7, 0.2, 0, 0.35, 1.1, wood)
	Kit.box(ctx, 0.2, 0.7, 2.4, -3.4, 0.35, 0, wood)
	Kit.box(ctx, 0.2, 0.7, 2.4, 3.4, 0.35, 0, wood)
	Kit.box(ctx, 6.6, 0.55, 2.0, 0, 0.3, 0, hex(0x5b3a24))
	for i = 0, 5 do
		local x = -2.8 + i * 1.1
		for k = 1, 3 do
			Kit.ball(ctx, 0.22, x + rr(-0.15, 0.15), 0.62 + rr(0.05, 0.2), -0.45 + rr(-0.15, 0.15),
				if k % 2 == 0 then hex(0x8fd45a) else hex(0x6fbf47), { 1, 0.7, 1 })
		end
	end
	for i = 0, 3 do
		local x = -2.6 + i * 1.75
		Kit.stick(ctx, V(x, 0.5, 0.5), V(x, 1.9, 0.5), 0.035, hex(0xc89a62))
		Kit.box(ctx, 0.5, 0.45, 0.5, x, 1.3, 0.5, hex(0x4f9a35), { 0.5, 0.7, 0.3 })
		for _ = 1, 3 do
			Kit.ball(ctx, 0.1, x + rr(-0.25, 0.25), rr(0.9, 1.6), 0.5 + rr(-0.2, 0.25), hex(0xff4b3a))
		end
	end
end

local function deck(ctx: any)
	local boards = { hex(0xb98250), hex(0xa9733f) }
	for i = 0, 13 do
		Kit.box(ctx, 16, 0.22, 0.48, 0, 0.25, -3.2 + i * 0.5, boards[i % 2 + 1], nil, { Material = Enum.Material.Wood })
	end
	-- Barbie: four legs, a black hood, hotplates and a side tray.
	local bbq = Kit.sub(ctx, -4.5, 0.36, -1.6)
	local black, steel = hex(0x2a2a30), hex(0xc7cbd0)
	for _, l in { { -0.7, -0.35 }, { 0.7, -0.35 }, { -0.7, 0.35 }, { 0.7, 0.35 } } do
		Kit.cyl(bbq, 0.05, 1.0, l[1], 0.5, l[2], steel)
	end
	Kit.box(bbq, 1.7, 0.4, 0.95, 0, 1.15, 0, black)
	Kit.cyl(bbq, 0.45, 1.7, 0, 1.38, -0.35, black, { 0, 0, math.pi / 2 }) -- hood tipped open at the back
	for i = 0, 3 do
		Kit.box(bbq, 0.36, 0.08, 0.2, -0.55 + i * 0.37, 1.39, 0.15, hex(0xb5532f))
	end
	Kit.box(bbq, 0.6, 0.06, 0.95, 1.15, 1.1, 0, steel)
	-- Two outdoor chairs and a table.
	for _, c in { { 1.6, hex(0x3fa7d8), 0.3 }, { 4.6, hex(0xff8a5c), -0.3 } } do
		local ch = Kit.sub(ctx, c[1], 0.36, -1.4, 0, c[3], 0)
		Kit.box(ch, 0.9, 0.12, 0.9, 0, 0.55, 0, c[2])
		Kit.box(ch, 0.9, 0.9, 0.12, 0, 1.0, -0.42, c[2], { -0.15, 0, 0 })
		for _, l in { { -0.38, -0.38 }, { 0.38, -0.38 }, { -0.38, 0.38 }, { 0.38, 0.38 } } do
			Kit.cyl(ch, 0.04, 0.55, l[1], 0.27, l[2], c[2])
		end
	end
	Kit.cyl(ctx, 0.55, 0.08, 3.1, 1.05, -1.6, hex(0xf4f1ea))
	Kit.cyl(ctx, 0.06, 0.7, 3.1, 0.7, -1.6, hex(0xc7cbd0))
	Kit.cyl(ctx, 0.11, 0.25, 3.0, 1.22, -1.5, hex(0xfff4d6))
	for _, x in { -7.3, 7.3 } do
		Kit.cyl(ctx, 0.42, 0.7, x, 0.7, -2.6, hex(0xc96a3a))
		Kit.ball(ctx, 0.6, x, 1.35, -2.6, hex(0x4f9a35), { 1, 0.85, 1 })
	end
end

local function trampoline(ctx: any)
	Kit.cyl(ctx, 2.55, 0.12, 0, 0.9, 0, hex(0x3fa7d8))
	Kit.cyl(ctx, 2.3, 0.14, 0, 0.92, 0, hex(0x2a2a30))
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		Kit.cyl(ctx, 0.05, 0.9, math.cos(a) * 2.4, 0.45, math.sin(a) * 2.4, hex(0xc7cbd0))
	end
end

export type BuildInfo = { tiles: Folder, decor: Folder, parts: number }

-- Builds the yard into `model`. `centre` is the world position of the grid centre at
-- ground level. `isPath(x, y)` and the field's waypoints decide the path and the
-- gate and shed sides. Returns the Tiles and Decor folders and the part count.
function Garden.build(model: Model, centre: Vector3, cols: number, rows: number, waypoints: { { number } }, isPath: (number, number) -> boolean, beds: { { number } }): BuildInfo
	local U = 2 -- studs per unit (Visuals.UNIT)
	local rnd, rr = Kit.rng(7)

	local tiles = Instance.new("Folder")
	tiles.Name = "Tiles"
	tiles.Parent = model
	local decor = Instance.new("Folder")
	decor.Name = "Decor"
	decor.Parent = model

	local ctx = Kit.new(decor, CFrame.new(centre), U)
	local function tile(x: number, y: number): (number, number)
		return tw(x, y, cols, rows)
	end

	-- Gate side (first waypoint) and shed side (last waypoint), -1 left or 1 right.
	local first, last = waypoints[1], waypoints[#waypoints]
	local gateSide = if first[1] <= 0 then -1 elseif first[1] >= cols - 1 then 1 else 0
	local shedSide = if last[1] >= cols - 1 then 1 elseif last[1] <= 0 then -1 else 0
	local x0 = if shedSide < 0 then -19 else -17
	local x1 = if shedSide > 0 then 19 else 17
	local z0, z1 = -15.5, 11.5

	-- Ground: the street lawn and the yard's slightly brighter lawn.
	local ground = Kit.box(ctx, 140, 0.5, 120, 0, -0.27, -2, hex(0x5c9f3c), nil, { Material = Enum.Material.Grass, CanCollide = true, CastShadow = false })
	ground.Name = "Ground"
	local yard = Kit.box(ctx, x1 - x0, 0.3, z1 - z0, (x0 + x1) / 2, -0.1, (z0 + z1) / 2, hex(0x6fbf47), nil, { CastShadow = false })
	yard.Name = "Yard"

	-- Tiles (raised lawn squares and paver path tiles).
	local bedSet: { [string]: boolean } = {}
	for _, b in beds do
		if not isPath(b[1], b[2]) then
			bedSet[b[1] .. "," .. b[2]] = true
		end
	end
	local grassVar = { hex(0x7dd14f), hex(0x78cc4b), hex(0x83d655), hex(0x6cc244), hex(0x67bd40), hex(0x72c849) }
	local pavers = { hex(0xe6cfa3), hex(0xdcc395), hex(0xeed9b0), hex(0xd6b98a) }
	local tileCtx = Kit.new(tiles, CFrame.new(centre), U)
	for y = 0, rows - 1 do
		for x = 0, cols - 1 do
			local px, pz = tile(x, y)
			local onPath = isPath(x, y)
			local t: BasePart
			if onPath then
				t = pathTile(tileCtx, rnd, rr, px, pz, pavers, true)
				-- The pavers made with it go to Decor.
				for i = #tileCtx.rec, #tileCtx.rec - 3, -1 do
					tileCtx.rec[i].part.Parent = decor
				end
			else
				t = Kit.box(tileCtx, 1.94, 0.4, 1.94, px, TILE_TOP - 0.2, pz, grassVar[((x + y) % 2) * 3 + math.floor(rnd() * 3) + 1])
				t.CanQuery = true
			end
			t.Name = "T_" .. x .. "_" .. y
			t:SetAttribute("X", x)
			t:SetAttribute("Y", y)
			t:SetAttribute("IsPath", onPath)
			if bedSet[x .. "," .. y] then
				t:SetAttribute("Bed", true)
			end
		end
	end

	-- The path runs off the grid to the gate and into the shed.
	local function beyond(a: { number }, b: { number }, k: number): (number, number)
		return a[1] + math.sign(a[1] - b[1]) * k, a[2] + math.sign(a[2] - b[2]) * k
	end
	for k = 1, 3 do
		local gx, gy = beyond(first, waypoints[2], k)
		local px, pz = tile(gx, gy)
		pathTile(ctx, rnd, rr, px, pz, pavers, false)
	end
	do
		local sx, sy = beyond(last, waypoints[#waypoints - 1], 1)
		local px, pz = tile(sx, sy)
		pathTile(ctx, rnd, rr, px, pz, pavers, false)
	end

	-- Soil beds with timber edging.
	local soil, soilDark, timber = hex(0x5b3a24), hex(0x4a2e1b), hex(0xc28a52)
	for key in bedSet do
		local bx, by = string.match(key, "(%d+),(%d+)")
		local px, pz = tile(tonumber(bx) :: number, tonumber(by) :: number)
		Garden.soilPlot(ctx, px, pz, soil, timber)
		for _ = 1, 2 do
			Kit.ball(ctx, 0.09, px + rr(-0.5, 0.5), TILE_TOP + 0.1, pz + rr(-0.5, 0.5), soilDark, { 1, 0.5, 1 }, nil, { CastShadow = false })
		end
	end

	-- Grass tufts and little flowers on the plain lawn tiles.
	local small = Kit.sub(ctx, 0, 0, 0)
	small.shadows = false
	local tuftCols = { hex(0x5fb03a), hex(0x8ad85a) }
	local flowerCols = { WHITE, hex(0xffe066), hex(0xff8fb1) }
	for y = 0, rows - 1 do
		for x = 0, cols - 1 do
			if not isPath(x, y) and not bedSet[x .. "," .. y] then
				local px, pz = tile(x, y)
				for _ = 1, 1 + math.floor(rnd() * 2) do
					grassTuft(small, rr, px + rr(-0.7, 0.7), TILE_TOP, pz + rr(-0.7, 0.7), tuftCols)
				end
				if rnd() < 0.45 then
					flower(small, px + rr(-0.6, 0.6), TILE_TOP, pz + rr(-0.6, 0.6), flowerCols[if rnd() < 0.5 then 1 else 2])
				end
			end
		end
	end
	local gridHalfX, gridHalfZ = cols + 1, rows + 1
	local placed = 0
	while placed < 60 do
		local x, z = rr(x0 + 0.5, x1 - 0.5), rr(z0 + 0.5, z1 - 0.5)
		if not (x > -gridHalfX - 1 and x < gridHalfX + 1 and z > -gridHalfZ and z < gridHalfZ) then
			placed += 1
			grassTuft(small, rr, x, 0.05, z, tuftCols)
			if rnd() < 0.3 then
				flower(small, x + 0.3, 0.05, z, flowerCols[math.floor(rnd() * 3) + 1])
			end
		end
	end

	-- Fences: Colorbond on three sides (a gap for the gate), white pickets at the front.
	local _, gateZ = tile(0, first[2])
	local function sideFence(x: number, side: number)
		if gateSide == side then
			fenceRun(ctx, x, z0, x, gateZ - 1.2, true)
			fenceRun(ctx, x, gateZ + 1.2, x, z1, true)
		else
			fenceRun(ctx, x, z0, x, z1, true)
		end
	end
	fenceRun(ctx, x0, z0, x1, z0, true)
	sideFence(x0, -1)
	sideFence(x1, 1)
	picketRun(ctx, x0, z1, x1, z1)

	-- Open timber gate and the pests' burrow just outside it.
	if gateSide ~= 0 then
		local gx = if gateSide < 0 then x0 else x1
		local gate = Kit.sub(ctx, gx, 0, gateZ - 1.2, 0, if gateSide < 0 then -1.1 else math.pi + 1.1, 0)
		for i = 0, 5 do
			Kit.box(gate, 0.36, 1.7, 0.08, 0.2 + i * 0.4, 0.95, 0, hex(0xb07a46))
		end
		for _, yy in { 0.45, 1.45 } do
			Kit.box(gate, 2.4, 0.12, 0.1, 1.2, yy, 0.06, hex(0x8c5e33))
		end
		Kit.ball(ctx, 1.0, gx + gateSide * 1.4, -0.1, gateZ, hex(0x7a5434), { 1.2, 0.35, 1.2 })
		Kit.cyl(ctx, 0.6, 0.06, gx + gateSide * 1.4, 0.22, gateZ, hex(0x24160c))
	end

	-- Nan's shed past the end of the path, the rainwater tank beside it, Nan and a gnome.
	do
		local sx, sz = tile(last[1] + math.max(shedSide, 0) - math.max(-shedSide, 0), last[2])
		local cx = sx + shedSide * 2.6
		if shedSide == 0 then
			cx = sx
		end
		shed(Kit.sub(ctx, cx, 0, sz), if shedSide < 0 then -1 else 1)
		tank(Kit.sub(ctx, cx + shedSide * 0.4, 0, sz - 3.9))
		local nan = Kit.sub(ctx, sx + shedSide * 0.2, 0.02, sz - 2.4, 0, -0.55 * (if shedSide < 0 then -1 else 1), 0, 1.05)
		Props.nan(nan)
		local gx, gz = tile(if shedSide < 0 then 0 else cols - 1, rows - 1)
		Props.gnome(Kit.sub(ctx, gx + 0.4, TILE_TOP, gz + 0.1, 0, -0.4, 0, 1.15))
	end
	Props.gnome(Kit.sub(ctx, -14.5, 0.05, 9.5, 0, 0.6, 0))

	-- Back of the yard: Hills Hoist and the raised veggie bed.
	hillsHoist(Kit.sub(ctx, 5.5, 0, -12.2, 0, 0.35, 0))
	veggieBed(Kit.sub(ctx, -8, 0, -12.6), rr)

	-- Front flower bed along the pickets.
	local bush = { hex(0x4f9a35), hex(0x5aab3d) }
	local blooms = { hex(0xff6f91), hex(0xffd25a), WHITE }
	for i = 0, 17 do
		local x = -15 + i * 1.9
		Kit.ball(ctx, 0.5, x, 0.4, 10.4, bush[i % 2 + 1], { 1, 0.75, 0.8 })
		if i % 2 == 0 then
			for k = 0, 2 do
				Kit.ball(small, 0.1, x + rr(-0.3, 0.3), 0.75, 10.4 + rr(-0.2, 0.25), blooms[(i + k) % 3 + 1])
			end
		end
	end

	-- Back deck with a barbie, past the front pickets.
	deck(Kit.sub(ctx, -4, 0, 15.2))

	-- Gum trees and shrubs beyond the fences.
	gumTree(ctx, rnd, rr, -14.5, -18.5, 9.5, 1.0)
	gumTree(ctx, rnd, rr, -4, -19.5, 10.5, 1.1)
	gumTree(ctx, rnd, rr, 14.5, -19, 9, 1.0)
	gumTree(ctx, rnd, rr, 23, 2, 9, 1.0)
	gumTree(ctx, rnd, rr, -21.5, 6, 8.5, 0.95)
	local shrubCols = { hex(0x4f8a3a), hex(0x5c9a44), hex(0x6aa84e) }
	for i = 1, 24 do
		shrub(ctx, rr, rr(-30, 32), rr(-24, -17.5), rr(1.0, 1.8), shrubCols[i % 3 + 1])
	end

	-- Neighbours' yards beyond the side fences.
	fenceRun(ctx, x0 - 22, z0 + 4, x0 - 0.2, z0 + 4, false)
	fenceRun(ctx, x1 + 0.2, z0 + 6, x1 + 24, z0 + 6, false)
	fenceRun(ctx, x0 - 0.2, z1 + 8, x0 - 22, z1 + 8, false)
	for i = 1, 20 do
		local side = if i % 2 == 1 then 1 else -1
		local x = if side > 0 then rr(x1 + 3, x1 + 20) else rr(x0 - 20, x0 - 3)
		shrub(ctx, rr, x, rr(z0 - 4, z1 + 10), rr(0.8, 1.5), shrubCols[i % 3 + 1])
	end
	Kit.box(ctx, 4, 2.4, 3, x0 - 9, 1.2, z0 + 9, hex(0xc96a4a))
	Kit.box(ctx, 4.6, 0.2, 3.6, x0 - 9, 2.5, z0 + 9, hex(0xdfe2e4), { 0.12, 0, 0 })
	trampoline(Kit.sub(ctx, x1 + 9, 0, z0 + 14))

	local count = #ctx.rec + #tileCtx.rec
	return { tiles = tiles, decor = decor, parts = count }
end

-- A soil plot with timber edging centred on a tile (units). Used for empty beds here
-- and under every plant on the client.
function Garden.soilPlot(ctx: any, px: number, pz: number, soil: Color3?, timber: Color3?)
	local s = soil or hex(0x5b3a24)
	local t = timber or hex(0xc28a52)
	Kit.box(ctx, 1.5, 0.14, 1.5, px, TILE_TOP + 0.03, pz, s, nil, { CastShadow = false })
	Kit.box(ctx, 1.72, 0.16, 0.14, px, TILE_TOP + 0.06, pz - 0.79, t)
	Kit.box(ctx, 1.72, 0.16, 0.14, px, TILE_TOP + 0.06, pz + 0.79, t)
	Kit.box(ctx, 0.14, 0.16, 1.72, px - 0.79, TILE_TOP + 0.06, pz, t)
	Kit.box(ctx, 0.14, 0.16, 1.72, px + 0.79, TILE_TOP + 0.06, pz, t)
end

Garden.TILE_TOP = TILE_TOP
Garden.PLOT_TOP = PLOT_TOP

return Garden
