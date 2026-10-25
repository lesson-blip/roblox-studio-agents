--!strict
-- Shots and pops, presentation only (design/preview3d scene.js effects):
-- Thorn and Burr fire glowing darts, Dandelion lobs white puffs, Pumpkin lobs a glowing
-- pumpkin on a high arc, Snapjaw snaps. A hit flashes a small star; a shooed pest
-- bursts into leaves with a "+N" Sap float. Projectiles fly on a RenderStepped loop
-- (one BulkMoveTo), and parts are reused from a pool.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local EffectsController = {}

local board: any = nil
local pests: any = nil
local MAX_LIVE = 60
local folder: Folder? = nil

type Shot = { part: BasePart, from: Vector3, to: Vector3, t: number, dur: number, arc: number, spin: boolean, onHit: (() -> ())? }
local flying: { Shot } = {}
local pool: { [string]: { BasePart } } = {}
local live = 0

local function ensureFolder(): Folder
	if folder and folder.Parent then
		return folder
	end
	local f = Instance.new("Folder")
	f.Name = "SeedSiegeEffects"
	f.Parent = workspace
	folder = f
	return f
end

local function newPart(kind: string): BasePart
	local list = pool[kind]
	if list and #list > 0 then
		local p = table.remove(list) :: BasePart
		p.Transparency = 0
		return p
	end
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	if kind == "dart" then
		p.Size = Vector3.new(0.3, 0.3, 1.4)
		p.Color = Color3.fromRGB(226, 255, 120)
	elseif kind == "burr" then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(0.6, 0.6, 0.6)
		p.Color = Color3.fromRGB(200, 150, 80)
		p.Material = Enum.Material.SmoothPlastic
	elseif kind == "puff" then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(0.75, 0.75, 0.75)
		p.Color = Color3.fromRGB(255, 255, 255)
	elseif kind == "pumpkin" then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(1.3, 1.3, 1.3)
		p.Color = Color3.fromRGB(255, 138, 31)
	elseif kind == "star" then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(0.8, 0.8, 0.8)
		p.Color = Color3.fromRGB(255, 239, 138)
	elseif kind == "leaf" then
		p.Size = Vector3.new(0.6, 0.12, 0.3)
		p.Material = Enum.Material.SmoothPlastic
	elseif kind == "ring" then
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(0.1, 3, 3)
		p.Color = Color3.fromRGB(255, 233, 168)
	end
	return p
end

local function release(kind: string, p: BasePart)
	p.Parent = nil
	pool[kind] = pool[kind] or {}
	if #pool[kind] < 40 then
		table.insert(pool[kind], p)
	else
		p:Destroy()
	end
end

-- A quick bright flash at a hit.
local function star(at: Vector3, color: Color3?)
	local p = newPart("star")
	p.Color = color or Color3.fromRGB(255, 239, 138)
	p.Size = Vector3.new(0.6, 0.6, 0.6)
	p.Position = at
	p.Parent = ensureFolder()
	local tw = TweenService:Create(p, TweenInfo.new(0.22), { Size = Vector3.new(2.2, 2.2, 2.2), Transparency = 1 })
	tw.Completed:Connect(function()
		release("star", p)
	end)
	tw:Play()
end

local function splash(at: Vector3)
	local p = newPart("ring")
	p.Size = Vector3.new(0.1, 1, 1)
	p.Transparency = 0.3
	p.CFrame = CFrame.new(at) * CFrame.Angles(0, 0, math.pi / 2)
	p.Parent = ensureFolder()
	local tw = TweenService:Create(p, TweenInfo.new(0.35), { Size = Vector3.new(0.1, 7, 7), Transparency = 1 })
	tw.Completed:Connect(function()
		release("ring", p)
	end)
	tw:Play()
end

local function launch(kind: string, from: Vector3, to: Vector3, dur: number, arc: number, onHit: (() -> ())?)
	local p = newPart(kind)
	p.CFrame = CFrame.new(from)
	p.Parent = ensureFolder()
	live += 1
	table.insert(flying, { part = p, from = from, to = to, t = 0, dur = dur, arc = arc, spin = kind == "dart", onHit = onHit })
	p:SetAttribute("Kind", kind)
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
	board.fired(plantId, to)
	local seed = board.plantSeed(plantId)
	if seed == "snapjaw" then
		star(to + Vector3.new(0, 0.5, 0), Color3.fromRGB(255, 154, 138))
	elseif seed == "pumpkin" then
		launch("pumpkin", from, to, 0.5, 6, function()
			star(to, Color3.fromRGB(255, 160, 64))
			splash(to)
		end)
	elseif seed == "dandelion" then
		launch("puff", from, to, 0.4, 2.4, function()
			star(to, Color3.new(1, 1, 1))
		end)
	elseif seed == "burr" then
		launch("burr", from, to, 0.22, 0.6, function()
			star(to, Color3.fromRGB(230, 200, 140))
		end)
	else
		launch("dart", from, to, 0.16, 0, function()
			star(to)
		end)
	end
end

local function onRender(dt: number)
	if #flying == 0 then
		return
	end
	local parts: { BasePart } = {}
	local cframes: { CFrame } = {}
	for i = #flying, 1, -1 do
		local s = flying[i]
		s.t += dt
		local k = math.min(1, s.t / s.dur)
		local p = s.from:Lerp(s.to, k) + Vector3.new(0, math.sin(k * math.pi) * s.arc, 0)
		if k >= 1 then
			table.remove(flying, i)
			live -= 1
			release(s.part:GetAttribute("Kind") :: string, s.part)
			if s.onHit then
				s.onHit()
			end
		else
			local ahead = s.from:Lerp(s.to, math.min(1, k + 0.05)) + Vector3.new(0, math.sin(math.min(1, k + 0.05) * math.pi) * s.arc, 0)
			local cf = if (ahead - p).Magnitude > 1e-3 then CFrame.lookAt(p, ahead) else CFrame.new(p)
			table.insert(parts, s.part)
			table.insert(cframes, cf)
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function EffectsController.pop(position: Vector3, reward: number)
	-- Leaf burst: a few leaves fly out and fade, with a pale ring on the ground.
	local leafCols = { Color3.fromRGB(111, 200, 74), Color3.fromRGB(166, 224, 90), Color3.fromRGB(255, 210, 90) }
	for i = 1, 8 do
		local p = newPart("leaf")
		p.Color = leafCols[i % 3 + 1]
		local a = i / 8 * math.pi * 2
		local out = Vector3.new(math.cos(a), 0.6 + (i % 3) * 0.3, math.sin(a)) * 2.2
		p.CFrame = CFrame.new(position) * CFrame.Angles(a, a * 2, 0)
		p.Parent = ensureFolder()
		local tw = TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(position + out) * CFrame.Angles(a + 2, a * 2 + 1, 1),
			Transparency = 1,
		})
		tw.Completed:Connect(function()
			release("leaf", p)
		end)
		tw:Play()
	end
	splash(position - Vector3.new(0, 0.5, 0))
	-- "+N" Sap float.
	local anchor = Instance.new("Part")
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Position = position
	anchor.Parent = ensureFolder()
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(70, 32)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Adornee = anchor
	bb.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextSize = 24
	t.TextColor3 = Color3.fromRGB(184, 245, 90)
	t.Text = "+" .. tostring(reward)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(35, 32, 43)
	stroke.Thickness = 2.5
	stroke.Parent = t
	t.Parent = bb
	bb.Parent = anchor
	local rise = TweenService:Create(anchor, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = position + Vector3.new(0, 3.5, 0) })
	local fade = TweenService:Create(t, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
	local fadeStroke = TweenService:Create(stroke, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 })
	rise.Completed:Connect(function()
		anchor:Destroy()
	end)
	rise:Play()
	fade:Play()
	fadeStroke:Play()
end

function EffectsController.init(boardRenderer: any, pestRenderer: any)
	board = boardRenderer
	pests = pestRenderer
	RunService.RenderStepped:Connect(onRender)
end

return EffectsController
