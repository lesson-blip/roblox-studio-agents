--!strict
-- The only shapes sent to clients (spec 6.3 "Views"). Pure.

local L: any = nil
local Views = {}

function Views.bind(bundle: any)
	L = bundle
end

-- run = { runId, fieldId, speed, loadout = { seedIds }, locked = { [seedId] = reason } }
function Views.runView(state: any, run: any): any
	local plants = {}
	for i, p in state.plants do
		local undo = p.canUndo == true
		plants[i] = {
			id = p.id,
			seed = p.seed,
			x = p.x,
			y = p.y,
			level = p.level,
			growth = p.growth,
			mode = p.mode,
			upgradeCost = L.Economy.upgradeCost(p.seed, p.level),
			sellValue = L.Economy.sellValue(p.spent, undo),
			canUndo = undo,
		}
	end
	local loadout = {}
	for i, id in run.loadout or {} do
		loadout[i] = {
			id = id,
			cost = L.Seeds.byId[id].cost,
			locked = if run.locked then run.locked[id] else nil,
		}
	end
	return {
		runId = run.runId,
		fieldId = state.fieldId,
		phase = state.phase,
		wave = state.wave,
		currentWave = if state.phase == "wave" or state.phase == "lostPending" then state.wave + 1 else state.wave,
		totalWaves = state.totalWaves,
		hearts = math.max(0, state.hearts),
		sap = state.sap,
		speed = run.speed or 1,
		plants = plants,
		loadout = loadout,
		spawned = state.spawned,
		scheduled = state.scheduled,
		result = state.result,
		secondWind = {
			allowed = state.secondWindAllowed and not state.secondWindUsed,
		},
	}
end

-- Packs pests into flat arrays: { id, typeIndex, dCenti, hpPercent, flags } per pest.
-- flags: 1 hidden, 2 slowed, 4 burning.
function Views.pestSnapshot(state: any, shots: { number }?, gone: { number }?, sap: { number }?, serverTick: number): any
	local packed = {}
	for _, e in state.pests do
		local flags = 0
		if e.hidden then
			flags += 1
		end
		if e.slowed then
			flags += 2
		end
		if e.burning then
			flags += 4
		end
		local pct = if e.maxHp > 0 then math.clamp(math.ceil(e.hp / e.maxHp * 100), 0, 100) else 0
		table.insert(packed, e.id)
		table.insert(packed, L.Pests.index[e.type])
		table.insert(packed, math.floor(e.d * 100))
		table.insert(packed, pct)
		table.insert(packed, flags)
	end
	return {
		pests = packed,
		shots = shots or {},
		gone = gone or {},
		sap = sap or {},
		serverTick = serverTick,
	}
end

-- Reads a packed snapshot back into rows (used by the client and tests).
function Views.unpackPests(packed: { number }): { any }
	local rows = {}
	for i = 1, #packed, 5 do
		table.insert(rows, {
			id = packed[i],
			typeIndex = packed[i + 1],
			d = packed[i + 2] / 100,
			hpPercent = packed[i + 3],
			hidden = bit32.band(packed[i + 4], 1) ~= 0,
			slowed = bit32.band(packed[i + 4], 2) ~= 0,
			burning = bit32.band(packed[i + 4], 4) ~= 0,
		})
	end
	return rows
end

return Views
