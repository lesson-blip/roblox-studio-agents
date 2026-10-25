--!strict
-- Draws pests (the Shared.Art.Pests models) from the 5 Hz snapshots, moving them
-- smoothly between snapshots (a short prediction along the path, then a gentle blend).
-- Each pest bobs as it walks, wiggles its legs (flyers flap), turns to face the way
-- the path goes, and a caterpillar's segments follow the path behind its head.
-- Health bars are BillboardGuis. Every pest part moves in one BulkMoveTo a frame.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Visuals = require(Shared:WaitForChild("Visuals")) :: any
local Art = Shared:WaitForChild("Art")
local Kit = require(Art:WaitForChild("Kit")) :: any
local ArtPests = require(Art:WaitForChild("Pests")) :: any

local PestRenderer = {}

local L: any = nil
local store: any = nil
local effects: any = nil
local folder: Folder? = nil
local MAX_AHEAD = 0.35 -- tiles of prediction past the last snapshot
local clock = 0

type Moving = { part: BasePart, offset: CFrame, tag: string?, pivot: Vector3?, phase: number }

type Entry = {
	model: Model,
	moving: { Moving },
	anchor: BasePart,
	bar: Frame,
	barGui: BillboardGui,
	glow: PointLight,
	typeId: string,
	fly: number,
	trailTiles: number,
	shownD: number,
	snapD: number,
	snapAt: number,
	slowed: boolean,
	hidden: boolean,
	burning: boolean,
	yaw: number,
	phase: number,
}

local entries: { [number]: Entry } = {}

local function ensureFolder(): Folder
	if folder and folder.Parent then
		return folder
	end
	local f = Instance.new("Folder")
	f.Name = "SeedSiegePests"
	f.Parent = workspace
	folder = f
	return f
end

local function hpColour(pct: number): Color3
	if pct > 50 then
		return Color3.fromRGB(94, 224, 90)
	elseif pct > 25 then
		return Color3.fromRGB(255, 201, 58)
	end
	return Color3.fromRGB(255, 91, 91)
end

local function create(id: number, typeId: string, d: number): Entry
	local look = Visuals.PESTS[typeId] or { size = 1, fly = 0 }
	local model = Instance.new("Model")
	model.Name = typeId .. "_" .. id
	local ctx = Kit.new(model, CFrame.new(), Visuals.PEST_SCALE)
	local info = ArtPests.build(typeId, ctx)
	local moving: { Moving } = {}
	for _, r in ctx.rec do
		r.part.CastShadow = r.part.Size.Magnitude > 0.6 -- tiny legs and pupils cast no shadow
		table.insert(moving, { part = r.part, offset = r.part.CFrame, tag = r.tag, pivot = r.pivot, phase = r.phase or 0 })
	end
	local anchor = ctx.rec[1].part
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 140, 40)
	glow.Brightness = 2
	glow.Range = 6
	glow.Enabled = false
	glow.Parent = anchor
	-- Health bar: a dark rounded track with a coloured fill and a shine.
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(40, 9)
	bb.StudsOffsetWorldSpace = Vector3.new(0, info.top * Visuals.PEST_SCALE + 0.9 - anchor.Position.Y, 0)
	bb.Adornee = anchor
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Enabled = false
	local back = Instance.new("Frame")
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = Color3.fromRGB(27, 24, 34)
	back.BorderSizePixel = 0
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0.5, 0)
	bc.Parent = back
	back.Parent = bb
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -4, 1, -4)
	track.Position = UDim2.fromOffset(2, 2)
	track.BackgroundColor3 = Color3.fromRGB(58, 53, 70)
	track.BorderSizePixel = 0
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0.5, 0)
	tc.Parent = track
	track.Parent = back
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromScale(1, 1)
	bar.BackgroundColor3 = hpColour(100)
	bar.BorderSizePixel = 0
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0.5, 0)
	fc.Parent = bar
	local shine = Instance.new("UIGradient")
	shine.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200))
	shine.Rotation = 90
	shine.Parent = bar
	bar.Parent = track
	bb.Parent = model
	model.Parent = ensureFolder()
	return {
		model = model, moving = moving, anchor = anchor, bar = bar, barGui = bb, glow = glow,
		typeId = typeId, fly = look.fly or 0,
		trailTiles = if info.trailGap then info.trailGap * Visuals.PEST_SCALE / Visuals.TILE else 0,
		shownD = d, snapD = d, snapAt = os.clock(), slowed = false, hidden = false, burning = false,
		yaw = 0, phase = (id * 0.37) % 1 * math.pi * 2,
	}
end

-- World point and walking direction (yaw) at a distance along the path.
local function along(d: number, height: number): (Vector3, number)
	local px, py = L.Grid.positionAt(store.path, math.max(0, d))
	local qx, qy = L.Grid.positionAt(store.path, math.max(0, d) + 0.05)
	local yaw = if qx == px and qy == py then nil else math.atan2(qx - px, qy - py)
	return Visuals.toWorld(store.origin, px, py, height), yaw or 0
end

function PestRenderer.pestPosition(id: number): Vector3?
	local e = entries[id]
	return if e then e.anchor.Position else nil
end

local function remove(id: number, popReward: number?)
	local e = entries[id]
	if not e then
		return
	end
	if popReward and effects then
		effects.pop(e.anchor.Position, popReward)
	end
	e.model:Destroy()
	entries[id] = nil
end

local function setHidden(e: Entry, hidden: boolean)
	for _, m in e.moving do
		m.part.LocalTransparencyModifier = if hidden then 0.7 else 0
	end
end

local function onSnapshot(snap: any, receivedAt: number)
	if not store.path then
		return
	end
	local rewards: { [number]: number } = {}
	local sap = snap.sap or {}
	for i = 1, #sap, 2 do
		rewards[sap[i]] = sap[i + 1]
	end
	-- Shots first, while both ends still exist.
	if effects then
		local shots = snap.shots or {}
		for i = 1, #shots, 2 do
			effects.shot(shots[i], shots[i + 1])
		end
	end
	local seen: { [number]: boolean } = {}
	for _, row in L.Views.unpackPests(snap.pests) do
		seen[row.id] = true
		local typeId = L.Pests.order[row.typeIndex]
		local e = entries[row.id]
		if not e then
			e = create(row.id, typeId, row.d)
			entries[row.id] = e
		end
		assert(e)
		e.snapD = row.d
		e.snapAt = receivedAt
		e.slowed = row.slowed
		if e.hidden ~= row.hidden then
			e.hidden = row.hidden
			setHidden(e, row.hidden)
		end
		if e.burning ~= row.burning then
			e.burning = row.burning
			e.glow.Enabled = row.burning
		end
		e.barGui.Enabled = row.hpPercent < 100 and not row.hidden
		e.bar.Size = UDim2.fromScale(math.max(0.06, row.hpPercent / 100), 1)
		e.bar.BackgroundColor3 = hpColour(row.hpPercent)
	end
	for id in entries do
		if not seen[id] then
			remove(id, rewards[id])
		end
	end
end

local function onRender(dt: number)
	clock += dt
	local view = store.view
	if not view or not store.path then
		return
	end
	local now = os.clock()
	local runSpeed = view.speed or 1
	local moving = view.phase == "wave"
	local parts: { BasePart } = {}
	local cframes: { CFrame } = {}
	for _, e in entries do
		local def = L.Pests.byId[e.typeId]
		local speed = def.speed * (if e.slowed then 0.7 else 1) * runSpeed
		local predicted = e.snapD
		if moving then
			predicted += math.min(MAX_AHEAD, speed * (now - e.snapAt))
		end
		e.shownD += (predicted - e.shownD) * math.min(1, dt * 10)
		local height = Visuals.PATH_TOP + e.fly
		if e.hidden then
			height = Visuals.PATH_TOP - 0.6
		end
		local pos, yaw = along(e.shownD, height)
		local diff = (yaw - e.yaw + math.pi) % (2 * math.pi) - math.pi
		e.yaw += diff * math.min(1, dt * 10)
		-- Walk cycle: faster pests step faster. Flyers hover and flap instead.
		local step = clock * (6 + speed * 6) + e.phase
		local bob = if e.fly > 0 then math.sin(clock * 3 + e.phase) * 0.25 else math.abs(math.sin(step)) * 0.12
		local root = CFrame.new(pos + Vector3.new(0, bob, 0)) * CFrame.Angles(0, e.yaw, 0)
			* CFrame.Angles(0, 0, math.sin(step) * 0.04)
		for _, m in e.moving do
			local cf: CFrame
			if m.tag == "leg" and m.pivot then
				local pv = m.pivot :: Vector3
				if e.fly > 0 then
					local flap = math.sin(clock * 22 + e.phase) * 0.5 * (if pv.X < 0 then -1 else 1)
					cf = root * CFrame.new(pv) * CFrame.Angles(0, 0, flap) * CFrame.new(-pv) * m.offset
				else
					local swing = math.sin(step + m.phase * 2.1) * 0.45
					cf = root * CFrame.new(pv) * CFrame.Angles(0, swing, 0) * CFrame.new(-pv) * m.offset
				end
			elseif m.tag == "trail" and m.pivot then
				local pv = m.pivot :: Vector3
				local sd = e.shownD - m.phase * e.trailTiles
				local spos, syaw = along(sd, height)
				local lift = math.max(0, math.sin(step - m.phase * 0.9)) * 0.25
				cf = CFrame.new(spos + Vector3.new(0, lift, 0)) * CFrame.Angles(0, syaw, 0) * CFrame.new(-pv) * m.offset
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

function PestRenderer.init(bundle: any, stateStore: any, effectsController: any)
	L = bundle
	store = stateStore
	effects = effectsController
	store.snapshot:connect(onSnapshot)
	store.plotReady:connect(function()
		for id in entries do
			remove(id, nil)
		end
	end)
	RunService.RenderStepped:Connect(onRender)
end

return PestRenderer
