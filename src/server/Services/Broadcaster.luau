--!strict
-- Sends run state to that run's players only (spec 6.4): RunUpdated when something
-- changed (at most 10 a second) and PestSnapshot 5 times a second during waves.

local Broadcaster = {}

local L: any = nil
local Router: any = nil
local PUSH_GAP = 0.1
local SNAP_GAP = 0.2
local MAX_SHOTS = 40 -- shot pairs per snapshot, to keep the message small

function Broadcaster.init(bundle: any, router: any)
	L = bundle
	Router = router
end

function Broadcaster.view(run: any): any
	return L.Views.runView(run.sim:getState(), {
		runId = run.runId,
		speed = run.speed,
		loadout = run.loadout,
		locked = run.locked,
	})
end

function Broadcaster.push(run: any, now: number, force: boolean?)
	if not force and (not run.dirty or now - run.lastPush < PUSH_GAP) then
		return
	end
	run.dirty = false
	run.lastPush = now
	local view = Broadcaster.view(run)
	for _, player in run.players do
		Router.fire(player, "RunUpdated", view)
	end
end

function Broadcaster.snapshot(run: any, now: number, force: boolean?)
	if not force and now - run.lastSnap < SNAP_GAP then
		return
	end
	run.lastSnap = now
	local shots = run.shots
	if #shots > MAX_SHOTS * 2 then
		shots = table.move(shots, #shots - MAX_SHOTS * 2 + 1, #shots, 1, {})
	end
	local snap = L.Views.pestSnapshot(run.sim:getState(), shots, run.gone, run.sapPops, run.sim.totalTicks)
	run.shots = {}
	run.gone = {}
	run.sapPops = {}
	for _, player in run.players do
		Router.fire(player, "PestSnapshot", snap)
	end
end

return Broadcaster
