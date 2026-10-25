--!strict
-- Shared numbers for the rules (spec 6.3). Pure data.

local Constants = {
	GRID_W = 12,
	GRID_H = 8,
	TILE_STUDS = 4,
	TICK = 0.1,
	START_HEARTS = 20,
	LOADOUT_BASE = 5,
	LOADOUT_MAX = 6,
	UPGRADE_COST = table.freeze({ 0.6, 1.0 }),
	LEVEL_DMG = table.freeze({ 1.0, 1.4, 1.9 }),
	LEVEL_RANGE_BONUS = table.freeze({ 0, 0, 0.5 }),
	MAX_LEVEL = 3,
	SELL_REFUND = 0.6,
	SEEDLING_DMG = 0.5,
	WAVE_BONUS_BASE = 25,
	WAVE_BONUS_PER = 5,
	MAX_PESTS = 120,
	MAX_PLANTS = 40,
	SPEEDS = table.freeze({ 1, 1.5, 2 }),
	WEEKLY_MAX_SPEED = 1.5,
	FROST_HP = 1.4,
	FROST_PETALS = 1.5,
	SECOND_WIND_HEARTS = 10,
	SECOND_WIND_MIN_WAVE = 3,
	WEEKLY_WAVES = 40,
	WEEKLY_START_SAP = 350,
	LEVEL_SOIL = table.freeze({
		dmg = 0.10,
		rate = 0.05,
		sapMult = 0.10,
		hearts = 0,
		range = 0,
		startSap = 0,
		grow = 0,
	}),
	NO_BONUSES = table.freeze({
		dmg = 0,
		rate = 0,
		sapMult = 0,
		hearts = 0,
		range = 0,
		startSap = 0,
		grow = 0,
	}),
	SCHEMA_VERSION = 1,
	-- Float tolerance used in every range check (spec 3.1).
	EPS = 1e-9,
	TARGET_MODES = table.freeze({ "first", "strong", "last", "close" }),
}

return table.freeze(Constants)
