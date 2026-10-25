--!strict
-- Top bar (hearts, Sap, wave and progress, speed, menu), Start wave button and toasts (spec 7.1).

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent:WaitForChild("Theme")) :: any
local Components = require(script.Parent:WaitForChild("Components")) :: any

local Hud = {}

local store: any = nil
local refs: { [string]: any } = {}
local lastSap: number? = nil
local toastToken = 0

local function chip(name: string, icon: string, color: Color3, x: number, parent: Instance): TextLabel
	local f = Components.frame({
		Name = name,
		Size = UDim2.fromOffset(96, 40),
		Position = UDim2.fromOffset(x, 8),
	}, parent)
	Components.corner(f, 12)
	Components.label(icon, {
		Size = UDim2.fromOffset(30, 40),
		Position = UDim2.fromOffset(6, 0),
		TextColor3 = color,
		TextSize = 20,
		Font = Theme.FONT_HEAD,
	}, f)
	local value = Components.label("0", {
		Name = "Value",
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.fromOffset(36, 0),
		TextSize = Theme.TEXT_NUMBER,
		Font = Theme.FONT_HEAD,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, f)
	local scale = Instance.new("UIScale")
	scale.Parent = f
	return value
end

local function pulse(label: TextLabel)
	local frame = label.Parent
	local scale = frame and frame:FindFirstChildOfClass("UIScale")
	if not scale then
		return
	end
	scale.Scale = 1.12
	TweenService:Create(scale, TweenInfo.new(0.2), { Scale = 1 }):Play()
end

function Hud.toast(text: string)
	local t = refs.toast :: TextLabel
	if not t then
		return
	end
	toastToken += 1
	local mine = toastToken
	t.Text = text
	t.Visible = true
	task.delay(2.5, function()
		if toastToken == mine then
			t.Visible = false
		end
	end)
end

local function update(view: any)
	refs.hearts.Text = tostring(view.hearts)
	refs.sap.Text = tostring(view.sap)
	if lastSap ~= nil and lastSap ~= view.sap then
		pulse(refs.sap)
	end
	lastSap = view.sap
	local shownWave = if view.phase == "build" then view.wave + 1 else view.currentWave
	shownWave = math.min(shownWave, view.totalWaves)
	refs.wave.Text = "Wave " .. shownWave .. " / " .. view.totalWaves
	local frac = 0
	if view.phase == "wave" and view.scheduled > 0 then
		frac = view.spawned / view.scheduled
	elseif view.phase == "over" or (view.phase == "build" and view.wave > 0) then
		frac = 1
	end
	refs.bar.Size = UDim2.fromScale(frac, 1)
	refs.speed.Text = (if view.speed == 1.5 then "1.5" else tostring(view.speed)) .. "x"
	local start = refs.start :: TextButton
	start.Visible = view.phase == "build"
	start.Text = "Start wave " .. (view.wave + 1)
end

function Hud.init(stateStore: any, root: Instance)
	store = stateStore
	local top = Components.frame({
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
	}, root)
	refs.hearts = chip("Hearts", "\u{2665}", Theme.HEART, 8, top)
	refs.sap = chip("Sap", "\u{25CF}", Theme.SAP, 112, top)

	local waveBox = Components.frame({
		Name = "Wave",
		Size = UDim2.fromOffset(200, 48),
		Position = UDim2.new(0.5, -100, 0, 6),
	}, top)
	Components.corner(waveBox, 12)
	refs.wave = Components.label("Wave 1 / 10", {
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.fromOffset(0, 2),
		Font = Theme.FONT_HEAD,
		TextSize = Theme.TEXT_NUMBER,
	}, waveBox)
	local barBack = Components.frame({
		Size = UDim2.new(1, -24, 0, 8),
		Position = UDim2.fromOffset(12, 32),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.3,
	}, waveBox)
	Components.corner(barBack, 4)
	refs.bar = Components.frame({
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.SAP,
		BackgroundTransparency = 0,
	}, barBack)
	Components.corner(refs.bar, 4)

	refs.speed = Components.button("1x", {
		Name = "Speed",
		Size = UDim2.fromOffset(56, 48),
		Position = UDim2.new(1, -128, 0, 6),
	}, function()
		local view = store.view
		if not view then
			return
		end
		-- Cycles 1x, 1.5x, 2x. 2x is locked until Fast Forward exists (M4).
		local nextSpeed = if view.speed == 1 then 1.5 elseif view.speed == 1.5 then 2 else 1
		local res = store.call("SetSpeed", nextSpeed)
		if not res.ok and nextSpeed == 2 then
			store.call("SetSpeed", 1)
		end
	end, top)

	local menu: Frame
	refs.menuButton = Components.button("\u{2261}", {
		Name = "Menu",
		Size = UDim2.fromOffset(56, 48),
		Position = UDim2.new(1, -64, 0, 6),
		BackgroundColor3 = Theme.BUTTON_ALT,
		TextSize = 26,
	}, function()
		menu.Visible = not menu.Visible
	end, top)
	menu = Components.frame({
		Name = "MenuPanel",
		Size = UDim2.fromOffset(170, 64),
		Position = UDim2.new(1, -178, 0, 60),
		Visible = false,
	}, root)
	Components.corner(menu, 12)
	Components.button("Leave run", {
		Size = UDim2.new(1, -16, 0, 48),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.WARN,
	}, function()
		menu.Visible = false
		store.call("LeaveRun")
	end, menu)

	refs.start = Components.button("Start wave 1", {
		Name = "StartWave",
		Size = UDim2.fromOffset(140, 56),
		Position = UDim2.new(1, -148, 1, -64),
	}, function()
		store.clearSelection()
		store.call("StartWave")
	end, root)

	refs.toast = Components.label("", {
		Name = "Toast",
		Size = UDim2.fromOffset(360, 36),
		Position = UDim2.new(0.5, -180, 0, 62),
		BackgroundTransparency = 0.2,
		BackgroundColor3 = Theme.PANEL,
		TextSize = Theme.TEXT_MIN + 2,
		Visible = false,
	}, root)
	Components.corner(refs.toast, 10)

	store.changed:connect(update)
	store.toast:connect(Hud.toast)
end

return Hud
