--!strict
-- The 10 pests (spec 3.3). Pure data, keyed by id, with an order list.

export type Pest = {
	id: string,
	name: string,
	hp: number,
	speed: number,
	reward: number,
	leak: number,
	armour: number,
	resist: { [string]: number },
	heavy: boolean,
	flying: boolean,
	burrow: boolean,
	regen: number?,
	splitInto: string?,
	splitCount: number?,
	boss: boolean,
	threat: number,
	minWave: number?, -- nil for boss waves only
	tip: string,
}

local list: { Pest } = {
	{ id = "aphid", name = "Aphid", hp = 18, speed = 1.2, reward = 3, leak = 1, armour = 0,
		resist = {}, heavy = false, flying = false, burrow = false, boss = false,
		threat = 2, minWave = 1, tip = "Aphids are quick but weak." },
	{ id = "ant", name = "Ant", hp = 34, speed = 1.0, reward = 4, leak = 1, armour = 0,
		resist = {}, heavy = false, flying = false, burrow = false, boss = false,
		threat = 3, minWave = 1, tip = "Ants come in big lines." },
	{ id = "snail", name = "Snail", hp = 110, speed = 0.5, reward = 8, leak = 2, armour = 2,
		resist = { poison = 1.5 }, heavy = true, flying = false, burrow = false, boss = false,
		threat = 8, minWave = 2, tip = "Snails are tough. Upgrade or add plants." },
	{ id = "moth", name = "Moth", hp = 36, speed = 1.4, reward = 5, leak = 1, armour = 0,
		resist = {}, heavy = false, flying = true, burrow = false, boss = false,
		threat = 4, minWave = 3, tip = "Moths fly! Not every plant reaches them." },
	{ id = "caterpillar", name = "Caterpillar", hp = 140, speed = 0.8, reward = 10, leak = 2, armour = 0,
		resist = { fire = 1.5 }, regen = 4, heavy = false, flying = false, burrow = false, boss = false,
		threat = 10, minWave = 4, tip = "Caterpillars heal. Hit them hard and fast." },
	{ id = "beetle", name = "Beetle", hp = 200, speed = 0.7, reward = 12, leak = 3, armour = 5,
		resist = { pierce = 0.75, blunt = 1.25 }, heavy = true, flying = false, burrow = false, boss = false,
		threat = 16, minWave = 5, tip = "Beetles have shells. Big hits work best." },
	{ id = "wasp", name = "Wasp", hp = 70, speed = 1.7, reward = 8, leak = 2, armour = 0,
		resist = { poison = 0.5 }, heavy = false, flying = true, burrow = false, boss = false,
		threat = 7, minWave = 6, tip = "Wasps fly fast. Use sky plants." },
	{ id = "mole", name = "Mole", hp = 170, speed = 0.8, reward = 14, leak = 3, armour = 1,
		resist = { blunt = 1.25 }, heavy = false, flying = false, burrow = true, boss = false,
		threat = 14, minWave = 5, tip = "Moles hide underground. Mint Mist finds them." },
	{ id = "slugmum", name = "Slug Matriarch", hp = 280, speed = 0.5, reward = 18, leak = 4, armour = 0,
		resist = { fire = 0.5, poison = 1.5 }, heavy = true, flying = false, burrow = false, boss = false,
		splitInto = "aphid", splitCount = 3,
		threat = 26, minWave = 8, tip = "Slug mums split into aphids." },
	{ id = "possum", name = "Night Possum", hp = 2600, speed = 0.45, reward = 150, leak = 20, armour = 4,
		resist = { fire = 0.75, bite = 1.25 }, heavy = true, flying = false, burrow = false, boss = true,
		threat = 200, minWave = nil, tip = "The possum is here! Everything on it!" },
}

local byId: { [string]: Pest } = {}
local order: { string } = {}
local index: { [string]: number } = {}
for i, p in list do
	table.freeze(p.resist)
	byId[p.id] = p
	table.freeze(p)
	order[i] = p.id
	index[p.id] = i
end

return table.freeze({
	byId = table.freeze(byId),
	order = table.freeze(order),
	-- Small integer per pest type, used to pack snapshots.
	index = table.freeze(index),
})
