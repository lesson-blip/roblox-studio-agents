--!strict
-- The run simulation (spec 3.1 and 6.3 "WaveSim"). Pure: no services, no clock.
-- The server and the Lune tests run exactly this code.

local L: any = nil
local WaveSim = {}
WaveSim.__index = WaveSim

function WaveSim.bind(bundle: any)
	L = bundle
end

export type Plant = {
	id: number,
	seed: string,
	x: number,
	y: number,
	cx: number,
	cy: number,
	level: number,
	growth: number,
	cooldown: number,
	mode: string,
	spent: number,
	buildIndex: number,
}

export type PestState = {
	id: number,
	type: string,
	hp: number,
	maxHp: number,
	d: number,
	slow: number,
	slowTime: number,
	burn: number,
	burnTime: number,
	burnClock: number,
	burrowClock: number,
	hidden: boolean,
}

-- Modifier effects, by id (spec 3.5). Weekly only; fixed fields pass none.
local MODIFIER_EFFECTS: { [string]: { [string]: number } } = {
	drought = { sapMult = 0.75, startSap = 100 },
	bloom = { sunMult = 2 },
	rainy = { grow = 1 },
	heatwave = { fireMult = 1.3, speedMult = 1.1 },
	fog = { range = -0.5 },
	swarm = { hpMult = 0.7 },
	ironshell = { armour = 2 },
	nightshift = { mintRange = 0.5 },
}
WaveSim.MODIFIER_EFFECTS = MODIFIER_EFFECTS

local function modsFrom(ids: { string }?): any
	local m: { [string]: number } = {
		sapMult = 1, startSap = 0, sunMult = 1, grow = 0, fireMult = 1, speedMult = 1,
		range = 0, hpMult = 1, armour = 0, mintRange = 0,
	}
	for _, id in ids or ({} :: { string }) do
		local e = MODIFIER_EFFECTS[id]
		if e then
			for k, v in e do
				if k == "sapMult" or k == "sunMult" or k == "fireMult" or k == "speedMult" or k == "hpMult" then
					m[k] *= v
				else
					m[k] += v
				end
			end
		end
	end
	return m
end

local function withDefaults(b: any): any
	b = b or {}
	return {
		dmg = b.dmg or 0, rate = b.rate or 0, sapMult = b.sapMult or 0, hearts = b.hearts or 0,
		range = b.range or 0, startSap = b.startSap or 0, grow = b.grow or 0,
	}
end

-- config = { field, modifiers?, bonuses?, loadout?, hpExtra?, weekly?, secondWindAllowed?, maxWaves? }
function WaveSim.new(config: any)
	local C = L.Constants
	local field = config.field
	local bonuses = withDefaults(config.bonuses)
	local mods = modsFrom(config.modifiers)
	local self: any = setmetatable({}, WaveSim)
	self.field = field
	self.path = L.Grid.expandPath(field.waypoints)
	self.bonuses = bonuses
	self.mods = mods
	self.hpExtra = config.hpExtra or 1
	self.weekly = config.weekly == true
	self.secondWindAllowed = config.secondWindAllowed == true
	self.totalWaves = if self.weekly then C.WEEKLY_WAVES else #field.waves
	if config.loadout then
		local set = {}
		for _, id in config.loadout do
			set[id] = true
		end
		self.loadout = set
	else
		self.loadout = nil -- nil means every seed may be planted (tests only)
	end
	self.sap = field.startSap + bonuses.startSap + mods.startSap
	self.hearts = C.START_HEARTS + bonuses.hearts
	self.sapMult = (1 + bonuses.sapMult) * mods.sapMult
	self.phase = "build"
	self.wave = 0 -- waves cleared
	self.buildIndex = 1
	self.plants = {} :: { Plant }
	self.pests = {} :: { PestState }
	self.nextPlantId = 1
	self.nextPestId = 1
	self.events = {}
	self.schedule = {}
	self.schedIndex = 1
	self.waveTick = 0
	self.totalTicks = 0
	self.secondWindUsed = false
	self.result = nil
	return self
end

local function emit(self: any, ev: any)
	table.insert(self.events, ev)
end

function WaveSim.findPlant(self: any, plantId: number): (Plant?, number?)
	for i, p in self.plants do
		if p.id == plantId then
			return p, i
		end
	end
	return nil, nil
end

function WaveSim.plantAt(self: any, x: number, y: number): Plant?
	for _, p in self.plants do
		if p.x == x and p.y == y then
			return p
		end
	end
	return nil
end

local function actionPhaseError(self: any): string?
	if self.phase == "over" then
		return "run_over"
	end
	if self.phase ~= "build" and self.phase ~= "wave" then
		return "wrong_phase"
	end
	return nil
end

function WaveSim.place(self: any, seedId: string, x: number, y: number): (boolean, any)
	local err = actionPhaseError(self)
	if err then
		return false, err
	end
	local seed = L.Seeds.byId[seedId]
	if not seed then
		return false, "bad_seed"
	end
	if self.loadout and not self.loadout[seedId] then
		return false, "not_in_loadout"
	end
	if not L.Grid.inBounds(x, y) then
		return false, "out_of_bounds"
	end
	if L.Grid.isPathTile(self.path, x, y) then
		return false, "on_path"
	end
	if self:plantAt(x, y) then
		return false, "tile_taken"
	end
	if #self.plants >= L.Constants.MAX_PLANTS then
		return false, "too_many_plants"
	end
	if self.sap < seed.cost then
		return false, "no_sap"
	end
	self.sap -= seed.cost
	local id = self.nextPlantId
	self.nextPlantId += 1
	local plant: Plant = {
		id = id,
		seed = seedId,
		x = x,
		y = y,
		cx = x + 0.5,
		cy = y + 0.5,
		level = 1,
		growth = math.max(0, seed.growth - self.bonuses.grow - self.mods.grow),
		cooldown = 0,
		mode = "first",
		spent = seed.cost,
		-- Only plants placed in a build phase can be undone at full value.
		buildIndex = if self.phase == "build" then self.buildIndex else -1,
	}
	table.insert(self.plants, plant)
	emit(self, { kind = "placed", plant = id, seed = seedId, x = x, y = y })
	return true, id
end

function WaveSim.upgrade(self: any, plantId: number): (boolean, any)
	local err = actionPhaseError(self)
	if err then
		return false, err
	end
	local p = self:findPlant(plantId)
	if not p then
		return false, "no_plant"
	end
	local cost = L.Economy.upgradeCost(p.seed, p.level)
	if not cost then
		return false, "max_level"
	end
	if self.sap < cost then
		return false, "no_sap"
	end
	self.sap -= cost
	p.level += 1
	p.spent += cost
	emit(self, { kind = "upgraded", plant = p.id, level = p.level })
	return true, p.level
end

function WaveSim.canUndo(self: any, p: Plant): boolean
	return self.phase == "build" and p.buildIndex == self.buildIndex
end

function WaveSim.sell(self: any, plantId: number): (boolean, any)
	local err = actionPhaseError(self)
	if err then
		return false, err
	end
	local p, i = self:findPlant(plantId)
	if not p or not i then
		return false, "no_plant"
	end
	local refund = L.Economy.sellValue(p.spent, self:canUndo(p))
	self.sap += refund
	table.remove(self.plants, i)
	emit(self, { kind = "sold", plant = p.id, refund = refund })
	return true, refund
end

function WaveSim.setTargetMode(self: any, plantId: number, mode: string): (boolean, any)
	local err = actionPhaseError(self)
	if err then
		return false, err
	end
	local p = self:findPlant(plantId)
	if not p then
		return false, "no_plant"
	end
	if not table.find(L.Constants.TARGET_MODES, mode) then
		return false, "bad_mode"
	end
	p.mode = mode
	return true, mode
end

-- Builds the spawn list for the next wave: sorted by time, then group order.
local function buildSchedule(self: any, waveDef: { any }): { any }
	local sched: { any } = {}
	for gi, g in waveDef do
		for k = 0, g.count - 1 do
			table.insert(sched, { time = g.start + k * g.gap, group = gi, k = k, pest = g.pest, hpMult = g.hpMult or 1 })
		end
	end
	table.sort(sched, function(a: any, b: any): boolean
		if a.time ~= b.time then
			return a.time < b.time
		end
		if a.group ~= b.group then
			return a.group < b.group
		end
		return a.k < b.k
	end)
	return sched
end

function WaveSim.waveDef(self: any, n: number): { any }?
	return self.field.waves[n]
end

function WaveSim.startWave(self: any): (boolean, any)
	if self.phase == "over" then
		return false, "run_over"
	end
	if self.phase ~= "build" then
		return false, "wrong_phase"
	end
	local def = self:waveDef(self.wave + 1)
	if not def then
		return false, "run_over"
	end
	self.schedule = buildSchedule(self, def)
	self.schedIndex = 1
	self.waveTick = 0
	self.phase = "wave"
	self.buildIndex += 1
	emit(self, { kind = "waveStarted", wave = self.wave + 1 })
	return true, self.wave + 1
end

local function spawnPest(self: any, typeId: string, d: number, hpMult: number)
	local def = L.Pests.byId[typeId]
	local hp = def.hp * self.field.hpScale * self.mods.hpMult * self.hpExtra * hpMult
	local id = self.nextPestId
	self.nextPestId += 1
	local pest: PestState = {
		id = id, type = typeId, hp = hp, maxHp = hp, d = d,
		slow = 0, slowTime = 0, burn = 0, burnTime = 0, burnClock = 0,
		burrowClock = 0, hidden = false,
	}
	table.insert(self.pests, pest)
	emit(self, { kind = "spawned", pest = id, type = typeId })
	return pest
end

local function mintRange(self: any): number
	return L.Seeds.byId.mint.range + self.mods.mintRange
end

-- Inside a grown Mint Mist's range (position in tile units).
local function revealedAt(self: any, px: number, py: number): boolean
	local r = mintRange(self) + L.Constants.EPS
	for _, q in self.plants do
		if q.seed == "mint" and q.growth == 0 then
			if L.Grid.distance(px, py, q.cx, q.cy) <= r then
				return true
			end
		end
	end
	return false
end

-- Largest buff from any grown Mint Mist covering the plant (never itself, never stacked).
local function mintBuff(self: any, p: Plant): number
	local best = 0
	local r = mintRange(self) + L.Constants.EPS
	local buffs = L.Seeds.byId.mint.buff
	for _, q in self.plants do
		if q ~= p and q.seed == "mint" and q.growth == 0 then
			if L.Grid.distance(q.cx, q.cy, p.cx, p.cy) <= r then
				best = math.max(best, buffs[q.level])
			end
		end
	end
	return best
end

local function damagePest(self: any, pest: PestState, amount: number)
	pest.hp -= amount
end

local function plantAct(self: any, p: Plant)
	local C = L.Constants
	local seed = L.Seeds.byId[p.seed]
	if seed.rate <= 0 then
		return
	end
	p.cooldown -= C.TICK
	if p.cooldown > 0 then
		return
	end
	local range = seed.range + C.LEVEL_RANGE_BONUS[p.level] + self.bonuses.range + self.mods.range
	local candidates = {}
	local limit = range + C.EPS
	for _, e in self.pests do
		local ex, ey = L.Grid.positionAt(self.path, e.d)
		if L.Grid.distance(ex, ey, p.cx, p.cy) <= limit then
			local revealed = (not e.hidden) or seed.detect or revealedAt(self, ex, ey)
			if L.Combat.canTarget(seed, e, revealed) then
				table.insert(candidates, { id = e.id, d = e.d, hp = e.hp, x = ex, y = ey, pest = e })
			end
		end
	end
	if #candidates == 0 then
		return
	end
	p.cooldown = 1 / (seed.rate * (1 + self.bonuses.rate) * (1 + mintBuff(self, p)))
	local isSeedling = p.growth > 0
	if seed.aura then
		local amount = L.Combat.baseDamage(seed, p.level, self.bonuses, isSeedling, nil)
		for _, c in candidates do
			local def = L.Pests.byId[c.pest.type]
			damagePest(self, c.pest, L.Combat.dotDamage(amount, seed.damageType, def, self.mods))
		end
		emit(self, { kind = "shot", plant = p.id, pest = candidates[1].id, aura = true })
		return
	end
	local target = L.Combat.pickTarget(candidates, p.mode, p.cx, p.cy)
	if not target then
		return
	end
	local tp: PestState = target.pest
	local tdef = L.Pests.byId[tp.type]
	if seed.splash then
		-- Every non flying pest near the target takes a direct hit (hidden ones only if revealed).
		local amount = L.Combat.baseDamage(seed, p.level, self.bonuses, isSeedling, nil)
		local sr = seed.splash + C.EPS
		for _, e in self.pests do
			local edef = L.Pests.byId[e.type]
			if not edef.flying then
				local ex, ey = L.Grid.positionAt(self.path, e.d)
				if not e.hidden or revealedAt(self, ex, ey) then
					if L.Grid.distance(ex, ey, target.x, target.y) <= sr then
						local typed = L.Combat.typed(amount, seed.damageType, edef, self.mods)
						damagePest(self, e, L.Combat.applyArmour(typed, edef, self.mods))
					end
				end
			end
		end
	else
		damagePest(self, tp, L.Combat.hitDamage(seed, p.level, self.bonuses, isSeedling, tdef, self.mods))
	end
	if seed.slow then
		tp.slow = math.max(if tp.slowTime > 0 then tp.slow else 0, seed.slow)
		tp.slowTime = seed.slowTime
	end
	if seed.burnDps then
		tp.burn = L.Combat.burnDps(seed, p.level, self.bonuses, isSeedling)
		tp.burnTime = seed.burnTime
	end
	emit(self, { kind = "shot", plant = p.id, pest = tp.id })
end

local function endWave(self: any)
	self.wave += 1
	local bonus = L.Economy.waveBonus(self.wave)
	self.sap += bonus
	for _, p in self.plants do
		if p.growth > 0 then
			p.growth -= 1
		end
	end
	local sunIncome = 0
	for _, p in self.plants do
		local seed = L.Seeds.byId[p.seed]
		if seed.income and p.growth == 0 then
			sunIncome += seed.income[p.level] * self.mods.sunMult
		end
	end
	self.sap += sunIncome
	emit(self, { kind = "waveEnded", wave = self.wave, bonus = bonus, income = sunIncome })
	if self.wave >= self.totalWaves then
		self.phase = "over"
		self.result = "won"
		emit(self, { kind = "runEnded", won = true, wave = self.wave, hearts = self.hearts })
	else
		self.phase = "build"
	end
end

-- One TICK of game time (spec 3.1 "Tick order"). Does nothing outside the wave phase.
function WaveSim.step(self: any)
	if self.phase ~= "wave" then
		return
	end
	local C = L.Constants
	local TICK = C.TICK
	local t = self.waveTick * TICK
	self.totalTicks += 1

	-- 1. Spawns.
	local sched = self.schedule
	while self.schedIndex <= #sched and sched[self.schedIndex].time <= t + C.EPS and #self.pests < C.MAX_PESTS do
		local s = sched[self.schedIndex]
		spawnPest(self, s.pest, 0, s.hpMult)
		self.schedIndex += 1
	end

	-- 2. Movement, slow, regeneration and burning.
	for _, e in self.pests do
		local def = L.Pests.byId[e.type]
		if def.burrow then
			e.burrowClock = (e.burrowClock + TICK) % 5.0
			e.hidden = e.burrowClock < 3.0
		end
		local slow = if e.slowTime > 0 then e.slow else 0
		e.d += def.speed * self.mods.speedMult * (1 - slow) * TICK
		if e.slowTime > 0 then
			e.slowTime -= TICK
		end
		if def.regen and e.burnTime <= 0 then
			e.hp = math.min(e.maxHp, e.hp + def.regen * TICK)
		end
		if e.burnTime > 0 then
			e.burnClock += TICK
			if e.burnClock >= 0.5 - C.EPS then
				e.burnClock -= 0.5
				damagePest(self, e, L.Combat.dotDamage(e.burn * 0.5, "fire", def, self.mods))
			end
			e.burnTime -= TICK
		end
	end

	-- 3. Leaks.
	local length = self.path.length
	local i = 1
	while i <= #self.pests do
		local e = self.pests[i]
		if e.d >= length then
			local def = L.Pests.byId[e.type]
			self.hearts -= def.leak
			table.remove(self.pests, i)
			emit(self, { kind = "leaked", pest = e.id, type = e.type, leak = def.leak })
		else
			i += 1
		end
	end

	-- 4. Plants act in placement order.
	for _, p in self.plants do
		plantAct(self, p)
	end

	-- 5. Defeats and splits.
	i = 1
	local children = {}
	while i <= #self.pests do
		local e = self.pests[i]
		if e.hp <= 0 then
			local def = L.Pests.byId[e.type]
			local reward = L.Economy.pestReward(def.reward, self.sapMult)
			self.sap += reward
			table.remove(self.pests, i)
			emit(self, { kind = "defeated", pest = e.id, type = e.type, reward = reward, d = e.d })
			if def.splitInto then
				for k = 0, (def.splitCount or 0) - 1 do
					table.insert(children, { type = def.splitInto, d = math.max(0, e.d - 0.3 * k) })
				end
			end
		else
			i += 1
		end
	end
	for _, c in children do
		spawnPest(self, c.type, c.d, 1)
	end

	self.waveTick += 1

	-- Hearts and wave end.
	if self.hearts <= 0 then
		if self.secondWindAllowed and not self.secondWindUsed and (self.wave + 1) >= C.SECOND_WIND_MIN_WAVE then
			self.phase = "lostPending"
			emit(self, { kind = "lostPending", wave = self.wave + 1 })
		else
			self.phase = "over"
			self.result = "lost"
			emit(self, { kind = "runEnded", won = false, wave = self.wave, hearts = self.hearts })
		end
		return
	end
	if self.schedIndex > #sched and #self.pests == 0 then
		endWave(self)
	end
end

function WaveSim.runUntilPhaseChange(self: any, maxTicks: number?): string
	local start = self.phase
	local limit = maxTicks or 100000
	local n = 0
	while self.phase == start and n < limit do
		self:step()
		n += 1
		if start ~= "wave" then
			break
		end
	end
	return self.phase
end

function WaveSim.secondWind(self: any): (boolean, any)
	if self.secondWindUsed then
		return false, "second_wind_used"
	end
	if self.phase ~= "lostPending" then
		return false, "wrong_phase"
	end
	self.secondWindUsed = true
	self.hearts = L.Constants.SECOND_WIND_HEARTS
	self.phase = "wave"
	emit(self, { kind = "secondWind" })
	return true, self.hearts
end

function WaveSim.giveUp(self: any)
	if self.phase == "over" then
		return
	end
	self.phase = "over"
	self.result = "lost"
	emit(self, { kind = "runEnded", won = false, wave = self.wave, hearts = self.hearts })
end

function WaveSim.drainEvents(self: any): { any }
	local ev = self.events
	self.events = {}
	return ev
end

-- Pests spawned so far and still to come in this wave (for the HUD bar).
function WaveSim.waveProgress(self: any): (number, number)
	local spawned = self.schedIndex - 1
	return spawned, #self.schedule
end

-- A copy that is safe to hand to views.
function WaveSim.getState(self: any): any
	local plants = {}
	for i, p in self.plants do
		plants[i] = {
			id = p.id, seed = p.seed, x = p.x, y = p.y, level = p.level, growth = p.growth,
			mode = p.mode, spent = p.spent, canUndo = self:canUndo(p),
		}
	end
	local pests = {}
	for i, e in self.pests do
		pests[i] = {
			id = e.id, type = e.type, hp = e.hp, maxHp = e.maxHp, d = e.d,
			hidden = e.hidden, slowed = e.slowTime > 0, burning = e.burnTime > 0,
		}
	end
	local spawned, total = self:waveProgress()
	return {
		fieldId = self.field.id,
		phase = self.phase,
		wave = self.wave,
		totalWaves = self.totalWaves,
		hearts = self.hearts,
		sap = self.sap,
		plants = plants,
		pests = pests,
		spawned = spawned,
		scheduled = total,
		result = self.result,
		secondWindUsed = self.secondWindUsed,
		secondWindAllowed = self.secondWindAllowed,
		ticks = self.totalTicks,
	}
end

return WaveSim
