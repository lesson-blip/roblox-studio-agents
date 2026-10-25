--!strict
local L = require("./bundle")
local A = require("./assert")
local V = L.Validate

return function(test)
	local nan = 0 / 0
	local bad = { nan, math.huge, -math.huge, 1.5, "3", true, {}, nil :: any }

	test("int accepts whole numbers in range and rejects everything else", function()
		A.truthy(V.int(0, 0, 11)); A.truthy(V.int(11, 0, 11))
		A.falsy(V.int(12, 0, 11)); A.falsy(V.int(-1, 0, 11))
		for _, v in bad do A.falsy(V.int(v, 0, 11), tostring(v)) end
	end)
	test("str checks type and length", function()
		A.truthy(V.str("thorn", 24))
		A.falsy(V.str(string.rep("a", 25), 24)); A.falsy(V.str("", 24))
		A.falsy(V.str(5, 24)); A.falsy(V.str({}, 24))
	end)
	test("oneOf with lists and sets", function()
		A.truthy(V.oneOf("first", L.Constants.TARGET_MODES)); A.falsy(V.oneOf("nope", L.Constants.TARGET_MODES))
		A.truthy(V.oneOf(1.5, L.Constants.SPEEDS)); A.falsy(V.oneOf(3, L.Constants.SPEEDS))
		A.falsy(V.oneOf(nan, L.Constants.SPEEDS)); A.falsy(V.oneOf({}, L.Constants.SPEEDS))
		A.truthy(V.oneOf("a", { a = true } :: any))
	end)
	test("seedId, tile, plantId", function()
		A.truthy(V.seedId("oak")); A.falsy(V.seedId("Oak")); A.falsy(V.seedId(1))
		A.truthy(V.tile(0, 0)); A.truthy(V.tile(11, 7)); A.falsy(V.tile(12, 0)); A.falsy(V.tile(0, 8))
		A.falsy(V.tile(1.5, 2)); A.falsy(V.tile(nan, 2)); A.falsy(V.tile("1", 2))
		A.truthy(V.plantId(1)); A.falsy(V.plantId(0)); A.falsy(V.plantId(2.5)); A.falsy(V.plantId(math.huge))
	end)
	test("loadout: unlocked, no repeats, within slots, plain array", function()
		local u = { thorn = true, sunpetal = true, burr = true }
		A.truthy(V.loadout({ "thorn", "burr" }, u, 5))
		A.falsy(V.loadout({ "thorn", "thorn" }, u, 5)); A.falsy(V.loadout({ "oak" }, u, 5))
		A.falsy(V.loadout({}, u, 5)); A.falsy(V.loadout({ "thorn", "burr" }, u, 1))
		A.falsy(V.loadout({ "thorn", x = 1 } :: any, u, 5)); A.falsy(V.loadout("thorn", u, 5))
	end)
	test("remote payloads: good ones pass", function()
		local ok, p = V.payload("PlaceSeed", { "thorn", 8, 2 })
		A.truthy(ok); A.deepEq(p, { seedId = "thorn", x = 8, y = 2 })
		A.truthy(V.payload("RequestStart", { "backyard", "normal" }))
		A.truthy(V.payload("UpgradePlant", { 3 })); A.truthy(V.payload("SellPlant", { 3 }))
		A.truthy(V.payload("SetTargetMode", { 3, "close" })); A.truthy(V.payload("StartWave", {}))
		A.truthy(V.payload("SetSpeed", { 1.5 }))
	end)
	test("remote payloads: bad ones are refused", function()
		local cases: { { any } } = {
			{ "PlaceSeed", { "thorn", 8.5, 2 } }, { "PlaceSeed", { "thorn", -1, 2 } }, { "PlaceSeed", { "thorn", 12, 2 } },
			{ "PlaceSeed", { "thorn", nan, 2 } }, { "PlaceSeed", { "gold", 1, 1 } }, { "PlaceSeed", { { "x" }, 1, 1 } },
			{ "PlaceSeed", { "thorn", "8", 2 } }, { "PlaceSeed", {} },
			{ "RequestStart", { "backyard", "easy" } }, { "RequestStart", { string.rep("x", 30), "normal" } },
			{ "UpgradePlant", { 0 } }, { "UpgradePlant", { "1" } }, { "SellPlant", { math.huge } },
			{ "SetTargetMode", { 1, "random" } }, { "SetSpeed", { 3 } }, { "SetSpeed", { "2" } },
			{ "GiveMeSap", { 1000 } },
		}
		for _, c in cases do
			local ok, err = V.payload(c[1], c[2])
			A.falsy(ok, c[1]); A.eq(err, "bad_payload")
		end
	end)
end
