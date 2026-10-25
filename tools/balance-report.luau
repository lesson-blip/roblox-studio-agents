--!strict
-- Prints the spec 3.7 balance table from the Luau code: `lune run tools/balance-report`.
local S = require("../tests/fixtures/scripts")
local R = require("../tests/helpers/runscript")

local NAMES: { [string]: string } = { backyard = "Backyard Patch", backyardLazy = "Backyard, 3 Thorn Sprouts only", veggie = "Veggie Rows", orchard = "Night Orchard" }
print("| Field | R0 | RMID | RFULL | Frost R0 | Frost RMID | Frost RFULL |")
print("|---|---|---|---|---|---|---|")
for _, name in { "backyard", "backyardLazy", "veggie", "orchard" } do
	local cells = {}
	for _, frost in { 1, 1.4 } do
		for _, lv in { "R0", "RMID", "RFULL" } do
			local r = R.run(S[name], { bonuses = S[lv], hpExtra = frost })
			table.insert(cells, if r.won then "win, " .. r.hearts else "lose " .. r.waveReached)
		end
	end
	print("| " .. NAMES[name] .. " | " .. table.concat(cells, " | ") .. " |")
end
