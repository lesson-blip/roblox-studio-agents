--!strict
-- Draws plants, the ghost plant, range rings and plantable tile hints from the
-- latest server view. Placeholder Parts only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Visuals")) :: any

local BoardRenderer = {}

local L: any = nil
local store: any = nil
local folder: Folder? = nil
local plantModels: { [number]: { model: Model, key: string } } = {}
local ghost: Model? = nil
local ghostRing: Part? = nil
local inspectRing: Part? = nil
local tileColours: { [BasePart]: Color3 } = {}

local function newPart(props: { [string]: any }, parent: Instance): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

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

-- Builds the placeholder look of one plant at a tile.
local function buildPlant(seedId: string, level: number, growth: number, x: number, y: number, transparency: number): Model
	local look = Visuals.SEEDS[seedId]
	local model = Instance.new("Model")
	model.Name = seedId
	local scale = (if growth > 0 then 0.65 else 1) * (1 + 0.15 * (level - 1))
	local h = look.height * scale
	local wdt = look.width * scale
	local base = Visuals.tileCentre(store.origin, x, y, 0)
	local body = newPart({
		Name = "Body",
		Shape = if look.shape == "Ball" then Enum.PartType.Ball else Enum.PartType.Block,
		Size = if look.shape == "Ball" then Vector3.new(wdt, wdt, wdt) else Vector3.new(wdt, h, wdt),
		Position = base + Vector3.new(0, (if look.shape == "Ball" then wdt else h) / 2 + 0.2, 0),
		Color = look.color,
		Transparency = transparency,
	}, model)
	newPart({
		Name = "Accent",
		Size = Vector3.new(wdt * 0.5, 0.4, wdt * 0.5),
		Position = body.Position + Vector3.new(0, body.Size.Y / 2 + 0.2, 0),
		Color = look.accent,
		Transparency = transparency,
	}, model)
	-- Level pips: small gold cubes on the tile corner.
	for i = 2, level do
		newPart({
			Name = "Pip" .. i,
			Size = Vector3.new(0.5, 0.5, 0.5),
			Position = base + Vector3.new(-1.4 + (i - 2) * 0.7, 0.45, 1.4),
			Color = Color3.fromRGB(255, 210, 60),
			Material = Enum.Material.Neon,
			Transparency = transparency,
		}, model)
	end
	if growth > 0 and transparency < 0.5 then
		local bb = Instance.new("BillboardGui")
		bb.Name = "Sprout"
		bb.Size = UDim2.fromOffset(26, 26)
		bb.StudsOffsetWorldSpace = Vector3.new(0, h + 1.2, 0)
		bb.AlwaysOnTop = true
		bb.Adornee = body
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundColor3 = Color3.fromRGB(80, 170, 70)
		t.TextColor3 = Color3.new(1, 1, 1)
		t.Font = Enum.Font.FredokaOne
		t.TextSize = 16
		t.Text = tostring(growth)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = t
		t.Parent = bb
		bb.Parent = model
	end
	model.PrimaryPart = body
	return model
end

local function ring(range: number, x: number, y: number, existing: Part?): Part
	local d = range * 2 * Visuals.TILE
	local p = existing or newPart({
		Name = "RangeRing",
		Shape = Enum.PartType.Cylinder,
		Color = Visuals.RANGE,
		Material = Enum.Material.ForceField,
		Transparency = 0.3,
	}, ensureFolder())
	p.Size = Vector3.new(0.12, d, d)
	p.CFrame = CFrame.new(Visuals.tileCentre(store.origin, x, y, 0.25)) * CFrame.Angles(0, 0, math.rad(90))
	return p
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
			t.Color = if on and free then Visuals.TILE_HINT else orig
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
		local entry = plantModels[p.id]
		if not entry or entry.key ~= key then
			if entry then
				entry.model:Destroy()
			end
			local m = buildPlant(p.seed, p.level, p.growth, p.x, p.y, 0)
			m.Parent = ensureFolder()
			plantModels[p.id] = { model = m, key = key }
		end
	end
	for id, entry in plantModels do
		if not seen[id] then
			entry.model:Destroy()
			plantModels[id] = nil
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
		local g = buildPlant(seedId, 1, 0, tile[1], tile[2], 0.55)
		if not store.isMouse then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.fromOffset(150, 30)
			bb.StudsOffsetWorldSpace = Vector3.new(0, 4.5, 0)
			bb.AlwaysOnTop = true
			local gp = g.PrimaryPart
			if gp then
				bb.Adornee = gp
			end
			local t = Instance.new("TextLabel")
			t.Size = UDim2.fromScale(1, 1)
			t.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
			t.BackgroundTransparency = 0.2
			t.TextColor3 = Color3.new(1, 1, 1)
			t.Font = Enum.Font.GothamBold
			t.TextSize = 14
			t.Text = "Tap again to plant"
			local c = Instance.new("UICorner")
			c.Parent = t
			t.Parent = bb
			bb.Parent = g
		end
		g.Parent = ensureFolder()
		ghost = g
		ghostRing = ring(rangeOf(seedId, 1), tile[1], tile[2], ghostRing)
		local r = ghostRing :: Part
		r.Transparency = if L.Seeds.byId[seedId].range > 0 then 0.3 else 1
	elseif ghostRing then
		ghostRing:Destroy()
		ghostRing = nil
	end
	-- Range ring for the inspected plant.
	local p = if store.inspectId then store.plantById(store.inspectId) else nil
	if p and L.Seeds.byId[p.seed].range > 0 then
		inspectRing = ring(rangeOf(p.seed, p.level), p.x, p.y, inspectRing)
	elseif inspectRing then
		inspectRing:Destroy()
		inspectRing = nil
	end
	setHints(seedId ~= nil)
end

-- World position of a plant's top, for shot effects.
function BoardRenderer.plantPosition(plantId: number): Vector3?
	local entry = plantModels[plantId]
	if entry and entry.model.PrimaryPart then
		return entry.model.PrimaryPart.Position + Vector3.new(0, 1, 0)
	end
	return nil
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
		for _, entry in plantModels do
			entry.model:Destroy()
		end
		plantModels = {}
		syncPlants()
		syncSelection()
	end)
end

return BoardRenderer
