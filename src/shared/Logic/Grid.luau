--!strict
-- Grid and path maths (spec 3.1 "Path" and 6.3 "Grid"). Pure.

export type Segment = { ax: number, ay: number, bx: number, by: number, start: number, length: number }
export type Path = {
	tiles: { [string]: boolean },
	tileList: { { number } },
	segments: { Segment },
	length: number,
}

local L: any = nil
local Grid = {}

function Grid.bind(bundle: any)
	L = bundle
end

function Grid.key(x: number, y: number): string
	return tostring(x) .. "," .. tostring(y)
end

function Grid.inBounds(x: number, y: number): boolean
	local C = L.Constants
	return x >= 0 and x < C.GRID_W and y >= 0 and y < C.GRID_H
end

function Grid.distance(ax: number, ay: number, bx: number, by: number): number
	local dx, dy = ax - bx, ay - by
	return math.sqrt(dx * dx + dy * dy)
end

-- Turns waypoints into path tiles, segments through tile centres and the route length.
function Grid.expandPath(waypoints: { { number } }): Path
	local segments: { Segment } = {}
	local total = 0
	for i = 1, #waypoints - 1 do
		local a, b = waypoints[i], waypoints[i + 1]
		local ax, ay, bx, by = a[1] + 0.5, a[2] + 0.5, b[1] + 0.5, b[2] + 0.5
		local len = Grid.distance(ax, ay, bx, by)
		table.insert(segments, { ax = ax, ay = ay, bx = bx, by = by, start = total, length = len })
		total += len
	end
	local tiles: { [string]: boolean } = {}
	local tileList: { { number } } = {}
	local function add(x: number, y: number)
		local k = Grid.key(x, y)
		if not tiles[k] then
			tiles[k] = true
			table.insert(tileList, { x, y })
		end
	end
	for i = 1, #waypoints - 1 do
		local a, b = waypoints[i], waypoints[i + 1]
		if a[1] == b[1] then
			local step = if b[2] >= a[2] then 1 else -1
			for y = a[2], b[2], step do
				add(a[1], y)
			end
		else
			local step = if b[1] >= a[1] then 1 else -1
			for x = a[1], b[1], step do
				add(x, a[2])
			end
		end
	end
	if #waypoints == 1 then
		add(waypoints[1][1], waypoints[1][2])
	end
	return { tiles = tiles, tileList = tileList, segments = segments, length = total }
end

-- Position (tile units) at distance d along the route.
function Grid.positionAt(path: Path, d: number): (number, number)
	local segs = path.segments
	for _, s in segs do
		if d <= s.start + s.length then
			local t = if s.length > 0 then (d - s.start) / s.length else 0
			return s.ax + (s.bx - s.ax) * t, s.ay + (s.by - s.ay) * t
		end
	end
	local last = segs[#segs]
	return last.bx, last.by
end

function Grid.isPathTile(path: Path, x: number, y: number): boolean
	return path.tiles[Grid.key(x, y)] == true
end

-- Number of path tiles whose centre is within range of tile (x, y).
function Grid.coverage(path: Path, x: number, y: number, range: number): number
	local n = 0
	local cx, cy = x + 0.5, y + 0.5
	for _, t in path.tileList do
		if Grid.distance(t[1] + 0.5, t[2] + 0.5, cx, cy) <= range + L.Constants.EPS then
			n += 1
		end
	end
	return n
end

function Grid.mirror(waypoints: { { number } }): { { number } }
	local out = {}
	for i, w in waypoints do
		out[i] = { L.Constants.GRID_W - 1 - w[1], w[2] }
	end
	return out
end

function Grid.plantableCount(path: Path): number
	local C = L.Constants
	return C.GRID_W * C.GRID_H - #path.tileList
end

-- Checks a field's waypoints: in bounds, straight segments, no tile used twice,
-- and at least 40 plantable tiles.
function Grid.validateField(field: any): (boolean, { string })
	local errors: { string } = {}
	local wps = field.waypoints
	if type(wps) ~= "table" or #wps < 2 then
		return false, { "need at least 2 waypoints" }
	end
	for i, w in wps do
		if not Grid.inBounds(w[1], w[2]) then
			table.insert(errors, "waypoint " .. i .. " out of bounds")
		end
	end
	local seen: { [string]: boolean } = {}
	local count = 0
	for i = 1, #wps - 1 do
		local a, b = wps[i], wps[i + 1]
		if a[1] ~= b[1] and a[2] ~= b[2] then
			table.insert(errors, "segment " .. i .. " is not straight")
		elseif a[1] == b[1] and a[2] == b[2] then
			table.insert(errors, "segment " .. i .. " has no length")
		else
			-- Walk the segment, skipping its first tile after the first segment (a shared corner).
			local dx = if b[1] > a[1] then 1 elseif b[1] < a[1] then -1 else 0
			local dy = if b[2] > a[2] then 1 elseif b[2] < a[2] then -1 else 0
			local x, y = a[1], a[2]
			local first = true
			while true do
				if not (first and i > 1) then
					local k = Grid.key(x, y)
					if seen[k] then
						table.insert(errors, "tile " .. k .. " used twice")
					end
					seen[k] = true
					count += 1
				end
				first = false
				if x == b[1] and y == b[2] then
					break
				end
				x += dx
				y += dy
			end
		end
	end
	local C = L.Constants
	if C.GRID_W * C.GRID_H - count < 40 then
		table.insert(errors, "fewer than 40 plantable tiles")
	end
	return #errors == 0, errors
end

return Grid
