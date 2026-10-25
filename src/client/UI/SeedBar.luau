--!strict
-- One card per loadout seed (spec 7.2), styled like the preview: the seed's colour,
-- its key number, a 3D portrait of the real plant model (ViewportFrame), the name and
-- the cost. A clear state when it cannot be afforded ("need N") or is locked; colour
-- is never the only signal. Keys 1 to 6 pick a card on a keyboard.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Visuals = require(Shared:WaitForChild("Visuals")) :: any
local Kit = require(Shared:WaitForChild("Art"):WaitForChild("Kit")) :: any
local ArtSeeds = require(Shared:WaitForChild("Art"):WaitForChild("Seeds")) :: any
local Theme = require(script.Parent:WaitForChild("Theme")) :: any
local Components = require(script.Parent:WaitForChild("Components")) :: any

local SeedBar = {}

type Card = {
	holder: Frame,
	button: TextButton,
	gradient: UIGradient,
	cost: TextLabel,
	note: TextLabel,
	noteBox: Frame,
	glow: UIStroke,
	portrait: ViewportFrame,
}

local L: any = nil
local store: any = nil
local bar: Frame? = nil
local cards: { [string]: Card } = {}
local order: { string } = {}

local CARD_W, CARD_H, GAP = 70, 88, 8
local KEYS = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six }

local function select(seedId: string)
	local view = store.view
	if not view then
		return
	end
	for _, s in view.loadout do
		if s.id == seedId and s.locked then
			store.toast:fire(s.locked .. " to unlock " .. L.Seeds.byId[seedId].name .. ".")
			return
		end
	end
	if store.selectedSeed == seedId then
		store.clearSelection()
	else
		store.selectedSeed = seedId
		store.ghostTile = nil
		store.inspectId = nil
		store.selection:fire()
	end
end

-- A 3D portrait of the seed's plant model, framed from its bounding box.
local function portrait(seedId: string, parent: Instance): ViewportFrame
	local vp = Instance.new("ViewportFrame")
	vp.Name = "Portrait"
	vp.BackgroundTransparency = 1
	vp.Size = UDim2.new(1, 0, 0, 50)
	vp.Position = UDim2.fromOffset(0, 2)
	vp.Ambient = Color3.fromRGB(200, 200, 200)
	vp.LightColor = Color3.fromRGB(255, 242, 221)
	vp.LightDirection = Vector3.new(0.4, -0.7, -0.6)
	vp.ZIndex = 4
	local model = Instance.new("Model")
	model.Name = seedId
	ArtSeeds.build(seedId, Kit.new(model, CFrame.new(), 1))
	model.Parent = vp
	local cf, size = model:GetBoundingBox()
	local dist = math.max(size.Y, size.X * 0.9) * 2.4
	local cam = Instance.new("Camera")
	cam.FieldOfView = 28
	cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0.35, 0.35, 1).Unit * dist, cf.Position)
	cam.Parent = vp
	vp.CurrentCamera = cam
	vp.Parent = parent
	return vp
end

local function build(view: any)
	assert(bar)
	for _, c in cards do
		c.holder:Destroy()
	end
	cards = {}
	order = {}
	for i, s in view.loadout do
		local seed = L.Seeds.byId[s.id]
		local holder = Components.frame({
			Name = s.id,
			Size = UDim2.fromOffset(CARD_W, CARD_H),
			Position = UDim2.fromOffset((i - 1) * (CARD_W + GAP), 0),
			BackgroundTransparency = 1,
		}, bar)
		local edge = Components.frame({ Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = Theme.INK }, holder)
		Components.corner(edge, 14)
		local b = Instance.new("TextButton")
		b.Name = "Card"
		b.Text = ""
		b.AutoButtonColor = true
		b.BorderSizePixel = 0
		b.Size = UDim2.fromScale(1, 1)
		b.BackgroundColor3 = Color3.new(1, 1, 1)
		b.ZIndex = 2
		Components.corner(b, 14)
		local cols = Visuals.CARD[s.id] or { Color3.fromRGB(220, 220, 220), Color3.fromRGB(150, 150, 150) }
		local g = Components.gradient(b, cols[1], cols[2])
		local glow = Components.stroke(b, Theme.INK, 2)
		b.Activated:Connect(function()
			select(s.id)
		end)
		b.Parent = holder
		-- A soft light spot behind the portrait, as the preview's radial highlight.
		local spot = Components.frame({
			Size = UDim2.fromOffset(52, 40),
			Position = UDim2.new(0.5, -26, 0, 6),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.6,
			ZIndex = 3,
		}, b)
		Components.round(spot)
		local vp = portrait(s.id, b)
		local key = Components.label(tostring(i), {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(5, 3),
			TextSize = 14,
			ZIndex = 6,
		}, b)
		Components.textStroke(key, 2)
		local name = Components.label(seed.short, {
			Size = UDim2.new(1, -4, 0, 16),
			Position = UDim2.fromOffset(2, 50),
			TextSize = 14,
			TextWrapped = false,
			TextScaled = false,
			ZIndex = 6,
		}, b)
		Components.textStroke(name, 2)
		local drop = Components.drop(b, 14, UDim2.new(0.5, -22, 0, 68))
		for _, d in drop:GetDescendants() do
			if d:IsA("GuiObject") then
				d.ZIndex += 4
			end
		end
		local cost = Components.label(tostring(seed.cost), {
			Name = "Cost",
			Size = UDim2.fromOffset(40, 16),
			Position = UDim2.new(0.5, -6, 0, 67),
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = false,
			ZIndex = 6,
		}, b)
		Components.textStroke(cost, 2)
		-- "need N" or "Locked" sits over the portrait, so the card never grows.
		local noteBox = Components.frame({
			Name = "NoteBox",
			Size = UDim2.new(1, -10, 0, 16),
			Position = UDim2.fromOffset(5, 32),
			BackgroundColor3 = Theme.INK,
			BackgroundTransparency = 0.2,
			Visible = false,
			ZIndex = 7,
		}, b)
		Components.corner(noteBox, 8)
		local note = Components.label("", {
			Name = "Note",
			Size = UDim2.fromScale(1, 1),
			TextSize = 12,
			TextWrapped = false,
			ZIndex = 8,
		}, noteBox)
		cards[s.id] = { holder = holder, button = b, gradient = g, cost = cost, note = note, noteBox = noteBox, glow = glow, portrait = vp }
		table.insert(order, s.id)
	end
end

local function refresh()
	local view = store.view
	if not bar or not view then
		return
	end
	local ids = {}
	for _, s in view.loadout do
		table.insert(ids, s.id)
	end
	if table.concat(ids, ",") ~= table.concat(order, ",") then
		build(view)
	end
	bar.Visible = store.inspectId == nil and view.phase ~= "over"
	for i, s in view.loadout do
		local c = cards[s.id]
		local seed = L.Seeds.byId[s.id]
		local selected = store.selectedSeed == s.id
		c.holder.Position = UDim2.fromOffset((i - 1) * (CARD_W + GAP), if selected then -10 else 0)
		c.glow.Color = if selected then Color3.fromRGB(255, 248, 214) else Theme.INK
		c.glow.Thickness = if selected then 3 else 2
		local cols = Visuals.CARD[s.id] or { Color3.fromRGB(220, 220, 220), Color3.fromRGB(150, 150, 150) }
		if s.locked then
			c.gradient.Color = ColorSequence.new(Color3.fromRGB(190, 186, 196), Theme.GREY)
			c.cost.Text = tostring(seed.cost)
			c.note.Text = "Locked"
			c.noteBox.Visible = true
			c.portrait.ImageTransparency = 0.55
		elseif view.sap < seed.cost then
			c.gradient.Color = ColorSequence.new(cols[1]:Lerp(Theme.GREY, 0.6), cols[2]:Lerp(Theme.GREY, 0.6))
			c.cost.Text = tostring(seed.cost)
			c.note.Text = "need " .. (seed.cost - view.sap)
			c.noteBox.Visible = true
			c.portrait.ImageTransparency = 0.3
		else
			c.gradient.Color = ColorSequence.new(cols[1], cols[2])
			c.cost.Text = tostring(seed.cost)
			c.note.Text = ""
			c.noteBox.Visible = false
			c.portrait.ImageTransparency = 0
		end
	end
end

function SeedBar.init(bundle: any, stateStore: any, root: Instance)
	L = bundle
	store = stateStore
	bar = Components.frame({
		Name = "SeedBar",
		Size = UDim2.fromOffset(6 * (CARD_W + GAP), CARD_H),
		Position = UDim2.new(0, 8, 1, -(CARD_H + 10)),
		BackgroundTransparency = 1,
	}, root)
	store.changed:connect(refresh)
	store.selection:connect(refresh)
	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local i = table.find(KEYS, input.KeyCode)
		if i and order[i] and bar and bar.Visible then
			select(order[i])
		end
	end)
end

return SeedBar
