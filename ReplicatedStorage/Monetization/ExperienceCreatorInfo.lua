local GroupService = game:GetService("GroupService")
local UserService = game:GetService("UserService")
local Players = game:GetService("Players")

local v = nil

local function getUserDisplayName(p)
	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({ p })
	end)

	if success and type(result) == "table" and type(result[1]) == "table" then
		local displayName = tostring(result[1].DisplayName or "")

		if displayName ~= "" then
			return displayName
		end

		local username = tostring(result[1].Username or "")

		if username ~= "" then
			return username
		end
	end

	local success2, result2 = pcall(function()
		return Players:GetNameFromUserIdAsync(p)
	end)

	if success2 and tostring(result2 or "") ~= "" then
		return (tostring(result2))
	end

	return "Creator"
end

local function getGroupName(p)
	local success, result = pcall(function()
		return GroupService:GetGroupInfoAsync(p)
	end)

	if success and type(result) == "table" and tostring(result.Name or "") ~= "" then
		return (tostring(result.Name))
	end

	return "Group"
end

return {
	Get = function()
		if v then
			return v
		end

		local creatorId = math.max(0, (math.floor(tonumber(game.CreatorId) or 0)))
		local creatorType = game.CreatorType
		local creatorName = "Piano Sim"

		if creatorType == Enum.CreatorType.Group and creatorId > 0 then
			creatorName = getGroupName(creatorId)
		elseif creatorType == Enum.CreatorType.User and creatorId > 0 then
			creatorName = getUserDisplayName(creatorId)
		else
			creatorType = Enum.CreatorType.User
		end

		v = { creatorName = creatorName, creatorType = creatorType, creatorId = creatorId }

		return v
	end
}