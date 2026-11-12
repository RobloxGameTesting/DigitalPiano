local Zone = require(script.Parent:WaitForChild("Zone"))

local PianoGroupService = {}
local object = setmetatable({}, { __mode = "k" })

local function getGroupId(instance) -- 2 equivalent calls inferred from this helper
	if not instance then
		return nil
	end

	local pianoGroupId = instance:GetAttribute("PianoGroupId") or instance:GetAttribute("PianoGroup")

	if typeof(pianoGroupId) == "string" and pianoGroupId ~= "" then
		return pianoGroupId
	end

	return nil
end

local function findGroupZonePart(groupId)
	local pianoGroupZones = workspace:FindFirstChild("PianoGroupZones")

	if not pianoGroupZones then
		return nil
	end

	local part = pianoGroupZones:FindFirstChild(groupId)

	if not part then
		return nil
	end

	if part:IsA("BasePart") then
		return part
	end

	local zone = part:FindFirstChild("Zone")
	return if zone and zone:IsA("BasePart") then zone else nil
end

function PianoGroupService.GetGroupId(instance)
	return getGroupId(instance) -- inferred equivalent call
end

function PianoGroupService.GetZonePart(instance)
	local groupId = getGroupId(instance) -- inferred equivalent call
	local v = groupId and findGroupZonePart(groupId)

	if v then
		return v
	end

	return instance:WaitForChild("Zone")
end

function PianoGroupService.GetZone(p)
	local zonePart = PianoGroupService.GetZonePart(p)
	local zone = object[zonePart]

	if not zone then
		zone = Zone.new(zonePart)
		object[zonePart] = zone
	end

	return zone
end

function PianoGroupService.GetAudiencePlayers(p)
	return PianoGroupService.GetZone(p):getPlayers()
end

function PianoGroupService.IsPlayerInAudience(p, p2): boolean
	if not p2 then
		return false
	end

	for _, v in ipairs(PianoGroupService.GetAudiencePlayers(p)) do
		if v == p2 then
			return true
		end
	end

	return false
end

return PianoGroupService