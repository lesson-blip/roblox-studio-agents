--!nonstrict
-- Headless check of the real server scripts (src/server and src/shared) in Lune.
-- It fakes just enough of Roblox (instances, Players, RunService, remotes) to load
-- Main.server.luau unchanged, then acts as a client: bad payloads, a path tile,
-- too little Sap, and a full Backyard Patch run through the remotes.
-- Run: `lune run tools/server-smoke`. This is not a Roblox playtest; see build/BUILD_REPORT.md.

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local taskLib = require("@lune/task")

local clock = 0
local failures = 0
local function check(cond: boolean, label: string)
	if cond then
		print("pass  " .. label)
	else
		failures += 1
		print("FAIL  " .. label)
	end
end

-- Fake instances ---------------------------------------------------------------

local Fake = {}
local methods = {}
local mt = {}

local function signal()
	local s = { handlers = {} }
	function s:Connect(fn)
		table.insert(self.handlers, fn)
		return { Disconnect = function() end }
	end
	function s:Fire(...)
		for _, fn in self.handlers do
			fn(...)
		end
	end
	return s
end

local function new(className: string, name: string?)
	local self = setmetatable({
		ClassName = className,
		Name = name or className,
		_children = {},
		_attrs = {},
		_props = {},
		_signals = {},
		_fired = {},
	}, mt)
	return self
end
Fake.new = new

mt.__index = function(t, k)
	local m = methods[k]
	if m then
		return m
	end
	local props = rawget(t, "_props")
	if props[k] ~= nil then
		return props[k]
	end
	for _, c in rawget(t, "_children") do
		if c.Name == k then
			return c
		end
	end
	if type(k) == "string" and (string.find(k, "Event$") or k == "Heartbeat" or k == "RenderStepped" or k == "PlayerAdded" or k == "PlayerRemoving" or k == "Activated") then
		local sigs = rawget(t, "_signals")
		sigs[k] = sigs[k] or signal()
		return sigs[k]
	end
	return nil
end
mt.__newindex = function(t, k, v)
	if k == "Parent" then
		local old = t._props.Parent
		if old then
			local i = table.find(old._children, t)
			if i then
				table.remove(old._children, i)
			end
		end
		t._props.Parent = v
		if v then
			table.insert(v._children, t)
		end
	else
		t._props[k] = v
	end
end

function methods:FindFirstChild(name)
	for _, c in self._children do
		if c.Name == name then
			return c
		end
	end
	return nil
end
function methods:WaitForChild(name)
	local c = self:FindFirstChild(name)
	assert(c, "WaitForChild would hang: " .. self.Name .. "." .. tostring(name))
	return c
end
function methods:GetChildren()
	return table.clone(self._children)
end
function methods:SetAttribute(k, v)
	self._attrs[k] = v
end
function methods:GetAttribute(k)
	return self._attrs[k]
end
function methods:Destroy()
	self.Parent = nil
end
function methods:IsA(c)
	return c == self.ClassName or c == "Instance" or (c == "BasePart" and self.ClassName == "Part")
end
function methods:FireClient(player, ...)
	table.insert(player._inbox, { event = self.Name, args = table.pack(...) })
end
function methods:GetPropertyChangedSignal()
	return signal()
end
function methods:Connect() end

-- Script tree built from the source folders -------------------------------------

local modules: { [any]: string } = {}
local function mount(dir: string, node)
	for _, entry in fs.readDir(dir) do
		local full = dir .. "/" .. entry
		if fs.isDir(full) then
			local f = new("Folder", entry)
			f.Parent = node
			mount(full, f)
		elseif string.sub(entry, -5) == ".luau" then
			local base = string.sub(entry, 1, -6)
			local cls = "ModuleScript"
			if string.sub(base, -7) == ".server" then
				cls, base = "Script", string.sub(base, 1, -8)
			elseif string.sub(base, -7) == ".client" then
				cls, base = "LocalScript", string.sub(base, 1, -8)
			end
			local s = new(cls, base)
			s.Parent = node
			modules[s] = full
		end
	end
end

local services = {}
local game = new("DataModel", "game")
function game:GetService(name)
	if not services[name] then
		local s = new(name, name)
		s.Parent = game
		services[name] = s
	end
	return services[name]
end
local workspaceFake = game:GetService("Workspace")
local shared = new("Folder", "Shared")
shared.Parent = game:GetService("ReplicatedStorage")
mount("src/shared", shared)
local server = new("Folder", "Server")
server.Parent = game:GetService("ServerScriptService")
mount("src/server", server)

local players = game:GetService("Players")
local playerList = {}
function players:GetPlayers()
	return table.clone(playerList)
end

-- Loading scripts in a fake environment -------------------------------------------

local cache = {}
local env
local function runScript(inst)
	local path = modules[inst]
	assert(path, "require of a non module: " .. tostring(inst and inst.Name))
	local src = fs.readFile(path)
	local scriptEnv = table.clone(env)
	scriptEnv.script = inst
	local fn = luau.load(src, { debugName = path, environment = scriptEnv })
	return fn()
end
local function fakeRequire(inst)
	if cache[inst] == nil then
		cache[inst] = runScript(inst)
	end
	return cache[inst]
end

env = {
	game = game,
	workspace = workspaceFake,
	require = fakeRequire,
	Instance = { new = function(c) return new(c) end },
	Vector3 = roblox.Vector3,
	Vector2 = roblox.Vector2,
	Color3 = roblox.Color3,
	CFrame = roblox.CFrame,
	UDim = roblox.UDim,
	UDim2 = roblox.UDim2,
	Enum = roblox.Enum,
	task = taskLib,
	warn = function(...) print("WARN", ...) end,
	os = { clock = function() return clock end, time = os.time },
}

-- Boot the server exactly as Roblox would run Main.server.luau.
local mainScript = server:FindFirstChild("Main")
runScript(mainScript)

local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
check(remotes ~= nil, "server created ReplicatedStorage.Remotes")
local heartbeat = game:GetService("RunService").Heartbeat

-- A fake player joins.
local player = new("Player", "Tester")
player.UserId = 1
player._inbox = {}
table.insert(playerList, player)
players.PlayerAdded:Fire(player)

local function call(name, ...)
	clock += 0.6 -- stay inside the rate limits
	local rf = remotes:FindFirstChild(name)
	return rf.OnServerInvoke(player, ...)
end
local function lastView()
	for i = #player._inbox, 1, -1 do
		local m = player._inbox[i]
		if m.event == "RunUpdated" then
			return m.args[1]
		end
	end
	return nil
end
local function frames(n, dt)
	for _ = 1, n do
		clock += dt
		heartbeat:Fire(dt)
	end
end

local v0 = lastView()
check(v0 ~= nil and v0.phase == "build" and v0.sap == 200 and v0.hearts == 20, "a Backyard run starts on join (200 Sap, 20 hearts)")
check(workspaceFake:FindFirstChild("Plots") and workspaceFake.Plots:FindFirstChild("Plot1") ~= nil, "Plot1 was built")
check(#workspaceFake.Plots.Plot1.Tiles:GetChildren() == 96, "96 tiles built")

-- Bad payloads and cheats are refused.
local r = call("PlaceSeed", "thorn", 4, 1)
check(not r.ok and r.err == "on_path", "planting on a path tile is refused (on_path)")
r = call("PlaceSeed", "thorn", 8.5, 2)
check(not r.ok and r.err == "bad_payload", "a fractional tile is refused (bad_payload)")
r = call("PlaceSeed", "thorn", 0 / 0, 2)
check(not r.ok and r.err == "bad_payload", "NaN is refused")
r = call("PlaceSeed", "golden", 3, 3)
check(not r.ok and r.err == "bad_payload", "an unknown seed is refused")
r = call("PlaceSeed", { cost = 0 }, 3, 3)
check(not r.ok and r.err == "bad_payload", "a table instead of a seed id is refused")
r = call("PlaceSeed", "burr", 3, 3)
check(not r.ok and r.err == "locked", "Burr Vine is locked before wave 3")
r = call("PlaceSeed", "oak", 3, 3)
check(not r.ok and r.err == "not_in_loadout", "a seed outside the loadout is refused")
r = call("SetSpeed", 2)
check(not r.ok and r.err == "needs_pass", "2x speed needs the pass")
r = call("SetSpeed", 7)
check(not r.ok and r.err == "bad_payload", "speed 7 is refused")
r = call("RequestStart", "orchard", "normal")
check(not r.ok and (r.err == "in_run" or r.err == "locked"), "starting another field is refused (" .. tostring(r.err) .. ")")

-- Rate limit: 12 instant PlaceSeed calls with no time passing.
local limited = 0
for _ = 1, 12 do
	local res = remotes.PlaceSeed.OnServerInvoke(player, "thorn", 99, 99)
	if res.err == "rate_limited" then
		limited += 1
	end
end
check(limited == 0, "invalid payloads are refused before the rate limit (bad_payload first)")
clock += 5
limited = 0
for _ = 1, 12 do
	local res = remotes.UpgradePlant.OnServerInvoke(player, 999)
	if res.err == "rate_limited" then
		limited += 1
	end
end
check(limited == 4, "UpgradePlant allows a burst of 8 then rate_limited (" .. limited .. " limited)")
clock += 5

-- The first three steps of the Appendix B order, then ask for more than is left.
r = call("PlaceSeed", "thorn", 8, 2)
check(r.ok, "plant a Thorn Sprout at (8, 2)")
r = call("PlaceSeed", "thorn", 3, 5)
check(r.ok, "plant a Thorn Sprout at (3, 5)")
r = call("PlaceSeed", "sunpetal", 11, 0)
check(r.ok, "plant a Sunpetal at (11, 0)")
r = call("PlaceSeed", "thorn", 5, 3)
check(not r.ok and r.err == "no_sap", "a Thorn Sprout with 5 Sap left is refused (no_sap)")
r = call("PlaceSeed", "thorn", 8, 2)
check(not r.ok and (r.err == "tile_taken" or r.err == "no_sap"), "a taken tile is refused")
local v1 = lastView()
check(v1.sap == 5 and #v1.plants == 3, "server Sap is 5 with 3 plants")
local sunId = v1.plants[3].id
r = call("SellPlant", sunId)
check(r.ok and r.data == 75, "undo in the same build phase refunds the full 75")
r = call("PlaceSeed", "sunpetal", 11, 0)
check(r.ok and lastView().sap == 5, "replant the Sunpetal")

-- Play the rest of the Appendix B order through the remotes.
local steps = {
	{ "p", "thorn", 5, 3 }, { "p", "thorn", 6, 5 }, { "p", "burr", 8, 3 },
	{ "u", 8, 2 }, { "u", 3, 5 }, { "p", "thorn", 5, 2 }, { "u", 5, 3 }, { "u", 6, 5 }, { "p", "burr", 3, 3 },
	{ "u", 8, 2 }, { "u", 3, 5 }, { "p", "thorn", 10, 5 }, { "u", 11, 0 },
}
local function plantIdAt(x, y)
	for _, p in lastView().plants do
		if p.x == x and p.y == y then
			return p.id
		end
	end
	return nil
end
local speedSet = false
local waves = 0
while true do
	local view = lastView()
	if view.phase == "over" then
		break
	end
	while #steps > 0 do
		local st = steps[1]
		local res
		if st[1] == "p" then
			res = call("PlaceSeed", st[2], st[3], st[4])
		else
			res = call("UpgradePlant", plantIdAt(st[2], st[3]))
		end
		if res.ok then
			table.remove(steps, 1)
		elseif res.err == "no_sap" or res.err == "locked" then
			break -- wait for the next build phase
		else
			check(false, "unexpected error " .. tostring(res.err) .. " on a build step")
			break
		end
	end
	r = call("StartWave")
	check(r.ok, "StartWave for wave " .. (view.wave + 1))
	if not speedSet then
		r = call("SetSpeed", 1.5)
		check(r.ok, "speed 1.5x during a wave")
		speedSet = true
	end
	r = call("StartWave")
	if r.err ~= "wrong_phase" then
		check(false, "a second StartWave mid wave should be wrong_phase, got " .. tostring(r.err))
	end
	local guard = 0
	repeat
		frames(10, 1 / 60)
		guard += 1
	until lastView().phase ~= "wave" or guard > 20000
	waves += 1
	if waves > 12 then
		break
	end
end
local final = lastView()
local ended = nil
local snaps = 0
for _, m in player._inbox do
	if m.event == "RunEnded" then
		ended = m.args[1]
	elseif m.event == "PestSnapshot" then
		snaps += 1
	end
end
check(final.phase == "over", "the run ended")
check(ended ~= nil, "RunEnded was sent")
check(snaps > 100, "pest snapshots were sent during waves (" .. snaps .. ")")
if ended then
	print(string.format("      result: %s, waves cleared %d of %d, hearts left %d, most leaked %s",
		if ended.won then "won" else "lost", ended.wavesCleared, ended.totalWaves, ended.heartsLeft, tostring(ended.mostLeaked)))
end
check(ended ~= nil and ended.won and ended.heartsLeft == 17,
	"through the real server at 1.5x the run matches the Lune result (win, 17 hearts)")
r = call("PlaceSeed", "thorn", 0, 0)
check(not r.ok and r.err == "run_over", "planting after the run is over is refused (run_over)")
r = call("RequestStart", "backyard", "normal")
check(r.ok, "Play again starts a new run on the same plot")
check(lastView().sap == 200 and #lastView().plants == 0, "the new run starts fresh")

players.PlayerRemoving:Fire(player)
print(string.rep("-", 60))
print(if failures == 0 then "server smoke: all checks passed" else "server smoke: " .. failures .. " check(s) failed")
process.exit(if failures == 0 then 0 else 1)
