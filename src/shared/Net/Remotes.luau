--!strict
-- Remote names and setup (spec 6.5). The server creates them; clients wait for them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

-- Client to server calls. Each returns { ok, err, data }.
Remotes.FUNCTIONS = table.freeze({
	"RequestStart",
	"PlaceSeed",
	"UpgradePlant",
	"SellPlant",
	"SetTargetMode",
	"StartWave",
	"SetSpeed",
	"LeaveRun",
})

-- Server to client messages.
Remotes.EVENTS = table.freeze({
	"RunUpdated",
	"PestSnapshot",
	"RunEnded",
	"Toast",
})

local FOLDER = "Remotes"

-- Server only. Creates every remote once and returns the folder.
function Remotes.setup(): Folder
	local folder = ReplicatedStorage:FindFirstChild(FOLDER) :: Folder?
	if not folder then
		local f = Instance.new("Folder")
		f.Name = FOLDER
		f.Parent = ReplicatedStorage
		folder = f
	end
	assert(folder)
	for _, name in Remotes.FUNCTIONS do
		if not folder:FindFirstChild(name) then
			local rf = Instance.new("RemoteFunction")
			rf.Name = name
			rf.Parent = folder
		end
	end
	for _, name in Remotes.EVENTS do
		if not folder:FindFirstChild(name) then
			local re = Instance.new("RemoteEvent")
			re.Name = name
			re.Parent = folder
		end
	end
	return folder
end

function Remotes.fn(name: string): RemoteFunction
	local folder = ReplicatedStorage:WaitForChild(FOLDER)
	return folder:WaitForChild(name) :: RemoteFunction
end

function Remotes.event(name: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(FOLDER)
	return folder:WaitForChild(name) :: RemoteEvent
end

return Remotes
