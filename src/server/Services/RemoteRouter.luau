--!strict
-- Creates remotes and binds handlers with validation, rate limits and pcall (spec 6.5).
-- Every handler returns { ok, err, data }. The client never sends costs, damage or rewards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Net"):WaitForChild("Remotes")) :: any

local RemoteRouter = {}

type Handler = (player: Player, payload: any) -> (boolean, string?, any)

local L: any = nil
local folder: Folder? = nil
local isReady: (Player) -> boolean = function()
	return true
end
local buckets: { [Player]: { [string]: any } } = {}

function RemoteRouter.init(bundle: any, readyCheck: (Player) -> boolean)
	L = bundle
	isReady = readyCheck
	folder = Remotes.setup()
	Players.PlayerRemoving:Connect(function(player)
		buckets[player] = nil
	end)
end

local function reply(ok: boolean, err: string?, data: any?): any
	return { ok = ok, err = err, data = data }
end

local function takeToken(player: Player, name: string): boolean
	local limit = L.Validate.LIMITS[name]
	if not limit then
		return false
	end
	local mine = buckets[player]
	if not mine then
		mine = {}
		buckets[player] = mine
	end
	local b = mine[name] or L.RateLimit.new(limit.rate, limit.burst)
	local allowed, nb = L.RateLimit.take(b, os.clock())
	mine[name] = nb
	return allowed
end

function RemoteRouter.bind(name: string, handler: Handler)
	assert(folder, "RemoteRouter.init first")
	local rf = folder:FindFirstChild(name) :: RemoteFunction
	assert(rf, "unknown remote " .. name)
	rf.OnServerInvoke = function(player: Player, ...: any): any
		if not isReady(player) then
			return reply(false, "not_ready")
		end
		local args = { ... }
		local okPayload, payload = L.Validate.payload(name, args)
		if not okPayload then
			return reply(false, "bad_payload")
		end
		if not takeToken(player, name) then
			return reply(false, "rate_limited")
		end
		local okCall, ok, err, data = pcall(handler, player, payload)
		if not okCall then
			warn("[SeedSiege] " .. name .. " handler error: " .. tostring(ok))
			return reply(false, "server_error")
		end
		return reply(ok == true, err, data)
	end
end

function RemoteRouter.fire(player: Player, eventName: string, ...: any)
	assert(folder)
	local re = folder:FindFirstChild(eventName) :: RemoteEvent
	re:FireClient(player, ...)
end

return RemoteRouter
