--!strict
-- Draws pests as coloured spheres from the 5 Hz snapshots, moving them smoothly
-- between snapshots (a short prediction along the path, then a gentle blend).

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Visuals")) :: any

local PestRenderer = {}

local L: any = nil
local store: any = nil
local effects: any = nil
local folder: Folder? = nil
local MAX_AHEAD = 0.35 -- tiles of prediction past the last snapshot

type Entry = {
	part: Part,
	bar: Frame,
	barGui: BillboardGui,
	typeId: string,
	shownD: number,
	snapD: number,
	snapAt: number,
	slowed: boolean,
	hidden: boolean,
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

local function create(id: number, typeId: string, d: number): Entry
	local look = Visuals.PESTS[typeId]
	local p = Instance.new("Part")
	p.Name = typeId .. "_" .. id
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(look.size, look.size, look.size)
	p.Color = look.color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Parent = ensureFolder()
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(36, 6)
	bb.StudsOffsetWorldSpace = Vector3.new(0, look.size / 2 + 0.8, 0)
	bb.Adornee = p
	bb.AlwaysOnTop = true
	bb.Enabled = false
	local back = Instance.new("Frame")
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	back.BorderSizePixel = 0
	back.Parent = bb
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromScale(1, 1)
	bar.BackgroundColor3 = Color3.fromRGB(110, 220, 90)
	bar.BorderSizePixel = 0
	bar.Parent = back
	bb.Parent = p
	return {
		part = p, bar = bar, barGui = bb, typeId = typeId,
		shownD = d, snapD = d, snapAt = os.clock(), slowed = false, hidden = false,
	}
end

local function worldAt(e: Entry, d: number): Vector3
	local look = Visuals.PESTS[e.typeId]
	local px, py = L.Grid.positionAt(store.path, d)
	local height = look.size / 2 + 0.2 + look.fly
	if e.hidden then
		height = look.size * 0.15
	end
	return Visuals.toWorld(store.origin, px, py, height)
end

function PestRenderer.pestPosition(id: number): Vector3?
	local e = entries[id]
	return if e then e.part.Position else nil
end

local function remove(id: number, popReward: number?)
	local e = entries[id]
	if not e then
		return
	end
	if popReward and effects then
		effects.pop(e.part.Position, popReward)
	end
	e.part:Destroy()
	entries[id] = nil
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
		e.hidden = row.hidden
		e.part.Transparency = if row.hidden then 0.7 else 0
		e.part.Material = if row.burning then Enum.Material.Neon else Enum.Material.SmoothPlastic
		e.barGui.Enabled = row.hpPercent < 100 and not row.hidden
		e.bar.Size = UDim2.fromScale(row.hpPercent / 100, 1)
	end
	for id in entries do
		if not seen[id] then
			remove(id, rewards[id])
		end
	end
end

local function onRender(dt: number)
	local view = store.view
	if not view or not store.path then
		return
	end
	local now = os.clock()
	local runSpeed = view.speed or 1
	local moving = view.phase == "wave"
	for _, e in entries do
		local def = L.Pests.byId[e.typeId]
		local speed = def.speed * (if e.slowed then 0.7 else 1) * runSpeed
		local predicted = e.snapD
		if moving then
			predicted += math.min(MAX_AHEAD, speed * (now - e.snapAt))
		end
		e.shownD += (predicted - e.shownD) * math.min(1, dt * 10)
		e.part.Position = worldAt(e, e.shownD)
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
