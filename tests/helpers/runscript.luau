--!strict
-- Plays a reference build order through WaveSim, the way the prototype does:
-- before each wave, take steps in order while they succeed; a step that cannot be
-- afforded waits (never skips). Unlock rules are ignored; the loadout is respected.

local L = require("../bundle")

export type Result = { won: boolean, waveReached: number, hearts: number, sim: any, events: { any } }

-- opts = { bonuses?, hpExtra?, ticksPerFrame?, keepEvents? }
local function run(script: any, opts: any?): Result
	local o = opts or {}
	local field = L.Fields.byId[script.field]
	local sim = L.WaveSim.new({
		field = field,
		bonuses = o.bonuses,
		loadout = script.loadout,
		hpExtra = o.hpExtra or 1,
	})
	local events: { any } = {}
	local queue = table.clone(script.steps)
	local tpf = o.ticksPerFrame or 1
	while sim.phase == "build" do
		while #queue > 0 do
			local st = queue[1]
			local ok, err
			if st[1] == "p" then
				ok, err = sim:place(st[2], st[3], st[4])
			else
				local p = sim:plantAt(st[2], st[3])
				if not p then
					error("no plant at " .. st[2] .. "," .. st[3])
				end
				ok, err = sim:upgrade(p.id)
			end
			if ok then
				table.remove(queue, 1)
			elseif err == "no_sap" then
				break
			else
				error("script step failed: " .. tostring(err))
			end
		end
		sim:startWave()
		-- Frames of `tpf` ticks each; nothing is done between frames during a wave.
		local guard = 0
		while sim.phase == "wave" do
			for _ = 1, tpf do
				if sim.phase ~= "wave" then
					break
				end
				sim:step()
			end
			guard += 1
			if guard > 100000 then
				error("wave did not end")
			end
		end
		if o.keepEvents then
			for _, e in sim:drainEvents() do
				table.insert(events, e)
			end
		else
			sim:drainEvents()
		end
	end
	local won = sim.result == "won"
	return {
		won = won,
		-- On a loss, the wave that was being played (1 based), as in the prototype's "lose wave N".
		waveReached = if won then sim.wave else sim.wave + 1,
		hearts = sim.hearts,
		sim = sim,
		events = events,
	}
end

return { run = run }
