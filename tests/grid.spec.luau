--!strict
local L = require("./bundle")
local A = require("./assert")

return function(test)
	local backyard = L.Grid.expandPath(L.Fields.byId.backyard.waypoints)

	test("path tile counts 31, 25, 31 and plantable 65, 71, 65", function()
		A.eq(#backyard.tileList, 31)
		A.eq(L.Grid.plantableCount(backyard), 65)
		local v = L.Grid.expandPath(L.Fields.byId.veggie.waypoints)
		A.eq(#v.tileList, 25); A.eq(L.Grid.plantableCount(v), 71)
		local o = L.Grid.expandPath(L.Fields.byId.orchard.waypoints)
		A.eq(#o.tileList, 31); A.eq(L.Grid.plantableCount(o), 65)
	end)

	test("positionAt at 0, each corner and the end", function()
		local x, y = L.Grid.positionAt(backyard, 0)
		A.near(x, 0.5); A.near(y, 1.5)
		-- Corners at d = 9, 12, 19, 21, 30.
		local corners = { { 9, 9.5, 1.5 }, { 12, 9.5, 4.5 }, { 19, 2.5, 4.5 }, { 21, 2.5, 6.5 }, { 30, 11.5, 6.5 } }
		for _, c in corners do
			x, y = L.Grid.positionAt(backyard, c[1])
			A.near(x, c[2], 1e-9, "x at " .. c[1]); A.near(y, c[3], 1e-9, "y at " .. c[1])
		end
		x, y = L.Grid.positionAt(backyard, 4.25)
		A.near(x, 4.75); A.near(y, 1.5)
		x, y = L.Grid.positionAt(backyard, 99)
		A.near(x, 11.5); A.near(y, 6.5)
	end)

	test("path tiles and bounds", function()
		A.truthy(L.Grid.isPathTile(backyard, 0, 1)); A.truthy(L.Grid.isPathTile(backyard, 9, 3))
		A.truthy(L.Grid.isPathTile(backyard, 2, 5)); A.truthy(L.Grid.isPathTile(backyard, 11, 6))
		A.falsy(L.Grid.isPathTile(backyard, 8, 2)); A.falsy(L.Grid.isPathTile(backyard, 10, 1))
		A.truthy(L.Grid.inBounds(0, 0)); A.truthy(L.Grid.inBounds(11, 7))
		A.falsy(L.Grid.inBounds(12, 0)); A.falsy(L.Grid.inBounds(0, 8)); A.falsy(L.Grid.inBounds(-1, 3))
	end)

	test("coverage on Backyard at range 2.5: (8,2) 9, (3,5) 9, (11,0) 1", function()
		A.eq(L.Grid.coverage(backyard, 8, 2, 2.5), 9)
		A.eq(L.Grid.coverage(backyard, 3, 5, 2.5), 9)
		A.eq(L.Grid.coverage(backyard, 11, 0, 2.5), 1)
	end)

	test("mirror flips x", function()
		A.deepEq(L.Grid.mirror({ { 0, 2 }, { 8, 2 } }), { { 11, 2 }, { 3, 2 } })
	end)

	test("validateField catches bad paths", function()
		A.falsy((L.Grid.validateField({ waypoints = { { 0, 0 }, { 3, 2 } } })))
		A.falsy((L.Grid.validateField({ waypoints = { { 0, 0 }, { 12, 0 } } })))
		-- Crosses itself at (4, 2).
		A.falsy((L.Grid.validateField({ waypoints = { { 0, 2 }, { 8, 2 }, { 8, 4 }, { 4, 4 }, { 4, 0 } } })))
		A.truthy((L.Grid.validateField({ waypoints = { { 0, 2 }, { 8, 2 }, { 8, 5 }, { 0, 5 } } })))
	end)
end
