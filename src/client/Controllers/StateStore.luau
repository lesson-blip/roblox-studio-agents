--!strict
-- Holds what the server last said, plus local selection state, and makes remote calls.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Net"):WaitForChild("Remotes")) :: any
local Visuals = require(Shared:WaitForChild("Visuals")) :: any
local Signal = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("Signal")) :: any

local StateStore = {}

local L: any = nil

StateStore.view = nil :: any -- latest RunUpdated view
StateStore.path = nil :: any -- Grid path of the current field
StateStore.origin = Vector3.zero
StateStore.plotIndex = 0
StateStore.selectedSeed = nil :: string?
StateStore.ghostTile = nil :: { number }?
StateStore.inspectId = nil :: number?
StateStore.isMouse = false

StateStore.changed = Signal.new() -- (view)
StateStore.snapshot = Signal.new() -- (snap, receivedAt)
StateStore.ended = Signal.new() -- (summary)
StateStore.toast = Signal.new() -- (text)
StateStore.selection = Signal.new() -- ()
StateStore.plotReady = Signal.new() -- (plotModel)

local plotModel: Model? = nil

function StateStore.init(bundle: any)
	L = bundle
	Remotes.event("RunUpdated").OnClientEvent:Connect(function(view: any)
		StateStore.applyView(view)
	end)
	Remotes.event("PestSnapshot").OnClientEvent:Connect(function(snap: any)
		StateStore.snapshot:fire(snap, os.clock())
	end)
	Remotes.event("RunEnded").OnClientEvent:Connect(function(summary: any)
		StateStore.ended:fire(summary)
	end)
	Remotes.event("Toast").OnClientEvent:Connect(function(key: string, args: any)
		StateStore.toast:fire(StateStore.message(key, args))
	end)
end

function StateStore.plot(): Model?
	return plotModel
end

function StateStore.applyView(view: any)
	local prevField = StateStore.view and StateStore.view.fieldId
	local prevRun = StateStore.view and StateStore.view.runId
	StateStore.view = view
	if view.fieldId ~= prevField or view.runId ~= prevRun then
		local field = L.Fields.byId[view.fieldId]
		StateStore.path = L.Grid.expandPath(field.waypoints)
		local idx = Players.LocalPlayer:GetAttribute("PlotIndex")
		StateStore.plotIndex = if type(idx) == "number" then idx else 1
		StateStore.origin = Visuals.plotOrigin(StateStore.plotIndex)
		StateStore.clearSelection()
		local plots = workspace:WaitForChild("Plots")
		local model = plots:WaitForChild("Plot" .. StateStore.plotIndex, 10) :: Model?
		if model then
			-- Tiles are built on the server; wait until they have arrived.
			local tiles = model:WaitForChild("Tiles", 10)
			if tiles then
				local want = L.Constants.GRID_W * L.Constants.GRID_H
				local t0 = os.clock()
				while #tiles:GetChildren() < want and os.clock() - t0 < 10 do
					task.wait(0.1)
				end
			end
			plotModel = model
			StateStore.plotReady:fire(model)
		end
	end
	if StateStore.inspectId and not StateStore.plantById(StateStore.inspectId) then
		StateStore.inspectId = nil
		StateStore.selection:fire()
	end
	StateStore.changed:fire(view)
end

function StateStore.plantById(id: number): any?
	local view = StateStore.view
	if not view then
		return nil
	end
	for _, p in view.plants do
		if p.id == id then
			return p
		end
	end
	return nil
end

function StateStore.plantAt(x: number, y: number): any?
	local view = StateStore.view
	if not view then
		return nil
	end
	for _, p in view.plants do
		if p.x == x and p.y == y then
			return p
		end
	end
	return nil
end

function StateStore.clearSelection()
	StateStore.selectedSeed = nil
	StateStore.ghostTile = nil
	StateStore.inspectId = nil
	StateStore.selection:fire()
end

-- Friendly words for server error codes and toasts. Australian English, no dashes.
local MESSAGES: { [string]: string } = {
	no_sap = "Not enough Sap yet.",
	on_path = "Pests walk there. Plant beside the path.",
	tile_taken = "Something is already planted there.",
	out_of_bounds = "That is outside the garden.",
	not_in_loadout = "That seed is not in your bag.",
	locked = "That is still locked.",
	too_many_plants = "Your garden is full.",
	max_level = "That plant is fully grown.",
	no_plant = "That plant is gone.",
	wrong_phase = "Not right now.",
	run_over = "This run has finished.",
	needs_pass = "2x speed comes with Fast Forward (coming soon).",
	rate_limited = "Slow down a little.",
	bad_payload = "Something went wrong. Try again.",
	not_ready = "Still loading your garden.",
	no_plot = "All gardens are busy. Try another server.",
	server_error = "Something went wrong on the server.",
	unlock_burr = "New seed! Burr Vine slows pests. Try a corner.",
	start_failed = "Could not start a run. Tap Play again.",
}

function StateStore.message(key: string, _args: any?): string
	return MESSAGES[key] or key
end

-- Calls a server RemoteFunction and returns { ok, err, data }. Shows a toast on failure.
function StateStore.call(name: string, ...: any): any
	local rf = Remotes.fn(name)
	local okCall, res = pcall(function(...)
		return rf:InvokeServer(...)
	end, ...)
	if not okCall or type(res) ~= "table" then
		StateStore.toast:fire(MESSAGES.server_error)
		return { ok = false, err = "server_error" }
	end
	if not res.ok and res.err and res.err ~= "in_run" then
		StateStore.toast:fire(StateStore.message(res.err))
	end
	return res
end

return StateStore
