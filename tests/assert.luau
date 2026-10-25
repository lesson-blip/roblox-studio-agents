--!strict
-- A tiny assert library: eq, near, truthy, throws, deepEq.

local A = {}

local function show(v: any): string
	if type(v) == "string" then
		return string.format("%q", v)
	end
	return tostring(v)
end

local function fail(msg: string, label: string?)
	error((if label then label .. ": " else "") .. msg, 3)
end

function A.eq(actual: any, expected: any, label: string?)
	if actual ~= expected then
		fail("expected " .. show(expected) .. ", got " .. show(actual), label)
	end
end

function A.near(actual: number, expected: number, tol: number?, label: string?)
	local t = tol or 1e-6
	if type(actual) ~= "number" or math.abs(actual - expected) > t then
		fail("expected " .. show(expected) .. " (within " .. t .. "), got " .. show(actual), label)
	end
end

function A.truthy(v: any, label: string?)
	if not v then
		fail("expected a true value, got " .. show(v), label)
	end
end

function A.falsy(v: any, label: string?)
	if v then
		fail("expected a false value, got " .. show(v), label)
	end
end

function A.throws(fn: () -> (), label: string?)
	local ok = pcall(fn)
	if ok then
		fail("expected an error", label)
	end
end

local function deep(a: any, b: any, path: string): string?
	if type(a) ~= type(b) then
		return path .. ": type " .. type(a) .. " vs " .. type(b)
	end
	if type(a) ~= "table" then
		if a ~= b then
			return path .. ": " .. show(a) .. " vs " .. show(b)
		end
		return nil
	end
	for k, v in a do
		local r = deep(v, b[k], path .. "." .. tostring(k))
		if r then
			return r
		end
	end
	for k in b do
		if a[k] == nil then
			return path .. "." .. tostring(k) .. ": missing on the left"
		end
	end
	return nil
end

function A.deepEq(actual: any, expected: any, label: string?)
	local r = deep(actual, expected, "value")
	if r then
		fail("tables differ at " .. r, label)
	end
end

return A
