--!strict
-- Payload checks for remotes (spec 6.3 and 6.5). Each returns (ok, value or errCode).

local L: any = nil
local Validate = {}
local BAD = "bad_payload"

function Validate.bind(bundle: any)
	L = bundle
end

local function isFiniteNumber(v: any): boolean
	return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

function Validate.int(v: any, min: number, max: number): (boolean, any)
	if not isFiniteNumber(v) or v ~= math.floor(v) or v < min or v > max then
		return false, BAD
	end
	return true, v
end

function Validate.str(v: any, maxLen: number): (boolean, any)
	if type(v) ~= "string" or #v > maxLen or #v == 0 then
		return false, BAD
	end
	return true, v
end

-- set may be a list or a { [value] = true } table.
function Validate.oneOf(v: any, set: { any }): (boolean, any)
	if v == nil or (type(v) == "number" and v ~= v) or type(v) == "table" then
		return false, BAD
	end
	if (set :: any)[v] == true then
		return true, v
	end
	for _, item in ipairs(set) do
		if item == v then
			return true, v
		end
	end
	return false, BAD
end

function Validate.seedId(v: any): (boolean, any)
	local ok = Validate.str(v, 24)
	if not ok or L.Seeds.byId[v] == nil then
		return false, BAD
	end
	return true, v
end

function Validate.tile(x: any, y: any): (boolean, any)
	local C = L.Constants
	local okX = Validate.int(x, 0, C.GRID_W - 1)
	local okY = Validate.int(y, 0, C.GRID_H - 1)
	if not okX or not okY then
		return false, BAD
	end
	return true, { x = x, y = y }
end

function Validate.plantId(v: any): (boolean, any)
	return Validate.int(v, 1, 1000000)
end

-- unlocked: { [seedId] = true }; slots: how many seeds are allowed.
function Validate.loadout(list: any, unlocked: { [string]: boolean }, slots: number): (boolean, any)
	if type(list) ~= "table" then
		return false, BAD
	end
	local n = #list
	if n < 1 or n > slots then
		return false, BAD
	end
	local count = 0
	for _ in pairs(list) do
		count += 1
	end
	if count ~= n then
		return false, BAD -- not a plain array
	end
	local seen: { [string]: boolean } = {}
	local out = {}
	for i = 1, n do
		local id = list[i]
		local ok = Validate.seedId(id)
		if not ok or seen[id] or not unlocked[id] then
			return false, BAD
		end
		seen[id] = true
		out[i] = id
	end
	return true, out
end

-- Rate limits per remote (spec 6.5): rate is tokens a second, burst the bucket size.
Validate.LIMITS = table.freeze({
	RequestStart = { rate = 0.5, burst = 1 },
	PlaceSeed = { rate = 8, burst = 10 },
	UpgradePlant = { rate = 8, burst = 8 },
	SellPlant = { rate = 8, burst = 8 },
	SetTargetMode = { rate = 8, burst = 8 },
	StartWave = { rate = 2, burst = 2 },
	SetSpeed = { rate = 2, burst = 2 },
	LeaveRun = { rate = 1, burst = 1 },
})

local MODES = { "normal", "frost", "weekly" }

-- Checks the arguments of one remote call. Returns (ok, payload table or "bad_payload").
-- Only remotes built in M1 are listed; any other name is refused.
function Validate.payload(remote: string, args: { any }): (boolean, any)
	local a, b, c = args[1], args[2], args[3]
	if remote == "RequestStart" then
		local ok1 = Validate.str(a, 24)
		local ok2 = Validate.oneOf(b, MODES)
		if not ok1 or not ok2 then
			return false, BAD
		end
		return true, { fieldId = a, mode = b }
	elseif remote == "PlaceSeed" then
		local ok1 = Validate.seedId(a)
		local ok2, tile = Validate.tile(b, c)
		if not ok1 or not ok2 then
			return false, BAD
		end
		return true, { seedId = a, x = tile.x, y = tile.y }
	elseif remote == "UpgradePlant" or remote == "SellPlant" then
		local ok1 = Validate.plantId(a)
		if not ok1 then
			return false, BAD
		end
		return true, { plantId = a }
	elseif remote == "SetTargetMode" then
		local ok1 = Validate.plantId(a)
		local ok2 = Validate.oneOf(b, L.Constants.TARGET_MODES)
		if not ok1 or not ok2 then
			return false, BAD
		end
		return true, { plantId = a, mode = b }
	elseif remote == "StartWave" or remote == "LeaveRun" then
		return true, {}
	elseif remote == "SetSpeed" then
		local ok1 = Validate.oneOf(a, L.Constants.SPEEDS)
		if not ok1 then
			return false, BAD
		end
		return true, { speed = a }
	end
	return false, BAD
end

return Validate
