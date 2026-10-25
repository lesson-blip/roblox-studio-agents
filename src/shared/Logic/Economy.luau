--!strict
-- In-run Sap economy (spec 4.1). Petals arrive in M2. Pure.

local L: any = nil
local Economy = {}

function Economy.bind(bundle: any)
	L = bundle
end

-- round(v) = floor(v + 0.5) everywhere (spec 0).
function Economy.round(v: number): number
	return math.floor(v + 0.5)
end

-- Cost to go from `level` to `level + 1`, or nil at max level.
-- Uses whole number maths (x * 6 / 10) so 0.6 never drifts.
function Economy.upgradeCost(seedId: string, level: number): number?
	local seed = L.Seeds.byId[seedId]
	if not seed or level >= L.Constants.MAX_LEVEL or level < 1 then
		return nil
	end
	if level == 1 then
		return Economy.round(seed.cost * 6 / 10)
	end
	return seed.cost
end

-- What selling gives back. undo: placed in the current build phase, before Start wave.
function Economy.sellValue(spent: number, undo: boolean): number
	if undo then
		return spent
	end
	return math.floor(spent * 6 / 10)
end

function Economy.waveBonus(n: number): number
	return L.Constants.WAVE_BONUS_BASE + L.Constants.WAVE_BONUS_PER * n
end

function Economy.pestReward(reward: number, sapMult: number): number
	return Economy.round(reward * sapMult)
end

return Economy
