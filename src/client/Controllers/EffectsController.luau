--!strict
-- Shot sparks and the "+3" Sap pop with a leafy poof when a pest is shooed.
-- Only transparency, size and position tweens; nothing touches the HUD layout.

local TweenService = game:GetService("TweenService")

local EffectsController = {}

local board: any = nil
local pests: any = nil
local MAX_LIVE = 40
local live = 0

local function spark(): Part
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(0.45, 0.45, 0.45)
	p.Material = Enum.Material.Neon
	p.Color = Color3.fromRGB(255, 240, 160)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	return p
end

function EffectsController.shot(plantId: number, pestId: number)
	if live >= MAX_LIVE or not board or not pests then
		return
	end
	local from = board.plantPosition(plantId)
	local to = pests.pestPosition(pestId)
	if not from or not to then
		return
	end
	live += 1
	local p = spark()
	p.Position = from
	p.Parent = workspace
	local tw = TweenService:Create(p, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Position = to })
	tw.Completed:Connect(function()
		p:Destroy()
		live -= 1
	end)
	tw:Play()
end

function EffectsController.pop(position: Vector3, reward: number)
	-- Leafy poof.
	local puff = Instance.new("Part")
	puff.Shape = Enum.PartType.Ball
	puff.Size = Vector3.new(1, 1, 1)
	puff.Color = Color3.fromRGB(120, 190, 90)
	puff.Material = Enum.Material.SmoothPlastic
	puff.Anchored = true
	puff.CanCollide = false
	puff.CanQuery = false
	puff.CanTouch = false
	puff.Transparency = 0.2
	puff.Position = position
	puff.Parent = workspace
	local grow = TweenService:Create(puff, TweenInfo.new(0.35), { Size = Vector3.new(3, 3, 3), Transparency = 1 })
	grow.Completed:Connect(function()
		puff:Destroy()
	end)
	grow:Play()
	-- "+N" Sap floater.
	local anchor = Instance.new("Part")
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Position = position
	anchor.Parent = workspace
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(60, 28)
	bb.AlwaysOnTop = true
	bb.Adornee = anchor
	bb.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextSize = 20
	t.TextColor3 = Color3.fromRGB(255, 215, 80)
	t.TextStrokeTransparency = 0.3
	t.Text = "+" .. tostring(reward)
	t.Parent = bb
	bb.Parent = anchor
	local rise = TweenService:Create(anchor, TweenInfo.new(0.8), { Position = position + Vector3.new(0, 3, 0) })
	local fade = TweenService:Create(t, TweenInfo.new(0.8), { TextTransparency = 1, TextStrokeTransparency = 1 })
	rise.Completed:Connect(function()
		anchor:Destroy()
	end)
	rise:Play()
	fade:Play()
end

function EffectsController.init(boardRenderer: any, pestRenderer: any)
	board = boardRenderer
	pests = pestRenderer
end

return EffectsController
