--!strict
-- Data tables match spec sections 3.2 to 3.4.
local L = require("./bundle")
local A = require("./assert")

return function(test)
	test("constants match spec 6.3", function()
		local C = L.Constants
		A.eq(C.GRID_W, 12); A.eq(C.GRID_H, 8); A.eq(C.TILE_STUDS, 4); A.eq(C.TICK, 0.1)
		A.eq(C.START_HEARTS, 20); A.eq(C.MAX_PESTS, 120); A.eq(C.MAX_PLANTS, 40)
		A.deepEq(C.UPGRADE_COST, { 0.6, 1.0 }); A.deepEq(C.LEVEL_DMG, { 1.0, 1.4, 1.9 })
		A.deepEq(C.LEVEL_RANGE_BONUS, { 0, 0, 0.5 }); A.deepEq(C.SPEEDS, { 1, 1.5, 2 })
		A.eq(C.WAVE_BONUS_BASE, 25); A.eq(C.WAVE_BONUS_PER, 5)
	end)

	test("every seed number matches spec 3.2", function()
		-- id, cost, grows, damage, range, rate, type, air, level 2 cost
		local rows: { { any } } = {
			{ "thorn", 60, 0, 8, 2.5, 1.0, "pierce", true, 36 },
			{ "sunpetal", 75, 1, 0, 0, 0, nil, false, 45 },
			{ "burr", 70, 1, 3, 2.0, 1.2, "pierce", false, 42 },
			{ "nettle", 90, 1, 3, 1.5, 2.0, "poison", false, 54 },
			{ "dandelion", 100, 1, 8, 4.0, 1.4, "pierce", true, 60 },
			{ "pumpkin", 130, 2, 22, 3.5, 0.4, "blunt", false, 78 },
			{ "mint", 110, 1, 0, 1.5, 0, nil, false, 66 },
			{ "chilli", 150, 2, 6, 2.5, 0.8, "fire", true, 90 },
			{ "snapjaw", 170, 2, 55, 1.5, 0.4, "bite", false, 102 },
			{ "oak", 320, 3, 30, 4.5, 0.8, "pierce", true, 192 },
		}
		A.eq(#L.Seeds.order, 10)
		for i, r in rows do
			local s = L.Seeds.byId[r[1]]
			A.truthy(s, r[1])
			A.eq(L.Seeds.order[i], r[1], "order")
			A.eq(s.cost, r[2], r[1] .. " cost"); A.eq(s.growth, r[3], r[1] .. " growth")
			A.eq(s.damage, r[4], r[1] .. " damage"); A.eq(s.range, r[5], r[1] .. " range")
			A.eq(s.rate, r[6], r[1] .. " rate"); A.eq(s.damageType, r[7], r[1] .. " type")
			A.eq(s.air, r[8], r[1] .. " air")
			A.eq(L.Economy.upgradeCost(r[1], 1), r[9], r[1] .. " level 2 cost")
			A.eq(L.Economy.upgradeCost(r[1], 2), r[2], r[1] .. " level 3 cost")
		end
		local S = L.Seeds.byId
		A.deepEq(S.sunpetal.income, { 20, 30, 45 })
		A.eq(S.burr.slow, 0.30); A.eq(S.burr.slowTime, 2.0)
		A.eq(S.nettle.aura, true); A.eq(S.dandelion.airMult, 2.0); A.eq(S.pumpkin.splash, 1.0)
		A.deepEq(S.mint.buff, { 0.15, 0.20, 0.25 })
		A.eq(S.chilli.burnDps, 6); A.eq(S.chilli.burnTime, 3.0)
		A.eq(S.snapjaw.heavyMult, 2.0); A.eq(S.oak.detect, true)
		for _, id in L.Seeds.order do
			if id ~= "oak" then A.eq(S[id].detect, false, id .. " detect") end
		end
	end)

	test("seed unlock rules refer to real things", function()
		local nodes = { L1 = true, L2 = true, L4 = true, L7 = true }
		for _, id in L.Seeds.order do
			local u = L.Seeds.byId[id].unlock
			if u.kind == "research" then
				A.truthy(nodes[u.node], id .. " node")
			elseif u.kind == "fieldWave" then
				local f = L.Fields.byId[u.field]
				A.truthy(f, id .. " field")
				A.truthy(u.wave >= 1 and u.wave <= #f.waves, id .. " wave")
			elseif u.kind == "fieldClear" then
				A.truthy(L.Fields.byId[u.field], id .. " field")
			else
				A.eq(u.kind, "start", id)
			end
		end
		A.eq(L.Seeds.byId.burr.unlock.wave, 3); A.eq(L.Seeds.byId.snapjaw.unlock.wave, 7)
	end)

	test("every pest number matches spec 3.3", function()
		-- id, hp, speed, reward, leak, armour, threat, min wave
		local rows: { { any } } = {
			{ "aphid", 18, 1.2, 3, 1, 0, 2, 1 },
			{ "ant", 34, 1.0, 4, 1, 0, 3, 1 },
			{ "snail", 110, 0.5, 8, 2, 2, 8, 2 },
			{ "moth", 36, 1.4, 5, 1, 0, 4, 3 },
			{ "caterpillar", 140, 0.8, 10, 2, 0, 10, 4 },
			{ "beetle", 200, 0.7, 12, 3, 5, 16, 5 },
			{ "wasp", 70, 1.7, 8, 2, 0, 7, 6 },
			{ "mole", 170, 0.8, 14, 3, 1, 14, 5 },
			{ "slugmum", 280, 0.5, 18, 4, 0, 26, 8 },
			{ "possum", 2600, 0.45, 150, 20, 4, 200, nil },
		}
		A.eq(#L.Pests.order, 10)
		for i, r in rows do
			local p = L.Pests.byId[r[1]]
			A.truthy(p, r[1]); A.eq(L.Pests.order[i], r[1])
			A.eq(p.hp, r[2], r[1] .. " hp"); A.eq(p.speed, r[3], r[1] .. " speed")
			A.eq(p.reward, r[4], r[1] .. " reward"); A.eq(p.leak, r[5], r[1] .. " leak")
			A.eq(p.armour, r[6], r[1] .. " armour"); A.eq(p.threat, r[7], r[1] .. " threat")
			A.eq(p.minWave, r[8], r[1] .. " min wave")
			A.truthy(#p.tip > 0, r[1] .. " tip")
		end
		local P = L.Pests.byId
		A.deepEq(P.snail.resist, { poison = 1.5 }); A.deepEq(P.caterpillar.resist, { fire = 1.5 })
		A.deepEq(P.beetle.resist, { pierce = 0.75, blunt = 1.25 }); A.deepEq(P.wasp.resist, { poison = 0.5 })
		A.deepEq(P.mole.resist, { blunt = 1.25 }); A.deepEq(P.slugmum.resist, { fire = 0.5, poison = 1.5 })
		A.deepEq(P.possum.resist, { fire = 0.75, bite = 1.25 })
		A.eq(P.caterpillar.regen, 4); A.eq(P.slugmum.splitInto, "aphid"); A.eq(P.slugmum.splitCount, 3)
		local heavy = { snail = true, beetle = true, slugmum = true, possum = true }
		local flying = { moth = true, wasp = true }
		for _, id in L.Pests.order do
			A.eq(P[id].heavy, heavy[id] == true, id .. " heavy")
			A.eq(P[id].flying, flying[id] == true, id .. " flying")
			A.eq(P[id].burrow, id == "mole", id .. " burrow")
		end
	end)

	test("ids are unique and tables are frozen", function()
		for _, t in { L.Seeds, L.Pests, L.Fields } do
			local seen = {}
			for _, id in t.order do
				A.falsy(seen[id], "duplicate " .. id); seen[id] = true
				A.truthy(t.byId[id], id)
			end
			A.truthy(table.isfrozen(t.byId))
		end
		A.throws(function() (L.Seeds.byId.thorn :: any).cost = 1 end)
	end)

	test("fields match spec 3.4", function()
		local F = L.Fields.byId
		A.deepEq(F.backyard.waypoints, { { 0, 1 }, { 9, 1 }, { 9, 4 }, { 2, 4 }, { 2, 6 }, { 11, 6 } })
		A.deepEq(F.veggie.waypoints, { { 0, 3 }, { 3, 3 }, { 3, 0 }, { 6, 0 }, { 6, 6 }, { 9, 6 }, { 9, 2 }, { 11, 2 } })
		A.deepEq(F.orchard.waypoints, { { 11, 1 }, { 1, 1 }, { 1, 3 }, { 8, 3 }, { 8, 6 }, { 0, 6 } })
		A.eq(F.backyard.startSap, 200); A.eq(F.veggie.startSap, 300); A.eq(F.orchard.startSap, 400)
		A.eq(F.backyard.hpScale, 1.0); A.eq(F.veggie.hpScale, 1.2); A.eq(F.orchard.hpScale, 1.1)
		A.eq(#F.backyard.waves, 10); A.eq(#F.veggie.waves, 15); A.eq(#F.orchard.waves, 20)
		A.deepEq(F.backyard.petals, { perWave = 2, clear = 20, firstClear = 50, frostFirstClear = 100 })
		-- Spot checks of the wave tables.
		A.deepEq(F.backyard.waves[1], { { pest = "aphid", count = 4, gap = 1.5, start = 0 } })
		A.deepEq(F.backyard.waves[10], {
			{ pest = "beetle", count = 2, gap = 5.0, start = 0 },
			{ pest = "snail", count = 4, gap = 2.0, start = 2 },
			{ pest = "ant", count = 12, gap = 0.6, start = 4 },
		})
		A.deepEq(F.veggie.waves[14][3], { pest = "aphid", count = 20, gap = 0.4, start = 1 })
		A.deepEq(F.orchard.waves[20][1], { pest = "possum", count = 2, gap = 12, start = 0 })
		A.eq(F.orchard.waves[10][1].pest, "possum"); A.eq(F.orchard.waves[10][1].count, 1)
	end)

	test("every wave group is well formed", function()
		for _, fid in L.Fields.order do
			for wi, wave in L.Fields.byId[fid].waves do
				A.truthy(#wave >= 1, fid .. " wave " .. wi)
				for _, g in wave do
					A.truthy(L.Pests.byId[g.pest], fid .. " pest " .. g.pest)
					A.truthy(g.count >= 1 and g.count == math.floor(g.count), "count")
					A.truthy(g.gap > 0, "gap"); A.truthy(g.start >= 0, "start")
				end
			end
		end
	end)

	test("all three fields pass validateField, mirrored too", function()
		for _, fid in L.Fields.order do
			local f = L.Fields.byId[fid]
			local ok, errs = L.Grid.validateField(f)
			A.truthy(ok, fid .. ": " .. table.concat(errs, "; "))
			local ok2, errs2 = L.Grid.validateField({ waypoints = L.Grid.mirror(f.waypoints) })
			A.truthy(ok2, fid .. " mirrored: " .. table.concat(errs2, "; "))
		end
	end)

	test("route lengths 30, 24, 30", function()
		A.eq(L.Grid.expandPath(L.Fields.byId.backyard.waypoints).length, 30)
		A.eq(L.Grid.expandPath(L.Fields.byId.veggie.waypoints).length, 24)
		A.eq(L.Grid.expandPath(L.Fields.byId.orchard.waypoints).length, 30)
	end)
end
