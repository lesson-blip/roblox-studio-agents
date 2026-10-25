--!strict
local L = require("./bundle")
local A = require("./assert")

return function(test)
	local function sim()
		local s = L.WaveSim.new({ field = L.Fields.byId.backyard, loadout = { "thorn", "sunpetal", "burr" } })
		s:place("thorn", 8, 2)
		return s
	end

	test("runView has the HUD fields and per plant prices", function()
		local s = sim()
		local v = L.Views.runView(s:getState(), { runId = 7, speed = 1.5, loadout = { "thorn", "sunpetal", "burr" }, locked = { burr = "Clear wave 3" } })
		A.eq(v.runId, 7); A.eq(v.phase, "build"); A.eq(v.wave, 0); A.eq(v.totalWaves, 10)
		A.eq(v.hearts, 20); A.eq(v.sap, 140); A.eq(v.speed, 1.5)
		A.eq(#v.plants, 1)
		A.eq(v.plants[1].upgradeCost, 36); A.eq(v.plants[1].sellValue, 60); A.eq(v.plants[1].canUndo, true)
		A.eq(v.loadout[3].id, "burr"); A.eq(v.loadout[3].locked, "Clear wave 3"); A.eq(v.loadout[1].cost, 60)
	end)
	test("runView never sends pests or internals", function()
		local v = L.Views.runView(sim():getState(), { runId = 1, loadout = {} })
		A.eq(v.pests, nil); A.eq(v.schedule, nil); A.eq(v.events, nil)
	end)
	test("pest snapshot packs and unpacks", function()
		local s = sim()
		s:startWave()
		for _ = 1, 3 do s:step() end
		local snap = L.Views.pestSnapshot(s:getState(), { 1, 1 }, { 5 }, nil, 42)
		A.eq(snap.serverTick, 42)
		local rows = L.Views.unpackPests(snap.pests)
		A.eq(#rows, #s.pests)
		A.eq(rows[1].id, s.pests[1].id)
		A.eq(rows[1].typeIndex, L.Pests.index.aphid)
		A.near(rows[1].d, math.floor(s.pests[1].d * 100) / 100)
		A.truthy(rows[1].hpPercent >= 0 and rows[1].hpPercent <= 100)
		A.deepEq(snap.shots, { 1, 1 }); A.deepEq(snap.gone, { 5 })
	end)
end
