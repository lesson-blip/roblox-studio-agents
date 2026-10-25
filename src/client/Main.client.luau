--!strict
-- Client entry: builds the HUD and starts the controllers. The client only sends
-- intents and draws what the server says.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local L = require(Shared:WaitForChild("LogicBundle")) :: any

local Controllers = script.Parent:WaitForChild("Controllers")
local UI = script.Parent:WaitForChild("UI")
local StateStore = require(Controllers:WaitForChild("StateStore")) :: any
local CameraController = require(Controllers:WaitForChild("CameraController")) :: any
local BoardRenderer = require(Controllers:WaitForChild("BoardRenderer")) :: any
local PestRenderer = require(Controllers:WaitForChild("PestRenderer")) :: any
local EffectsController = require(Controllers:WaitForChild("EffectsController")) :: any
local PlacementController = require(Controllers:WaitForChild("PlacementController")) :: any
local Theme = require(UI:WaitForChild("Theme")) :: any
local Hud = require(UI:WaitForChild("Hud")) :: any
local SeedBar = require(UI:WaitForChild("SeedBar")) :: any
local Inspector = require(UI:WaitForChild("Inspector")) :: any
local Results = require(UI:WaitForChild("Results")) :: any

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

-- A single player plot game with no typing (spec 1): the player list, chat window,
-- backpack and emotes would only sit over the HUD. (Owner playtest, M1: the player
-- list hid the speed and menu buttons and the chat notice covered hearts and Sap.)
for _, kind in { Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health } do
	pcall(function()
		StarterGui:SetCoreGuiEnabled(kind, false)
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SeedSiegeHud"
gui.ResetOnSpawn = false
-- Only the device's notch and rounded corners are kept out; the Roblox top bar is
-- kept clear by hand below (CoreUISafeInsets still put the HUD under it in playtest).
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Height of the Roblox top bar (its buttons), in pixels from the top of the screen.
local function topInset(): number
	local inset = GuiService:GetGuiInset()
	local bar = GuiService.TopbarInset
	return math.max(inset.Y, bar.Max.Y, 36) + 6
end

-- One layout for every screen, scaled from the 844 by 390 phone reference (spec 7),
-- measured on the space left under the top bar.
local uiScale = Instance.new("UIScale")
uiScale.Parent = gui
local function rescale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local vp = camera.ViewportSize
	local s = math.min(vp.X / Theme.REF_W, (vp.Y - topInset()) / Theme.REF_H)
	uiScale.Scale = math.clamp(s, 0.7, 1.5)
end
rescale()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)
end

-- With UIScale, children are laid out in a box of the reference size, so the HUD
-- sits in a frame sized by 1 / scale, starting just under the top bar.
local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1, 1)
root.Parent = gui
local function sizeRoot()
	local s = uiScale.Scale
	local top = topInset() / s
	root.Position = UDim2.fromOffset(0, top)
	root.Size = UDim2.new(1 / s, 0, 1 / s, -top)
end
sizeRoot()
uiScale:GetPropertyChangedSignal("Scale"):Connect(sizeRoot)
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
	rescale()
	sizeRoot()
end)

StateStore.init(L)
CameraController.init(L, StateStore)
BoardRenderer.init(L, StateStore)
EffectsController.init(BoardRenderer, PestRenderer)
PestRenderer.init(L, StateStore, EffectsController)
PlacementController.init(StateStore)
Hud.init(StateStore, root)
SeedBar.init(L, StateStore, root)
Inspector.init(L, StateStore, root)
Results.init(L, StateStore, root)

gui.Parent = playerGui

-- The server starts a run on join. This call makes sure we get the current state even
-- if the first update arrived before our listeners were ready ("in_run" is expected).
task.defer(function()
	StateStore.call("RequestStart", "backyard", "normal")
end)
