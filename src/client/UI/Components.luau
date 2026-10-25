--!strict
-- Small helpers that build GUI objects with the house style.

local Theme = require(script.Parent:WaitForChild("Theme")) :: any

local Components = {}

function Components.corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
end

function Components.stroke(parent: Instance, color: Color3?, thickness: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(0, 0, 0)
	s.Thickness = thickness or 2
	s.Transparency = 0.2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

function Components.frame(props: { [string]: any }, parent: Instance?): Frame
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Theme.PANEL
	f.BackgroundTransparency = 0.15
	for k, v in props do
		(f :: any)[k] = v
	end
	f.Parent = parent
	return f
end

function Components.label(text: string, props: { [string]: any }, parent: Instance?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.Font = Theme.FONT_BOLD
	t.TextSize = Theme.TEXT_MIN
	t.TextColor3 = Theme.TEXT
	t.TextWrapped = true
	for k, v in props do
		(t :: any)[k] = v
	end
	t.Parent = parent
	return t
end

function Components.button(text: string, props: { [string]: any }, onClick: () -> (), parent: Instance?): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.BackgroundColor3 = Theme.BUTTON
	b.Text = text
	b.Font = Theme.FONT_HEAD
	b.TextSize = Theme.TEXT_NUMBER
	b.TextColor3 = Theme.TEXT
	b.TextWrapped = true
	for k, v in props do
		(b :: any)[k] = v
	end
	Components.corner(b, 12)
	b.Activated:Connect(onClick)
	b.Parent = parent
	return b
end

return Components
