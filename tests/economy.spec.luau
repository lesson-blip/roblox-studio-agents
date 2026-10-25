--!strict
-- Sap parts of the economy (spec 4.1). Petals arrive in M2.
local L = require("./bundle")
local A = require("./assert")

return function(test)
	test("upgrade costs for every seed", function()
		local expect: { [string]: { number } } = {
			thorn = { 36, 60 }, sunpetal = { 45, 75 }, burr = { 42, 70 }, nettle = { 54, 90 },
			dandelion = { 60, 100 }, pumpkin = { 78, 130 }, mint = { 66, 110 }, chilli = { 90, 150 },
			snapjaw = { 102, 170 }, oak = { 192, 320 },
		}
		for id, e in expect do
			A.eq(L.Economy.upgradeCost(id, 1), e[1], id)
			A.eq(L.Economy.upgradeCost(id, 2), e[2], id)
			A.eq(L.Economy.upgradeCost(id, 3), nil, id .. " max")
		end
		A.eq(L.Economy.upgradeCost("nope", 1), nil)
	end)
	test("sell values: 60% rounded down, undo 100%", function()
		for _, id in L.Seeds.order do
			local s = L.Seeds.byId[id]
			A.eq(L.Economy.sellValue(s.cost, false), math.floor(s.cost * 0.6 + 1e-9), id)
			A.eq(L.Economy.sellValue(s.cost, true), s.cost, id .. " undo")
			local full = s.cost + L.Economy.upgradeCost(id, 1) + s.cost
			A.eq(L.Economy.sellValue(full, false), math.floor(full * 6 / 10), id .. " level 3")
		end
		A.eq(L.Economy.sellValue(75, false), 45)
		A.eq(L.Economy.sellValue(155, false), 93)
	end)
	test("wave bonus 25 + 5n", function()
		A.eq(L.Economy.waveBonus(1), 30); A.eq(L.Economy.waveBonus(10), 75)
	end)
	test("round is half up", function()
		A.eq(L.Economy.round(2.5), 3); A.eq(L.Economy.round(3.5), 4); A.eq(L.Economy.round(2.4999), 2)
		A.eq(L.Economy.pestReward(3, 1.1), 3); A.eq(L.Economy.pestReward(5, 1.1), 6) -- 5.5 rounds up
	end)
end
