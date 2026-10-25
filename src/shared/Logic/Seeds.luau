--!strict
-- The 10 seeds (spec 3.2). Pure data, keyed by id, with an order list.

export type Unlock = {
	kind: string, -- "start" | "research" | "fieldWave" | "fieldClear"
	node: string?,
	field: string?,
	wave: number?,
}

export type Seed = {
	id: string,
	name: string,
	short: string,
	cost: number,
	growth: number,
	damage: number,
	range: number,
	rate: number,
	damageType: string?,
	air: boolean,
	detect: boolean,
	airMult: number?,
	heavyMult: number?,
	splash: number?,
	slow: number?,
	slowTime: number?,
	aura: boolean?,
	burnDps: number?,
	burnTime: number?,
	income: { number }?,
	buff: { number }?,
	special: string,
	unlock: Unlock,
}

local list: { Seed } = {
	{
		id = "thorn", name = "Thorn Sprout", short = "Thorn",
		cost = 60, growth = 0, damage = 8, range = 2.5, rate = 1.0,
		damageType = "pierce", air = true, detect = false,
		special = "Cheap all rounder",
		unlock = { kind = "start" },
	},
	{
		id = "sunpetal", name = "Sunpetal", short = "Sunpetal",
		cost = 75, growth = 1, damage = 0, range = 0, rate = 0,
		damageType = nil, air = false, detect = false,
		income = { 20, 30, 45 },
		special = "Pays Sap at each wave end once grown",
		unlock = { kind = "start" },
	},
	{
		id = "burr", name = "Burr Vine", short = "Burr",
		cost = 70, growth = 1, damage = 3, range = 2.0, rate = 1.2,
		damageType = "pierce", air = false, detect = false,
		slow = 0.30, slowTime = 2.0,
		special = "Slows pests 30% for 2 s",
		unlock = { kind = "fieldWave", field = "backyard", wave = 3 },
	},
	{
		id = "nettle", name = "Nettle Patch", short = "Nettle",
		cost = 90, growth = 1, damage = 3, range = 1.5, rate = 2.0,
		damageType = "poison", air = false, detect = false,
		aura = true,
		special = "Hits every pest in range, ignores armour",
		unlock = { kind = "research", node = "L2" },
	},
	{
		id = "dandelion", name = "Dandelion Lofter", short = "Dandelion",
		cost = 100, growth = 1, damage = 8, range = 4.0, rate = 1.4,
		damageType = "pierce", air = true, detect = false,
		airMult = 2.0,
		special = "Double damage to flying pests",
		unlock = { kind = "fieldClear", field = "backyard" },
	},
	{
		id = "pumpkin", name = "Pumpkin Mortar", short = "Pumpkin",
		cost = 130, growth = 2, damage = 22, range = 3.5, rate = 0.4,
		damageType = "blunt", air = false, detect = false,
		splash = 1.0,
		special = "Splash 1 tile, ground only",
		unlock = { kind = "research", node = "L1" },
	},
	{
		id = "mint", name = "Mint Mist", short = "Mint",
		cost = 110, growth = 1, damage = 0, range = 1.5, rate = 0,
		damageType = nil, air = false, detect = false,
		buff = { 0.15, 0.20, 0.25 },
		special = "Speeds up nearby plants and reveals hidden pests",
		unlock = { kind = "fieldClear", field = "veggie" },
	},
	{
		id = "chilli", name = "Chilli Burner", short = "Chilli",
		cost = 150, growth = 2, damage = 6, range = 2.5, rate = 0.8,
		damageType = "fire", air = true, detect = false,
		burnDps = 6, burnTime = 3.0,
		special = "Burns 6 a second for 3 s, ignores armour",
		unlock = { kind = "research", node = "L4" },
	},
	{
		id = "snapjaw", name = "Snapjaw", short = "Snapjaw",
		cost = 170, growth = 2, damage = 55, range = 1.5, rate = 0.4,
		damageType = "bite", air = false, detect = false,
		heavyMult = 2.0,
		special = "Double damage to Heavy pests",
		unlock = { kind = "fieldWave", field = "veggie", wave = 7 },
	},
	{
		id = "oak", name = "Oak Sentinel", short = "Oak",
		cost = 320, growth = 3, damage = 30, range = 4.5, rate = 0.8,
		damageType = "pierce", air = true, detect = true,
		special = "Sees hidden pests",
		unlock = { kind = "research", node = "L7" },
	},
}

local byId: { [string]: Seed } = {}
local order: { string } = {}
for i, s in list do
	table.freeze(s.unlock)
	if s.income then table.freeze(s.income) end
	if s.buff then table.freeze(s.buff) end
	byId[s.id] = s
	table.freeze(s)
	order[i] = s.id
end

return table.freeze({
	byId = table.freeze(byId),
	order = table.freeze(order),
})
