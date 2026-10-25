--!strict
-- Builds plots from plain Parts and hands them out (spec 6.4). M1 uses one plot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Visuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Visuals")) :: any

local PlotService = {}

local L: any = nil
local PLOT_COUNT = 1 -- M2 raises this to 4
local owners: { [number]: boolean } = {}
local plotsFolder: Folder? = nil

function PlotService.init(bundle: any)
	L = bundle
	local folder = workspace:FindFirstChild("Plots") :: Folder?
	if not folder then
		local f = Instance.new("Folder")
		f.Name = "Plots"
		f.Parent = workspace
		folder = f
	end
	plotsFolder = folder
end

function PlotService.claim(): number?
	for i = 1, PLOT_COUNT do
		if not owners[i] then
			owners[i] = true
			return i
		end
	end
	return nil
end

function PlotService.release(plotIndex: number)
	owners[plotIndex] = nil
end

function PlotService.tileToWorld(plotIndex: number, x: number, y: number): Vector3
	return Visuals.tileCentre(Visuals.plotOrigin(plotIndex), x, y, 0)
end

local function part(props: { [string]: any }, parent: Instance): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

-- Builds (or rebuilds) the board for a field on a plot.
function PlotService.build(plotIndex: number, field: any): Model
	assert(plotsFolder, "PlotService.init first")
	local name = "Plot" .. plotIndex
	local old = plotsFolder:FindFirstChild(name)
	if old then
		old:Destroy()
	end
	local C = L.Constants
	local T = Visuals.TILE
	local origin = Visuals.plotOrigin(plotIndex)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("PlotIndex", plotIndex)
	model:SetAttribute("FieldId", field.id)

	local w, h = C.GRID_W * T, C.GRID_H * T
	local ground = part({
		Name = "Ground",
		Size = Vector3.new(w + 16, 1, h + 16),
		Position = origin + Vector3.new(w / 2, -0.6, h / 2),
		Color = Visuals.GROUND,
		Material = Enum.Material.Grass,
		CanCollide = true,
	}, model)
	model.PrimaryPart = ground

	local path = L.Grid.expandPath(field.waypoints)
	local tiles = Instance.new("Folder")
	tiles.Name = "Tiles"
	tiles.Parent = model
	for y = 0, C.GRID_H - 1 do
		for x = 0, C.GRID_W - 1 do
			local isPath = L.Grid.isPathTile(path, x, y)
			local alt = (x + y) % 2 == 0
			local t = part({
				Name = "T_" .. x .. "_" .. y,
				Size = Vector3.new(T - 0.2, 0.4, T - 0.2),
				Position = Visuals.tileCentre(origin, x, y, -0.05),
				Color = if isPath then Visuals.TILE_PATH elseif alt then Visuals.TILE_PLANTABLE else Visuals.TILE_PLANTABLE_ALT,
				Material = if isPath then Enum.Material.Sand else Enum.Material.Grass,
				CanQuery = true,
			}, tiles)
			t:SetAttribute("X", x)
			t:SetAttribute("Y", y)
			t:SetAttribute("IsPath", isPath)
		end
	end

	-- Gate before the first waypoint and shed after the last, along the path direction.
	local wps = field.waypoints
	local function beyond(a: { number }, b: { number }): (number, number)
		local dx = math.sign(a[1] - b[1])
		local dy = math.sign(a[2] - b[2])
		return a[1] + dx, a[2] + dy
	end
	local gx, gy = beyond(wps[1], wps[2])
	part({
		Name = "Gate",
		Size = Vector3.new(T * 0.9, 3, T * 0.9),
		Position = Visuals.tileCentre(origin, gx, gy, 1.5),
		Color = Visuals.GATE,
		Material = Enum.Material.WoodPlanks,
	}, model)
	local sx, sy = beyond(wps[#wps], wps[#wps - 1])
	part({
		Name = "Shed",
		Size = Vector3.new(T * 1.2, 5, T * 1.2),
		Position = Visuals.tileCentre(origin, sx, sy, 2.5),
		Color = Visuals.SHED,
		Material = Enum.Material.WoodPlanks,
	}, model)
	part({
		Name = "ShedRoof",
		Size = Vector3.new(T * 1.4, 1, T * 1.4),
		Position = Visuals.tileCentre(origin, sx, sy, 5.5),
		Color = Color3.fromRGB(90, 60, 50),
	}, model)

	model.Parent = plotsFolder
	return model
end

return PlotService
