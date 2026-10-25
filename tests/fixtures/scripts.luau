--!strict
-- Reference build orders (spec Appendix B) and research levels (spec 3.7).
-- { "p", seed, x, y } plants; { "u", x, y } upgrades the plant on that tile.

local function P(seed: string, x: number, y: number): { any }
	return { "p", seed, x, y }
end
local function U(x: number, y: number): { any }
	return { "u", x, y }
end

local S: { [string]: any } = {}

S.backyard = {
	field = "backyard",
	loadout = { "thorn", "sunpetal", "burr" },
	steps = {
		P("thorn", 8, 2), P("thorn", 3, 5), P("sunpetal", 11, 0), P("thorn", 5, 3), P("thorn", 6, 5),
		P("burr", 8, 3), U(8, 2), U(3, 5), P("thorn", 5, 2), U(5, 3), U(6, 5), P("burr", 3, 3),
		U(8, 2), U(3, 5), P("thorn", 10, 5), U(11, 0),
	},
}

S.backyardLazy = {
	field = "backyard",
	loadout = { "thorn" },
	steps = { P("thorn", 8, 2), P("thorn", 3, 5), P("thorn", 5, 3) },
}

S.veggie = {
	field = "veggie",
	loadout = { "thorn", "sunpetal", "dandelion", "pumpkin", "snapjaw" },
	steps = {
		P("thorn", 4, 1), P("thorn", 7, 3), P("sunpetal", 0, 7), P("dandelion", 5, 2), P("thorn", 7, 4),
		P("sunpetal", 1, 7), P("pumpkin", 4, 2), U(4, 1), U(7, 3), P("dandelion", 8, 5), P("pumpkin", 8, 3),
		U(5, 2), U(4, 2), P("thorn", 10, 4), U(0, 7), U(1, 7), P("snapjaw", 5, 5), U(8, 5), U(8, 3), U(5, 2),
		U(4, 2), U(4, 1), U(7, 3), P("pumpkin", 2, 1), U(2, 1), P("dandelion", 7, 5), U(7, 5), U(8, 5),
		U(8, 3), U(2, 1), U(7, 5), U(7, 4), U(7, 4),
	},
}

S.orchard = {
	field = "orchard",
	loadout = { "thorn", "mint", "pumpkin", "dandelion", "snapjaw" },
	steps = {
		P("thorn", 4, 2), P("thorn", 7, 2), P("mint", 7, 4), P("pumpkin", 5, 2), P("dandelion", 2, 2),
		P("thorn", 9, 4), U(4, 2), U(7, 2), P("snapjaw", 9, 3), P("mint", 2, 4), P("pumpkin", 7, 5),
		U(5, 2), U(2, 2), P("dandelion", 3, 2), U(9, 3), P("pumpkin", 4, 4), U(7, 5), U(5, 2), U(2, 2),
		U(4, 2), U(7, 2), P("snapjaw", 9, 2), U(9, 3), P("pumpkin", 5, 4), U(5, 4), U(3, 2), U(7, 5),
		U(4, 4), P("dandelion", 9, 5), U(9, 5), U(9, 2), U(5, 4), U(3, 2), U(4, 4), U(9, 5), U(9, 2),
		U(9, 4), U(9, 4), U(7, 4), U(2, 4),
	},
}

S.R0 = {}
S.RMID = { dmg = 0.10, rate = 0.05, startSap = 50, sapMult = 0.10 }
S.RFULL = { dmg = 0.20, rate = 0.10, startSap = 100, hearts = 5, sapMult = 0.20, range = 0.25, grow = 1 }

return S
