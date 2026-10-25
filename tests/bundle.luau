--!strict
-- Lune side wiring of the pure Logic modules. Same modules as src/shared/LogicBundle.luau.

local L: { [string]: any } = {
	Constants = require("../src/shared/Logic/Constants"),
	Seeds = require("../src/shared/Logic/Seeds"),
	Pests = require("../src/shared/Logic/Pests"),
	Fields = require("../src/shared/Logic/Fields"),
	Grid = require("../src/shared/Logic/Grid"),
	Combat = require("../src/shared/Logic/Combat"),
	Economy = require("../src/shared/Logic/Economy"),
	Validate = require("../src/shared/Logic/Validate"),
	RateLimit = require("../src/shared/Logic/RateLimit"),
	Views = require("../src/shared/Logic/Views"),
	WaveSim = require("../src/shared/Logic/WaveSim"),
}
for name in L do
	local mod: any = L[name]
	local bind = mod.bind :: ((any) -> ())?
	if bind then
		bind(L)
	end
end

return L
