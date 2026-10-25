--!strict
local L = require("./bundle")
local A = require("./assert")

return function(test)
	local S, P = L.Seeds.byId, L.Pests.byId
	local NB = L.Constants.NO_BONUSES
	local function hit(seed: string, pest: string, opts: any?)
		local o = opts or {}
		return L.Combat.hitDamage(S[seed], o.level or 1, o.bonuses or NB, o.seedling == true, P[pest], o.mods)
	end

	test("thorn level 1 on beetle = 1 (8 x 0.75 = 6, minus 5)", function()
		A.near(hit("thorn", "beetle"), 1)
	end)
	test("thorn on aphid = 8, seedling thorn on aphid = 4", function()
		A.near(hit("thorn", "aphid"), 8)
		A.near(hit("thorn", "aphid", { seedling = true }), 4)
	end)
	test("snapjaw on snail = 55 x 2 - 2 = 108", function()
		A.near(hit("snapjaw", "snail"), 108)
	end)
	test("pumpkin on beetle = 22 x 1.25 - 5 = 22.5", function()
		A.near(hit("pumpkin", "beetle"), 22.5)
	end)
	test("dandelion on moth = 16", function()
		A.near(hit("dandelion", "moth"), 16)
	end)
	test("chilli burn tick on caterpillar = 6 x 1.5 x 0.5 = 4.5", function()
		local dps = L.Combat.burnDps(S.chilli, 1, NB, false)
		A.near(dps, 6)
		A.near(L.Combat.dotDamage(dps * 0.5, "fire", P.caterpillar, nil), 4.5)
	end)
	test("burn uses level, research and seedling factors", function()
		A.near(L.Combat.burnDps(S.chilli, 2, { dmg = 0.1 }, true), 6 * 1.4 * 1.1 * 0.5)
	end)
	test("ironshell adds 2 armour", function()
		A.near(hit("thorn", "snail", { mods = { armour = 2 } }), 8 - 4)
		A.near(hit("thorn", "aphid", { mods = { armour = 2 } }), 6)
	end)
	test("heatwave makes fire x1.3", function()
		A.near(hit("chilli", "aphid", { mods = { fireMult = 1.3 } }), 6 * 1.3)
		A.near(hit("thorn", "aphid", { mods = { fireMult = 1.3 } }), 8, 1e-9, "pierce unchanged")
	end)
	test("direct hits do at least 1", function()
		A.near(hit("burr", "beetle"), 1) -- 3 x 0.75 = 2.25, minus 5
		A.near(hit("thorn", "possum", { seedling = true }), 1)
	end)
	test("aura and burn ignore armour and have no minimum", function()
		A.near(L.Combat.dotDamage(3, "poison", P.beetle, { armour = 2 }), 3)
		A.near(L.Combat.dotDamage(3, "poison", P.snail, nil), 4.5)
		A.near(L.Combat.dotDamage(0.2, "poison", P.wasp, nil), 0.1)
	end)
	test("levels and research scale damage", function()
		A.near(hit("thorn", "aphid", { level = 2 }), 8 * 1.4)
		A.near(hit("thorn", "aphid", { level = 3 }), 8 * 1.9)
		A.near(hit("thorn", "aphid", { bonuses = { dmg = 0.2 } }), 9.6)
	end)
	test("snapjaw heavy bonus only on heavy pests", function()
		A.near(hit("snapjaw", "ant"), 55)
		A.near(hit("snapjaw", "possum"), 55 * 2 * 1.25 - 4)
	end)

	test("canTarget: flying and hidden rules", function()
		local moth = { type = "moth", hidden = false }
		local mole = { type = "mole", hidden = true }
		A.truthy(L.Combat.canTarget(S.thorn, moth, true))
		A.falsy(L.Combat.canTarget(S.burr, moth, true))
		A.falsy(L.Combat.canTarget(S.thorn, mole, false))
		A.truthy(L.Combat.canTarget(S.thorn, mole, true))
		A.truthy(L.Combat.canTarget(S.oak, mole, false), "oak detects")
	end)

	test("targeting modes, ties go to the earliest spawn", function()
		local c = {
			{ id = 3, d = 5, hp = 10, x = 1, y = 1 },
			{ id = 1, d = 5, hp = 30, x = 9, y = 9 },
			{ id = 2, d = 2, hp = 30, x = 2, y = 2 },
			{ id = 4, d = 2, hp = 5, x = 2, y = 2 },
		}
		A.eq(L.Combat.pickTarget(c, "first", 0, 0).id, 1)
		A.eq(L.Combat.pickTarget(c, "last", 0, 0).id, 2)
		A.eq(L.Combat.pickTarget(c, "strong", 0, 0).id, 1)
		A.eq(L.Combat.pickTarget(c, "close", 0, 0).id, 3)
		A.eq(L.Combat.pickTarget(c, "close", 2, 2).id, 2)
		A.eq(L.Combat.pickTarget({}, "first", 0, 0), nil)
	end)
end
