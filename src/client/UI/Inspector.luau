--!strict
-- Shows a planted plant in place of the seed bar (spec 7.2): name, level, stats and
-- Upgrade, Sell (or Undo) and Target buttons. Prices come from the server view.

local Theme = require(script.Parent:WaitForChild("Theme")) :: any
local Components = require(script.Parent:WaitForChild("Components")) :: any

local Inspector = {}

local L: any = nil
local store: any = nil
local panel: Frame? = nil
local refs: { [string]: any } = {}

local MODE_NAMES: { [string]: string } = { first = "First", strong = "Strong", last = "Last", close = "Close" }
local NEXT_MODE: { [string]: string } = { first = "strong", strong = "last", last = "close", close = "first" }

local function fmt(n: number): string
	if n == math.floor(n) then
		return tostring(n)
	end
	return string.format("%.1f", n)
end

local function refresh()
	if not panel then
		return
	end
	local p = if store.inspectId then store.plantById(store.inspectId) else nil
	local view = store.view
	panel.Visible = p ~= nil and view ~= nil and view.phase ~= "over"
	if not p or not view then
		return
	end
	local seed = L.Seeds.byId[p.seed]
	local C = L.Constants
	refs.name.Text = seed.name .. "   Level " .. p.level .. " of 3"
	local stats: string
	if seed.rate > 0 then
		local dmg = seed.damage * C.LEVEL_DMG[p.level]
		local range = seed.range + C.LEVEL_RANGE_BONUS[p.level]
		stats = "Damage " .. fmt(dmg) .. "   Range " .. fmt(range) .. "   Rate " .. fmt(seed.rate) .. "/s"
	elseif seed.income then
		stats = "Pays " .. seed.income[p.level] .. " Sap each wave"
	else
		stats = "Range " .. fmt(seed.range)
	end
	if p.growth > 0 then
		stats ..= "   Grows in " .. p.growth .. (if p.growth == 1 then " wave" else " waves")
	end
	refs.stats.Text = stats
	refs.special.Text = seed.special .. (if seed.air then "   Hits flying pests" else "")
	local up = refs.upgrade :: TextButton
	if p.upgradeCost then
		up.Text = "Upgrade " .. p.upgradeCost
		up.BackgroundColor3 = if view.sap >= p.upgradeCost then Theme.BUTTON else Theme.GREY
	else
		up.Text = "Max level"
		up.BackgroundColor3 = Theme.GREY
	end
	refs.sell.Text = if p.canUndo then "Undo +" .. p.sellValue else "Sell +" .. p.sellValue
	refs.target.Text = "Target: " .. (MODE_NAMES[p.mode] or p.mode)
	refs.target.Visible = seed.rate > 0
end

function Inspector.init(bundle: any, stateStore: any, root: Instance)
	L = bundle
	store = stateStore
	local holder, f = Components.pill({
		Name = "Inspector",
		Size = UDim2.fromOffset(470, 104),
		Position = UDim2.new(0, 8, 1, -114),
		Visible = false,
	}, root, 14)
	panel = holder
	refs.name = Components.label("", {
		Size = UDim2.new(1, -60, 0, 24),
		Position = UDim2.fromOffset(12, 4),
		Font = Theme.FONT_HEAD,
		TextSize = Theme.TEXT_NUMBER,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, f)
	refs.stats = Components.label("", {
		Size = UDim2.new(1, -24, 0, 18),
		Position = UDim2.fromOffset(12, 28),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, f)
	refs.special = Components.label("", {
		Size = UDim2.new(1, -24, 0, 18),
		Position = UDim2.fromOffset(12, 46),
		Font = Theme.FONT_BODY,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, f)
	local function act(remote: string, ...: any)
		local id = store.inspectId
		if id then
			store.call(remote, id, ...)
		end
	end
	refs.upgrade = Components.button("Upgrade", {
		Size = UDim2.fromOffset(140, 36),
		Position = UDim2.fromOffset(12, 64),
		TextSize = Theme.TEXT_MIN + 2,
	}, function()
		act("UpgradePlant")
	end, f)
	refs.sell = Components.button("Sell", {
		Size = UDim2.fromOffset(120, 36),
		Position = UDim2.fromOffset(160, 64),
		BackgroundColor3 = Theme.WARN,
		TextSize = Theme.TEXT_MIN + 2,
	}, function()
		local id = store.inspectId
		if id then
			local res = store.call("SellPlant", id)
			if res.ok then
				store.inspectId = nil
				store.selection:fire()
			end
		end
	end, f)
	refs.target = Components.button("Target: First", {
		Size = UDim2.fromOffset(170, 36),
		Position = UDim2.fromOffset(288, 64),
		BackgroundColor3 = Theme.BUTTON_ALT,
		TextSize = Theme.TEXT_MIN + 2,
	}, function()
		local p = if store.inspectId then store.plantById(store.inspectId) else nil
		if p then
			act("SetTargetMode", NEXT_MODE[p.mode] or "first")
		end
	end, f)
	Components.button("X", {
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.new(1, -52, 0, -4),
		BackgroundColor3 = Theme.BUTTON_ALT,
	}, function()
		store.inspectId = nil
		store.selection:fire()
	end, f)
	store.changed:connect(refresh)
	store.selection:connect(refresh)
end

return Inspector
