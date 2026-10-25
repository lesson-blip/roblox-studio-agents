--!strict
-- Small helpers that build GUI objects in the house style (design/preview3d HUD):
-- rounded shapes with a near black outline, a soft top to bottom shade, a dark drop
-- edge underneath, and bold rounded text with a dark stroke.

local Theme = require(script.Parent:WaitForChild("Theme")) :: any

local Components = {}

function Components.corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or Theme.RADIUS)
	c.Parent = parent
end

function Components.round(parent: Instance)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = parent
end

-- Outline around a frame or button.
function Components.stroke(parent: Instance, color: Color3?, thickness: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.INK
	s.Thickness = thickness or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

-- Outline around a label's text (the preview's -webkit-text-stroke).
function Components.textStroke(label: Instance, thickness: number?, color: Color3?): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.TEXT_STROKE
	s.Thickness = thickness or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = label
	return s
end

-- Top to bottom colour gradient. With one colour it shades white to grey, which
-- multiplies with the background colour (so changing the background still works).
function Components.gradient(parent: Instance, top: Color3?, bottom: Color3?): UIGradient
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(top or Color3.new(1, 1, 1), bottom or Color3.fromRGB(196, 196, 204))
	g.Rotation = 90
	g.Parent = parent
	return g
end

function Components.frame(props: { [string]: any }, parent: Instance?): Frame
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Theme.PANEL
	f.BackgroundTransparency = 0
	for k, v in props do
		(f :: any)[k] = v
	end
	f.Parent = parent
	return f
end

-- A dark rounded pill with a drop edge (hearts, Sap, panels). Returns the outer
-- holder (position and size it) and the face (put content in it).
function Components.pill(props: { [string]: any }, parent: Instance, radius: number?): (Frame, Frame)
	local holder = Components.frame({ BackgroundTransparency = 1 }, parent)
	for k, v in props do
		(holder :: any)[k] = v
	end
	local r = radius or 14
	local edge = Components.frame({
		Name = "Edge",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, 3),
		BackgroundColor3 = Theme.INK,
		ZIndex = 1,
	}, holder)
	Components.corner(edge, r)
	local face = Components.frame({
		Name = "Face",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
	}, holder)
	Components.corner(face, r)
	Components.gradient(face, Theme.PILL_TOP, Theme.PILL_BOTTOM)
	Components.stroke(face, Theme.INK, 2)
	return holder, face
end

function Components.label(text: string, props: { [string]: any }, parent: Instance?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.Font = Theme.FONT_HEAD
	t.TextSize = Theme.TEXT_MIN
	t.TextColor3 = Theme.TEXT
	t.TextWrapped = true
	for k, v in props do
		(t :: any)[k] = v
	end
	t.Parent = parent
	return t
end

-- A chunky button: colour, shade, outline and a dark drop edge (a stroke under the
-- button's own text keeps it readable on any colour).
function Components.button(text: string, props: { [string]: any }, onClick: () -> (), parent: Instance?): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.BackgroundColor3 = Theme.BUTTON
	b.Text = text
	b.Font = Theme.FONT_HEAD
	b.TextSize = Theme.TEXT_NUMBER
	b.TextColor3 = Theme.TEXT
	b.TextStrokeColor3 = Theme.TEXT_STROKE
	b.TextStrokeTransparency = 0.35
	b.TextWrapped = true
	for k, v in props do
		(b :: any)[k] = v
	end
	Components.corner(b, 12)
	Components.gradient(b)
	Components.stroke(b, Theme.INK, 2)
	b.Activated:Connect(onClick)
	b.Parent = parent
	return b
end

-- A heart drawn from two circles and a turned square (no image assets).
function Components.heart(parent: Instance, size: number, pos: UDim2): Frame
	local box = Components.frame({ Name = "Heart", BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Position = pos }, parent)
	local function piece(props: { [string]: any }, color: Color3, z: number): Frame
		local f = Components.frame(props, box)
		f.BackgroundColor3 = color
		f.ZIndex = z
		return f
	end
	local r = size * 0.56
	for _, layer in { { Theme.INK, 2, 3 }, { Theme.HEART, 0, 4 } } do
		local col, grow, z = layer[1] :: Color3, layer[2] :: number, layer[3] :: number
		for _, x in { 0.04, 0.42 } do
			local c = piece({ Size = UDim2.fromOffset(r + grow * 2, r + grow * 2), Position = UDim2.fromOffset(size * x - grow, size * 0.08 - grow) }, col, z)
			Components.round(c)
		end
		local sq = size * 0.56
		local d = piece({
			Size = UDim2.fromOffset(sq + grow * 2, sq + grow * 2),
			Position = UDim2.fromOffset(size * 0.5 - sq / 2 - grow, size * 0.4 - grow),
			Rotation = 45,
		}, col, z)
		Components.corner(d, 3)
	end
	local shine = piece({ Size = UDim2.fromOffset(size * 0.16, size * 0.12), Position = UDim2.fromOffset(size * 0.22, size * 0.24) }, Color3.new(1, 1, 1), 5)
	shine.BackgroundTransparency = 0.3
	Components.round(shine)
	return box
end

-- A Sap drop: a circle with a turned square on top for the point.
function Components.drop(parent: Instance, size: number, pos: UDim2): Frame
	local box = Components.frame({ Name = "Drop", BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Position = pos }, parent)
	local r = size * 0.66
	for _, layer in { { Theme.INK, 2, 3 }, { Theme.SAP, 0, 4 } } do
		local col, grow, z = layer[1] :: Color3, layer[2] :: number, layer[3] :: number
		local sq = r * 0.62
		local tip = Components.frame({
			Size = UDim2.fromOffset(sq + grow * 2, sq + grow * 2),
			Position = UDim2.fromOffset(size / 2 - sq / 2 - grow, size * 0.16 - grow),
			Rotation = 45,
			BackgroundColor3 = col,
			ZIndex = z,
		}, box)
		Components.corner(tip, 2)
		local c = Components.frame({
			Size = UDim2.fromOffset(r + grow * 2, r + grow * 2),
			Position = UDim2.fromOffset(size / 2 - r / 2 - grow, size - r - grow),
			BackgroundColor3 = col,
			ZIndex = z,
		}, box)
		Components.round(c)
	end
	local shine = Components.frame({
		Size = UDim2.fromOffset(size * 0.12, size * 0.22),
		Position = UDim2.fromOffset(size * 0.32, size * 0.56),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.25,
		ZIndex = 5,
	}, box)
	Components.round(shine)
	return box
end

return Components
