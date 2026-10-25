--!strict
-- A fixed 3/4 tower defence camera like the preview hero (design/preview3d): it sits
-- to the right of the field looking down about 44 degrees, and is fitted (Shared
-- Art.CameraFit) so the whole 12 by 8 grid and the front of the shed fill the screen
-- between the top HUD row and the seed cards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Visuals = require(Shared:WaitForChild("Visuals")) :: any
local CameraFit = require(Shared:WaitForChild("Art"):WaitForChild("CameraFit")) :: any

local CameraController = {}

local L: any = nil
local store: any = nil

local function apply()
	local camera = workspace.CurrentCamera
	if not camera or not store.view then
		return
	end
	local C = L.Constants
	local T = Visuals.TILE
	local o = store.origin
	local w, h = C.GRID_W * T, C.GRID_H * T
	local top = Visuals.TILE_TOP
	local points = {
		o + Vector3.new(0, top, 0), o + Vector3.new(w, top, 0),
		o + Vector3.new(0, top, h), o + Vector3.new(w, top, h),
	}
	-- The front of Nan's shed, past the end of the path.
	local field = L.Fields.byId[store.view.fieldId]
	local last = field and field.waypoints[#field.waypoints]
	if last and (last[1] <= 0 or last[1] >= C.GRID_W - 1) then
		local x = if last[1] <= 0 then -8 else w + 8
		table.insert(points, o + Vector3.new(x, 3, (last[2] + 0.5) * T))
	end
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = CameraFit.FOV
	local vp = camera.ViewportSize
	local aspect = if vp.Y > 0 then vp.X / vp.Y else 16 / 9
	camera.CFrame = CameraFit.fit(points, aspect, Visuals.CAMERA_SAFE, CameraFit.FOV)
	camera.Focus = CFrame.new(o + Vector3.new(w / 2, 0, h / 2))
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
