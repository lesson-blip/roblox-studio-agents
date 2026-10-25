--!strict
-- Client entry: builds the HUD and starts the controllers. The client only sends
-- intents and draws what the server says.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local gui = Instance.new("ScreenGui")
gui.Name = "SeedSiegeHud"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- One layout for every screen, scaled from the 844 by 390 phone reference (spec 7).
local uiScale = Instance.new("UIScale")
uiScale.Parent = gui
local function rescale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local vp = camera.ViewportSize
	local s = math.min(vp.X / Theme.REF_W, vp.Y / Theme.REF_H)
	uiScale.Scale = math.clamp(s, 0.75, 1.5)
end
rescale()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)
end

-- With UIScale, children are laid out in a box of the reference size, so the HUD
-- sits in a full screen frame sized by 1 / scale.
local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1, 1)
root.Parent = gui
local function sizeRoot()
	local s = uiScale.Scale
	root.Size = UDim2.fromScale(1 / s, 1 / s)
end
sizeRoot()
uiScale:GetPropertyChangedSignal("Scale"):Connect(sizeRoot)

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
