--!strict
-- Starts the server services in order (spec 6.4, M1 subset). M1: a run starts on join.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local L = require(Shared:WaitForChild("LogicBundle")) :: any

local Services = script.Parent:WaitForChild("Services")
local PlotService = require(Services:WaitForChild("PlotService")) :: any
local RemoteRouter = require(Services:WaitForChild("RemoteRouter")) :: any
local Broadcaster = require(Services:WaitForChild("Broadcaster")) :: any
local RunManager = require(Services:WaitForChild("RunManager")) :: any

local ready: { [Player]: boolean } = {}

PlotService.init(L)
RemoteRouter.init(L, function(player: Player): boolean
	return ready[player] == true
end)
Broadcaster.init(L, RemoteRouter)
RunManager.init(L, PlotService, RemoteRouter, Broadcaster)

local function intent(kind: string)
	return function(player: Player, payload: any): (boolean, string?, any)
		return RunManager.intent(player, kind, payload)
	end
end

RemoteRouter.bind("RequestStart", function(player: Player, payload: any): (boolean, string?, any)
	return RunManager.start({ player }, payload.fieldId, payload.mode)
end)
RemoteRouter.bind("PlaceSeed", intent("place"))
RemoteRouter.bind("UpgradePlant", intent("upgrade"))
RemoteRouter.bind("SellPlant", intent("sell"))
RemoteRouter.bind("SetTargetMode", intent("target"))
RemoteRouter.bind("StartWave", intent("startWave"))
RemoteRouter.bind("SetSpeed", intent("speed"))
RemoteRouter.bind("LeaveRun", intent("leave"))

local function onJoin(player: Player)
	ready[player] = true
	local ok, err = RunManager.start({ player }, "backyard", "normal")
	if not ok then
		RemoteRouter.fire(player, "Toast", "start_failed", { err = err })
	end
end

Players.PlayerAdded:Connect(onJoin)
for _, p in Players:GetPlayers() do
	task.spawn(onJoin, p)
end
Players.PlayerRemoving:Connect(function(player)
	ready[player] = nil
	RunManager.leave(player)
end)

print("[SeedSiege] server ready (M1)")
