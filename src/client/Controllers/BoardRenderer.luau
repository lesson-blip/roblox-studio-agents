--!strict
-- Draws plants (the Shared.Art.Seeds models), the ghost plant, range rings and
-- plantable tile hints from the latest server view. Presentation only: each plant
-- sways gently, turns to face the pest it last shot at and gives a little kick when it
-- fires (Snapjaw snaps its jaw). All plants move in one workspace:BulkMoveTo a frame.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Visuals = require(Shared:WaitForChild("Visuals")) :: any
local Art = Shared:WaitForChild("Art")
local Kit = require(Art:WaitForChild("Kit")) :: any
local ArtSeeds = require(Art:WaitForChild("Seeds")) :: any
local Garden = require(Art:WaitForChild("Garden")) :: any

local BoardRenderer = {}

type Moving = { part: BasePart, offset: CFrame, tag: string?, pivot: Vector3? }
type Plant = {
	model: Model,
	key: string,
	seed: string,
	base: CFrame, -- soil top at the tile centre
	moving: { Moving },
	muzzle: Vector3, -- studs, plant space
	yaw: number,
	targetYaw: number,
	kick: number,
	jaw: number,
	phase: number,
}

local L: any = nil
local store: any = nil
local folder: Folder? = nil
local plants: { [number]: Plant } = {}
local ghost: Model? = nil
local ghostRing: Model? = nil
local inspectRing: Model? = nil
local tileColours: { [BasePart]: Color3 } = {}
local clock = 0

local function ensureFolder(): Folder
	if folder and folder.Parent then
		return folder
	end
	local f = Instance.new("Folder")
	f.Name = "SeedSiegeLocal"
	f.Parent = workspace
	folder = f
	return f
end

local function plantScale(level: number, growth: number): number
	return (if growth > 0 then 0.65 else 1) * (1 + 0.12 * (level - 1))
end

local function tileIsBed(x: number, y: number): boolean
	local plot = store.plot()
	local tiles = plot and plot:FindFirstChild("Tiles")
	local t = tiles and tiles:FindFirstChild("T_" .. x .. "_" .. y)
	return t ~= nil and t:GetAttribute("Bed") == true
end

-- Builds one plant model at a tile. Returns the model and its moving parts.
local function buildPlant(seedId: string, level: number, growth: number, x: number, y: number): (Model, CFrame, { Moving }, Vector3)
	local model = Instance.new("Model")
	model.Name = seedId
	local centre = Visuals.tileCentre(store.origin, x, y, 0)
	-- Soil under the plant (a timber edged plot unless the tile already has a bed), a mound.
	local soil = Kit.new(model, CFrame.new(centre.X, 0, centre.Z), Visuals.UNIT)
	if not tileIsBed(x, y) then
		Garden.soilPlot(soil, 0, 0)
	end
	Kit.ball(soil, 0.62, 0, Garden.PLOT_TOP - 0.05, 0, Kit.hex(0x4a2e1b), { 1, 0.18, 1 }, nil, { CastShadow = false })
	-- Level pips: gold beads on the plot's front edge.
	for i = 2, level do
		Kit.ball(soil, 0.12, -0.55 + (i - 2) * 0.32, Garden.PLOT_TOP + 0.05, 0.79, Color3.fromRGB(255, 210, 60), nil, nil, { Material = Enum.Material.Neon })
	end
	local base = CFrame.new(centre.X, Visuals.PLOT_TOP, centre.Z)
	local sc = Visuals.SEED_SCALE * plantScale(level, growth)
	local ctx = Kit.new(model, base, sc)
	local info = ArtSeeds.build(seedId, ctx)
	local moving: { Moving } = {}
	local inv = base:Inverse()
	for _, r in ctx.rec do
		table.insert(moving, {
			part = r.part,
			offset = inv * r.part.CFrame,
			tag = r.tag,
			pivot = if r.pivot then inv * r.pivot else nil,
		})
	end
	if growth > 0 then
		local bb = Instance.new("BillboardGui")
		bb.Name = "Sprout"
		bb.Size = UDim2.fromOffset(26, 26)
		bb.StudsOffsetWorldSpace = Vector3.new(0, 4.5 * plantScale(level, growth) + 1, 0)
		bb.AlwaysOnTop = true
		bb.LightInfluence = 0
		bb.Adornee = soil.rec[#soil.rec].part
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundColor3 = Color3.fromRGB(79, 174, 60)
		t.TextColor3 = Color3.new(1, 1, 1)
		t.Font = Enum.Font.FredokaOne
		t.TextSize = 16
		t.Text = tostring(growth)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = t
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(20, 18, 26)
		s.Thickness = 2
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = t
		t.Parent = bb
		bb.Parent = model
	end
	return model, base, moving, info.muzzle * sc
end

-- A range ring: a faint cream disc and a bright edge made of short segments.
local function ring(range: number, x: number, y: number, existing: Model?): Model
	if existing then
		existing:Destroy()
	end
	local m = Instance.new("Model")
	m.Name = "RangeRing"
	local r = range * Visuals.TILE
	local centre = Visuals.tileCentre(store.origin, x, y, Visuals.TILE_TOP + 0.35)
	local ctx = Kit.new(m, CFrame.new(centre), 1)
	ctx.shadows = false
	Kit.cyl(ctx, r, 0.05, 0, 0, 0, Color3.fromRGB(255, 240, 184), nil, { Transparency = 0.82 })
	local n = math.clamp(math.floor(r * 3), 24, 72)
	local seg = 2 * math.pi * r / n * 1.05
	for i = 0, n - 1 do
		local a = i / n * math.pi * 2
		Kit.box(ctx, 0.22, 0.08, seg, math.cos(a) * r, 0.03, math.sin(a) * r, Color3.new(1, 1, 1), { 0, -a, 0 }, { Transparency = 0.25, Material = Enum.Material.Neon })
	end
	m.Parent = ensureFolder()
	return m
end

local function rangeOf(seedId: string, level: number): number
	local seed = L.Seeds.byId[seedId]
	return seed.range + L.Constants.LEVEL_RANGE_BONUS[level]
end

local function setHints(on: boolean)
	local plot = store.plot()
	if not plot then
		return
	end
	local tiles = plot:FindFirstChild("Tiles")
	if not tiles then
		return
	end
	for _, t in tiles:GetChildren() do
		if t:IsA("BasePart") then
			local orig = tileColours[t]
			if not orig then
				orig = t.Color
				tileColours[t] = orig
			end
			local x, y = t:GetAttribute("X"), t:GetAttribute("Y")
			local free = not t:GetAttribute("IsPath") and type(x) == "number" and type(y) == "number" and store.plantAt(x, y) == nil
			t.Color = if on and free then orig:Lerp(Visuals.TILE_HINT, 0.6) else orig
		end
	end
end

local function syncPlants()
	local view = store.view
	if not view then
		return
	end
	local seen: { [number]: boolean } = {}
	for _, p in view.plants do
		seen[p.id] = true
		local key = p.seed .. ":" .. p.level .. ":" .. p.growth .. ":" .. p.x .. ":" .. p.y
		local entry = plants[p.id]
		if not entry or entry.key ~= key then
			local yaw = if entry then entry.yaw else 0
			if entry then
				entry.model:Destroy()
			end
			local m, base, moving, muzzle = buildPlant(p.seed, p.level, p.growth, p.x, p.y)
			m.Parent = ensureFolder()
			plants[p.id] = {
				model = m, key = key, seed = p.seed, base = base, moving = moving, muzzle = muzzle,
				yaw = yaw, targetYaw = yaw, kick = 0, jaw = 0, phase = (p.x * 7 + p.y * 13) % 10,
			}
		end
	end
	for id, entry in plants do
		if not seen[id] then
			entry.model:Destroy()
			plants[id] = nil
		end
	end
end

local function syncSelection()
	-- Ghost plant and its range ring.
	local seedId = store.selectedSeed
	local tile = store.ghostTile
	if ghost then
		ghost:Destroy()
		ghost = nil
	end
	if seedId and tile then
		local g = buildPlant(seedId, 1, 0, tile[1], tile[2])
		Kit.ghost(g, 0.5)
		if not store.isMouse then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.fromOffset(150, 30)
			bb.StudsOffsetWorldSpace = Vector3.new(0, 6, 0)
			bb.AlwaysOnTop = true
			local anchor = g:FindFirstChildWhichIsA("BasePart")
			if anchor then
				bb.Adornee = anchor
			end
			local t = Instance.new("TextLabel")
			t.Size = UDim2.fromScale(1, 1)
			t.BackgroundColor3 = Color3.fromRGB(36, 33, 45)
			t.BackgroundTransparency = 0.1
			t.TextColor3 = Color3.new(1, 1, 1)
			t.Font = Enum.Font.FredokaOne
			t.TextSize = 15
			t.Text = "Tap again to plant"
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 10)
			c.Parent = t
			local s = Instance.new("UIStroke")
			s.Color = Color3.fromRGB(20, 18, 26)
			s.Thickness = 2
			s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			s.Parent = t
			t.Parent = bb
			bb.Parent = g
		end
		g.Parent = ensureFolder()
		ghost = g
		if L.Seeds.byId[seedId].range > 0 then
			ghostRing = ring(rangeOf(seedId, 1), tile[1], tile[2], ghostRing)
		elseif ghostRing then
			ghostRing:Destroy()
			ghostRing = nil
		end
	elseif ghostRing then
		ghostRing:Destroy()
		ghostRing = nil
	end
	-- Range ring for the inspected plant.
	local p = if store.inspectId then store.plantById(store.inspectId) else nil
	if p and L.Seeds.byId[p.seed].range > 0 then
		local key = p.seed .. ":" .. p.level .. ":" .. p.x .. ":" .. p.y
		if not inspectRing or inspectRing:GetAttribute("Key") ~= key then
			local r = ring(rangeOf(p.seed, p.level), p.x, p.y, inspectRing)
			r:SetAttribute("Key", key)
			inspectRing = r
		end
	elseif inspectRing then
		inspectRing:Destroy()
		inspectRing = nil
	end
	setHints(seedId ~= nil)
end

-- Plant space to world, with sway, facing and kick.
local function rootOf(p: Plant, t: number): CFrame
	local swayX = math.sin(t * 1.7 + p.phase) * 0.035 - p.kick * 0.18
	local swayZ = math.cos(t * 1.3 + p.phase * 1.3) * 0.035
	local bob = math.sin(t * 2.2 + p.phase) * 0.04
	return p.base * CFrame.new(0, bob, 0) * CFrame.Angles(0, p.yaw, 0) * CFrame.Angles(swayX, 0, swayZ)
end

local function onRender(dt: number)
	clock += dt
	local parts: { BasePart } = {}
	local cframes: { CFrame } = {}
	for _, p in plants do
		-- Turn towards the last target, ease the kick and the jaw back.
		local diff = (p.targetYaw - p.yaw + math.pi) % (2 * math.pi) - math.pi
		p.yaw += diff * math.min(1, dt * 8)
		p.kick = math.max(0, p.kick - dt * 5)
		p.jaw = math.max(0, p.jaw - dt * 4)
		local root = rootOf(p, clock)
		local nod = math.sin(clock * 2.6 + p.phase) * 0.05
		for _, m in p.moving do
			local cf: CFrame
			if m.tag == "jaw" and m.pivot then
				local pv = m.pivot :: Vector3
				cf = root * CFrame.new(pv) * CFrame.Angles(math.min(1, p.jaw * 1.6) * 0.95, 0, 0) * CFrame.new(-pv) * m.offset
			elseif m.tag == "head" and m.pivot then
				local pv = m.pivot :: Vector3
				cf = root * CFrame.new(pv) * CFrame.Angles(nod, 0, nod * 0.6) * CFrame.new(-pv) * m.offset
			else
				cf = root * m.offset
			end
			table.insert(parts, m.part)
			table.insert(cframes, cf)
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

-- World position a plant's shot starts from.
function BoardRenderer.plantPosition(plantId: number): Vector3?
	local p = plants[plantId]
	if not p then
		return nil
	end
	return (rootOf(p, clock) * CFrame.new(p.muzzle)).Position
end

function BoardRenderer.plantSeed(plantId: number): string?
	local p = plants[plantId]
	return if p then p.seed else nil
end

-- A plant fired at a world position: turn to it, kick, and snap if it has a jaw.
function BoardRenderer.fired(plantId: number, at: Vector3)
	local p = plants[plantId]
	if not p then
		return
	end
	local d = at - p.base.Position
	if d.Magnitude > 0.1 then
		p.targetYaw = math.atan2(d.X, d.Z)
	end
	p.kick = 1
	p.jaw = 1
end

function BoardRenderer.init(bundle: any, stateStore: any)
	L = bundle
	store = stateStore
	store.changed:connect(function()
		syncPlants()
		syncSelection()
	end)
	store.selection:connect(syncSelection)
	store.plotReady:connect(function()
		tileColours = {}
		for _, entry in plants do
			entry.model:Destroy()
		end
		plants = {}
		syncPlants()
		syncSelection()
	end)
	RunService.RenderStepped:Connect(onRender)
end

return BoardRenderer
