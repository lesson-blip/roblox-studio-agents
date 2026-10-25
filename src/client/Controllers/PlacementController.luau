--!strict
-- Turns taps and clicks on the plot into intents (spec 7.2):
-- touch: tap a card, tap a tile for the ghost, tap the same tile again to plant.
-- mouse: the ghost follows the mouse and one click plants.
-- With no card selected, tapping a plant opens the inspector; tapping ground closes it.

local UserInputService = game:GetService("UserInputService")

local PlacementController = {}

local store: any = nil
local busy = false

local function tileAt(screen: Vector2): (number?, number?, boolean)
	local camera = workspace.CurrentCamera
	local plot = store.plot()
	if not camera or not plot then
		return nil, nil, false
	end
	local tiles = plot:FindFirstChild("Tiles")
	if not tiles then
		return nil, nil, false
	end
	local ray = camera:ScreenPointToRay(screen.X, screen.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { tiles }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	if not hit then
		return nil, nil, false
	end
	local x, y = hit.Instance:GetAttribute("X"), hit.Instance:GetAttribute("Y")
	if type(x) ~= "number" or type(y) ~= "number" then
		return nil, nil, false
	end
	return x, y, hit.Instance:GetAttribute("IsPath") == true
end

local function plant(x: number, y: number)
	if busy then
		return
	end
	busy = true
	local seedId = store.selectedSeed
	local res = store.call("PlaceSeed", seedId, x, y)
	busy = false
	if res.ok then
		store.clearSelection()
	end
end

local function onTap(screen: Vector2)
	local view = store.view
	if not view or view.phase == "over" then
		return
	end
	local x, y, isPath = tileAt(screen)
	if store.selectedSeed then
		if x == nil or y == nil then
			return
		end
		if isPath or store.plantAt(x, y) then
			store.toast:fire(if isPath then store.message("on_path") else store.message("tile_taken"))
			return
		end
		local g = store.ghostTile
		if store.isMouse or (g and g[1] == x and g[2] == y) then
			plant(x, y)
		else
			store.ghostTile = { x, y }
			store.selection:fire()
		end
		return
	end
	local p = if x ~= nil and y ~= nil then store.plantAt(x, y) else nil
	if p then
		store.inspectId = p.id
	else
		store.inspectId = nil
	end
	store.selection:fire()
end

function PlacementController.init(stateStore: any)
	store = stateStore
	store.isMouse = UserInputService.MouseEnabled and not UserInputService.TouchEnabled
	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then
			return
		end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			onTap(Vector2.new(input.Position.X, input.Position.Y))
		elseif t == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape then
			store.clearSelection()
		end
	end)
	UserInputService.InputChanged:Connect(function(input: InputObject, processed: boolean)
		if processed or not store.isMouse or not store.selectedSeed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local x, y, isPath = tileAt(Vector2.new(input.Position.X, input.Position.Y))
			local g = store.ghostTile
			if x ~= nil and y ~= nil and not isPath and not store.plantAt(x, y) then
				if not g or g[1] ~= x or g[2] ~= y then
					store.ghostTile = { x, y }
					store.selection:fire()
				end
			elseif g then
				store.ghostTile = nil
				store.selection:fire()
			end
		end
	end)
end

return PlacementController
