--!strict
-- End of run panel (spec 7.8, M1 subset: no Petals yet). Play again starts a new run.

local Theme = require(script.Parent:WaitForChild("Theme")) :: any
local Components = require(script.Parent:WaitForChild("Components")) :: any

local Results = {}

local store: any = nil
local panel: Frame? = nil
local refs: { [string]: any } = {}

-- A counter seed for the pest that leaked most (one line hint on a loss).
local HINTS: { [string]: string } = {
	aphid = "Aphids rushed past. Add a few more Thorn Sprouts.",
	ant = "Ants got through. Upgrade plants near the path corners.",
	snail = "Snails are tough. Upgrade or add plants.",
	caterpillar = "Caterpillars heal. Focus several plants on one spot.",
	beetle = "Beetles have shells. Upgraded plants hit harder.",
	moth = "Moths flew past. Try a Dandelion Lofter.",
	wasp = "Wasps flew past. Try a Dandelion Lofter.",
	mole = "Moles hid underground. Mint Mist finds them.",
	slugmum = "Slug mums split. Splash damage helps.",
	possum = "The possum is big. Save up for strong plants.",
}

local function show(summary: any)
	assert(panel)
	refs.title.Text = if summary.won then "Garden saved!" else "The pests got through"
	refs.lines.Text = "Waves cleared: " .. summary.wavesCleared .. " of " .. summary.totalWaves
		.. "\nHearts left: " .. summary.heartsLeft
	local hint = ""
	if not summary.won and summary.mostLeaked then
		hint = HINTS[summary.mostLeaked] or ""
	end
	refs.hint.Text = hint
	panel.Visible = true
end

function Results.init(_bundle: any, stateStore: any, root: Instance)
	store = stateStore
	local holder, f = Components.pill({
		Name = "Results",
		Size = UDim2.fromOffset(380, 230),
		Position = UDim2.new(0.5, -190, 0.5, -115),
		Visible = false,
	}, root, 18)
	panel = holder
	refs.title = Components.label("", {
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.fromOffset(0, 10),
		Font = Theme.FONT_HEAD,
		TextSize = 28,
	}, f)
	refs.lines = Components.label("", {
		Size = UDim2.new(1, -24, 0, 52),
		Position = UDim2.fromOffset(12, 58),
		TextSize = Theme.TEXT_NUMBER,
	}, f)
	refs.hint = Components.label("", {
		Size = UDim2.new(1, -24, 0, 40),
		Position = UDim2.fromOffset(12, 112),
		Font = Theme.FONT_BODY,
		TextSize = Theme.TEXT_MIN + 1,
	}, f)
	Components.button("Play again", {
		Size = UDim2.fromOffset(180, 52),
		Position = UDim2.new(0.5, -90, 1, -64),
	}, function()
		local res = store.call("RequestStart", "backyard", "normal")
		if res.ok then
			holder.Visible = false
		end
	end, f)
	store.ended:connect(show)
	store.changed:connect(function(view: any)
		if view.phase ~= "over" then
			holder.Visible = false
		end
	end)
end

return Results
