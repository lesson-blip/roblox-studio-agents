--!strict
-- A fixed camera looking down over the plot, sized so the whole 12 by 8 grid fits
-- between the HUD bars on a phone held sideways.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Visuals")) :: any

local CameraController = {}

local L: any = nil
local store: any = nil
local TILT = math.rad(58) -- angle down from the horizon
local MARGIN = 1.35 -- leaves room for the top HUD and the seed bar

local function apply()
	local camera = workspace.CurrentCamera
	if not camera or not store.view then
		return
	end
	local C = L.Constants
	local T = Visuals.TILE
	local w, h = C.GRID_W * T + 4, C.GRID_H * T + 4
	local centre = Visuals.toWorld(store.origin, C.GRID_W / 2, C.GRID_H / 2 + 0.3, 0)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 40
	local vp = camera.ViewportSize
	local aspect = if vp.Y > 0 then vp.X / vp.Y else 16 / 9
	local vfov = math.rad(camera.FieldOfView)
	local hfov = 2 * math.atan(math.tan(vfov / 2) * aspect)
	local fitW = (w / 2) / math.tan(hfov / 2)
	-- The plot's depth seen at the tilt angle.
	local fitH = (h * math.sin(TILT) / 2) / math.tan(vfov / 2) + h * math.cos(TILT) / 2
	local dist = math.max(fitW, fitH) * MARGIN
	local offset = Vector3.new(0, math.sin(TILT), math.cos(TILT)) * dist
	camera.CFrame = CFrame.lookAt(centre + offset, centre)
end

function CameraController.init(bundle: any, stateStore: any)
	L = bundle
	store = stateStore
	store.plotReady:connect(apply)
	store.changed:connect(function()
		local camera = workspace.CurrentCamera
		if camera and camera.CameraType ~= Enum.CameraType.Scriptable then
			apply()
		end
	end)
	local function hook()
		local camera = workspace.CurrentCamera
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply)
		end
	end
	hook()
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		hook()
		apply()
	end)
end

return CameraController
