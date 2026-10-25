--!strict
-- Shared look constants and the tile to world maths used by server and client.
-- The models themselves are built from Parts in `Shared.Art` (see design/preview3d,
-- the three.js mock up they follow). One preview unit is UNIT studs.

local Visuals = {}

Visuals.TILE = 4 -- studs per tile (Constants.TILE_STUDS)
Visuals.PLOT_GAP = 180 -- studs between plots along X (a whole yard and its neighbours fit)
Visuals.UNIT = 2 -- studs per preview unit (the preview's tile is 2 units, ours 4 studs)

-- Heights in studs (preview TILE_TOP 0.42, PATH_Y 0.32, PLOT_TOP 0.52 units).
Visuals.TILE_TOP = 0.84 -- top of a lawn tile
Visuals.PATH_TOP = 0.64 -- top of the sandstone pavers, where pests walk
Visuals.PLOT_TOP = 1.04 -- top of a soil plot, where plants stand
Visuals.SEED_SCALE = 1.4 * 2 -- studs per unit for plants (scene.js placeSeed scale 1.4)
Visuals.PEST_SCALE = 1.7 * 2 -- studs per unit for pests (scene.js scale about 1.7)

-- Where the field must sit on screen (normalised -1..1 from the centre): clear of the
-- top HUD row and mostly clear of the seed cards, like design/preview3d hero.
Visuals.CAMERA_SAFE = { left = -0.97, right = 0.97, bottom = -0.62, top = 0.74 }

-- Empty soil beds dotted over the lawn (scene.js PLOTS); any that fall on a path are skipped.
Visuals.BEDS = {
	{ 3, 3 }, { 1, 2 }, { 6, 5 }, { 10, 3 }, { 3, 5 }, { 7, 2 }, { 2, 0 }, { 6, 0 },
	{ 10, 0 }, { 6, 3 }, { 8, 2 }, { 1, 5 }, { 5, 7 }, { 9, 7 }, { 10, 5 }, { 4, 2 },
}

-- Seed card gradients (top, bottom) as in the preview HUD; others get their own colour.
Visuals.CARD = {
	thorn = { Color3.fromRGB(155, 227, 106), Color3.fromRGB(79, 174, 60) },
	sunpetal = { Color3.fromRGB(255, 226, 122), Color3.fromRGB(242, 176, 30) },
	burr = { Color3.fromRGB(214, 184, 140), Color3.fromRGB(150, 104, 60) },
	nettle = { Color3.fromRGB(190, 236, 160), Color3.fromRGB(90, 160, 90) },
	dandelion = { Color3.fromRGB(191, 230, 255), Color3.fromRGB(111, 181, 234) },
	pumpkin = { Color3.fromRGB(255, 187, 114), Color3.fromRGB(238, 122, 42) },
	mint = { Color3.fromRGB(196, 248, 228), Color3.fromRGB(80, 190, 150) },
	chilli = { Color3.fromRGB(255, 160, 140), Color3.fromRGB(205, 50, 45) },
	snapjaw = { Color3.fromRGB(255, 154, 168), Color3.fromRGB(222, 74, 99) },
	oak = { Color3.fromRGB(200, 176, 140), Color3.fromRGB(120, 86, 50) },
} :: { [string]: { Color3 } }
export type SeedLook = { color: Color3, shape: string, height: number, width: number, accent: Color3 }
export type PestLook = { color: Color3, size: number, fly: number }

Visuals.SEEDS = {
	thorn = { color = Color3.fromRGB(60, 140, 70), shape = "Block", height = 2.2, width = 1.6, accent = Color3.fromRGB(230, 220, 120) },
	sunpetal = { color = Color3.fromRGB(250, 200, 40), shape = "Ball", height = 1.8, width = 1.8, accent = Color3.fromRGB(240, 120, 40) },
	burr = { color = Color3.fromRGB(130, 90, 50), shape = "Block", height = 1.4, width = 2.4, accent = Color3.fromRGB(90, 150, 60) },
	nettle = { color = Color3.fromRGB(90, 160, 90), shape = "Block", height = 1.0, width = 2.8, accent = Color3.fromRGB(160, 210, 120) },
	dandelion = { color = Color3.fromRGB(245, 245, 235), shape = "Ball", height = 2.6, width = 1.6, accent = Color3.fromRGB(110, 170, 70) },
	pumpkin = { color = Color3.fromRGB(235, 130, 40), shape = "Ball", height = 2.0, width = 2.4, accent = Color3.fromRGB(70, 120, 50) },
	mint = { color = Color3.fromRGB(150, 230, 200), shape = "Ball", height = 1.6, width = 2.0, accent = Color3.fromRGB(60, 160, 120) },
	chilli = { color = Color3.fromRGB(210, 40, 40), shape = "Block", height = 2.4, width = 1.4, accent = Color3.fromRGB(60, 130, 50) },
	snapjaw = { color = Color3.fromRGB(150, 50, 110), shape = "Block", height = 2.0, width = 2.2, accent = Color3.fromRGB(240, 240, 240) },
	oak = { color = Color3.fromRGB(110, 75, 40), shape = "Block", height = 3.6, width = 2.0, accent = Color3.fromRGB(50, 120, 50) },
} :: { [string]: SeedLook }

Visuals.PESTS = {
	aphid = { color = Color3.fromRGB(150, 220, 90), size = 0.9, fly = 0 },
	ant = { color = Color3.fromRGB(60, 40, 35), size = 1.0, fly = 0 },
	snail = { color = Color3.fromRGB(200, 160, 110), size = 1.6, fly = 0 },
	moth = { color = Color3.fromRGB(210, 200, 180), size = 1.1, fly = 3 },
	caterpillar = { color = Color3.fromRGB(110, 200, 60), size = 1.5, fly = 0 },
	beetle = { color = Color3.fromRGB(40, 70, 120), size = 1.8, fly = 0 },
	wasp = { color = Color3.fromRGB(240, 200, 30), size = 1.1, fly = 3.5 },
	mole = { color = Color3.fromRGB(90, 70, 60), size = 1.7, fly = 0 },
	slugmum = { color = Color3.fromRGB(170, 130, 160), size = 2.0, fly = 0 },
	possum = { color = Color3.fromRGB(120, 120, 130), size = 3.4, fly = 0 },
} :: { [string]: PestLook }

Visuals.GROUND = Color3.fromRGB(120, 170, 80)
Visuals.TILE_PLANTABLE = Color3.fromRGB(96, 156, 70)
Visuals.TILE_PLANTABLE_ALT = Color3.fromRGB(104, 164, 76)
Visuals.TILE_PATH = Color3.fromRGB(196, 168, 120)
Visuals.TILE_HINT = Color3.fromRGB(150, 210, 110)
Visuals.SHED = Color3.fromRGB(150, 80, 60)
Visuals.GATE = Color3.fromRGB(200, 190, 170)
Visuals.RANGE = Color3.fromRGB(255, 255, 255)

-- World origin of a plot (its tile (0, 0) corner).
function Visuals.plotOrigin(plotIndex: number): Vector3
	return Vector3.new((plotIndex - 1) * Visuals.PLOT_GAP, 0, 0)
end

-- World position of a point in tile units (tile centres are x + 0.5, y + 0.5).
function Visuals.toWorld(origin: Vector3, tx: number, ty: number, height: number?): Vector3
	return origin + Vector3.new(tx * Visuals.TILE, height or 0, ty * Visuals.TILE)
end

function Visuals.tileCentre(origin: Vector3, x: number, y: number, height: number?): Vector3
	return Visuals.toWorld(origin, x + 0.5, y + 0.5, height)
end

return Visuals
