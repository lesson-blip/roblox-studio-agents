--!strict
-- Top row (hearts, Sap, wave title, bar and pests left, speed, menu), Start wave
-- button and Nan's tip bubble (spec 7.1), styled like the preview HUD
-- (design/preview3d/index.html). Server messages (toasts) are spoken by Nan.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(script.Parent:WaitForChild("Theme")) :: any
local Components = require(script.Parent:WaitForChild("Components")) :: any
local Art = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Art")
local Kit = require(Art:WaitForChild("Kit")) :: any
local Props = require(Art:WaitForChild("Props")) :: any

local Hud = {}

local store: any = nil
local refs: { [string]: any } = {}
local lastSap: number? = nil
local lastHearts: number? = nil
local alive = 0
local toastToken = 0

local function counter(name: string, x: number, w: number, parent: Instance, icon: (Instance, number, UDim2) -> Frame): TextLabel
	local holder, face = Components.pill({ Name = name, Size = UDim2.fromOffset(w, 34), Position = UDim2.fromOffset(x, 6) }, parent, 12)
	icon(face, 24, UDim2.fromOffset(6, 5))
	local value = Components.label("0", {
		Name = "Value",
		Size = UDim2.new(1, -36, 1, 0),
		Position = UDim2.fromOffset(34, 0),
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	}, face)
	Components.textStroke(value, 2)
	local scale = Instance.new("UIScale")
	scale.Parent = holder
	return value
end

local function pulse(label: TextLabel)
	local face = label.Parent
	local holder = face and face.Parent
	local scale = holder and holder:FindFirstChildOfClass("UIScale")
	if not scale then
		return
	end
	scale.Scale = 1.14
	TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

-- Nan's portrait: her head built from Parts in a ViewportFrame.
local function nanFace(parent: Instance): ViewportFrame
	local vp = Instance.new("ViewportFrame")
	vp.Name = "NanFace"
	vp.Size = UDim2.fromScale(1, 1)
	vp.BackgroundColor3 = Color3.fromRGB(245, 201, 140)
	vp.Ambient = Color3.fromRGB(190, 190, 190)
	vp.LightColor = Color3.fromRGB(255, 244, 228)
	vp.LightDirection = Vector3.new(-0.4, -0.6, -1)
	Components.round(vp)
	Components.gradient(vp, Color3.fromRGB(255, 246, 232), Color3.fromRGB(245, 201, 140))
	local model = Instance.new("Model")
	model.Name = "Nan"
	Props.nanHead(Kit.new(model, CFrame.new(), 2))
	model.Parent = vp
	local cam = Instance.new("Camera")
	cam.FieldOfView = 30
	cam.CFrame = CFrame.lookAt(Vector3.new(0.9, 0.5, 5.6), Vector3.new(0, 0.15, 0))
	cam.Parent = vp
	vp.CurrentCamera = cam
	vp.Parent = parent
	return vp
end

-- Nan says something for a few seconds (or keeps an idle tip when `hold`).
function Hud.say(text: string, hold: boolean?)
	local bubble = refs.tip :: Frame
	if not bubble then
		return
	end
	toastToken += 1
	local mine = toastToken
	refs.tipText.Text = text
	bubble.Visible = true
	local s = bubble:FindFirstChildOfClass("UIScale")
	if s then
		s.Scale = 0.85
		TweenService:Create(s, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	if not hold then
		task.delay(3, function()
			if toastToken == mine then
				bubble.Visible = false
			end
		end)
	end
end

function Hud.toast(text: string)
	Hud.say(text, false)
end

local function update(view: any)
	refs.hearts.Text = tostring(view.hearts)
	refs.sap.Text = tostring(view.sap)
	if lastSap ~= nil and lastSap ~= view.sap then
		pulse(refs.sap)
	end
	if lastHearts ~= nil and lastHearts ~= view.hearts then
		pulse(refs.hearts)
	end
	lastSap = view.sap
	lastHearts = view.hearts
	local shownWave = if view.phase == "build" then view.wave + 1 else view.currentWave
	shownWave = math.min(shownWave, view.totalWaves)
	refs.wave.Text = "Wave " .. shownWave .. " / " .. view.totalWaves
	local frac = 0
	if view.phase == "wave" and view.scheduled > 0 then
		frac = view.spawned / view.scheduled
	elseif view.phase == "over" or (view.phase == "build" and view.wave > 0) then
		frac = 1
	end
	refs.bar.Size = UDim2.new(math.clamp(frac, 0.04, 1), 0, 1, 0)
	refs.bar.Visible = frac > 0
	if view.phase == "wave" then
		local left = math.max(0, view.scheduled - view.spawned) + alive
		refs.sub.Text = left .. (if left == 1 then " pest left" else " pests left")
	elseif view.phase == "build" then
		refs.sub.Text = "Plant, then start the wave"
	else
		refs.sub.Text = ""
	end
	refs.speed.Text = (if view.speed == 1.5 then "1.5" else tostring(view.speed)) .. "x"
	local start = refs.start :: TextButton
	start.Visible = view.phase == "build"
	start.Text = "Start wave " .. (view.wave + 1)
end

function Hud.init(stateStore: any, root: Instance)
	store = stateStore
	local top = Components.frame({
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundTransparency = 1,
	}, root)
	refs.hearts = counter("Hearts", 8, 76, top, Components.heart)
	refs.sap = counter("Sap", 92, 92, top, Components.drop)

	-- Wave title, bar and pests left, centred.
	local waveBox = Components.frame({
		Name = "Wave",
		Size = UDim2.fromOffset(200, 62),
		Position = UDim2.new(0.5, -100, 0, 2),
		BackgroundTransparency = 1,
	}, top)
	refs.wave = Components.label("Wave 1 / 10", {
		Size = UDim2.new(1, 0, 0, 28),
		TextSize = 26,
		TextWrapped = false,
	}, waveBox)
	Components.textStroke(refs.wave, 3)
	local barBack = Components.frame({
		Name = "Bar",
		Size = UDim2.fromOffset(170, 12),
		Position = UDim2.new(0.5, -85, 0, 30),
		BackgroundColor3 = Theme.PILL_BOTTOM,
	}, waveBox)
	Components.corner(barBack, 6)
	Components.stroke(barBack, Theme.INK, 2)
	local inner = Components.frame({
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.fromOffset(2, 2),
		BackgroundTransparency = 1,
	}, barBack)
	refs.bar = Components.frame({
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, inner)
	Components.corner(refs.bar, 4)
	Components.gradient(refs.bar, Theme.SAP_TOP, Theme.SAP_BOTTOM)
	refs.sub = Components.label("", {
		Size = UDim2.new(1, 40, 0, 16),
		Position = UDim2.new(0, -20, 0, 45),
		TextSize = 14,
		TextWrapped = false,
	}, waveBox)
	Components.textStroke(refs.sub, 2)

	-- Speed and menu, top right (the player list is turned off in Main, so this is clear).
	refs.speed = Components.button("1x", {
		Name = "Speed",
		Size = UDim2.fromOffset(62, 34),
		Position = UDim2.new(1, -120, 0, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextSize = 20,
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
	local sg = refs.speed:FindFirstChildOfClass("UIGradient")
	if sg then
		sg.Color = ColorSequence.new(Theme.SPEED_TOP, Theme.SPEED_BOTTOM)
	end

	local menu: Frame
	local menuButton = Components.button("", {
		Name = "Menu",
		Size = UDim2.fromOffset(44, 34),
		Position = UDim2.new(1, -52, 0, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, function()
		menu.Visible = not menu.Visible
	end, top)
	local mg = menuButton:FindFirstChildOfClass("UIGradient")
	if mg then
		mg.Color = ColorSequence.new(Theme.MENU_TOP, Theme.PILL_TOP)
	end
	for i = -1, 1 do
		local line = Components.frame({
			Size = UDim2.fromOffset(20, 3),
			Position = UDim2.new(0.5, -10, 0.5, -1 + i * 7),
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, menuButton)
		Components.corner(line, 2)
	end
	refs.menuButton = menuButton
	local menuHolder, menuFace = Components.pill({
		Name = "MenuPanel",
		Size = UDim2.fromOffset(170, 64),
		Position = UDim2.new(1, -178, 0, 48),
		Visible = false,
	}, root, 14)
	menu = menuHolder
	Components.button("Leave run", {
		Size = UDim2.new(1, -16, 0, 44),
		Position = UDim2.fromOffset(8, 10),
		BackgroundColor3 = Theme.WARN,
		ZIndex = 6,
	}, function()
		menu.Visible = false
		store.call("LeaveRun")
	end, menuFace)

	refs.start = Components.button("Start wave 1", {
		Name = "StartWave",
		Size = UDim2.fromOffset(136, 46),
		Position = UDim2.new(1, -144, 1, -56),
		BackgroundColor3 = Color3.new(1, 1, 1),
		TextSize = 20,
	}, function()
		store.clearSelection()
		store.call("StartWave")
	end, root)
	local stg = refs.start:FindFirstChildOfClass("UIGradient")
	if stg then
		stg.Color = ColorSequence.new(Theme.BUTTON_TOP, Theme.BUTTON)
	end

	-- Nan's tip bubble with her portrait, bottom right above the Start button.
	local tip = Components.frame({
		Name = "NanTip",
		Size = UDim2.fromOffset(276, 58),
		Position = UDim2.new(1, -284, 1, -124),
		BackgroundTransparency = 1,
		Visible = false,
	}, root)
	local tipScale = Instance.new("UIScale")
	tipScale.Parent = tip
	local bubbleEdge = Components.frame({
		Size = UDim2.new(1, -62, 1, 0),
		Position = UDim2.fromOffset(0, 3),
		BackgroundColor3 = Theme.INK,
	}, tip)
	Components.corner(bubbleEdge, 14)
	local bubble = Components.frame({
		Name = "Bubble",
		Size = UDim2.new(1, -62, 1, 0),
		BackgroundColor3 = Theme.PANEL_LIGHT,
	}, tip)
	Components.corner(bubble, 14)
	Components.stroke(bubble, Theme.INK, 2)
	Components.label("NAN", {
		Size = UDim2.new(1, -20, 0, 14),
		Position = UDim2.fromOffset(10, 5),
		TextSize = 11,
		TextColor3 = Theme.NAN_NAME,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, bubble)
	refs.tipText = Components.label("", {
		Size = UDim2.new(1, -20, 1, -22),
		Position = UDim2.fromOffset(10, 18),
		TextSize = 14,
		TextColor3 = Theme.TEXT_DARK,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextScaled = true,
	}, bubble)
	local tsz = Instance.new("UITextSizeConstraint")
	tsz.MaxTextSize = 15
	tsz.MinTextSize = 10
	tsz.Parent = refs.tipText
	local faceHolder = Components.frame({
		Name = "Face",
		Size = UDim2.fromOffset(54, 54),
		Position = UDim2.new(1, -54, 0, 2),
		BackgroundColor3 = Theme.INK,
	}, tip)
	Components.round(faceHolder)
	local faceInner = Components.frame({
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.fromOffset(2, 2),
		BackgroundTransparency = 1,
	}, faceHolder)
	nanFace(faceInner)
	refs.tip = tip

	store.changed:connect(update)
	store.toast:connect(Hud.toast)
	store.snapshot:connect(function(snap: any)
		local n = #(snap.pests or {}) // 5
		if n ~= alive then
			alive = n
			if store.view then
				update(store.view)
			end
		end
	end)
end

return Hud
