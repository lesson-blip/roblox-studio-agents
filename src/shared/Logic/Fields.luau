--!strict
-- The 3 hand made fields (spec 3.4). Pure data. Waypoints are { x, y } tile pairs.
-- Generated once from design/prototype/fields.py and checked by data.spec.luau.

export type Group = { pest: string, count: number, gap: number, start: number, hpMult: number? }
export type Field = {
	id: string,
	name: string,
	waypoints: { { number } },
	startSap: number,
	hpScale: number,
	petals: { perWave: number, clear: number, firstClear: number, frostFirstClear: number },
	unlock: { kind: string, field: string? },
	waves: { { Group } },
}

local list: { Field } = {
	{
		id = "backyard",
		name = "Backyard Patch",
		waypoints = { { 0, 1 }, { 9, 1 }, { 9, 4 }, { 2, 4 }, { 2, 6 }, { 11, 6 } },
		startSap = 200,
		hpScale = 1,
		petals = { perWave = 2, clear = 20, firstClear = 50, frostFirstClear = 100 },
		unlock = { kind = "start" },
		waves = {
			{ { pest = "aphid", count = 4, gap = 1.5, start = 0 } },
			{ { pest = "aphid", count = 8, gap = 1, start = 0 } },
			{ { pest = "ant", count = 6, gap = 1.2, start = 0 }, { pest = "aphid", count = 4, gap = 1, start = 4 } },
			{ { pest = "ant", count = 10, gap = 1, start = 0 } },
			{ { pest = "snail", count = 2, gap = 4, start = 0 }, { pest = "aphid", count = 8, gap = 0.8, start = 2 } },
			{ { pest = "ant", count = 12, gap = 0.8, start = 0 }, { pest = "snail", count = 2, gap = 3, start = 6 } },
			{ { pest = "caterpillar", count = 3, gap = 3, start = 0 }, { pest = "ant", count = 8, gap = 0.8, start = 2 } },
			{ { pest = "snail", count = 5, gap = 2.5, start = 0 }, { pest = "aphid", count = 12, gap = 0.6, start = 1 } },
			{ { pest = "caterpillar", count = 4, gap = 2.5, start = 0 }, { pest = "ant", count = 14, gap = 0.7, start = 1 } },
			{ { pest = "beetle", count = 2, gap = 5, start = 0 }, { pest = "snail", count = 4, gap = 2, start = 2 }, { pest = "ant", count = 12, gap = 0.6, start = 4 } },
		},
	},
	{
		id = "veggie",
		name = "Veggie Rows",
		waypoints = { { 0, 3 }, { 3, 3 }, { 3, 0 }, { 6, 0 }, { 6, 6 }, { 9, 6 }, { 9, 2 }, { 11, 2 } },
		startSap = 300,
		hpScale = 1.2,
		petals = { perWave = 3, clear = 40, firstClear = 100, frostFirstClear = 150 },
		unlock = { kind = "fieldClear", field = "backyard" },
		waves = {
			{ { pest = "ant", count = 8, gap = 1.2, start = 0 } },
			{ { pest = "aphid", count = 14, gap = 0.7, start = 0 }, { pest = "ant", count = 4, gap = 1, start = 5 } },
			{ { pest = "moth", count = 6, gap = 1.2, start = 0 }, { pest = "ant", count = 8, gap = 1, start = 2 } },
			{ { pest = "snail", count = 4, gap = 2.5, start = 0 }, { pest = "moth", count = 6, gap = 1, start = 3 } },
			{ { pest = "caterpillar", count = 4, gap = 2, start = 0 }, { pest = "ant", count = 12, gap = 0.7, start = 1 } },
			{ { pest = "moth", count = 12, gap = 0.8, start = 0 }, { pest = "aphid", count = 12, gap = 0.6, start = 2 } },
			{ { pest = "beetle", count = 3, gap = 3.5, start = 0 }, { pest = "ant", count = 14, gap = 0.6, start = 2 } },
			{ { pest = "wasp", count = 6, gap = 1.5, start = 0 }, { pest = "snail", count = 5, gap = 2, start = 1 } },
			{ { pest = "caterpillar", count = 6, gap = 1.8, start = 0 }, { pest = "moth", count = 10, gap = 0.8, start = 2 } },
			{ { pest = "slugmum", count = 2, gap = 6, start = 0 }, { pest = "ant", count = 16, gap = 0.5, start = 2 } },
			{ { pest = "beetle", count = 5, gap = 2.5, start = 0 }, { pest = "wasp", count = 8, gap = 1.2, start = 3 } },
			{ { pest = "slugmum", count = 3, gap = 4, start = 0 }, { pest = "moth", count = 14, gap = 0.6, start = 1 } },
			{ { pest = "caterpillar", count = 8, gap = 1.5, start = 0 }, { pest = "wasp", count = 10, gap = 1, start = 2 } },
			{ { pest = "beetle", count = 7, gap = 2, start = 0 }, { pest = "slugmum", count = 3, gap = 4, start = 4 }, { pest = "aphid", count = 20, gap = 0.4, start = 1 } },
			{ { pest = "wasp", count = 16, gap = 0.7, start = 0 }, { pest = "beetle", count = 6, gap = 2, start = 2 }, { pest = "slugmum", count = 3, gap = 3.5, start = 6 } },
		},
	},
	{
		id = "orchard",
		name = "Night Orchard",
		waypoints = { { 11, 1 }, { 1, 1 }, { 1, 3 }, { 8, 3 }, { 8, 6 }, { 0, 6 } },
		startSap = 400,
		hpScale = 1.1,
		petals = { perWave = 4, clear = 70, firstClear = 200, frostFirstClear = 250 },
		unlock = { kind = "fieldClear", field = "veggie" },
		waves = {
			{ { pest = "ant", count = 10, gap = 1, start = 0 } },
			{ { pest = "snail", count = 3, gap = 2.5, start = 0 }, { pest = "aphid", count = 10, gap = 0.7, start = 2 } },
			{ { pest = "mole", count = 3, gap = 3, start = 0 }, { pest = "ant", count = 10, gap = 0.8, start = 1 } },
			{ { pest = "moth", count = 10, gap = 0.8, start = 0 }, { pest = "caterpillar", count = 3, gap = 2.5, start = 2 } },
			{ { pest = "mole", count = 5, gap = 2.5, start = 0 }, { pest = "snail", count = 4, gap = 2, start = 2 } },
			{ { pest = "beetle", count = 4, gap = 3, start = 0 }, { pest = "wasp", count = 6, gap = 1.2, start = 2 } },
			{ { pest = "slugmum", count = 3, gap = 4, start = 0 }, { pest = "mole", count = 4, gap = 2.5, start = 2 } },
			{ { pest = "caterpillar", count = 8, gap = 1.5, start = 0 }, { pest = "moth", count = 12, gap = 0.7, start = 1 } },
			{ { pest = "beetle", count = 6, gap = 2.5, start = 0 }, { pest = "mole", count = 6, gap = 2, start = 2 } },
			{ { pest = "possum", count = 1, gap = 1, start = 0 }, { pest = "ant", count = 20, gap = 0.6, start = 2 } },
			{ { pest = "wasp", count = 14, gap = 0.7, start = 0 }, { pest = "slugmum", count = 3, gap = 4, start = 2 } },
			{ { pest = "mole", count = 10, gap = 1.5, start = 0 }, { pest = "beetle", count = 5, gap = 2.5, start = 3 } },
			{ { pest = "caterpillar", count = 10, gap = 1.2, start = 0 }, { pest = "wasp", count = 10, gap = 0.9, start = 2 } },
			{ { pest = "slugmum", count = 5, gap = 3, start = 0 }, { pest = "beetle", count = 7, gap = 2, start = 1 } },
			{ { pest = "mole", count = 12, gap = 1.2, start = 0 }, { pest = "moth", count = 16, gap = 0.5, start = 1 } },
			{ { pest = "beetle", count = 10, gap = 1.6, start = 0 }, { pest = "wasp", count = 14, gap = 0.7, start = 2 } },
			{ { pest = "slugmum", count = 6, gap = 2.5, start = 0 }, { pest = "mole", count = 10, gap = 1.4, start = 2 } },
			{ { pest = "caterpillar", count = 14, gap = 1, start = 0 }, { pest = "beetle", count = 8, gap = 1.8, start = 2 }, { pest = "wasp", count = 12, gap = 0.8, start = 4 } },
			{ { pest = "mole", count = 14, gap = 1, start = 0 }, { pest = "slugmum", count = 6, gap = 2.5, start = 2 }, { pest = "beetle", count = 8, gap = 1.6, start = 4 } },
			{ { pest = "possum", count = 2, gap = 12, start = 0 }, { pest = "beetle", count = 10, gap = 1.5, start = 2 }, { pest = "wasp", count = 14, gap = 0.7, start = 6 }, { pest = "mole", count = 10, gap = 1.2, start = 8 } },
		},
	},
}

local function deepFreeze(t: any): any
	for _, v in t do
		if type(v) == "table" and not table.isfrozen(v) then
			deepFreeze(v)
		end
	end
	return table.freeze(t)
end

local byId: { [string]: Field } = {}
local order: { string } = {}
for i, f in list do
	byId[f.id] = deepFreeze(f)
	order[i] = f.id
end

return table.freeze({
	byId = table.freeze(byId),
	order = table.freeze(order),
})
