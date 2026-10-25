--!strict
-- One run per plot (spec 6.4). Owns the WaveSim, runs the tick loop on Heartbeat,
-- applies intents and ends runs. M1: solo, Backyard Patch only, no saves.

local RunService = game:GetService("RunService")

local RunManager = {}

local L: any = nil
local Plots: any = nil
local Router: any = nil
local Broadcaster: any = nil

local MAX_TICKS_PER_FRAME = 6
local M1_LOADOUT = { "thorn", "sunpetal", "burr" }
local BURR_LOCK_TEXT = "Clear wave 3"

local runs: { [number]: any } = {} -- by plot index
local byPlayer: { [Player]: any } = {}
local nextRunId = 1

function RunManager.init(bundle: any, plots: any, router: any, broadcaster: any)
	L = bundle
	Plots = plots
	Router = router
	Broadcaster = broadcaster
	RunService.Heartbeat:Connect(RunManager.onHeartbeat)
end

function RunManager.runOf(player: Player): any?
	return byPlayer[player]
end

local function isActive(run: any): boolean
	return run.sim.phase ~= "over"
end

-- Starts a run for these players. M1 checks: Backyard Patch, normal mode only.
function RunManager.start(players: { Player }, fieldId: string, mode: string): (boolean, string?, any)
	local field = L.Fields.byId[fieldId]
	if not field then
		return false, "bad_field"
	end
	if mode ~= "normal" or fieldId ~= "backyard" then
		return false, "locked" -- other fields and modes open in M2 and M3
	end
	local plotIndex: number? = nil
	for _, p in players do
		local old = byPlayer[p]
		if old then
			if isActive(old) then
				-- Resend the state so a client that loaded late is in sync.
				old.dirty = true
				Broadcaster.push(old, os.clock(), true)
				return false, "in_run"
			end
			plotIndex = old.plotIndex -- reuse the plot of a finished run
		end
	end
	if plotIndex == nil then
		plotIndex = Plots.claim()
	end
	if plotIndex == nil then
		return false, "no_plot"
	end
	Plots.build(plotIndex, field)
	local sim = L.WaveSim.new({
		field = field,
		modifiers = {},
		bonuses = L.Constants.NO_BONUSES, -- research arrives in M2
		loadout = M1_LOADOUT,
		hpExtra = 1,
		weekly = false,
		secondWindAllowed = false, -- Second Wind arrives in M2 and M4
	})
	local run = {
		runId = nextRunId,
		plotIndex = plotIndex,
		fieldId = fieldId,
		mode = mode,
		players = table.clone(players),
		sim = sim,
		speed = 1,
		acc = 0,
		loadout = table.clone(M1_LOADOUT),
		locked = { burr = BURR_LOCK_TEXT },
		dirty = true,
		lastPush = -1,
		lastSnap = -1,
		shots = {},
		gone = {},
		sapPops = {},
		leaks = {},
		ended = false,
	}
	nextRunId += 1
	runs[plotIndex] = run
	for _, p in players do
		byPlayer[p] = run
		p:SetAttribute("PlotIndex", plotIndex)
	end
	Broadcaster.push(run, os.clock(), true)
	Broadcaster.snapshot(run, os.clock(), true)
	return true, nil, { runId = run.runId, plotIndex = plotIndex }
end

local function mostLeaked(run: any): string?
	local best, bestN = nil, 0
	for pestId, n in run.leaks do
		if n > bestN then
			best, bestN = pestId, n
		end
	end
	return best
end

local function finish(run: any)
	if run.ended then
		return
	end
	run.ended = true
	local sim = run.sim
	local summary = {
		runId = run.runId,
		fieldId = run.fieldId,
		won = sim.result == "won",
		wavesCleared = sim.wave,
		totalWaves = sim.totalWaves,
		heartsLeft = math.max(0, sim.hearts),
		mostLeaked = mostLeaked(run),
	}
	Broadcaster.push(run, os.clock(), true)
	Broadcaster.snapshot(run, os.clock(), true)
	for _, p in run.players do
		Router.fire(p, "RunEnded", summary)
	end
end

-- Reads the sim's events into what the Broadcaster sends.
local function absorbEvents(run: any)
	for _, e in run.sim:drainEvents() do
		local k = e.kind
		if k == "shot" then
			table.insert(run.shots, e.plant)
			table.insert(run.shots, e.pest)
		elseif k == "defeated" then
			table.insert(run.gone, e.pest)
			table.insert(run.sapPops, e.pest)
			table.insert(run.sapPops, e.reward)
			run.dirty = true
		elseif k == "leaked" then
			table.insert(run.gone, e.pest)
			run.leaks[e.type] = (run.leaks[e.type] or 0) + e.leak
			run.dirty = true
		elseif k == "waveEnded" then
			run.dirty = true
			-- Mid run unlock (spec 3.2): Burr Vine once wave 3 is cleared.
			if e.wave >= 3 and run.locked.burr then
				run.locked.burr = nil
				for _, p in run.players do
					Router.fire(p, "Toast", "unlock_burr", {})
				end
			end
		elseif k == "runEnded" then
			run.dirty = true
		else
			run.dirty = true
		end
	end
end

function RunManager.onHeartbeat(dt: number)
	local now = os.clock()
	for _, run in runs do
		local sim = run.sim
		if sim.phase == "wave" then
			run.acc += dt * (1 / L.Constants.TICK) * run.speed
			local n = math.min(math.floor(run.acc), MAX_TICKS_PER_FRAME)
			run.acc = math.min(run.acc - n, MAX_TICKS_PER_FRAME)
			for _ = 1, n do
				sim:step()
				if sim.phase ~= "wave" then
					run.acc = 0
					break
				end
			end
			absorbEvents(run)
			Broadcaster.snapshot(run, now, sim.phase ~= "wave")
		else
			absorbEvents(run)
		end
		Broadcaster.push(run, now)
		if sim.phase == "over" and not run.ended then
			finish(run)
		end
	end
end

-- Applies one validated intent. Returns ok, err, data.
function RunManager.intent(player: Player, kind: string, args: any): (boolean, string?, any)
	local run = byPlayer[player]
	if not run then
		return false, "no_run"
	end
	local sim = run.sim
	local ok, res
	if kind == "place" then
		if run.locked[args.seedId] then
			return false, "locked"
		end
		ok, res = sim:place(args.seedId, args.x, args.y)
	elseif kind == "upgrade" then
		ok, res = sim:upgrade(args.plantId)
	elseif kind == "sell" then
		ok, res = sim:sell(args.plantId)
	elseif kind == "target" then
		ok, res = sim:setTargetMode(args.plantId, args.mode)
	elseif kind == "startWave" then
		ok, res = sim:startWave()
	elseif kind == "speed" then
		if args.speed == 2 then
			return false, "needs_pass" -- Fast Forward arrives in M4
		end
		run.speed = args.speed
		run.dirty = true
		return true, nil, args.speed
	elseif kind == "leave" then
		if sim.phase == "over" then
			return false, "run_over"
		end
		sim:giveUp()
		ok, res = true, nil
	else
		return false, "bad_payload"
	end
	absorbEvents(run)
	if ok then
		run.dirty = true
		Broadcaster.push(run, os.clock(), true)
		return true, nil, res
	end
	return false, res
end

function RunManager.leave(player: Player)
	local run = byPlayer[player]
	byPlayer[player] = nil
	if not run then
		return
	end
	local idx = table.find(run.players, player)
	if idx then
		table.remove(run.players, idx)
	end
	if #run.players == 0 then
		runs[run.plotIndex] = nil
		Plots.release(run.plotIndex)
	end
end

return RunManager
