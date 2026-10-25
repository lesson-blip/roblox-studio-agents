--!strict
-- WaveSim rules, one by one (spec 3.1), plus determinism and speed.
local L = require("./bundle")
local A = require("./assert")
local S = require("./fixtures/scripts")
local R = require("./helpers/runscript")

-- A test field: a straight path along row 0, from (0,0) to (11,0). Length 11.
local function lineField(waves: { any }, startSap: number?): any
	return {
		id = "test",
		name = "Test",
		waypoints = { { 0, 0 }, { 11, 0 } },
		startSap = startSap or 1000,
		hpScale = 1,
		waves = waves,
	}
end

local function one(pest: string, count: number?, gap: number?): { any }
	return { { pest = pest, count = count or 1, gap = gap or 1, start = 0 } }
end

local function newSim(waves: { any }, extra: any?): any
	local cfg = { field = lineField(waves, extra and extra.startSap) }
	if extra then
		for k, v in extra do
			if k ~= "startSap" then
				cfg[k] = v
			end
		end
	end
	return L.WaveSim.new(cfg)
end

local function hashEvents(events: { any }): string
	local h = 2166136261
	local function feed(s: string)
		for i = 1, #s do
			h = bit32.bxor(h, string.byte(s, i))
			h = (h * 16777619) % 4294967296
		end
	end
	for _, e in events do
		local keys = {}
		for k in e do
			table.insert(keys, k)
		end
		table.sort(keys)
		for _, k in keys do
			local v = e[k]
			feed(k .. "=" .. (if type(v) == "number" then string.format("%.17g", v) else tostring(v)) .. ";")
		end
		feed("|")
	end
	return string.format("%08x:%d", h, #events)
end

return function(test)
	test("tick order: a pest spawns and moves in the same tick", function()
		local sim = newSim({ one("aphid") })
		sim:startWave()
		sim:step()
		A.eq(#sim.pests, 1)
		A.near(sim.pests[1].d, 0.12)
	end)

	test("a leak costs the pest's leak hearts", function()
		local sim = newSim({ one("snail") })
		sim:startWave()
		sim:runUntilPhaseChange(1000)
		A.eq(sim.hearts, 18)
		A.eq(sim.phase, "over") -- only wave of the test field
		A.eq(sim.result, "won")
	end)

	test("wave end bonus is 25 + 5n", function()
		local sim = newSim({ one("aphid"), one("aphid") }, { startSap = 200 })
		sim:startWave(); sim:runUntilPhaseChange(1000)
		A.eq(sim.sap, 230); A.eq(sim.wave, 1); A.eq(sim.phase, "build")
		sim:startWave(); sim:runUntilPhaseChange(1000)
		A.eq(sim.sap, 265)
	end)

	test("growth counts down after the bonus and a Sunpetal pays only once grown", function()
		local sim = newSim({ one("aphid"), one("aphid"), one("aphid") }, { startSap = 200 })
		local ok, id = sim:place("sunpetal", 3, 3)
		A.truthy(ok)
		A.eq(sim:findPlant(id).growth, 1)
		sim:startWave(); sim:runUntilPhaseChange(1000)
		A.eq(sim:findPlant(id).growth, 0)
		A.eq(sim.sap, 200 - 75 + 30 + 20)
		sim:upgrade(id) -- 45
		sim:startWave(); sim:runUntilPhaseChange(1000)
		A.eq(sim.sap, 175 - 45 + 35 + 30)
		-- A seedling Sunpetal pays nothing.
		local sim2 = newSim({ one("aphid") }, { startSap = 200 })
		sim2:place("sunpetal", 3, 3)
		local p = sim2.plants[1]
		p.growth = 2
		sim2:startWave(); sim2:runUntilPhaseChange(1000)
		A.eq(sim2.sap, 200 - 75 + 30)
	end)

	test("seedlings deal half damage", function()
		local sim = newSim({ one("snail") })
		sim:place("burr", 0, 1) -- growth 1
		sim:startWave(); sim:step()
		-- 3 x 0.5 = 1.5, minus 2 armour, minimum 1.
		A.near(sim.pests[1].hp, 109)
		local sim2 = newSim({ one("aphid") })
		sim2:place("burr", 0, 1)
		sim2:startWave(); sim2:step()
		A.near(sim2.pests[1].hp, 18 - 1.5)
	end)

	test("mint buff: largest one counts, no stacking, only when grown", function()
		local sim = newSim({ one("ant") }, { bonuses = { grow = 1 } })
		sim:place("thorn", 2, 2)
		local _, m1 = sim:place("mint", 3, 2)
		local _, m2 = sim:place("mint", 1, 2)
		sim:upgrade(m2) -- level 2: +20%
		sim:startWave()
		for _ = 1, 30 do
			sim:step()
			if sim.plants[1].cooldown > 0 then break end
		end
		A.near(sim.plants[1].cooldown, 1 / 1.2, 1e-9)
		-- A seedling mint gives nothing.
		local sim2 = newSim({ one("ant") })
		sim2:place("thorn", 2, 2)
		sim2:place("mint", 3, 2)
		sim2:startWave()
		for _ = 1, 30 do
			sim2:step()
			if sim2.plants[1].cooldown > 0 then break end
		end
		A.near(sim2.plants[1].cooldown, 1.0, 1e-9)
		A.truthy(m1 ~= nil)
	end)

	test("a mint never buffs itself or another mint's rate", function()
		local sim = newSim({ one("ant") }, { bonuses = { grow = 1 } })
		sim:place("mint", 3, 2)
		sim:place("mint", 4, 2)
		sim:startWave(); sim:step()
		A.eq(sim.plants[1].cooldown, 0) -- mints never attack, so they never set a cooldown
	end)

	test("hidden moles: only Mint range or Oak can target them", function()
		local function firstHitHp(setup: (any) -> ()): number
			local sim = newSim({ one("mole") }, { bonuses = { grow = 3 } })
			setup(sim)
			sim:startWave(); sim:step()
			A.truthy(sim.pests[1].hidden, "mole hidden at spawn")
			return sim.pests[1].hp
		end
		A.near(firstHitHp(function(sim) sim:place("thorn", 0, 1) end), 170, 1e-9, "thorn alone")
		A.near(firstHitHp(function(sim)
			sim:place("thorn", 0, 1)
			sim:place("mint", 1, 1)
		end), 170 - 7, 1e-9, "thorn with mint")
		A.near(firstHitHp(function(sim) sim:place("oak", 0, 1) end), 170 - 29, 1e-9, "oak")
	end)

	test("burrow: hidden while clock mod 5 < 3 (float clock, as in the prototype)", function()
		local sim = newSim({ one("mole") })
		sim:startWave()
		local line = ""
		for _ = 1, 100 do
			sim:step()
			line ..= if sim.pests[1].hidden then "H" else "u"
		end
		-- The clock adds 0.1 each tick, so it passes 3.0 a hair early: 29 hidden ticks, then 21 up.
		-- This matches design/prototype/sim.py exactly (see build/BUILD_REPORT.md).
		A.eq(string.sub(line, 1, 50), string.rep("H", 29) .. string.rep("u", 21))
		A.eq(string.sub(line, 51, 79), string.rep("H", 29))
	end)

	test("a Slug Matriarch splits into 3 aphids at d - 0.3k, never below 0", function()
		local sim = newSim({ one("slugmum") }, { bonuses = { dmg = 100 } })
		sim:place("thorn", 5, 1)
		sim:startWave()
		local d
		for _ = 1, 200 do
			sim:step()
			if #sim.pests == 3 then break end
		end
		A.eq(#sim.pests, 3)
		d = sim.pests[1].d
		A.truthy(d > 2.5)
		for k = 0, 2 do
			local e = sim.pests[k + 1]
			A.eq(e.type, "aphid"); A.near(e.d, d - 0.3 * k, 1e-9); A.near(e.hp, 18)
		end
		local sim2 = newSim({ one("slugmum") }, { bonuses = { dmg = 100 } })
		sim2:place("thorn", 0, 1)
		sim2:startWave(); sim2:step()
		A.eq(#sim2.pests, 3)
		A.near(sim2.pests[2].d, 0); A.near(sim2.pests[3].d, 0)
	end)

	test("regeneration works, and stops while burning", function()
		local sim = newSim({ one("caterpillar") })
		sim:place("thorn", 0, 1)
		sim:startWave(); sim:step()
		local after = sim.pests[1].hp
		A.near(after, 140 - 8 + 0.4 - 0.4, 1e-9) -- regen happens before the hit at full health
		sim:step()
		A.near(sim.pests[1].hp, after + 0.4, 1e-9)
		local sim2 = newSim({ one("caterpillar") }, { bonuses = { grow = 2 } })
		sim2:place("chilli", 0, 1)
		sim2:startWave(); sim2:step()
		local hp = sim2.pests[1].hp
		A.near(hp, 140 - 9, 1e-9) -- 6 x 1.5 fire
		for _ = 1, 4 do sim2:step() end
		A.near(sim2.pests[1].hp, hp, 1e-9, "no regen in the first 0.4 s of burning")
		sim2:step()
		A.near(sim2.pests[1].hp, hp - 4.5, 1e-9, "burn tick at 0.5 s")
	end)

	test("Burr slow: 30% for 2 s, refreshed by each hit", function()
		local sim = newSim({ one("aphid") }, { bonuses = { grow = 1 } })
		sim:place("burr", 0, 1)
		sim:startWave(); sim:step()
		local e = sim.pests[1]
		A.near(e.slow, 0.3); A.near(e.slowTime, 2.0)
		local d0 = e.d
		sim:step()
		A.near(e.d - d0, 1.2 * 0.7 * 0.1, 1e-9)
		A.near(e.slowTime, 1.9, 1e-9)
	end)

	test("120 pest cap: extra spawns wait for room", function()
		local sim = newSim({ { { pest = "aphid", count = 200, gap = 0.001, start = 0 } } }, { bonuses = { hearts = 1000 } })
		sim:startWave()
		local most = 0
		while sim.phase == "wave" do
			sim:step()
			most = math.max(most, #sim.pests)
		end
		A.eq(most, 120)
		A.eq(sim.nextPestId - 1, 200)
	end)

	test("undo refunds 100% only in the same build phase; sell is 60%", function()
		local sim = newSim({ one("aphid"), one("aphid") }, { startSap = 500 })
		local _, a = sim:place("thorn", 3, 3)
		local _, b = sim:place("pumpkin", 4, 3)
		A.eq(select(2, sim:sell(a)), 60)
		A.eq(sim.sap, 500 - 130)
		sim:startWave()
		local _, c = sim:place("thorn", 5, 3) -- placed during a wave: no undo
		A.eq(select(2, sim:sell(c)), 36)
		sim:runUntilPhaseChange(1000)
		sim:upgrade(b)
		A.eq(select(2, sim:sell(b)), math.floor((130 + 78) * 0.6))
	end)

	test("every error code is reachable", function()
		local sim = newSim({ one("aphid"), one("aphid"), one("aphid") }, { startSap = 100000, loadout = { "thorn", "sunpetal" } })
		A.eq(select(2, sim:place("nope", 3, 3)), "bad_seed")
		A.eq(select(2, sim:place("oak", 3, 3)), "not_in_loadout")
		A.eq(select(2, sim:place("thorn", 12, 3)), "out_of_bounds")
		A.eq(select(2, sim:place("thorn", 4, 0)), "on_path")
		local _, id = sim:place("thorn", 3, 3)
		A.eq(select(2, sim:place("thorn", 3, 3)), "tile_taken")
		A.eq(select(2, sim:upgrade(999)), "no_plant")
		A.eq(select(2, sim:setTargetMode(id, "random")), "bad_mode")
		A.truthy(sim:setTargetMode(id, "strong"))
		sim:upgrade(id); sim:upgrade(id)
		A.eq(select(2, sim:upgrade(id)), "max_level")
		local placed = 1
		for y = 1, 7 do
			for x = 0, 11 do
				if placed < 40 and sim:plantAt(x, y) == nil then
					sim:place("thorn", x, y); placed += 1
				end
			end
		end
		A.eq(select(2, sim:place("thorn", 11, 7)), "too_many_plants")
		local poor = newSim({ one("aphid") }, { startSap = 10 })
		A.eq(select(2, poor:place("thorn", 3, 3)), "no_sap")
		poor:startWave()
		A.eq(select(2, poor:startWave()), "wrong_phase")
		A.eq(select(2, poor:secondWind()), "wrong_phase")
		poor:runUntilPhaseChange(1000)
		A.eq(select(2, poor:place("thorn", 3, 3)), "run_over")
		A.eq(select(2, poor:startWave()), "run_over")
		-- Second Wind, then used up.
		local sw = newSim({ one("aphid"), one("aphid"), { { pest = "possum", count = 2, gap = 1, start = 0 } }, one("aphid") },
			{ secondWindAllowed = true })
		for _ = 1, 3 do
			sw:startWave(); sw:runUntilPhaseChange(100000)
		end
		A.eq(sw.phase, "lostPending")
		A.truthy(sw:secondWind())
		A.eq(sw.hearts, 10); A.eq(sw.phase, "wave")
		A.eq(select(2, sw:secondWind()), "second_wind_used")
		sw:runUntilPhaseChange(100000)
		A.eq(sw.phase, "over"); A.eq(sw.result, "lost")
	end)

	test("lostPending only from wave 3, and giveUp ends the run", function()
		local early = newSim({ { { pest = "possum", count = 1, gap = 1, start = 0 } } }, { secondWindAllowed = true })
		early:startWave(); early:runUntilPhaseChange(100000)
		A.eq(early.phase, "over")
		local sw = newSim({ one("aphid"), one("aphid"), { { pest = "possum", count = 1, gap = 1, start = 0 } } },
			{ secondWindAllowed = true })
		for _ = 1, 3 do
			sw:startWave(); sw:runUntilPhaseChange(100000)
		end
		A.eq(sw.phase, "lostPending")
		sw:step() -- no ticks run while waiting
		A.eq(sw.phase, "lostPending")
		sw:giveUp()
		A.eq(sw.phase, "over"); A.eq(sw.result, "lost")
	end)

	test("Backyard script: same build order twice gives an identical event log", function()
		local a = R.run(S.backyard, { keepEvents = true })
		local b = R.run(S.backyard, { keepEvents = true })
		A.truthy(#a.events > 500)
		A.eq(hashEvents(a.events), hashEvents(b.events))
	end)

	test("1x and 2x (ticks per frame) give the same result", function()
		for _, name in { "backyard", "veggie" } do
			local a = R.run(S[name], { keepEvents = true, ticksPerFrame = 1 })
			local b = R.run(S[name], { keepEvents = true, ticksPerFrame = 2 })
			local c = R.run(S[name], { keepEvents = true, ticksPerFrame = 3 })
			A.eq(hashEvents(a.events), hashEvents(b.events), name .. " 2x")
			A.eq(hashEvents(a.events), hashEvents(c.events), name .. " 3x")
		end
	end)

	test("a full Night Orchard run takes under 2 seconds", function()
		local t0 = os.clock()
		local r = R.run(S.orchard, { bonuses = S.RFULL })
		local took = os.clock() - t0
		A.truthy(r.won, "RFULL orchard wins")
		A.truthy(took < 2, string.format("took %.3f s", took))
	end)

	test("getState is a copy", function()
		local sim = newSim({ one("aphid") })
		sim:place("thorn", 3, 3)
		local st = sim:getState()
		st.plants[1].level = 3
		st.sap = 0
		A.eq(sim.plants[1].level, 1); A.truthy(sim.sap > 0)
	end)
end
