--!strict
-- Builds plots (the field's tiles and Nan's backyard, all plain Parts) and hands them
-- out (spec 6.4). M1 uses one plot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Visuals = require(Shared:WaitForChild("Visuals")) :: any
local Garden = require(Shared:WaitForChild("Art"):WaitForChild("Garden")) :: any

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

-- Builds (or rebuilds) the board for a field on a plot: the 96 tiles the game uses
-- plus the backyard around them (Shared.Art.Garden, all plain Parts).
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

	local path = L.Grid.expandPath(field.waypoints)
	local centre = origin + Vector3.new(C.GRID_W * T / 2, 0, C.GRID_H * T / 2)
	local info = Garden.build(model, centre, C.GRID_W, C.GRID_H, field.waypoints, function(x: number, y: number): boolean
		return L.Grid.isPathTile(path, x, y)
	end, Visuals.BEDS)
	model:SetAttribute("PartCount", info.parts)
	local ground = info.decor:FindFirstChild("Ground")
	if ground and ground:IsA("BasePart") then
		model.PrimaryPart = ground
	end

	model.Parent = plotsFolder
	return model
end

return PlotService
