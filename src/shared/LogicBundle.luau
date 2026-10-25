--!strict
-- Roblox side wiring of the pure Logic modules (spec 0). Lune uses tests/bundle.luau.

local Logic = script.Parent:WaitForChild("Logic")

local NAMES = {
	"Constants", "Seeds", "Pests", "Fields", "Grid", "Combat", "Economy",
	"Validate", "RateLimit", "Views", "WaveSim",
}

local L: { [string]: any } = {}
for _, name in NAMES do
	L[name] = require(Logic:WaitForChild(name) :: ModuleScript) :: any
end
for _, name in NAMES do
	local bind = L[name].bind :: ((any) -> ())?
	if bind then
		bind(L)
	end
end

return L
