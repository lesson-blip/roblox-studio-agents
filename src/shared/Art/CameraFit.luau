--!strict
-- Pure camera maths for the fixed 3/4 tower defence view (design/preview3d hero:
-- the camera sits to the right of the field and looks down about 43 degrees).
-- Given world points that must be seen, it finds the camera that frames them
-- inside a safe box of the screen (normalised -1..1, leaving room for the HUD).
-- Used by the client's CameraController and by tools/export-parts.luau.

local CameraFit = {}

export type Safe = { left: number, right: number, bottom: number, top: number }

CameraFit.YAW = math.rad(17) -- camera to the right of the field, looking a little left
CameraFit.PITCH = math.rad(44) -- down from the horizon
CameraFit.FOV = 36 -- vertical field of view, degrees

local function project(cam: CFrame, p: Vector3, tanV: number, tanH: number): (number, number)
	local l = cam:PointToObjectSpace(p)
	local depth = math.max(-l.Z, 0.01)
	return l.X / (depth * tanH), l.Y / (depth * tanV)
end

-- Returns the camera CFrame. `aspect` is width / height.
function CameraFit.fit(points: { Vector3 }, aspect: number, safe: Safe, fovDeg: number?, yaw: number?, pitch: number?): CFrame
	local fov = math.rad(fovDeg or CameraFit.FOV)
	local tanV = math.tan(fov / 2)
	local tanH = tanV * aspect
	local rot = CFrame.Angles(0, yaw or CameraFit.YAW, 0) * CFrame.Angles(-(pitch or CameraFit.PITCH), 0, 0)
	local sum = Vector3.zero
	for _, p in points do
		sum += p
	end
	local target = sum / #points
	local cx, cy = (safe.left + safe.right) / 2, (safe.bottom + safe.top) / 2
	local hw, hh = (safe.right - safe.left) / 2, (safe.top - safe.bottom) / 2

	local function camAt(t: Vector3, d: number): CFrame
		return CFrame.new(t) * rot * CFrame.new(0, 0, d)
	end
	local function bounds(cam: CFrame): (number, number, number, number)
		local x0, x1, y0, y1 = math.huge, -math.huge, math.huge, -math.huge
		for _, p in points do
			local x, y = project(cam, p, tanV, tanH)
			x0, x1 = math.min(x0, x), math.max(x1, x)
			y0, y1 = math.min(y0, y), math.max(y1, y)
		end
		return x0, x1, y0, y1
	end

	local dist = 100
	for _ = 1, 6 do
		-- Closest distance at which the points' spread fits the safe box's size.
		local lo, hi = 5, 2000
		for _ = 1, 40 do
			local mid = (lo + hi) / 2
			local x0, x1, y0, y1 = bounds(camAt(target, mid))
			if (x1 - x0) / 2 <= hw and (y1 - y0) / 2 <= hh then
				hi = mid
			else
				lo = mid
			end
		end
		dist = hi
		-- Slide the target so the points' box sits in the middle of the safe box.
		local cam = camAt(target, dist)
		local x0, x1, y0, y1 = bounds(cam)
		local dx = (x0 + x1) / 2 - cx
		local dy = (y0 + y1) / 2 - cy
		target += cam.RightVector * (dx * dist * tanH) + cam.UpVector * (dy * dist * tanV)
	end
	return camAt(target, dist)
end

return CameraFit
