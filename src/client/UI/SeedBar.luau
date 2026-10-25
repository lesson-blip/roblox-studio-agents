--!strict
-- One card per loadout seed (spec 7.2): name, cost, and a clear state when it
-- cannot be afforded ("need N") or is locked. Colour is never the only signal.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Visuals")) :: any
local Theme = require(script.Parent:WaitForChild("Theme")) :: any
local Components = require(script.Parent:WaitForChild("Components")) :: any

local SeedBar = {}

local L: any = nil
local store: any = nil
local bar: Frame? = nil
local cards: { [string]: { button: TextButton, cost: TextLabel, note: TextLabel, stroke: UIStroke } } = {}
local order: { string } = {}

local CARD_W, CARD_H = 72, 88

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

local function build(view: any)
	assert(bar)
	for _, c in cards do
		c.button:Destroy()
	end
	cards = {}
	order = {}
	for i, s in view.loadout do
		local seed = L.Seeds.byId[s.id]
		local b = Components.button("", {
			Name = s.id,
			Size = UDim2.fromOffset(CARD_W, CARD_H),
			Position = UDim2.fromOffset((i - 1) * (CARD_W + 8), 0),
			BackgroundColor3 = Theme.PANEL_LIGHT,
		}, function()
			select(s.id)
		end, bar)
		local swatch = Components.frame({
			Size = UDim2.fromOffset(32, 32),
			Position = UDim2.new(0.5, -16, 0, 6),
			BackgroundColor3 = Visuals.SEEDS[s.id].color,
			BackgroundTransparency = 0,
		}, b)
		Components.corner(swatch, 16)
		Components.label(seed.short, {
			Size = UDim2.new(1, -4, 0, 18),
			Position = UDim2.fromOffset(2, 40),
			TextColor3 = Theme.TEXT_DARK,
			TextSize = Theme.TEXT_MIN,
			TextScaled = false,
		}, b)
		local cost = Components.label(tostring(seed.cost), {
			Name = "Cost",
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 56),
			TextColor3 = Theme.TEXT_DARK,
			Font = Theme.FONT_HEAD,
			TextSize = Theme.TEXT_NUMBER,
		}, b)
		local note = Components.label("", {
			Name = "Note",
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, 72),
			TextColor3 = Theme.WARN,
			TextSize = 12,
		}, b)
		local stroke = Components.stroke(b, Theme.SAP, 3)
		cards[s.id] = { button = b, cost = cost, note = note, stroke = stroke }
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
		c.button.Position = UDim2.fromOffset((i - 1) * (CARD_W + 8), if selected then -10 else 0)
		c.stroke.Enabled = selected
		if s.locked then
			c.button.BackgroundColor3 = Theme.GREY
			c.cost.Text = "\u{1F512}"
			c.note.Text = "Locked"
		elseif view.sap < seed.cost then
			c.button.BackgroundColor3 = Color3.fromRGB(190, 190, 185)
			c.cost.Text = tostring(seed.cost)
			c.note.Text = "need " .. (seed.cost - view.sap)
		else
			c.button.BackgroundColor3 = Theme.PANEL_LIGHT
			c.cost.Text = tostring(seed.cost)
			c.note.Text = ""
		end
	end
end

function SeedBar.init(bundle: any, stateStore: any, root: Instance)
	L = bundle
	store = stateStore
	bar = Components.frame({
		Name = "SeedBar",
		Size = UDim2.fromOffset(6 * (CARD_W + 8), CARD_H),
		Position = UDim2.new(0, 8, 1, -(CARD_H + 8)),
		BackgroundTransparency = 1,
	}, root)
	store.changed:connect(refresh)
	store.selection:connect(refresh)
end

return SeedBar
