--!strict
-- Damage and targeting (spec 3.1 "Damage" and "Attacks"). Pure.
-- bonuses: research style table { dmg, rate, range, ... }.
-- mods: { armour = extra armour, fireMult = fire damage multiplier }.

local L: any = nil
local Combat = {}

function Combat.bind(bundle: any)
	L = bundle
end

local function levelDmg(level: number): number
	return L.Constants.LEVEL_DMG[level]
end

-- Damage before resist and armour.
function Combat.baseDamage(seed: any, level: number, bonuses: any, isSeedling: boolean, pest: any?): number
	local seedling = if isSeedling then L.Constants.SEEDLING_DMG else 1
	local vs = 1
	if pest then
		if pest.flying and seed.airMult then
			vs = seed.airMult
		end
		if pest.heavy and seed.heavyMult then
			vs = seed.heavyMult
		end
	end
	return seed.damage * levelDmg(level) * (1 + (bonuses.dmg or 0)) * seedling * vs
end

-- Applies resist and the Heatwave fire bonus.
function Combat.typed(amount: number, damageType: string?, pest: any, mods: any?): number
	local v = amount
	if damageType then
		v *= (pest.resist[damageType] or 1)
		if damageType == "fire" and mods and mods.fireMult then
			v *= mods.fireMult
		end
	end
	return v
end

-- A direct hit: armour applies, minimum 1.
function Combat.applyArmour(typedAmount: number, pest: any, mods: any?): number
	local armour = pest.armour + (if mods and mods.armour then mods.armour else 0)
	return math.max(1, typedAmount - armour)
end

-- Final damage of one direct hit (spec 3.1).
function Combat.hitDamage(seed: any, level: number, bonuses: any, isSeedling: boolean, pest: any, mods: any?): number
	local base = Combat.baseDamage(seed, level, bonuses, isSeedling, pest)
	return Combat.applyArmour(Combat.typed(base, seed.damageType, pest, mods), pest, mods)
end

-- Damage over time (aura, burn): resist applies, no armour, no minimum.
function Combat.dotDamage(amount: number, damageType: string?, pest: any, mods: any?): number
	return Combat.typed(amount, damageType, pest, mods)
end

-- Burn damage per second set by a Chilli hit.
function Combat.burnDps(seed: any, level: number, bonuses: any, isSeedling: boolean): number
	local seedling = if isSeedling then L.Constants.SEEDLING_DMG else 1
	return (seed.burnDps or 0) * levelDmg(level) * (1 + (bonuses.dmg or 0)) * seedling
end

-- Whether a seed may target a pest. revealed: inside a grown Mint Mist's range.
function Combat.canTarget(seed: any, pestState: any, revealed: boolean): boolean
	local def = L.Pests.byId[pestState.type]
	if def.flying and not seed.air then
		return false
	end
	if pestState.hidden and not seed.detect and not revealed then
		return false
	end
	return true
end

-- Picks a target. Candidates have { id, d, hp, x, y }. Ties go to the lowest id
-- (the pest that spawned first).
function Combat.pickTarget(candidates: { any }, mode: string, plantX: number, plantY: number): any?
	local best: any = nil
	local bestKey = 0
	for _, c in candidates do
		local key: number
		if mode == "last" then
			key = -c.d
		elseif mode == "strong" then
			key = c.hp
		elseif mode == "close" then
			local dx, dy = c.x - plantX, c.y - plantY
			key = -(dx * dx + dy * dy)
		else
			key = c.d
		end
		if best == nil or key > bestKey or (key == bestKey and c.id < best.id) then
			best = c
			bestKey = key
		end
	end
	return best
end

return Combat
