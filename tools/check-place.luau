--!strict
-- Opens build/SeedSiege.rbxl with Lune and checks that every script landed where
-- Roblox expects it: `lune run tools/check-place` after `rojo build -o build/SeedSiege.rbxl`.

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local game = roblox.deserializePlace(fs.readFile("build/SeedSiege.rbxl"))
local problems = 0

local function find(path: string): any
	local node: any = game
	for part in string.gmatch(path, "[^%.]+") do
		if node == game then
			node = game:GetService(part)
		else
			node = node and node:FindFirstChild(part)
		end
	end
	return node
end

local function expect(path: string, className: string)
	local node = find(path)
	if not node then
		print("MISSING  " .. path)
		problems += 1
	elseif node.ClassName ~= className then
		print("WRONG    " .. path .. " is " .. node.ClassName .. ", want " .. className)
		problems += 1
	else
		print("ok       " .. path .. " (" .. className .. ")")
	end
end

expect("ServerScriptService.Server.Main", "Script")
for _, s in { "PlotService", "RemoteRouter", "Broadcaster", "RunManager" } do
	expect("ServerScriptService.Server.Services." .. s, "ModuleScript")
end
expect("StarterPlayer.StarterPlayerScripts.Client.Main", "LocalScript")
for _, s in { "StateStore", "CameraController", "BoardRenderer", "PestRenderer", "EffectsController", "PlacementController" } do
	expect("StarterPlayer.StarterPlayerScripts.Client.Controllers." .. s, "ModuleScript")
end
for _, s in { "Theme", "Components", "Hud", "SeedBar", "Inspector", "Results" } do
	expect("StarterPlayer.StarterPlayerScripts.Client.UI." .. s, "ModuleScript")
end
expect("StarterPlayer.StarterPlayerScripts.Client.Util.Signal", "ModuleScript")
expect("ReplicatedStorage.Shared.LogicBundle", "ModuleScript")
expect("ReplicatedStorage.Shared.Visuals", "ModuleScript")
expect("ReplicatedStorage.Shared.Net.Remotes", "ModuleScript")
for _, s in { "Constants", "Seeds", "Pests", "Fields", "Grid", "Combat", "Economy", "Validate", "RateLimit", "Views", "WaveSim" } do
	expect("ReplicatedStorage.Shared.Logic." .. s, "ModuleScript")
	-- Logic must stay pure: no require, no services, no clock (spec 0).
	local src: string = find("ReplicatedStorage.Shared.Logic." .. s).Source
	for _, banned in { "require%(", "game[:%.]", "workspace", "Instance%.", "os%.clock", "tick%(", "DateTime" } do
		if string.find(src, banned) then
			print("IMPURE   Logic." .. s .. " uses " .. banned)
			problems += 1
		end
	end
end

local sg = game:GetService("StarterGui")
print("StarterGui.ScreenOrientation = " .. tostring(sg.ScreenOrientation))
print("Players.CharacterAutoLoads = " .. tostring(game:GetService("Players").CharacterAutoLoads))
if game:GetService("Players").CharacterAutoLoads ~= false then
	problems += 1
end

print(if problems == 0 then "place file OK" else problems .. " problem(s)")
process.exit(if problems == 0 then 0 else 1)
