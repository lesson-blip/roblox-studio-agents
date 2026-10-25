--!nonstrict
-- Builds the real Seed Siege models (src/shared/Art) with Lune's Roblox instances and
-- writes every part to design/preview3d/export/parts.json, so the three.js viewer
-- (design/preview3d/roblox.html) can draw what the Roblox code makes. It also places
-- a few plants and pests where the preview hero has them, and the camera the game
-- would use for a given screen size.
-- Run: `lune run tools/export-parts [width height]` (default 1600 900).
-- This approximates Roblox (no Roblox lighting); it checks shapes, sizes and placement.

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local L = require("../tests/bundle")

local W = tonumber(process.args[1]) or 1600
local H = tonumber(process.args[2]) or 900

-- Load the Art modules with a tiny `script.Parent:WaitForChild(name)` stand in.
local cache = {}
local env
local function load(name: string)
	if cache[name] == nil then
		local src = fs.readFile("src/shared/Art/" .. name .. ".luau")
		local e = table.clone(env)
		e.script = { Parent = { WaitForChild = function(_, n) return { __art = n } end } }
		cache[name] = luau.load(src, { debugName = name, environment = e })()
	end
	return cache[name]
end
local visualsSrc = fs.readFile("src/shared/Visuals.luau")
env = {
	require = function(m)
		return load(m.__art)
	end,
	Instance = roblox.Instance,
	Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame,
	Color3 = roblox.Color3,
	UDim2 = roblox.UDim2,
	Enum = roblox.Enum,
}
local Visuals = luau.load(visualsSrc, { debugName = "Visuals", environment = env })()
local Kit = load("Kit")
local Garden = load("Garden")
local Seeds = load("Seeds")
local Pests = load("Pests")
local CameraFit = load("CameraFit")

local field = L.Fields.byId.backyard
local path = L.Grid.expandPath(field.waypoints)
local C = L.Constants
local T = Visuals.TILE
local origin = roblox.Vector3.new(0, 0, 0)
local centre = origin + roblox.Vector3.new(C.GRID_W * T / 2, 0, C.GRID_H * T / 2)

local root = roblox.Instance.new("Model")
root.Name = "Export"
local plot = roblox.Instance.new("Model")
plot.Parent = root
local info = Garden.build(plot, centre, C.GRID_W, C.GRID_H, field.waypoints, function(x, y)
	return L.Grid.isPathTile(path, x, y)
end, Visuals.BEDS)
print("plot parts: " .. info.parts .. " (Tiles " .. #info.tiles:GetChildren() .. ")")

-- Plants as in the preview hero (seed, tile x, tile y).
local plants = {
	{ "thorn", 3, 3 }, { "thorn", 1, 2 }, { "dandelion", 6, 5 }, { "pumpkin", 10, 3 },
	{ "snapjaw", 3, 5 }, { "sunpetal", 7, 2 }, { "burr", 5, 3 }, { "thorn", 8, 2 },
}
local plantParts = 0
for _, p in plants do
	local m = roblox.Instance.new("Model")
	m.Name = p[1]
	m.Parent = root
	local base = Visuals.tileCentre(origin, p[2], p[3], 0)
	local soil = Kit.new(m, roblox.CFrame.new(base.X, 0, base.Z), Visuals.UNIT)
	local tile = info.tiles:FindFirstChild("T_" .. p[2] .. "_" .. p[3])
	if not tile:GetAttribute("Bed") then
		Garden.soilPlot(soil, 0, 0)
	end
	Kit.ball(soil, 0.62, 0, Garden.PLOT_TOP - 0.05, 0, Kit.hex(0x4a2e1b), { 1, 0.18, 1 })
	local ctx = Kit.new(m, roblox.CFrame.new(base.X, Visuals.PLOT_TOP, base.Z), Visuals.SEED_SCALE)
	Seeds.build(p[1], ctx)
	plantParts += #ctx.rec + #soil.rec
end
print("plant parts (8 plants): " .. plantParts)

-- Pests along the route (type, distance in tiles), as in the preview.
local pests = { { "aphid", 0.65 }, { "aphid", 1.3 }, { "ant", 2.6 }, { "snail", 4.8 }, { "snail", 8.0 }, { "beetle", 10.15 }, { "ant", 11.6 }, { "caterpillar", 6.8 } }
local pestParts = 0
for _, e in pests do
	local m = roblox.Instance.new("Model")
	m.Name = e[1]
	m.Parent = root
	local px, py = L.Grid.positionAt(path, e[2])
	local qx, qy = L.Grid.positionAt(path, e[2] + 0.05)
	local pos = Visuals.toWorld(origin, px, py, Visuals.PATH_TOP)
	local yaw = math.atan2(qx - px, qy - py)
	local ctx = Kit.new(m, roblox.CFrame.new(pos) * roblox.CFrame.Angles(0, yaw, 0), Visuals.PEST_SCALE)
	local pinfo = Pests.build(e[1], ctx)
	-- Lay caterpillar segments along the path, as the client does.
	if pinfo.trailGap then
		for _, r in ctx.rec do
			if r.tag == "trail" then
				local d = e[2] - r.phase * pinfo.trailGap * Visuals.PEST_SCALE / T
				local sx, sy = L.Grid.positionAt(path, math.max(0, d))
				local spos = Visuals.toWorld(origin, sx, sy, Visuals.PATH_TOP)
				local rel = r.part.CFrame.Position - r.pivot
				r.part.CFrame = roblox.CFrame.new(spos + rel)
			end
		end
	end
	pestParts += #ctx.rec
end
print("pest parts (8 pests): " .. pestParts)

-- The camera the client would pick for this screen.
local w, h = C.GRID_W * T, C.GRID_H * T
local pts = {
	origin + roblox.Vector3.new(0, Visuals.TILE_TOP, 0), origin + roblox.Vector3.new(w, Visuals.TILE_TOP, 0),
	origin + roblox.Vector3.new(0, Visuals.TILE_TOP, h), origin + roblox.Vector3.new(w, Visuals.TILE_TOP, h),
	origin + roblox.Vector3.new(w + 8, 3, (field.waypoints[#field.waypoints][2] + 0.5) * T),
}
local cam = CameraFit.fit(pts, W / H, Visuals.CAMERA_SAFE, CameraFit.FOV)

local out = { parts = {}, camera = { cf = { cam:GetComponents() }, fov = CameraFit.FOV }, width = W, height = H }
for _, d in root:GetDescendants() do
	if d:IsA("BasePart") then
		local mesh = d:FindFirstChildOfClass("SpecialMesh")
		local shape = "Block"
		if d.ClassName == "Part" then
			shape = d.Shape.Name
		end
		table.insert(out.parts, {
			c = d.ClassName,
			sh = if mesh then "Sphere" else shape,
			s = { d.Size.X, d.Size.Y, d.Size.Z },
			cf = { d.CFrame:GetComponents() },
			col = { d.Color.R, d.Color.G, d.Color.B },
			t = d.Transparency,
			r = d.Reflectance,
			cs = d.CastShadow,
		})
	end
end
fs.writeDir("design/preview3d/export")
fs.writeFile("design/preview3d/export/parts.json", serde.encode("json", out))
print("wrote design/preview3d/export/parts.json (" .. #out.parts .. " parts)")
